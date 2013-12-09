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
+ (JSValueRef)JSValueForObject:(id)object inContext:(JSContextRef)ctx;

+ (id)objectForJSValue:(JSValueRef)value inContext:(JSContextRef)ctx;
+ (id)objectForJSValue:(JSValueRef)value inContext:(JSContextRef)ctx unboxObjects:(BOOL)unboxObjects;

+ (NSArray *)arrayForJSArray:(JSObjectRef)arrayValue inContext:(JSContextRef)ctx;
+ (NSDictionary *)dictionaryForJSHash:(JSObjectRef)hashValue inContext:(JSContextRef)ctx;

- (JSValueRef)JSValueForObject:(id)object;

- (id)objectForJSValue:(JSValueRef)value;
- (id)objectForJSValue:(JSValueRef)value unboxObjects:(BOOL)unboxObjects;

// JSObject <-> id
- (JSObjectRef)boxedJSObjectForObject:(id)object;

// Object storage
- (void)setGlobalObject:(id)object withName:(NSString *)name attributes:(JSPropertyAttributes)attributes;

// Evaluation
- (JSValueRef)evaluateJSString:(NSString *)string scriptPath:(NSString *)scriptPath;

// Exceptions
+ (NSException *)exceptionWithJSException:(JSValueRef)exception context:(JSContextRef)ctx;
- (NSException *)exceptionWithJSException:(JSValueRef)exception;
- (void)throwJSException:(JSValueRef)exception;

// Support
- (void)installBuiltins;

@end
