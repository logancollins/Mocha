//
//  MORuntime_Private.h
//  Mocha
//
//  Created by Logan Collins on 5/10/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import <Mocha/MORuntime.h>
#import <JavaScriptCore/JavaScriptCore.h>


@interface MORuntime ()

+ (MORuntime *)runtimeWithContext:(JSContextRef)ctx;

@property (readonly) JSGlobalContextRef context;
@property (readwrite) MORuntimeOptions options;

// JSValue <-> id
+ (id)objectForJSValue:(JSValueRef)value inContext:(JSContextRef)ctx;
+ (NSArray *)arrayForJSArray:(JSObjectRef)arrayValue inContext:(JSContextRef)ctx;

- (id)objectForJSValue:(JSValueRef)value inContext:(JSContextRef)ctx;
- (JSValueRef)JSValueForObject:(id)object inContext:(JSContextRef)ctx;

// Evaluation
- (JSValueRef)evaluateJSString:(NSString *)string scriptURL:(NSURL *)scriptURL;

// Exceptions
+ (NSException *)exceptionWithJSException:(JSValueRef)exception context:(JSContextRef)ctx;
- (void)throwJSException:(JSValueRef)exceptionJS inContext:(JSContextRef)ctx;

// Support
- (void)installBuiltins;

@end

extern void MORaiseRuntimeException(JSValueRef *exception, NSString* reason, MORuntime* runtime, JSContextRef ctx);
extern void MORaiseRuntimeExceptionNamed(NSString* name, JSValueRef *exception, NSString* reason, MORuntime* runtime, JSContextRef ctx);
extern NSException* MOThrowableRuntimeException(NSString* reason);
extern NSException* MOThrowableExceptionNamed(NSString* name, NSString* reason);

