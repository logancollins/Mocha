//
//  MOMethod.m
//  Mocha
//
//  Created by Logan Collins on 5/12/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import "MOMethod.h"
#import "MOMethod_Private.h"


@implementation MOMethod

@synthesize target=_target;
@synthesize selector=_selector;

+ (MOMethod *)methodWithTarget:(id)target selector:(SEL)selector {
    MOMethod *method = [[self alloc] init];
    method.target = target;
    method.selector = selector;
    return [method autorelease];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p : target=%@, selector=%@>", [self class], self, [self target], NSStringFromSelector([self selector])];
}

@end