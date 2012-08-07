//
//  MOPointer.h
//  Mocha
//
//  Created by Logan Collins on 7/31/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MOPointer : NSObject

- (id)initWithValue:(id)value;

@property (strong, readonly) id value;

@end
