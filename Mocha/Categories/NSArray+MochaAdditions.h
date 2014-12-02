//
//  NSArray+MochaAdditions.h
//  Mocha
//
//  Created by Logan Collins on 5/12/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSArray (MochaAdditions)

- (NSArray *)mo_objectsByApplyingBlock:(id (^)(id obj, NSUInteger idx, BOOL *stop))block;

@end
