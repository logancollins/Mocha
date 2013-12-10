//
//  MOJavaScriptFunction_Private.h
//  Mocha
//
//  Created by Logan Collins on 12/9/13.
//  Copyright (c) 2013 Sunflower Softworks. All rights reserved.
//

#import <Mocha/MOJavaScriptFunction.h>


typedef id (^MOJavaScriptClosureBlock)(id obj, ...);


@interface MOJavaScriptFunction ()

- (MOJavaScriptClosureBlock)blockWithArgumentCount:(NSUInteger *)argCount;

@end
