//
//  MOClosure.m
//  Mocha
//
//  Created by Logan Collins on 5/19/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import "MOClosure.h"
#import "MOClosure_Private.h"

#import "MOUtilities.h"


@implementation MOClosure

@synthesize block=_block;

struct BlockDescriptor {
    unsigned long reserved;
    unsigned long size;
    void *rest[1];
};

struct Block {
    void *isa;
    int flags;
    int reserved;
    void *invoke;
    struct BlockDescriptor *descriptor;
};

+ (MOClosure *)closureWithBlock:(id)block {
    return [[[self alloc] initWithBlock:block] autorelease];
}

- (id)initWithBlock:(id)block {
    self = [super init];
    if (self) {
        _block = [block copy];
    }
    return self;
}

- (void)dealloc {
    [_block release];
    [super dealloc];
}

- (void *)callAddress {
    return ((struct Block *)_block)->invoke;
}

- (const char *)typeEncoding {
    struct Block *block = (struct Block *)_block;
    struct BlockDescriptor *descriptor = block->descriptor;
    
    int copyDisposeFlag = 1 << 25;
    int signatureFlag = 1 << 30;
    
    assert(block->flags & signatureFlag);
    
    int index = 0;
    if (block->flags & copyDisposeFlag) {
        index += 2;
    }
    
    return descriptor->rest[index];
}

@end
