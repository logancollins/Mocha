//
//  MOMethod.h
//  Mocha
//
//  Created by Logan Collins on 5/12/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import <Mocha/MOObject.h>


@interface MOMethod : MOObject

+ (MOMethod *)methodWithTarget:(id)target selector:(SEL)selector;

@property (readonly) id target;
@property (readonly) SEL selector;

@end
