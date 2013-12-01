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


static const char interactivePrompt[] = "> ";


@interface MOCInterpreter ()

- (void)installBuiltins;

@end


@implementation MOCInterpreter {
    MORuntime *_runtime;
}

- (void)installBuiltins {
    _runtime = [[MORuntime alloc] init];
    
    MOMethod *gc = [MOMethod methodWithTarget:_runtime selector:@selector(garbageCollect)];
    [_runtime setValue:gc forKey:@"gc"];
    
    MOMethod *checkSyntax = [MOMethod methodWithTarget:_runtime selector:@selector(isSyntaxValidForString:)];
    [_runtime setValue:checkSyntax forKey:@"checkSyntax"];
    
    MOMethod *exit = [MOMethod methodWithTarget:self selector:@selector(exit)];
    [_runtime setValue:exit forKey:@"exit"];
}

- (void)run {
    [self installBuiltins];
    
    char *line = NULL;
    
    while ((line = readline(interactivePrompt))) {
        if (line[0]) {
            add_history(line);
        }
        
        NSString *string = [NSString stringWithCString:(const char *)line encoding:NSUTF8StringEncoding];
        
        if ([string length] > 0) {
            @try {
                JSValueRef value = [_runtime evaluateJSString:string];
                if (value != NULL) {
                    JSStringRef string = JSValueToStringCopy([_runtime context], value, NULL);
                    NSString *description = (NSString *)CFBridgingRelease(JSStringCopyCFString(NULL, string));
                    JSStringRelease(string);
                    printf("%s\n", [description UTF8String]);
                }
                
                // Set the last result as the special variable "_"
                id object = [_runtime objectForJSValue:value];
                if (object != nil) {
                    [_runtime setValue:object forKey:@"_"];
                }
                else {
                    [_runtime setNilValueForKey:@"_"];
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
