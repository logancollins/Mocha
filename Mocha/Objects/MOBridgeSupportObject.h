//
//  MOBridgeSupportObject.h
//  Mocha
//
//  Created by Logan Collins on 5/12/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import <Mocha/MOObject.h>


@class MOBridgeSupportSymbol;


@interface MOBridgeSupportObject : MOObject

+ (MOBridgeSupportObject *)bridgeSupportObjectWithSymbol:(MOBridgeSupportSymbol *)symbol;

@property (strong) MOBridgeSupportSymbol *symbol;

@end
