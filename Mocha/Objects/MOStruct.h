//
//  MOStruct.h
//  Mocha
//
//  Created by Logan Collins on 5/15/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MOStruct : NSObject

+ (MOStruct *)structureWithName:(NSString *)name memberNames:(NSArray *)memberNames;
- (id)initWithName:(NSString *)name memberNames:(NSArray *)memberNames;

@property (copy, readonly) NSString *name;
@property (copy, readonly) NSArray *memberNames;

- (id)objectForKey:(NSString *)key;
- (void)setObject:(id)obj forKey:(NSString *)key;

@end
