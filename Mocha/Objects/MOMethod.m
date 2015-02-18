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
@synthesize block=_block;

+ (MOMethod *)methodWithTarget:(id)target selector:(SEL)selector {
    MOMethod *method = [[self alloc] init];
    method.target = target;
    method.selector = selector;
    return method;
}

+ (MOMethod *)methodWithBlock:(id)block {
    MOMethod *method = [[self alloc] init];
    method.block = block;
    return method;
}

- (BOOL)isEqual:(id)object
{
  if ([object isKindOfClass: [MOMethod class]] == NO)
    return NO;
  
  MOMethod *objectMethod = (MOMethod *)object;
  return ([objectMethod->_target isEqual: self->_target] && objectMethod->_selector == self->_selector && objectMethod->_block == self->_block);
}

- (NSUInteger)hash
{
  return [self.target hash] + [NSStringFromSelector(self.selector) hash] + [self.block hash];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p : target=%@, selector=%@>", [self class], self, [self target], NSStringFromSelector([self selector])];
}

@end
