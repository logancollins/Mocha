//
//  MOFunctionArgument.h
//  Mocha
//
//  Created by Logan Collins on 5/13/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

// 
// Note: A lot of this code is based on code from the PyObjC and JSCocoa projects.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import <ffi/ffi.h>


@class MOPointer;


@interface MOFunctionArgument : NSObject

+ (NSArray *)argumentsFromTypeSignature:(NSString *)typeSignature;

- (instancetype)initWithTypeEncoding:(NSString *)typeEncoding;
- (instancetype)initWithTypeEncoding:(NSString *)typeEncoding storage:(void **)storagePtr;
- (instancetype)initWithBaseTypeEncoding:(char)baseTypeEncoding;

@property (strong) NSString *typeEncoding;
- (void)setTypeEncoding:(NSString *)typeEncoding storage:(void **)storagePtr;

@property (readonly) char baseTypeEncoding;
@property (readonly) NSString *typeDescription;
@property (readonly) size_t size;

@property (strong) MOPointer *pointer;
@property (getter=isReturnValue) BOOL returnValue;

@property (readonly) ffi_type *ffiType;
@property (readonly) void ** storage;

// JSValues
- (JSValueRef)getValueAsJSValueInContext:(JSContextRef)ctx;
- (void)setValueAsJSValue:(JSValueRef)value context:(JSContextRef)ctx;

- (JSValueRef)getValueAsJSValueInContext:(JSContextRef)ctx dereference:(BOOL)dereference;
- (void)setValueAsJSValue:(JSValueRef)value context:(JSContextRef)ctx dereference:(BOOL)dereference;

@end
