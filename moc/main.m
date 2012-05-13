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
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    MOCInterpreter *interpreter = [[MOCInterpreter alloc] init];
    [interpreter run];
    
    [interpreter release];
    
    [pool drain];
    
    return 0;
}

