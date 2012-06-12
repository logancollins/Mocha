//
//  MOInstanceVariableDescription.h
//  Mocha
//
//  Created by Logan Collins on 5/26/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import <Foundation/Foundation.h>


/*!
 * @class MOInstanceVariableDescription
 * @abstract A description of an Objective-C instance variable
 */
@interface MOInstanceVariableDescription : NSObject

+ (MOInstanceVariableDescription *)instanceVariableWithName:(NSString *)name typeEncoding:(NSString *)typeEncoding;

@property (copy, readonly) NSString *name;
@property (copy, readonly) NSString *typeEncoding;

@end
