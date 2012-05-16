//
//  MochaRuntime.h
//  Mocha
//
//  Created by Logan Collins on 5/10/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import <Mocha/MochaDefines.h>


@class MOException;
@protocol MochaDelegate;


@interface Mocha : NSObject

+ (Mocha *)sharedRuntime;

- (id)initWithGlobalContext:(JSGlobalContextRef)ctx;

@property (readonly) JSGlobalContextRef context;
@property (assign) id <MochaDelegate> delegate;

@property BOOL autocallObjCProperties;

// Evaluation
- (id)evalString:(NSString *)string;

// Frameworks
- (id)callFunctionWithName:(NSString *)functionName;
- (id)callFunctionWithName:(NSString *)functionName withArguments:(id)firstArg, ... NS_REQUIRES_NIL_TERMINATION;
- (id)callFunctionWithName:(NSString *)functionName withArgumentsInArray:(NSArray *)arguments;

// Syntax Validation
- (BOOL)isSyntaxValidForString:(NSString *)string;

// Frameworks
- (BOOL)loadFrameworkWithName:(NSString *)frameworkName;
- (BOOL)loadFrameworkWithName:(NSString *)frameworkName inDirectory:(NSString *)directory;

// Garbage Collector
- (void)garbageCollect;

@end


@protocol MochaDelegate <NSObject>

@optional

@end


@interface NSObject (MochaScripting)

+ (BOOL)isSelectorExcludedFromMochaScript:(SEL)aSelector;

- (void)finalizeForMochaScript;

@end


@interface NSObject (MochaObjectSubscripting)

// Indexed subscripts
- (id)objectForIndexedSubscript:(NSUInteger)idx;
- (void)setObject:(id)obj forIndexedSubscript:(NSUInteger)idx;

// Keyed subscripts
- (id)objectForKeyedSubscript:(NSString *)key;
- (void)setObject:(id)obj forKeyedSubscript:(NSString *)key;

@end


MOCHA_EXTERN NSString * const MORuntimeException;
MOCHA_EXTERN NSString * const MOJavaScriptException;
