//
//  MOCInterpreter.m
//  mocha
//
//  Created by Logan Collins on 5/12/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import "MOCInterpreter.h"

#import <JavaScriptCore/JavaScriptCore.h>

#import <Mocha/MORuntime_Private.h>

#import <stdio.h>
#import <stdlib.h>
#import <string.h>
#import <readline/readline.h>
#import <readline/history.h>


static const char interactivePrompt[] = ">>> ";


@implementation MOCInterpreter {
    MORuntime *_runtime;
}

- (instancetype)initWithOptions:(MORuntimeOptions)options {
    self = [super init];
    if (self) {
        _runtime = [[MORuntime alloc] initWithOptions:options];
        
//        MOMethod *gc = [MOMethod methodWithTarget:_runtime selector:@selector(garbageCollect)];
//        [_runtime setGlobalObject:gc withName:@"gc"];
        
        MOMethod *checkSyntax = [MOMethod methodWithTarget:_runtime selector:@selector(isSyntaxValidForString:)];
        [_runtime setGlobalObject:checkSyntax withName:@"checkSyntax"];
        
        MOMethod *exit = [MOMethod methodWithTarget:self selector:@selector(exit)];
        [_runtime setGlobalObject:exit withName:@"exit"];
    }
    return self;
}

- (void)run {
    char *line = NULL;
    
    while ((line = readline(interactivePrompt))) {
        if (line[0]) {
            add_history(line);
        }
        
        NSString *string = [NSString stringWithCString:(const char *)line encoding:NSUTF8StringEncoding];
        
        if ([string length] > 0) {
            @try {
                id object = [_runtime evaluateString:string];
                if (object != nil) {
                    printf("%s\n", [[object description] UTF8String]);
                }
                
                // Set the last result as the special variable "_"
                if (object != nil) {
                    [_runtime setGlobalObject:object withName:@"_"];
                }
                else {
                    [_runtime removeGlobalObjectWithName:@"_"];
                }
            }
            @catch (NSException *e) {
                if ([e userInfo] != nil) {
                    printf("%s: %s\n%s\n", [[e name] UTF8String], [[e reason] UTF8String], [[[e userInfo] description] UTF8String]);
                }
                else {
                    printf("%s: %s\n", [[e name] UTF8String], [[e reason] UTF8String]);
                }
            }
        }
        
        free(line);
    }
}

- (void)exit {
    exit(0);
}

@end
