//
//  MOProtocol.h
//  Mocha
//
//  Created by Logan Collins on 5/18/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import <Foundation/Foundation.h>


/*!
 * @class MOProtocol
 * @abstract Represents an Objective-C protocol
 * 
 * @discussion
 * While the Protocol class is technically an object,
 * it does not descend from NSObject (on 10.7 and before),
 * so this class allows protocols returned from the runtime
 * to be stored in arrays, queried for methods, etc. over
 * the bridge.
 */
@interface MOProtocol : NSObject

/*!
 * @method protocolWithProtocol:
 * @abstract Creates a new protocol wrapper
 * 
 * @param protocol
 * The Objective-C protocol object
 * 
 * @result An MOProtocol object
 */
+ (MOProtocol *)protocolWithProtocol:(Protocol *)protocol;


/*!
 * @property protocol
 * @abstract The Objective-C protocol object
 * 
 * @result A Protocol object
 */
@property (readonly) Protocol *protocol;


/*!
 * @property requiredClassMethods
 * @abstract The array of required class method names
 * 
 * @result An NSArray of NSString objects
 */
@property (copy, readonly) NSArray *requiredClassMethods;

/*!
 * @property optionalClassMethods
 * @abstract The array of optional class method names
 * 
 * @result An NSArray of NSString objects
 */
@property (copy, readonly) NSArray *optionalClassMethods;

/*!
 * @property requiredInstanceMethods
 * @abstract The array of required instance method names
 * 
 * @result An NSArray of NSString objects
 */
@property (copy, readonly) NSArray *requiredInstanceMethods;

/*!
 * @property optionalInstanceMethods
 * @abstract The array of optional instance method names
 * 
 * @result An NSArray of NSString objects
 */
@property (copy, readonly) NSArray *optionalInstanceMethods;

/*!
 * @property properties
 * @abstract The array of property names
 * 
 * @result An NSArray of NSString objects
 */
@property (copy, readonly) NSArray *properties;

/*!
 * @property protocols
 * @abstract The array of protocol names
 * 
 * @result An NSArray of NSString objects
 */
@property (copy, readonly) NSArray *protocols;

@end
