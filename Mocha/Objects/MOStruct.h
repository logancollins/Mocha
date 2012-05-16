//
//  MOStruct.h
//  Mocha
//
//  Created by Logan Collins on 5/15/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MOStruct : NSObject

@property (copy) NSString *name;

- (id)objectForKey:(NSString *)key;
- (void)setObject:(id)obj forKey:(NSString *)key;

@end
