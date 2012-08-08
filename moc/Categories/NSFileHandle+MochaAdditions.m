//
//  NSFileHandle+MochaAdditions.m
//  mocha
//
//  Created by Logan Collins on 8/8/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import "NSFileHandle+MochaAdditions.h"


@implementation NSFileHandle (MochaAdditions)

- (BOOL)mo_isReadable {
    int fd = [self fileDescriptor];
    fd_set fdset;
    struct timeval tmout = { 0, 0 }; // return immediately
    FD_ZERO(&fdset);
    FD_SET(fd, &fdset);
    if (select(fd + 1, &fdset, NULL, NULL, &tmout) <= 0)
        return NO;
    return FD_ISSET(fd, &fdset);
}

- (BOOL)mo_isTerminal {
    int fd = [self fileDescriptor];
    return (isatty(fd) == 1 ? YES : NO);
}

@end
