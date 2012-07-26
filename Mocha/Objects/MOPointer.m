//
//  MOPointer.m
//  Mocha
//
//  Created by Logan Collins on 7/26/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import "MOPointer.h"


@interface MOPointer ()

@property (readwrite) void * pointerValue;
@property (copy, readwrite) NSString *typeEncoding;

@end


@implementation MOPointer

@synthesize pointerValue=_pointerValue;
@synthesize typeEncoding=_typeEncoding;

- (id)initWithPointerValue:(void *)pointerValue typeEncoding:(NSString *)typeEncoding {
	self = [super init];
	if (self) {
		self.pointerValue = pointerValue;
		self.typeEncoding = typeEncoding;
	}
	return self;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<%p type=%@>", self.pointerValue, self.typeEncoding];
}

@end
