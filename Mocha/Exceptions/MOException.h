//
//  MOException.h
//  Mocha
//
//  Created by Logan Collins on 5/11/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MOException : NSObject

@property (copy, readonly) NSString *error;
@property (readonly) NSUInteger lineNumber;
@property (copy, readonly) NSURL *sourceURL;

@end
