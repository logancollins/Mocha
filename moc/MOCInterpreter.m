//
//  MOCInterpreter.m
//  Mocha
//
//  Created by Logan Collins on 5/12/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import "MOCInterpreter.h"

#import <JavaScriptCore/JavaScriptCore.h>

#import <Mocha/MochaRuntime_Private.h>

#import <stdio.h>
#import <stdlib.h>
#import <string.h>
#import <readline/readline.h>
#import <readline/history.h>


static const char interactivePrompt[] = "> ";


@interface MOCInterpreter ()

- (void)installBuiltins;

@end


@implementation MOCInterpreter

- (void)installBuiltins {
    Mocha *runtime = [Mocha sharedRuntime];
    
    MOMethod *gc = [MOMethod methodWithTarget:runtime selector:@selector(garbageCollect)];
    [runtime setValue:gc forKey:@"gc"];
    
    MOMethod *checkSyntax = [MOMethod methodWithTarget:runtime selector:@selector(isSyntaxValidForString:)];
    [runtime setValue:checkSyntax forKey:@"checkSyntax"];
    
    MOMethod *exit = [MOMethod methodWithTarget:self selector:@selector(exit)];
    [runtime setValue:exit forKey:@"exit"];
}

- (void)run {
    Mocha *runtime = [Mocha sharedRuntime];
    [runtime setDelegate:self];
    
    [self installBuiltins];
    
    while (1) {
        char *line = readline(interactivePrompt);
        if (line == NULL) {
            break;
        }
        if (line[0]) {
            add_history(line);
        }
        
        NSString *string = [NSString stringWithCString:(const char *)line encoding:NSUTF8StringEncoding];
        
        if ([string length] > 0) {
            @try {
                JSValueRef value = [runtime evalJSString:string];
                if (value != NULL) {
                    JSStringRef string = JSValueToStringCopy([runtime context], value, NULL);
                    NSString *description = [(NSString *)JSStringCopyCFString(NULL, string) autorelease];
                    JSStringRelease(string);
                    printf("%s\n", [description UTF8String]);
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
    }
}

- (void)exit {
    exit(0);
}

@end
