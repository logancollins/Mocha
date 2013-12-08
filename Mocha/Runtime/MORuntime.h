//
//  MORuntime.h
//  Mocha
//
//  Created by Logan Collins on 5/10/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mocha/MochaDefines.h>


/*!
 * @class MORuntime
 * @abstract The Mocha runtime interface
 */
@interface MORuntime : NSObject

/*!
 * @method isSyntaxValidForString:
 * @abstract Validates the syntax of a JavaScript expression
 * 
 * @param string
 * The JavaScript expression to validate
 * 
 * @result A BOOL value
 */
- (BOOL)isSyntaxValidForString:(NSString *)string;

/*!
 * @method evaluateString:
 * @abstract Evalutates the specified JavaScript expression, returning the result
 * 
 * @param string
 * The JavaScript expression to evaluate
 * 
 * @result An object, or nil
 */
- (id)evaluateString:(NSString *)string;


/*!
 * @method garbageCollect
 * @abstract Instructs the JavaScript garbage collector to perform a collection
 */
- (void)garbageCollect;


/*!
 * @group Objects
 */

/*!
 * @property globalObjectNames
 * @abstract Gets an array of all objects names in the global scope
 * 
 * @result An NSArray of NSString objects
 */
@property (copy, readonly) NSArray *globalObjectNames;

/*!
 * @method globalObjectWithName:
 * @abstract Gets an object in the global scope with a specified name
 * 
 * @result An object, or MOUndefined if an object with the specified name does not exist
 */
- (id)globalObjectWithName:(NSString *)objectName;


/*!
 * @group Bridge Support
 */

/*!
 * @method loadBridgeSupportFilesAtPath:
 * @abstract Loads BridgeSupport info and symbols at a specified location
 *
 * @param path
 * The path to load
 *
 * @result A BOOL value
 */
- (BOOL)loadBridgeSupportFilesAtPath:(NSString *)path;

#if !TARGET_OS_IPHONE

/*!
 * @method loadFrameworkWithName:
 * @abstract Loads BridgeSupport info and symbols for a specified framework
 * 
 * @param frameworkName
 * The name of the framework to load
 * 
 * @discussion
 * This method will attempt to load BridgeSupport info and symbols for the
 * framework via dyld. If the framework cannot be found, or fails to load,
 * this method returns NO.
 * 
 * @result A BOOL value
 */
- (BOOL)loadFrameworkWithName:(NSString *)frameworkName;

/*!
 * @method loadFrameworkWithName:inDirectory:
 * @abstract Loads BridgeSupport info and symbols for a specified framework
 * 
 * @param frameworkName
 * The name of the framework to load
 * 
 * @param directory
 * The directory in which to look for the framework
 * 
 * @discussion
 * This method will attempt to load BridgeSupport info and symbols for the
 * framework via dyld. If the framework cannot be found, or fails to load,
 * this method returns NO.
 * 
 * @result A BOOL value
 */
- (BOOL)loadFrameworkWithName:(NSString *)frameworkName inDirectory:(NSString *)directory;

/*!
 * @property frameworkSearchPaths
 * @abstract Gets the array of search paths to check when loading a framework
 * 
 * @result An NSArray of NSString objects
 */
@property (copy) NSArray *frameworkSearchPaths;

#endif

@end


/*!
 * @category NSObject(MOObjectSubscripting)
 * @abstract Methods for enabling object subscripting within the runtime
 * 
 * @discussion
 * This category defines but does not implement these methods.
 */
@interface NSObject (MOObjectSubscripting)

/*!
 * @method objectForIndexedSubscript:
 * @abstract Gets the object for a given index
 * 
 * @param idx
 * The index for which to get an object
 * 
 * @result An object
 */
- (id)objectForIndexedSubscript:(NSUInteger)idx;

/*!
 * @method setObject:forIndexedSubscript:
 * @abstract Sets the object for a given index
 * 
 * @param obj
 * The object value to set
 * 
 * @param idx
 * The index for which to get an object
 */
- (void)setObject:(id)obj forIndexedSubscript:(NSUInteger)idx;


/*!
 * @method objectForKeyedSubscript:
 * @abstract Gets the object for a given key
 * 
 * @param key
 * The key for which to get an object
 * 
 * @result An object
 */
- (id)objectForKeyedSubscript:(NSString *)key;

/*!
 * @method setObject:forKeyedSubscript:
 * @abstract Sets the object for a given key
 * 
 * @param obj
 * The object value to set
 * 
 * @param key
 * The key for which to get an object
 */
- (void)setObject:(id)obj forKeyedSubscript:(NSString *)key;

@end


/*!
 * @constant MORuntimeException
 * @abstract The name of exceptions raised within the runtime's internal implementation
 */
MOCHA_EXTERN NSString * const MORuntimeException;

/*!
 * @constant MOJavaScriptException
 * @abstract The name of exceptions raised within JavaScript code
 */
MOCHA_EXTERN NSString * const MOJavaScriptException;

