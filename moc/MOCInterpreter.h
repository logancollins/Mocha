//
//  MOCInterpreter.h
//  Mocha
//
//  Created by Logan Collins on 5/12/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mocha/Mocha.h>


@interface MOCInterpreter : NSObject <MochaDelegate>

- (void)run;
- (void)runScriptAtPath:(NSString*)path;

@end
