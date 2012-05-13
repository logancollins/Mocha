//
//  MOException.m
//  Mocha
//
//  Created by Logan Collins on 5/11/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import "MOException.h"
#import "MOException_Private.h"


@implementation MOException

@synthesize error=_error;
@synthesize lineNumber=_lineNumber;
@synthesize sourceURL=_sourceURL;

+ (MOException *)exceptionWithError:(NSString *)error lineNumber:(NSUInteger)lineNumber sourceURL:(NSURL *)sourceURL {
    MOException *exception = [[self alloc] init];
    exception.error = error;
    exception.lineNumber = lineNumber;
    exception.sourceURL = sourceURL;
    return exception;
}

- (void)dealloc {
    [_error release];
    [_sourceURL release];
    [super dealloc];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p : error=%@, lineNumber=%lu, sourceURL=%@>", [self class], self, self.error, self.lineNumber, self.sourceURL];
}

@end
