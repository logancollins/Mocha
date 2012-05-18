//
//  MOProtocol.m
//  Mocha
//
//  Created by Logan Collins on 5/18/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import "MOProtocol.h"

#import <objc/runtime.h>


@interface MOProtocol ()

@property (readwrite) Protocol *protocol;

@end


static const void * MOProtocolTableRetain(CFAllocatorRef allocator, const void *value) {
    [(id)value retain];
    return value;
}

static void MOProtocolTableRelease(CFAllocatorRef allocator, const void *value) {
    [(id)value release];
}

static Boolean MOProtocolTableEqual(const void *value1, const void *value2) {
    return (Boolean)((id)value1 == (id)value2);
}

static CFHashCode MOProtocolTableHash(const void *value) {
    return (CFHashCode)[(id)value hash];
}


@implementation MOProtocol

@synthesize protocol=_protocol;

static CFMutableDictionaryRef _protocolsTable = NULL;

+ (void)initialize {
    if (self == [MOProtocol class]) {
        CFDictionaryKeyCallBacks keyCallBacks = { 0, NULL, NULL, NULL, NULL, MOProtocolTableHash };
        CFDictionaryValueCallBacks valueCallBacks = { 0, MOProtocolTableRetain, MOProtocolTableRelease, NULL, MOProtocolTableEqual };
        _protocolsTable = CFDictionaryCreateMutable(NULL, 0, &keyCallBacks, &valueCallBacks);
    }
}

+ (MOProtocol *)protocolWithProtocol:(Protocol *)protocol {
    MOProtocol *protocolWrapper = (id)CFDictionaryGetValue(_protocolsTable, protocol);
    if (protocolWrapper == nil) {
        protocolWrapper = [[self alloc] init];
        protocolWrapper.protocol = protocol;
        CFDictionarySetValue(_protocolsTable, protocol, protocolWrapper);
    }
    return protocolWrapper;
}

- (NSArray *)requiredClassMethods {
    unsigned int count;
    struct objc_method_description *methodDescriptions = protocol_copyMethodDescriptionList(_protocol, YES, NO, &count);
    
    if (methodDescriptions == NULL) {
        return [NSArray array];
    }
    
    NSMutableArray *methodNames = [NSMutableArray arrayWithCapacity:count];
    
    for (NSUInteger i=0; i<count; i++) {
        struct objc_method_description methodDescription = methodDescriptions[i];
        SEL name = methodDescription.name;
        [methodNames addObject:NSStringFromSelector(name)];
    }
    
    free(methodDescriptions);
    
    return methodNames;
}

- (NSArray *)optionalClassMethods {
    unsigned int count;
    struct objc_method_description *methodDescriptions = protocol_copyMethodDescriptionList(_protocol, NO, NO, &count);
    
    if (methodDescriptions == NULL) {
        return [NSArray array];
    }
    
    NSMutableArray *methodNames = [NSMutableArray arrayWithCapacity:count];
    
    for (NSUInteger i=0; i<count; i++) {
        struct objc_method_description methodDescription = methodDescriptions[i];
        SEL name = methodDescription.name;
        [methodNames addObject:NSStringFromSelector(name)];
    }
    
    free(methodDescriptions);
    
    return methodNames;
}

- (NSArray *)requiredInstanceMethods {
    unsigned int count;
    struct objc_method_description *methodDescriptions = protocol_copyMethodDescriptionList(_protocol, YES, YES, &count);
    
    if (methodDescriptions == NULL) {
        return [NSArray array];
    }
    
    NSMutableArray *methodNames = [NSMutableArray arrayWithCapacity:count];
    
    for (NSUInteger i=0; i<count; i++) {
        struct objc_method_description methodDescription = methodDescriptions[i];
        SEL name = methodDescription.name;
        [methodNames addObject:NSStringFromSelector(name)];
    }
    
    free(methodDescriptions);
    
    return methodNames;
}

- (NSArray *)optionalInstanceMethods {
    unsigned int count;
    struct objc_method_description *methodDescriptions = protocol_copyMethodDescriptionList(_protocol, NO, YES, &count);
    
    if (methodDescriptions == NULL) {
        return [NSArray array];
    }
    
    NSMutableArray *methodNames = [NSMutableArray arrayWithCapacity:count];
    
    for (NSUInteger i=0; i<count; i++) {
        struct objc_method_description methodDescription = methodDescriptions[i];
        SEL name = methodDescription.name;
        [methodNames addObject:NSStringFromSelector(name)];
    }
    
    free(methodDescriptions);
    
    return methodNames;
}

- (NSArray *)properties {
    unsigned int count;
    objc_property_t * properties = protocol_copyPropertyList(_protocol, &count);
    
    if (properties == NULL) {
        return [NSArray array];
    }
    
    NSMutableArray *propertyNames = [NSMutableArray arrayWithCapacity:count];
    
    for (NSUInteger i=0; i<count; i++) {
        objc_property_t property = properties[i];
        NSString *name = [NSString stringWithUTF8String:property_getName(property)];
        [propertyNames addObject:name];
    }
    
    free(properties);
    
    return propertyNames;
}

- (NSArray *)protocols {
    unsigned int count;
    Protocol **protocols = protocol_copyProtocolList(_protocol, &count);
    
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

@end
