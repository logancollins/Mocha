//
//  NSObject+MochaAdditions.m
//  Mocha
//
//  Created by Logan Collins on 5/17/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import "NSObject+MochaAdditions.h"

#import "MOBridgeSupportController.h"
#import "MOBridgeSupportSymbol.h"

#import <objc/runtime.h>


@implementation NSObject (MochaAdditions)

+ (void)mo_swizzleAdditions {
    Class metaClass = object_getClass(self);
    
    SEL ancestorsSelector = @selector(ancestors);
    if (![self instancesRespondToSelector:ancestorsSelector]) {
        IMP imp = class_getMethodImplementation(metaClass, @selector(mo_ancestors));
        class_addMethod(metaClass, ancestorsSelector, imp, "@@:");
    }
    
    SEL classMethodsSelector = @selector(classMethods);
    if (![self instancesRespondToSelector:classMethodsSelector]) {
        IMP imp = class_getMethodImplementation(metaClass, @selector(mo_classMethods));
        class_addMethod(metaClass, classMethodsSelector, imp, "@@:");
    }
    
    SEL classMethodsWithAncestorsSelector = @selector(classMethodsWithAncestors);
    if (![self instancesRespondToSelector:classMethodsWithAncestorsSelector]) {
        IMP imp = class_getMethodImplementation(metaClass, @selector(mo_classMethodsWithAncestors));
        class_addMethod(metaClass, classMethodsWithAncestorsSelector, imp, "@@:");
    }
    
    SEL instanceMethodsSelector = @selector(instanceMethods);
    if (![self instancesRespondToSelector:instanceMethodsSelector]) {
        IMP imp = class_getMethodImplementation(metaClass, @selector(mo_instanceMethods));
        class_addMethod(metaClass, instanceMethodsSelector, imp, "@@:");
    }
    
    SEL instanceMethodsWithAncestorsSelector = @selector(instanceMethodsWithAncestors);
    if (![self instancesRespondToSelector:instanceMethodsWithAncestorsSelector]) {
        IMP imp = class_getMethodImplementation(metaClass, @selector(mo_instanceMethodsWithAncestors));
        class_addMethod(metaClass, instanceMethodsWithAncestorsSelector, imp, "@@:");
    }
    
    SEL propertiesSelector = @selector(properties);
    if (![self instancesRespondToSelector:propertiesSelector]) {
        IMP imp = class_getMethodImplementation(metaClass, @selector(mo_properties));
        class_addMethod(metaClass, propertiesSelector, imp, "@@:");
    }
    
    SEL propertiesWithAncestorsSelector = @selector(propertiesWithAncestors);
    if (![self instancesRespondToSelector:propertiesWithAncestorsSelector]) {
        IMP imp = class_getMethodImplementation(metaClass, @selector(mo_propertiesWithAncestors));
        class_addMethod(metaClass, propertiesWithAncestorsSelector, imp, "@@:");
    }
    
    SEL protocolsSelector = @selector(protocols);
    if (![self instancesRespondToSelector:protocolsSelector]) {
        IMP imp = class_getMethodImplementation(metaClass, @selector(mo_protocols));
        class_addMethod(metaClass, protocolsSelector, imp, "@@:");
    }
    
    SEL protocolsWithAncestorsSelector = @selector(protocolsWithAncestors);
    if (![self instancesRespondToSelector:protocolsWithAncestorsSelector]) {
        IMP imp = class_getMethodImplementation(metaClass, @selector(mo_protocolsWithAncestors));
        class_addMethod(metaClass, protocolsWithAncestorsSelector, imp, "@@:");
    }
}

+ (NSArray *)mo_ancestors {
    NSMutableArray *classes = [NSMutableArray array];
    Class klass = self;
    while ((klass = [klass superclass])) {
        [classes insertObject:klass atIndex:0];
    }
    return classes;
}

