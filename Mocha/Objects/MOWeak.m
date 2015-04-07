//
//  MOWeak.m
//  Mocha
//
//  Created by Logan Collins on 12/10/13.
//  Copyright (c) 2013 Sunflower Softworks. All rights reserved.
//

#import "MOWeak.h"
#import "MORuntime_Private.h"


@implementation MOWeak {
    __weak id _value;
}

+ (id)constructWithArguments:(NSArray *)arguments {
    if ([arguments count] == 0) {
        @throw MOThrowableExceptionNamed(NSInvalidArgumentException, @"Weak references require one argument");
    }
    return [[self alloc] initWithValue:[arguments objectAtIndex:0]];
}

- (instancetype)initWithValue:(id)value {
    self = [super init];
    if (self) {
        _value = value;
    }
    return self;
}

- (id)callWithArguments:(NSArray *)arguments {
    return _value;
}

@end
