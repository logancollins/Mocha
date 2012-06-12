//
//  MOMethodDescription.h
//  Mocha
//
//  Created by Logan Collins on 5/26/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import <Foundation/Foundation.h>


/*!
 * @class MOMethodDescription
 * @abstract A description of an Objective-C method
 */
@interface MOMethodDescription : NSObject

+ (MOMethodDescription *)methodWithSelector:(SEL)selector typeEncoding:(NSString *)typeEncoding;

@property (readonly) SEL selector;
@property (copy, readonly) NSString *typeEncoding;

@end
