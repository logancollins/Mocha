//
//  MOJavaScriptFunction.m
//  Mocha
//
//  Created by Logan Collins on 11/27/13.
//  Copyright (c) 2013 Sunflower Softworks. All rights reserved.
//

#import "MOJavaScriptFunction.h"
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

@end
