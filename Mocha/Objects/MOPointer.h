//
//  MOPointer.h
//  Mocha
//
//  Created by Logan Collins on 7/31/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>


@interface MOPointer : NSObject

- (id)initWithJSValue:(JSValueRef)JSValue context:(JSContextRef)JSContext;

@property (readonly) JSValueRef JSValue;
@property (readonly) JSContextRef JSContext;
- (void)setJSValue:(JSValueRef)JSValue JSContext:(JSContextRef)JSContext;

@property (readonly) id value;

@end
