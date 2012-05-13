//
//  MOFunction.h
//  Mocha
//
//  Created by Logan Collins on 5/12/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import <Mocha/MOObject.h>


@interface MOFunction : MOObject

+ (MOFunction *)functionWithTarget:(id)target selector:(SEL)selector;

@property (readonly) id target;
@property (readonly) SEL selector;

@end
