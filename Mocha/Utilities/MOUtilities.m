//
//  MOUtilities.m
//  Mocha
//
//  Created by Logan Collins on 5/11/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import "MOUtilities.h"

#import "MochaRuntime_Private.h"

#import "MOFunctionArgument.h"
#import "MOMethod.h"
#import "MOFunctionArgument.h"
#import "MOBridgeSupportObject.h"
#import "MOBridgeSupportSymbol.h"

#import "MOBox.h"

#import <objc/runtime.h>
#import <objc/message.h>
#import <ffi/ffi.h>
#import <dlfcn.h>


#pragma mark -
#pragma mark Descriptions

NSString * MOJSValueToString(JSValueRef value, JSContextRef ctx) {
	if (value == NULL || JSValueIsNull(ctx, value)) {
        return nil;
    }
	JSStringRef resultStringJS = JSValueToStringCopy(ctx, value, NULL);
	NSString *resultString = [(NSString *)JSStringCopyCFString(kCFAllocatorDefault, resultStringJS) autorelease];
	JSStringRelease(resultStringJS);
	return resultString;
}


#pragma mark -
#pragma mark Invocation

JSValueRef MOSelectorInvoke(id target, SEL selector, JSContextRef ctx, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
    Mocha *runtime = [Mocha runtimeWithContext:ctx];
    
    NSMethodSignature *methodSignature = [target methodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    [invocation setTarget:target];
    [invocation setSelector:selector];
    
    NSUInteger methodArgumentCount = [methodSignature numberOfArguments] - 2;
    if (methodArgumentCount != argumentCount) {
        NSString *reason = [NSString stringWithFormat:@"ObjC method %@ requires %lu %@, but JavaScript passed %d arguments", NSStringFromSelector(selector), methodArgumentCount, (methodArgumentCount == 1 ? @"argument" : @"arguments"), argumentCount, (argumentCount == 1 ? @"argument" : @"arguments")];
        NSException *e = [NSException exceptionWithName:MORuntimeException reason:reason userInfo:nil];
        if (exception != NULL) {
            *exception = [runtime JSValueForObject:e];
        }
        return NULL;
    }
    
    // Build arguments
    for (size_t i=0; i<argumentCount; i++) {
        JSValueRef argument = arguments[i];
        id object = [runtime objectForJSValue:argument unboxObjects:NO];
        
        NSUInteger argIndex = i + 2;
        const char * argType = [methodSignature getArgumentTypeAtIndex:argIndex];
        
        // MOBox
        if ([object isKindOfClass:[MOBox class]]) {
            id value = [object representedObject];
            [invocation setArgument:&value atIndex:argIndex];
            //id representedObject = [object representedObject];
            //if ([representedObject isKindOfClass:[MOBox class]]) {
            //}
            //else if ([object isKindOfClass:[MOFunction class]]) {
            //    SEL selector = [(MOFunction *)object selector];
            //    [invocation setArgument:&selector atIndex:argIndex];
            //}
            //else if ([[(MOPrivateObject *)object type] isEqualToString:@"pointer"]) {
            //    void * pointer = [[(MOPrivateObject *)object object] pointerValue];
            //    [invocation setArgument:&pointer atIndex:argIndex];
            //}
        }
        
        // NSNumber
        else if ([object isKindOfClass:[NSNumber class]]) {
            // long
            if (strcmp(argType, @encode(long)) == 0
                || strcmp(argType, @encode(unsigned long)) == 0) {
                long val = [object longValue];
                [invocation setArgument:&val atIndex:argIndex];
            }
            // short
            else if (strcmp(argType, @encode(short)) == 0
                     || strcmp(argType, @encode(unsigned short)) == 0) {
                short val = [object shortValue];
                [invocation setArgument:&val atIndex:argIndex];
                
            }
            // char
            else if (strcmp(argType, @encode(char)) == 0
                     || strcmp(argType, @encode(unsigned char)) == 0) {
                char val = [object charValue];
                [invocation setArgument:&val atIndex:argIndex];
            }
            // long long
            else if (strcmp(argType, @encode(long long)) == 0
                     || strcmp(argType, @encode(unsigned long long)) == 0) {
                long long val = [object longLongValue];
                [invocation setArgument:&val atIndex:argIndex];
            }
            // float
            else if (strcmp(argType, @encode(float)) == 0) {
                float val = [object floatValue];
                [invocation setArgument:&val atIndex:argIndex];
            }
            // double
            else if (strcmp(argType, @encode(double)) == 0) {
                double val = [object doubleValue];
                [invocation setArgument:&val atIndex:argIndex];
            }
            // BOOL
            else if (strcmp(argType, @encode(bool)) == 0
                     || strcmp(argType, @encode(_Bool)) == 0) {
                BOOL val = [object boolValue];
                [invocation setArgument:&val atIndex:argIndex];
            }
            // int
            else {
                int val = [object intValue];
                [invocation setArgument:&val atIndex:argIndex];
            }
        }
        // id
        else {
            [invocation setArgument:&object atIndex:argIndex];
        }
    }
    
    
    // Invoke
    [invocation invoke];
    
    
    // Build return value
    const char * returnType = [methodSignature methodReturnType];
    JSValueRef returnValue = NULL;
    
    if (strcmp(returnType, @encode(void)) == 0) {
        returnValue = JSValueMakeUndefined(ctx);
    }
    // id
    else if (strcmp(returnType, @encode(id)) == 0
             || strcmp(returnType, @encode(Class)) == 0) {
        id object = nil;
        [invocation getReturnValue:&object];
        returnValue = [runtime JSValueForObject:object];
    }
    // SEL
    /*else if (strcmp(returnType, @encode(SEL)) == 0) {
        SEL selector = NULL;
        [invocation getReturnValue:&selector];
        
        JSObjectRef object = [mocha newPrivateObject];
        MOPrivateObject *private = JSObjectGetPrivate(object);
        private.type = @"selector";
        private.selector = selector;
        
        returnValue = object;
    }*/
    // void *
    /*else if (strcmp(returnType, @encode(void *)) == 0) {
        void *pointer = NULL;
        [invocation getReturnValue:&pointer];
        
        JSObjectRef object = [mocha newPrivateObject];
        MOPrivateObject *private = JSObjectGetPrivate(object);
        private.type = @"pointer";
        private.object = [NSValue valueWithPointer:pointer];
        
        returnValue = object;
    }*/
    // bool
    else if (strcmp(returnType, @encode(bool)) == 0
             || strcmp(returnType, @encode(_Bool)) == 0) {
        BOOL value;
        [invocation getReturnValue:&value];
        returnValue = [runtime JSValueForObject:[NSNumber numberWithBool:value]];
    }
    // int
    else if (strcmp(returnType, @encode(int)) == 0
             || strcmp(returnType, @encode(unsigned int)) == 0) {
        int value;
        [invocation getReturnValue:&value];
        returnValue = [runtime JSValueForObject:[NSNumber numberWithInt:value]];
    }
    // long
    else if (strcmp(returnType, @encode(long)) == 0
             || strcmp(returnType, @encode(unsigned long)) == 0) {
        long value;
        [invocation getReturnValue:&value];
        returnValue = [runtime JSValueForObject:[NSNumber numberWithLong:value]];
    }
    // long long
    else if (strcmp(returnType, @encode(long long)) == 0
             || strcmp(returnType, @encode(unsigned long long)) == 0) {
        long long value;
        [invocation getReturnValue:&value];
        returnValue = [runtime JSValueForObject:[NSNumber numberWithLongLong:value]];
    }
    // short
    else if (strcmp(returnType, @encode(short)) == 0
             || strcmp(returnType, @encode(unsigned short)) == 0) {
        short value;
        [invocation getReturnValue:&value];
        returnValue = [runtime JSValueForObject:[NSNumber numberWithShort:value]];
    }
    // char
    else if (strcmp(returnType, @encode(char)) == 0
             || strcmp(returnType, @encode(unsigned char)) == 0) {
        char value;
        [invocation getReturnValue:&value];
        returnValue = [runtime JSValueForObject:[NSNumber numberWithChar:value]];
    }
    // float
    else if (strcmp(returnType, @encode(float)) == 0) {
        float value;
        [invocation getReturnValue:&value];
        returnValue = [runtime JSValueForObject:[NSNumber numberWithFloat:value]];
    }
    // double
    else if (strcmp(returnType, @encode(double)) == 0) {
        double value;
        [invocation getReturnValue:&value];
        returnValue = [runtime JSValueForObject:[NSNumber numberWithDouble:value]];
    }
    
    return returnValue;
}


JSValueRef MOFunctionInvoke(id function, JSContextRef ctx, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
    Mocha *runtime = [Mocha runtimeWithContext:ctx];
    
    JSValueRef value = NULL;
    BOOL objCCall = NO;
    NSArray *argumentEncodings = nil;
    MOFunctionArgument *returnValue = nil;
    void *callAddress = NULL;
    NSUInteger callAddressArgumentCount = 0;
    BOOL variadic = NO;
    
    id target = nil;
    SEL selector = NULL;
    
    // Determine the metadata for the function call
    if ([function isKindOfClass:[MOMethod class]]) {
        // ObjC method
        
        objCCall = YES;
        target = [function target];
        selector = [function selector];
        
        Method method = NULL;
        BOOL classMethod = (target == [target class]);
        
        // Determine the method type
        if (classMethod) {
            method = class_getClassMethod([target class], selector);
        }
        else {
            method = class_getInstanceMethod([target class], selector);
        }
        
        if (method == NULL) {
            NSException *e = [NSException exceptionWithName:MORuntimeException reason:[NSString stringWithFormat:@"Unable to locate method %@ of class %@", NSStringFromSelector(selector), [target class]] userInfo:nil];
            if (exception != NULL) {
                *exception = [runtime JSValueForObject:e];
            }
            return NULL;
        }
        
        const char *encoding = method_getTypeEncoding(method);
        argumentEncodings = MOParseObjCMethodEncoding(encoding);
        
        if (argumentEncodings == nil) {
            NSException *e = [NSException exceptionWithName:MORuntimeException reason:[NSString stringWithFormat:@"Unable to parse method encoding for method %@ of class %@", NSStringFromSelector(selector), [target class]] userInfo:nil];
            if (exception != NULL) {
                *exception = [runtime JSValueForObject:e];
            }
            return NULL;
        }
        
		// Function arguments are all arguments minus return value and [instance, selector] params to objc_send
		callAddressArgumentCount = [argumentEncodings count] - 3;
        
		// Get call address
		callAddress = MOInvocationGetObjCCallAddressForArguments(argumentEncodings);
    }
    else if ([function isKindOfClass:[MOBridgeSupportFunction class]]) {
        // C function
        
        NSString *functionName = [function name];
        
        callAddress = dlsym(RTLD_DEFAULT, [functionName UTF8String]);
        
        // If the function cannot be found, raise an exception (instead of crashing)
        if (callAddress == NULL) {
            if (exception != NULL) {
                NSException *e = [NSException exceptionWithName:MORuntimeException reason:[NSString stringWithFormat:@"Unable to find function name: %@", functionName] userInfo:nil];
                *exception = [runtime JSValueForObject:e];
            }
            return NULL;
        }
        
        variadic = [function isVariadic];
        
        NSUInteger functionArgCount = [[function arguments] count];
        if ((variadic && (functionArgCount > argumentCount))
            || (!variadic && (functionArgCount != argumentCount)))
        {
            if (functionArgCount > argumentCount) {
                NSString *reason = [NSString stringWithFormat:@"C function %@ requires %lu %@, but JavaScript passed %d arguments", functionName, functionArgCount, (functionArgCount == 1 ? @"argument" : @"arguments"), argumentCount, (argumentCount == 1 ? @"argument" : @"arguments")];
                NSException *e = [NSException exceptionWithName:MORuntimeException reason:reason userInfo:nil];
                if (exception != NULL) {
                    *exception = [runtime JSValueForObject:e];
                }
                return NULL;
            }
        }
        
		// Function arguments are all arguments minus return value
		callAddressArgumentCount = [argumentEncodings count] - 1;
    }
    
    
    // Prepare ffi
	ffi_cif cif;
	ffi_type** args = NULL;
	void** values = NULL;
    
    // Build the arguments
	NSUInteger effectiveArgumentCount = argumentCount + (objCCall ? 2 : 0);
	if (effectiveArgumentCount > 0) {
		args = malloc(sizeof(ffi_type *) * effectiveArgumentCount);
		values = malloc(sizeof(void *) * effectiveArgumentCount);
        
        NSUInteger j = 0;
        
        // ObjC calls include the target and selector as the first two arguments
        if (objCCall) {
            args[0] = &ffi_type_pointer;
			args[1] = &ffi_type_pointer;
			values[0] = (void *)&target;
			values[1] = (void *)&selector;
            j = 2;
        }
        
        for (NSUInteger i=0; i<argumentCount; i++, j++) {
            JSValueRef jsValue = arguments[i];
            
            MOFunctionArgument *arg = [argumentEncodings objectAtIndex:i];
            [arg setValueAsJSValue:jsValue context:ctx];
            
            ffi_type *argType = [arg ffiType];
            void *storage = [arg storage];
            
            args[i] = argType;
            values[i] = storage;
        }
    }
	
	// Get return value holder
	returnValue = [argumentEncodings objectAtIndex:0];
    
    // Prep
    ffi_status prep_status = ffi_prep_cif(&cif, FFI_DEFAULT_ABI, (unsigned int)effectiveArgumentCount, [returnValue ffiType], args);
    
	// Allocate return value storage if it's a pointer
	if ([returnValue typeEncoding] == _C_PTR) {
		[returnValue allocateStorage];
    }
    
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
    
    // If the return type is void, the return value should be undefined
    if ([returnValue ffiType] == &ffi_type_void) {
        return JSValueMakeUndefined(ctx);
    }
    
    @try {
        value = [returnValue getValueAsJSValueInContext:ctx];
    }
    @catch (NSException *e) {
        if (exception != NULL) {
            *exception = [runtime JSValueForObject:e];
        }
        return NULL;
    }
    
    return value;
}

NSArray * MOParseObjCMethodEncoding(const char *typeEncoding) {
	NSMutableArray *argumentEncodings = [NSMutableArray array];
	char *argsParser = (char *)typeEncoding;
    
	for(; *argsParser; argsParser++) {
		// Skip ObjC argument order
		if (*argsParser >= '0' && *argsParser <= '9') {
            continue;
        }
		else {
            // Skip ObjC type qualifiers - except for _C_CONST these are not defined in runtime.h
            if (*argsParser == _C_CONST ||
                *argsParser == 'n' ||
                *argsParser == 'N' || 
                *argsParser == 'o' ||
                *argsParser == 'O' ||
                *argsParser == 'R' ||
                *argsParser == 'V') {
                continue;
            }
            else {
                if (*argsParser == _C_STRUCT_B) {
                    // Parse structure encoding
                    NSInteger count = 0;
                    [MOFunctionArgument typeEncodingsFromStructureTypeEncoding:[NSString stringWithUTF8String:argsParser] parsedCount:&count];
                    
                    NSString *encoding = [[NSString alloc] initWithBytes:argsParser length:count encoding:NSUTF8StringEncoding];
                    MOFunctionArgument *argumentEncoding = [[MOFunctionArgument alloc] init];
                    
                    // Set return value
                    if ([argumentEncodings count] == 0) {
                        [argumentEncoding setReturnValue:YES];
                    }
                    
                    [argumentEncoding setStructureTypeEncoding:encoding];
                    [argumentEncodings addObject:argumentEncoding];
                    [argumentEncoding release];
                    
                    [encoding release];
                    argsParser += count - 1;
                }
                else {
                    // Custom handling for pointers as they're not one char long.
                    char* typeStart = argsParser;
                    if (*argsParser == '^') {
                        while (*argsParser && !(*argsParser >= '0' && *argsParser <= '9')) {
                            argsParser++;
                        }
                    }
                    
                    MOFunctionArgument *argumentEncoding = [[MOFunctionArgument alloc] init];
                    // Set return value
                    if ([argumentEncodings count] == 0) {
                        [argumentEncoding setReturnValue:YES];
                    }
                    
                    // If pointer, copy pointer type (^i, ^{NSRect}) to the argumentEncoding
                    if (*typeStart == _C_PTR) {
                        NSString *encoding = [[NSString alloc] initWithBytes:typeStart length:argsParser-typeStart encoding:NSUTF8StringEncoding];
                        [argumentEncoding setPointerTypeEncoding:encoding];
                        [encoding release];
                    }
                    else {
                        @try {
                            [argumentEncoding setTypeEncoding:*typeStart];
                        }
                        @catch (NSException *e) {
                            [argumentEncoding release];
                            return nil;
                        }
                        
                        // Blocks are '@?', skip '?'
                        if (typeStart[0] == _C_ID && typeStart[1] == _C_UNDEF) {
                            argsParser++;
                        }
                    }
                    
                    [argumentEncodings addObject:argumentEncoding];
                    [argumentEncoding release];
                }
            }
        }
        
		if (!*argsParser) {
            break;
        }
	}
	return argumentEncodings;
}


//
// From PyObjC : when to call objc_msgSend_stret, for structure return
// Depending on structure size & architecture, structures are returned as function first argument (done transparently by ffi) or via registers
//

#if defined(__ppc__)
#   define SMALL_STRUCT_LIMIT	4
#elif defined(__ppc64__)
#   define SMALL_STRUCT_LIMIT	8
#elif defined(__i386__) 
#   define SMALL_STRUCT_LIMIT 	8
#elif defined(__x86_64__) 
#   define SMALL_STRUCT_LIMIT	16
#elif TARGET_OS_IPHONE
// TOCHECK
#   define SMALL_STRUCT_LIMIT	4
#else
#   error "Unsupported MACOSX platform"
#endif

BOOL MOInvocationShouldUseStret(NSArray *arguments) {
	int resultSize = 0;
	char returnEncoding = [[arguments objectAtIndex:0] typeEncoding];
	if (returnEncoding == _C_STRUCT_B) {
        resultSize = [MOFunctionArgument sizeOfStructureTypeEncoding:[[arguments objectAtIndex:0] structureTypeEncoding]];
    }
    
	if (returnEncoding == _C_STRUCT_B && 
        //#ifdef  __ppc64__
        //			ffi64_stret_needs_ptr(signature_to_ffi_return_type(rettype), NULL, NULL)
        //
        //#else /* !__ppc64__ */
        (resultSize > SMALL_STRUCT_LIMIT
#ifdef __i386__
         /* darwin/x86 ABI is slightly odd ;-) */
         || (resultSize != 1 
             && resultSize != 2 
             && resultSize != 4 
             && resultSize != 8)
#endif
#ifdef __x86_64__
         /* darwin/x86-64 ABI is slightly odd ;-) */
         || (resultSize != 1 
             && resultSize != 2 
             && resultSize != 4 
             && resultSize != 8
             && resultSize != 16
             )
#endif
         )
        //#endif /* !__ppc64__ */
        ) {
        //					callAddress = objc_msgSend_stret;
        //					usingStret = YES;
        return YES;
    }
    return NO;
}

void * MOInvocationGetObjCCallAddressForArguments(NSArray *arguments) {
	BOOL usingStret	= MOInvocationShouldUseStret(arguments);
	void *callAddress = NULL;
	if (usingStret)	{
        callAddress = objc_msgSend_stret;
    }
    else {
        callAddress = objc_msgSend;
    }
    
#if __i386__
    // If i386 and the return type is float/double, use objc_msgSend_fpret
    // ARM and x86_64 use the standard objc_msgSend
	char returnEncoding = [[arguments objectAtIndex:0] typeEncoding];
	if (returnEncoding == 'f' || returnEncoding == 'd') {
		callAddress = objc_msgSend_fpret;
	}
#endif
    
	return callAddress;
}


#pragma mark -
#pragma mark Selectors

SEL MOSelectorFromPropertyName(NSString *propertyName) {
    NSString *selectorString = [propertyName stringByReplacingOccurrencesOfString:@"_" withString:@":"];
    SEL selector = NSSelectorFromString(selectorString);
    return selector;
}

NSString * MOSelectorToPropertyName(SEL selector) {
    NSString *selectorString = NSStringFromSelector(selector);
    NSString *propertyString = [selectorString stringByReplacingOccurrencesOfString:@":" withString:@"_"];
    return propertyString;
}


