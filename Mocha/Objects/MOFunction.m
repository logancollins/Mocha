//
//  MOFunction.m
//  Mocha
//
//  Created by Logan Collins on 5/12/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import "MOFunction.h"
#import "MOFunction_Private.h"


@implementation MOFunction

@synthesize target=_target;
@synthesize selector=_selector;

+ (MOFunction *)functionWithTarget:(id)target selector:(SEL)selector {
    MOFunction *function = [[self alloc] init];
    function.target = target;
    function.selector = selector;
    return [function autorelease];
}

@end
