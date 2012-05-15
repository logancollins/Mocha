//
//  MOUtilities.h
//  Mocha
//
//  Created by Logan Collins on 5/11/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

#import <ffi/ffi.h>


@class MOBridgeSupportFunction;


NSString * MOJSValueToString(JSValueRef value, JSContextRef ctx);

JSValueRef MOSelectorInvoke(id target, SEL selector, JSContextRef ctx, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception);
JSValueRef MOFunctionInvoke(MOBridgeSupportFunction *function, JSContextRef ctx, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception);

void * MOInvocationGetObjCCallAddressForArguments(NSArray *arguments);

NSArray * MOParseObjCMethodEncoding(const char *typeEncoding);

SEL MOSelectorFromPropertyName(NSString *propertyName);
NSString * MOSelectorToPropertyName(SEL selector);
