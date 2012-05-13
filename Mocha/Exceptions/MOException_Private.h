//
//  MOException_Private.h
//  Mocha
//
//  Created by Logan Collins on 5/11/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import "MOException.h"
#import <JavaScriptCore/JavaScriptCore.h>


@interface MOException ()

+ (MOException *)exceptionWithError:(NSString *)error lineNumber:(NSUInteger)lineNumber sourceURL:(NSURL *)sourceURL;

@property (copy, readwrite) NSString *error;
@property (readwrite) NSUInteger lineNumber;
@property (copy, readwrite) NSURL *sourceURL;

@end
