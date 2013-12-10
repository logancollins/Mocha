//
//  MOJavaScriptFunction.m
//  Mocha
//
//  Created by Logan Collins on 11/27/13.
//  Copyright (c) 2013 Sunflower Softworks. All rights reserved.
//

#import "MOJavaScriptFunction.h"
#import "MOJavaScriptFunction_Private.h"
#import "MOJavaScriptObject_Private.h"

#import "MORuntime_Private.h"


@implementation MOJavaScriptFunction

- (id)callWithArguments:(NSArray *)arguments {
    MORuntime *runtime = [MORuntime runtimeWithContext:[self JSContext]];
    size_t argumentCount = (size_t)[arguments count];
    
    JSValueRef * argumentRefs = NULL;
    if (argumentCount > 0) {
        argumentRefs = malloc(sizeof(JSValueRef));
    }
    
    for (size_t i=0; i<argumentCount; i++) {
        id object = arguments[i];
        JSValueRef value = [runtime JSValueForObject:object];
        argumentRefs[i] = value;
    }
    
    JSValueRef exceptionRef = NULL;
    JSValueRef returnValue = JSObjectCallAsFunction([self JSContext], [self JSObject], NULL, argumentCount, (const JSValueRef *)argumentRefs, &exceptionRef);
    
    if (argumentRefs != NULL) {
        free(argumentRefs);
    }
    
    if (exceptionRef != NULL) {
        [runtime throwJSException:exceptionRef];
    }
    
    return [runtime objectForJSValue:returnValue];
}

- (MOJavaScriptClosureBlock)blockWithArgumentCount:(NSUInteger *)argCount {
    if (argCount != NULL) {
        JSObjectRef jsFunction = [self JSObject];
        JSContextRef ctx = [self JSContext];
        
        JSStringRef lengthString = JSStringCreateWithCFString(CFSTR("length"));
        JSValueRef value = JSObjectGetProperty(ctx, jsFunction, lengthString, NULL);
        JSStringRelease(lengthString);
        
        *argCount = (NSUInteger)JSValueToNumber(ctx, value, NULL);
    }
    
    MOJavaScriptClosureBlock newBlock = (id)^(id obj, ...) {
        // JavaScript functions
        JSObjectRef jsFunction = [self JSObject];
        JSContextRef ctx = [self JSContext];
        MORuntime *runtime = [MORuntime runtimeWithContext:ctx];
        
        JSStringRef lengthString = JSStringCreateWithCFString(CFSTR("length"));
        JSValueRef value = JSObjectGetProperty(ctx, jsFunction, lengthString, NULL);
        JSStringRelease(lengthString);
        
        NSUInteger argumentCount = (NSUInteger)JSValueToNumber(ctx, value, NULL);
        
        JSValueRef exception = NULL;
        
        va_list args;
        va_start(args, obj);
        
        id arg = obj;
        JSValueRef jsValue = [runtime JSValueForObject:obj];
        JSObjectRef jsObject = JSValueToObject(ctx, jsValue, &exception);
        if (jsObject == NULL) {
            [runtime throwJSException:exception];
            return nil;
        }
        
        JSValueRef *jsArguments = (JSValueRef *)malloc(sizeof(JSValueRef) * (argumentCount - 1));
        
        // Handle passed arguments
        for (NSUInteger i=0; i<argumentCount; i++) {
            arg = va_arg(args, id);
            jsArguments[i] = [runtime JSValueForObject:arg];
        }
        
        va_end(args);
        
        JSValueRef jsReturnValue = JSObjectCallAsFunction(ctx, jsFunction, jsObject, argumentCount, jsArguments, &exception);
        id returnValue = [runtime objectForJSValue:jsReturnValue];
        
        if (jsArguments != NULL) {
            free(jsArguments);
        }
        
        if (exception != NULL) {
            [runtime throwJSException:exception];
            return nil;
        }
        
        return (__bridge void *)returnValue;
    };
    return [newBlock copy];
}

@end
