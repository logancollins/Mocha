//
//  MOMethod.h
//  Mocha
//
//  Created by Logan Collins on 5/12/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import <Foundation/Foundation.h>


/*!
 * @class MOMethod
 * @abstract Represents a callable method
 */
@interface MOMethod : NSObject

/*!
 * @method methodWithTarget:selector:
 * @abstract Creates a new method object
 * 
 * @param target
 * The target of the method call
 * 
 * @param selector
 * The selector called on the method target
 * 
 * @result An MOMethod object
 */
+ (MOMethod *)methodWithTarget:(id)target selector:(SEL)selector;


/*!
 * @property target
 * @abstract The target of the method call
 * 
 * @result An object
 */
@property (readonly) id target;

/*!
 * @property selector
 * @abstract The selector called on the method target
 * 
 * @result A SEL value
 */
@property (readonly) SEL selector;

@end
