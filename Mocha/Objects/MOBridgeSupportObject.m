//
//  MOBridgeSupportObject.m
//  Mocha
//
//  Created by Logan Collins on 5/12/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import "MOBridgeSupportObject.h"


@implementation MOBridgeSupportObject

@synthesize symbol=_symbol;

+ (MOBridgeSupportObject *)bridgeSupportObjectWithSymbol:(MOBridgeSupportSymbol *)symbol {
    MOBridgeSupportObject *object = [[self alloc] init];
    object.symbol = symbol;
    return [object autorelease];
}

- (void)dealloc {
    [_symbol release];
    [super dealloc];
}

@end
