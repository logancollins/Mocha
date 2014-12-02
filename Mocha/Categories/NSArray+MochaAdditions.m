//
//  NSArray+MochaAdditions.m
//  Mocha
//
//  Created by Logan Collins on 5/12/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import "NSArray+MochaAdditions.h"


@implementation NSArray (MochaAdditions)

+ (id)constructWithArguments:(NSArray *)arguments {
    return [[self alloc] initWithArray:arguments];
}

- (NSArray *)mo_objectsByApplyingBlock:(id (^)(id obj, NSUInteger idx, BOOL *stop))block {
    __block NSMutableArray *objects = [NSMutableArray arrayWithCapacity:[self count]];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        BOOL localStop = NO;
        id value = block(obj, idx, &localStop);
        if (value != nil) {
            [objects addObject:value];
        }
        if (localStop == YES) {
            *stop = YES;
        }
    }];
    return objects;
}

@end
