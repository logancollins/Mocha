//
//  MOFunctionInvocation.m
//  Mocha
//
//  Created by Logan Collins on 12/9/13.
//  Copyright (c) 2013 Sunflower Softworks. All rights reserved.
//

#import "MOFunctionInvocation.h"

#import "MORuntime_Private.h"

#import "MOMethod.h"
#import "MOAllocator.h"
#import "MOPointer.h"

#import "MOBridgeSupportController.h"
#import "MOBridgeSupportSymbol.h"

#import "MOFunctionArgument.h"
#import "MOUtilities.h"

#import <objc/runtime.h>
#import <dlfcn.h>

#if TARGET_OS_IPHONE
#import "ffi.h"
#else
#import <ffi/ffi.h>
#endif


JSValueRef MOFunctionInvoke(id function, JSContextRef ctx, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
    MORuntime *runtime = [MORuntime runtimeWithContext:ctx];
    
    // Determine the metadata for the function call
    JSValueRef value = NULL;
    BOOL objCCall = NO;
    BOOL blockCall = NO;
    NSMutableArray *argumentEncodings = nil;
    MOFunctionArgument *returnValue = nil;
    void * callAddress = NULL;
    NSUInteger callAddressArgumentCount = 0;
    BOOL variadic = NO;
    
    id target = nil;
    SEL selector = NULL;
    
    id block = nil;
    
    if ([function isKindOfClass:[MOMethod class]]) {
        // Objective-C method
        objCCall = YES;
        
        target = [function target];
        selector = [function selector];
        Class klass = [target class];
        
#if !TARGET_OS_IPHONE
        // Override for Distributed Objects
        if ([klass isSubclassOfClass:[NSDistantObject class]]
            || [klass isSubclassOfClass:[NSProtocolChecker class]]) {
            return MOSelectorInvoke(target, selector, ctx, argumentCount, arguments, exception);
        }
#endif
        
        // Override for -alloc...
        if (selector == @selector(alloc)
            || selector == @selector(allocWithZone:)) {
            // Override for -alloc
            MOAllocator *allocator = [[MOAllocator alloc] init];
            allocator.objectClass = klass;
            return [runtime JSValueForObject:allocator];
        }
        
        // Override for -release and -autorelease
        if ((selector == @selector(release) || selector == @selector(autorelease))
                 && runtime.options & MORuntimeOptionAutomaticReferenceCounting) {
            // ARC-mode disallows explicit release of objects
            NSException *e = [NSException exceptionWithName:MORuntimeException reason:[NSString stringWithFormat:@"Automatic reference counting disallows explicit calls to -%@.", NSStringFromSelector(selector)] userInfo:nil];
            *exception = [runtime JSValueForObject:e];
            return NULL;
        }
        
        if ([target isKindOfClass:[MOAllocator class]]) {
            klass = [target objectClass];
            target = [[target objectClass] alloc];
        }
        
        Method method = NULL;
        BOOL classMethod = (target == klass);
        
        // Determine the method type
        if (classMethod) {
            method = class_getClassMethod(klass, selector);
        }
        else {
            method = class_getInstanceMethod(klass, selector);
        }
        
        variadic = MOSelectorIsVariadic(klass, selector);
        
        if (method == NULL) {
            NSException *e = [NSException exceptionWithName:MORuntimeException reason:[NSString stringWithFormat:@"Unable to locate method %@ of class %@", NSStringFromSelector(selector), klass] userInfo:nil];
            if (exception != NULL) {
                *exception = [runtime JSValueForObject:e];
            }
            return NULL;
        }
        
        const char *encoding = method_getTypeEncoding(method);
        argumentEncodings = [MOParseObjCMethodEncoding(encoding) mutableCopy];
        
        if (argumentEncodings == nil) {
            NSException *e = [NSException exceptionWithName:MORuntimeException reason:[NSString stringWithFormat:@"Unable to parse method encoding for method %@ of class %@", NSStringFromSelector(selector), klass] userInfo:nil];
            if (exception != NULL) {
                *exception = [runtime JSValueForObject:e];
            }
            return NULL;
        }
        
        // Function arguments are all arguments minus return value and [instance, selector] params to objc_send
        callAddressArgumentCount = [argumentEncodings count] - 3;
        
        // Get call address
        callAddress = MOInvocationGetObjCCallAddressForArguments(argumentEncodings);
        
        if (variadic) {
            if (argumentCount > 0) {
                // Add an argument for NULL
                argumentCount++;
            }
        }
        
        if ((variadic && (callAddressArgumentCount > argumentCount))
            || (!variadic && (callAddressArgumentCount != argumentCount)))
        {
            NSString *reason = [NSString stringWithFormat:@"Objective-C method %@ requires %lu %@, but JavaScript passed %zd %@", NSStringFromSelector(selector), (unsigned long)callAddressArgumentCount, (callAddressArgumentCount == 1 ? @"argument" : @"arguments"), argumentCount, (argumentCount == 1 ? @"argument" : @"arguments")];
            NSException *e = [NSException exceptionWithName:MORuntimeException reason:reason userInfo:nil];
            if (exception != NULL) {
                *exception = [runtime JSValueForObject:e];
            }
            return NULL;
        }
    }
    else if ([function isKindOfClass:NSClassFromString(@"NSBlock")]) {
        // Block object
        blockCall = YES;
        
        block = function;
        
        const char * typeEncoding = NULL;
        callAddress = MOBlockGetCallAddress(block, &typeEncoding);
        
        argumentEncodings = [MOParseObjCMethodEncoding(typeEncoding) mutableCopy];
        
        if (argumentEncodings == nil) {
            NSException *e = [NSException exceptionWithName:MORuntimeException reason:[NSString stringWithFormat:@"Unable to parse method encoding for method %@ of class %@", NSStringFromSelector(selector), [target class]] userInfo:nil];
            if (exception != NULL) {
                *exception = [runtime JSValueForObject:e];
            }
            return NULL;
        }
        
        callAddressArgumentCount = [argumentEncodings count] - 2;
        
        if (callAddressArgumentCount != argumentCount) {
            NSString *reason = [NSString stringWithFormat:@"Block requires %lu %@, but JavaScript passed %zd %@", (unsigned long)callAddressArgumentCount, (callAddressArgumentCount == 1 ? @"argument" : @"arguments"), argumentCount, (argumentCount == 1 ? @"argument" : @"arguments")];
            NSException *e = [NSException exceptionWithName:MORuntimeException reason:reason userInfo:nil];
            if (exception != NULL) {
                *exception = [runtime JSValueForObject:e];
            }
            return NULL;
        }
    }
    else if ([function isKindOfClass:[MOBridgeSupportFunction class]]) {
        // BridgeSupport function
        
        NSString *functionName = [function name];
        
        callAddress = dlsym(RTLD_DEFAULT, [functionName UTF8String]);
        
        // If the function cannot be found, raise an exception (instead of crashing)
        if (callAddress == NULL) {
            if (exception != NULL) {
                NSException *e = [NSException exceptionWithName:MORuntimeException reason:[NSString stringWithFormat:@"Unable to find function with name: %@", functionName] userInfo:nil];
                *exception = [runtime JSValueForObject:e];
            }
            return NULL;
        }
        
        variadic = [function isVariadic];
        
        NSMutableArray *args = [NSMutableArray array];
        
        // Build return type
        MOBridgeSupportArgument *bridgeSupportReturnValue = [function returnValue];
        MOFunctionArgument *returnArg = nil;
        if (returnValue != nil) {
            NSString *returnTypeEncoding = nil;
#if __LP64__
            returnTypeEncoding = [bridgeSupportReturnValue type64];
            if (returnTypeEncoding == nil) {
                returnTypeEncoding = [bridgeSupportReturnValue type];
            }
#else
            returnTypeEncoding = [bridgeSupportReturnValue type];
#endif
            returnArg = MOFunctionArgumentForTypeEncoding(returnTypeEncoding);
        }
        else {
            // void return
            returnArg = [[MOFunctionArgument alloc] init];
            [returnArg setTypeEncoding:_C_VOID];
        }
        [returnArg setReturnValue:YES];
        [args addObject:returnArg];
        
        // Build arguments
        for (MOBridgeSupportArgument *argument in [function arguments]) {
            NSString *typeEncoding = nil;
#if __LP64__
            typeEncoding = [argument type64];
            if (typeEncoding == nil) {
                typeEncoding = [argument type];
            }
#else
            typeEncoding = [argument type];
#endif
            
            MOFunctionArgument *arg = MOFunctionArgumentForTypeEncoding(typeEncoding);
            [args addObject:arg];
        }
        
        argumentEncodings = [args mutableCopy];
        
        // Function arguments are all arguments minus return value
        callAddressArgumentCount = [args count] - 1;
        
        // Raise if the argument counts don't match
        if ((variadic && (callAddressArgumentCount > argumentCount))
            || (!variadic && (callAddressArgumentCount != argumentCount)))
        {
            NSString *reason = [NSString stringWithFormat:@"C function %@ requires %lu %@, but JavaScript passed %zd %@", functionName, (unsigned long)callAddressArgumentCount, (callAddressArgumentCount == 1 ? @"argument" : @"arguments"), argumentCount, (argumentCount == 1 ? @"argument" : @"arguments")];
            NSException *e = [NSException exceptionWithName:MORuntimeException reason:reason userInfo:nil];
            if (exception != NULL) {
                *exception = [runtime JSValueForObject:e];
            }
            return NULL;
        }
    }
    else {
        @throw [NSException exceptionWithName:MORuntimeException reason:[NSString stringWithFormat:@"Invalid object for function invocation: %@", function] userInfo:nil];
    }
    
    
    // Prepare ffi
    ffi_cif cif;
    ffi_type ** args = NULL;
    void ** values = NULL;
    
    // Build the arguments
    NSUInteger effectiveArgumentCount = argumentCount;
    if (objCCall) {
        effectiveArgumentCount += 2;
    }
    if (blockCall) {
        effectiveArgumentCount += 1;
    }
    
    if (effectiveArgumentCount > 0) {
        args = malloc(sizeof(ffi_type *) * effectiveArgumentCount);
        values = malloc(sizeof(void *) * effectiveArgumentCount);
        
        NSUInteger j = 0;
        
        if (objCCall) {
            // ObjC calls include the target and selector as the first two arguments
            args[0] = &ffi_type_pointer;
            args[1] = &ffi_type_pointer;
            values[0] = (void *)&target;
            values[1] = (void *)&selector;
            j = 2;
        }
        else if (blockCall) {
            // Block calls include the block as the first argument
            args[0] = &ffi_type_pointer;
            values[0] = (void *)&block;
            j = 1;
        }
        
        for (NSUInteger i=0; i<argumentCount; i++, j++) {
            JSValueRef jsValue = NULL;
            
            MOFunctionArgument *arg = nil;
            if (variadic && i >= callAddressArgumentCount) {
                arg = [[MOFunctionArgument alloc] init];
                [arg setTypeEncoding:_C_ID];
                [argumentEncodings addObject:arg];
            }
            else {
                arg = [argumentEncodings objectAtIndex:(j + 1)];
            }
            
            if (objCCall && variadic && i == argumentCount - 1) {
                // The last variadic argument in ObjC calls is nil (the sentinel value)
                jsValue = NULL;
            }
            else {
                jsValue = arguments[i];
            }
            
            if (jsValue != NULL) {
                id object = [runtime objectForJSValue:jsValue];
                
                // Handle pointers
                if ([object isKindOfClass:[MOPointer class]]) {
                    [arg setPointer:object];
                    
                    id objValue = [(MOPointer *)object value];
                    JSValueRef pointerJSValue = [runtime JSValueForObject:objValue];
                    [arg setValueAsJSValue:pointerJSValue context:ctx dereference:YES];
                }
                else {
                    [arg setValueAsJSValue:jsValue context:ctx];
                }
            }
            else {
                [arg setValueAsJSValue:NULL context:ctx];
            }
            
            args[j] = [arg ffiType];
            values[j] = [arg storage];
        }
    }
    
    // Get return value holder
    returnValue = [argumentEncodings objectAtIndex:0];
    
    // Prep
    ffi_status prep_status = ffi_prep_cif(&cif, FFI_DEFAULT_ABI, (unsigned int)effectiveArgumentCount, [returnValue ffiType], args);
    
    // Call
    if (prep_status == FFI_OK) {
        void *storage = [returnValue storage];
        
        @try {
            ffi_call(&cif, callAddress, storage, values);
        }
        @catch (NSException *e) {
            if (effectiveArgumentCount > 0) {
                free(args);
                free(values);
            }
            if (exception != NULL) {
                *exception = [runtime JSValueForObject:e];
            }
            return NULL;
        }
    }
    
    // Free the arguments
    if (effectiveArgumentCount > 0) {
        free(args);
        free(values);
    }
    
    // Throw an exception if the prep call failed
    if (prep_status != FFI_OK) {
        NSException *e = [NSException exceptionWithName:MORuntimeException reason:@"ffi_prep_cif failed" userInfo:nil];
        if (exception != NULL) {
            *exception = [runtime JSValueForObject:e];
        }
        return NULL;
    }
    
    // Populate the value of pointers
    for (MOFunctionArgument *arg in argumentEncodings) {
        if ([arg pointer] != nil) {
            MOPointer *pointer = [arg pointer];
            JSValueRef pointerJSValue = [arg getValueAsJSValueInContext:ctx dereference:YES];
            id pointerValue = [runtime objectForJSValue:pointerJSValue];
            pointer.value = pointerValue;
        }
    }
    
    // If the return type is void, the return value should be undefined
    if ([returnValue ffiType] == &ffi_type_void) {
        return JSValueMakeUndefined(ctx);
    }
    
    @try {
        value = [returnValue getValueAsJSValueInContext:ctx];
        
        if ([returnValue typeEncoding] == _C_CLASS
            || [returnValue typeEncoding] == _C_ID) {
            
            if (runtime.options & MORuntimeOptionAutomaticReferenceCounting) {
                // If the return value is an object, apply ARC-style retain semantics
                id object = [runtime objectForJSValue:value];
                
                BOOL shouldRelease = NO;
                if ([function isKindOfClass:[MOMethod class]]) {
                    shouldRelease = [(MOMethod *)function returnsRetained];
                }
                else if ([function isKindOfClass:[MOBridgeSupportFunction class]]) {
                    shouldRelease = [[(MOBridgeSupportFunction *)function returnValue] isAlreadyRetained];
                }
                
                if (shouldRelease) {
                    [object release];
                }
            }
        }
    }
    @catch (NSException *e) {
        if (exception != NULL) {
            *exception = [runtime JSValueForObject:e];
        }
        return NULL;
    }
    
    return value;
}
