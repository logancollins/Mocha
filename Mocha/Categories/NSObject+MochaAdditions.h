//
//  NSObject+MochaAdditions.h
//  Mocha
//
//  Created by Logan Collins on 5/17/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSObject (MochaAdditions)

+ (void)mo_swizzleAdditions;

+ (NSArray *)mo_methods;

+ (NSArray *)mo_ancestors;

+ (NSArray *)mo_protocols;

@end
