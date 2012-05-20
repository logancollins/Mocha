//
//  MOClosure_Private.h
//  Mocha
//
//  Created by Logan Collins on 5/19/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import <Mocha/MOClosure.h>


@interface MOClosure ()

- (id)initWithBlock:(id)block;

@property (copy, readwrite) id block;

@property (readonly) void * callAddress;
@property (readonly) const char * typeEncoding;

@end
