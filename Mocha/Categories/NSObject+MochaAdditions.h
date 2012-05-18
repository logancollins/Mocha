//
//  NSObject+MochaAdditions.h
//  Mocha
//
//  Created by Logan Collins on 5/17/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSObject (MochaAdditions)

+ (void)mo_swizzleAdditions;

+ (NSArray *)mo_ancestors;

+ (NSArray *)mo_instanceMethods;
+ (NSArray *)mo_instanceMethodsWithAncestors;

+ (NSArray *)mo_classMethods;
+ (NSArray *)mo_classMethodsWithAncestors;

+ (NSArray *)mo_properties;
+ (NSArray *)mo_propertiesWithAncestors;

+ (NSArray *)mo_protocols;
+ (NSArray *)mo_protocolsWithAncestors;

@end
