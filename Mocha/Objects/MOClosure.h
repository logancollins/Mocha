//
//  MOClosure.h
//  Mocha
//
//  Created by Logan Collins on 5/19/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import <Foundation/Foundation.h>


/*!
 * @class MOClosure
 * @abstract Represents a callable closure
 */
@interface MOClosure : NSObject

/*!
 * @method closureWithBlock:
 * @abstract Creates a new closure object from a block
 * 
 * @param block
 * The block object to call
 * 
 * @result An MOClosure object
 */
+ (MOClosure *)closureWithBlock:(id)block;


/*!
 * @property block
 * @abstract The block called for the closure
 * 
 * @result A block object
 */
@property (copy, readonly) id block;

@end
