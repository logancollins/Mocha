//
//  MOObjCRuntime.h
//  Mocha
//
//  Created by Logan Collins on 5/16/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MOObjCRuntime : NSObject

+ (MOObjCRuntime *)sharedRuntime;

@property (copy, readonly) NSArray *classes;
- (Class)classWithName:(NSString *)name;

@property (copy, readonly) NSArray *protocols;
- (Protocol *)protocolWithName:(NSString *)name;

@end
