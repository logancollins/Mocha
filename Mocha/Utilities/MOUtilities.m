//
//  MOUtilities.m
//  Mocha
//
//  Created by Logan Collins on 5/11/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import "MOUtilities.h"

#import "MochaRuntime_Private.h"

#import "MOBridgeSupportObject.h"

#import "MOBox.h"

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
    Mocha *mocha = [Mocha runtimeWithContext:ctx];
    
    NSMethodSignature *methodSignature = [target methodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    [invocation setTarget:target];
    [invocation setSelector:selector];
    
    NSUInteger methodArgumentCount = [methodSignature numberOfArguments] - 2;
    if (methodArgumentCount != argumentCount) {
        JSStringRef string = JSStringCreateWithCFString((CFStringRef)[NSString stringWithFormat:@"InvocationError: ObjC method signature takes %lu %@, but JavaScript passed %d arguments", methodArgumentCount, (methodArgumentCount == 1 ? @"argument" : @"arguments"), argumentCount, (argumentCount == 1 ? @"argument" : @"arguments")]);
        JSValueRef exceptionValue = JSValueMakeString(ctx, string);
        JSStringRelease(string);
        if (exception != NULL) {
            *exception = exceptionValue;
        }
        return NULL;
    }
    
    // Build arguments
    for (size_t i=0; i<argumentCount; i++) {
        JSValueRef argument = arguments[i];
        id object = [mocha objectForJSValue:argument unboxObjects:NO];
        
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
            else if (strcmp(argType, @encode(BOOL)) == 0
                     || strcmp(argType, @encode(bool)) == 0
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
        returnValue = [mocha JSValueForObject:object];
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
    // BOOL
    else if (strcmp(returnType, @encode(BOOL)) == 0
             || strcmp(returnType, @encode(bool)) == 0
             || strcmp(returnType, @encode(_Bool)) == 0) {
        BOOL value;
        [invocation getReturnValue:&value];
        returnValue = [mocha JSValueForObject:[NSNumber numberWithBool:value]];
    }
    // int
    else if (strcmp(returnType, @encode(int)) == 0
             || strcmp(returnType, @encode(unsigned int)) == 0) {
        int value;
        [invocation getReturnValue:&value];
        returnValue = [mocha JSValueForObject:[NSNumber numberWithInt:value]];
    }
    // long
    else if (strcmp(returnType, @encode(long)) == 0
             || strcmp(returnType, @encode(unsigned long)) == 0) {
        long value;
        [invocation getReturnValue:&value];
        returnValue = [mocha JSValueForObject:[NSNumber numberWithLong:value]];
    }
    // long long
    else if (strcmp(returnType, @encode(long long)) == 0
             || strcmp(returnType, @encode(unsigned long long)) == 0) {
        long long value;
        [invocation getReturnValue:&value];
        returnValue = [mocha JSValueForObject:[NSNumber numberWithLongLong:value]];
    }
    // short
    else if (strcmp(returnType, @encode(short)) == 0
             || strcmp(returnType, @encode(unsigned short)) == 0) {
        short value;
        [invocation getReturnValue:&value];
        returnValue = [mocha JSValueForObject:[NSNumber numberWithShort:value]];
    }
    // char
    else if (strcmp(returnType, @encode(char)) == 0
             || strcmp(returnType, @encode(unsigned char)) == 0) {
        char value;
        [invocation getReturnValue:&value];
        returnValue = [mocha JSValueForObject:[NSNumber numberWithChar:value]];
    }
    // float
    else if (strcmp(returnType, @encode(float)) == 0) {
        float value;
        [invocation getReturnValue:&value];
        returnValue = [mocha JSValueForObject:[NSNumber numberWithFloat:value]];
    }
    // double
    else if (strcmp(returnType, @encode(double)) == 0) {
        double value;
        [invocation getReturnValue:&value];
        returnValue = [mocha JSValueForObject:[NSNumber numberWithDouble:value]];
    }
    
    return returnValue;
}


JSValueRef MOFunctionInvoke(MOBridgeSupportFunction *function, JSContextRef ctx, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exceptionJS) {
    Mocha *runtime = [Mocha runtimeWithContext:ctx];
    NSString *name = [function name];
    void *callAddress = dlsym(RTLD_DEFAULT, [name UTF8String]);
    
    JSValueRef value = NULL;
    
    // If the function cannot be found, raise an exception (instead of crashing)
    if (callAddress == NULL) {
        if (exceptionJS != NULL) {
            NSException *exception = [NSException exceptionWithName:MORuntimeException reason:[NSString stringWithFormat:@"Unable to find function name: %@", name] userInfo:nil];
            *exceptionJS = [runtime JSValueForObject:exception];
        }
        return NULL;
    }
    
    
    
    
    return value;
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

