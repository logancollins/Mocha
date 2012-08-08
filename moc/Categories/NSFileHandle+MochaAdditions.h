//
//  NSFileHandle+MochaAdditions.h
//  mocha
//
//  Created by Logan Collins on 8/8/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSFileHandle (MochaAdditions)

- (BOOL)mo_isReadable;
- (BOOL)mo_isTerminal;

@end
