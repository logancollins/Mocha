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
    
    SEL methodsSelector = @selector(methods);
    if (![self instancesRespondToSelector:methodsSelector]) {
        IMP imp = class_getMethodImplementation(metaClass, @selector(mo_methods));
        class_addMethod(metaClass, methodsSelector, imp, "@@:");
    }
    
    SEL ancestorsSelector = @selector(ancestors);
    if (![self instancesRespondToSelector:ancestorsSelector]) {
        IMP imp = class_getMethodImplementation(metaClass, @selector(mo_ancestors));
        class_addMethod(metaClass, ancestorsSelector, imp, "@@:");
    }
    
    SEL protocolsSelector = @selector(protocols);
    if (![self instancesRespondToSelector:protocolsSelector]) {
        IMP imp = class_getMethodImplementation(metaClass, @selector(mo_protocols));
        class_addMethod(metaClass, protocolsSelector, imp, "@@:");
    }
}

+ (NSArray *)mo_methodsForClass:(Class)klass {
    unsigned int count;
    Method *methods = class_copyMethodList(klass, &count);
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
    return methodNames;
}

+ (NSArray *)mo_methods {
    NSMutableArray *methodNames = [NSMutableArray array];
    for (Class klass in [self mo_ancestors]) {
        [methodNames addObjectsFromArray:[self mo_methodsForClass:klass]];
    }
    [methodNames addObjectsFromArray:[self mo_methodsForClass:self]];
    [methodNames sortUsingSelector:@selector(caseInsensitiveCompare:)];
    return methodNames;
}

+ (NSArray *)mo_ancestors {
    NSMutableArray *classes = [NSMutableArray array];
    Class klass = self;
    while ((klass = [klass superclass])) {
        [classes insertObject:klass atIndex:0];
    }
    return classes;
}

+ (NSArray *)mo_protocolsForClass:(Class)klass {
    unsigned int count;
    Protocol **protocols = class_copyProtocolList(klass, &count);
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
    NSMutableArray *protocolNames = [NSMutableArray array];
    for (Class klass in [self mo_ancestors]) {
        [protocolNames addObjectsFromArray:[self mo_protocolsForClass:klass]];
    }
    [protocolNames addObjectsFromArray:[self mo_protocolsForClass:self]];
    return protocolNames;
}

@end
