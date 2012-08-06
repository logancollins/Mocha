//
//  MOPointer.m
//  Mocha
//
//  Created by Logan Collins on 7/31/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import "MOPointer.h"
#import "MochaRuntime_Private.h"


@implementation MOPointer {
    JSValueRef _JSValue;
    JSContextRef _JSContext;
}

@synthesize JSContext=_JSContext;

- (id)initWithJSValue:(JSValueRef)JSValue context:(JSContextRef)JSContext {
    self = [super init];
    if (self) {
        [self setJSValue:JSValue JSContext:JSContext];
    }
    return self;
}

- (void)dealloc {
    if (_JSValue != NULL) {
        JSValueUnprotect(_JSContext, _JSValue);
    }
}

- (JSValueRef)JSValue {
    return _JSValue;
}

- (JSContextRef)JSContext {
    return _JSContext;
}

- (void)setJSValue:(JSValueRef)JSValue JSContext:(JSContextRef)JSContext {
    if (_JSValue != NULL) {
        JSValueUnprotect(_JSContext, _JSValue);
    }
    _JSValue = JSValue;
    _JSContext = JSContext;
    if (_JSValue != NULL) {
        JSValueProtect(_JSContext, _JSValue);
    }
}

- (id)value {
    return [[Mocha runtimeWithContext:self.JSContext] objectForJSValue:self.JSValue];
}

@end
