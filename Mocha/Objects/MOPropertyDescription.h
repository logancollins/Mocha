//
//  MOPropertyDescription.h
//  Mocha
//
//  Created by Logan Collins on 5/26/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mocha/MOObjCRuntime.h>


/*!
 * @class MOPropertyDescription
 * @abstract Description for an Objective-C class property
 */
@interface MOPropertyDescription : NSObject

@property (copy) NSString *name;
@property (copy) NSString *typeEncoding;
@property (copy) NSString *ivarName;

@property SEL getterSelector;
@property SEL setterSelector;

@property MOObjCOwnershipRule ownershipRule;

@property (getter=isDynamic) BOOL dynamic;
@property (getter=isNonAtomic) BOOL nonAtomic;
@property (getter=isReadOnly) BOOL readOnly;
@property (getter=isWeak) BOOL weak;

@end
