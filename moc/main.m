//
//  main.m
//  moc
//
//  Created by Logan Collins on 5/12/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MOCInterpreter.h"


int main(int argc, const char * argv[]) {
    @autoreleasepool {
		MOCInterpreter *interpreter = [[MOCInterpreter alloc] init];
        [interpreter run];
    }
    return 0;
}