+ (NSArray *)mo_methodsForClass:(Class)klass {
    unsigned int count;
    Method *methods = class_copyMethodList(klass, &count);
    
    if (methods == NULL) {
        return [NSArray array];
    }
    
    NSMutableArray *methodNames = [NSMutableArray arrayWithCapacity:count];
    
    for (NSUInteger i=0; i<count; i++) {
        Method method = methods[i];
        SEL selector = method_getName(method);
        NSString *name = NSStringFromSelector(selector);
        if (![name hasPrefix:@"_"]) {
            [methodNames addObject:name];
        }
    }
    
    [methodNames sortUsingSelector:@selector(caseInsensitiveCompare:)];
    
    free(methods);
    
    return methodNames;
}

+ (NSArray *)mo_classMethods {
    Class metaClass = object_getClass(self);
    return [self mo_methodsForClass:metaClass];
}

+ (NSArray *)mo_classMethodsWithAncestors {
    NSMutableArray *methodNames = [NSMutableArray array];
    for (Class klass in [self mo_ancestors]) {
        Class metaClass = object_getClass(klass);
        [methodNames addObjectsFromArray:[self mo_methodsForClass:metaClass]];
    }
    Class metaClass = object_getClass(self);
    [methodNames addObjectsFromArray:[self mo_methodsForClass:metaClass]];
    [methodNames sortUsingSelector:@selector(caseInsensitiveCompare:)];
    return methodNames;
}

+ (NSArray *)mo_instanceMethods {
    return [self mo_methodsForClass:self];
}

+ (NSArray *)mo_instanceMethodsWithAncestors {
    NSMutableArray *methodNames = [NSMutableArray array];
    for (Class klass in [self mo_ancestors]) {
        [methodNames addObjectsFromArray:[self mo_methodsForClass:klass]];
    }
    [methodNames addObjectsFromArray:[self mo_methodsForClass:self]];
    [methodNames sortUsingSelector:@selector(caseInsensitiveCompare:)];
    return methodNames;
}

+ (NSArray *)mo_propertiesForClass:(Class)klass {
    unsigned int count;
    objc_property_t * properties = class_copyPropertyList(klass, &count);
    
    if (properties == NULL) {
        return [NSArray array];
    }
    
    NSMutableArray *propertyNames = [NSMutableArray arrayWithCapacity:count];
    
    for (NSUInteger i=0; i<count; i++) {
        objc_property_t property = properties[i];
        NSString *name = [NSString stringWithUTF8String:property_getName(property)];
        if (![name hasPrefix:@"_"]) {
            [propertyNames addObject:name];
        }
    }
    
    [propertyNames sortUsingSelector:@selector(caseInsensitiveCompare:)];
    
    free(properties);
    
    return propertyNames;
}

+ (NSArray *)mo_properties {
    return [self mo_propertiesForClass:self];
}

+ (NSArray *)mo_propertiesWithAncestors {
    NSMutableArray *propertyNames = [NSMutableArray array];
    for (Class klass in [self mo_ancestors]) {
        [propertyNames addObjectsFromArray:[self mo_propertiesForClass:klass]];
    }
    [propertyNames addObjectsFromArray:[self mo_propertiesForClass:self]];
    return propertyNames;
}

+ (NSArray *)mo_protocolsForClass:(Class)klass {
    unsigned int count;
    Protocol **protocols = class_copyProtocolList(klass, &count);
    
    if (protocols == NULL) {
        return [NSArray array];
    }
    
    NSMutableArray *protocolNames = [NSMutableArray arrayWithCapacity:count];
    
    for (NSUInteger i=0; i<count; i++) {
        Protocol *protocol = protocols[i];
        NSString *name = [NSString stringWithUTF8String:protocol_getName(protocol)];
        [protocolNames addObject:name];
    }
    
    free(protocols);
    
    return protocolNames;
}

+ (NSArray *)mo_protocols {
    return [self mo_protocolsForClass:self];
}

+ (NSArray *)mo_protocolsWithAncestors {
    NSMutableArray *protocolNames = [NSMutableArray array];
    for (Class klass in [self mo_ancestors]) {
        [protocolNames addObjectsFromArray:[self mo_protocolsForClass:klass]];
    }
    [protocolNames addObjectsFromArray:[self mo_protocolsForClass:self]];
    return protocolNames;
}

@end
