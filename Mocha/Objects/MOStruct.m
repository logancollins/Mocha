//
//  MOStruct.m
//  Mocha
//
//  Created by Logan Collins on 5/15/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import "MOStruct.h"
#import "MochaRuntime.h"


@implementation MOStruct {
    NSMutableDictionary *_dictionary;
}

@synthesize name=_name;

- (id)init {
    self = [super init];
    if (self) {
        _dictionary = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc {
    [_name release];
    [_dictionary release];
    [super dealloc];
}

- (NSString *)descriptionWithIndent:(NSUInteger)indent {
    NSMutableString *indentString = [NSMutableString string];
    for (NSUInteger i=0; i<indent; i++) {
        [indentString appendString:@"    "];
    }
    
    NSMutableString *items = [NSMutableString stringWithString:@"{\n"];
    NSArray *keys = [_dictionary allKeys];
    for (NSUInteger i=0; i<[keys count]; i++) {
        NSString *key = [keys objectAtIndex:i];
        
        [items appendString:indentString];
        [items appendString:@"    "];
        [items appendString:key];
        [items appendString:@" = "];
        
        id value = [_dictionary objectForKey:key];
        if ([value isKindOfClass:[MOStruct class]]) {
            [items appendString:[value descriptionWithIndent:indent + 1]];
        }
        else {
            [items appendString:[value description]];
        }
        
        if (i != [keys count] - 1) {
            [items appendString:@","];
        }
        
        [items appendString:@"\n"];
    }
    [items appendString:indentString];
    [items appendString:@"}"];
    return [NSString stringWithFormat:@"<%@: %p : %@%@>", [self class], self, self.name, items];
}

- (NSString *)description {
    return [self descriptionWithIndent:0];
}

- (id)objectForKey:(NSString *)key {
    return [_dictionary objectForKey:key];
}

- (void)setObject:(id)obj forKey:(NSString *)key {
    [_dictionary setObject:obj forKey:key];
}

- (id)objectForKeyedSubscript:(NSString *)key {
    return [self objectForKey:key];
}

- (void)setObject:(id)obj forKeyedSubscript:(NSString *)key {
    [self setObject:obj forKey:key];
}

@end
