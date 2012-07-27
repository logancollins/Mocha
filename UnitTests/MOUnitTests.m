//
//  MOUnitTests.m
//  UnitTests
//
//  Created by Logan Collins on 7/25/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import "MOUnitTests.h"
#import <Mocha/Mocha.h>


@implementation MOUnitTests

- (void)setUp {
    [super setUp];
    
}

- (void)tearDown {
    
    [super tearDown];
}

- (void)testUsingTestScripts {
    NSURL *testScriptURL = [[NSBundle bundleForClass:[MOUnitTests class]] URLForResource:@"Tests" withExtension:@""];
//    NSFileManager *fileManager = [[NSFileManager alloc] init];
//    NSArray *contents = [fileManager contentsOfDirectoryAtURL:testScriptURL includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
    NSArray *contents = @[
        //@"CoreGraphics.js",
        @"MemoryAllocation.js",
    ];
    
    for (NSString *path in contents) {
        NSURL *URL = [testScriptURL URLByAppendingPathComponent:path];
        Mocha *runtime = [[Mocha alloc] init];
        
        NSError *error = nil;
        NSString *testScript = [NSString stringWithContentsOfURL:URL usedEncoding:NULL error:&error];
        
        NSLog(@"Starting test script: %@", [[URL lastPathComponent] stringByDeletingPathExtension]);
        
        STAssertNotNil(testScript, @"Error loading test script: %@", error);
        
        [runtime evalString:testScript];
        
        NSArray *result = [runtime callFunctionWithName:@"main"];
        STAssertTrue([result[0] boolValue], result[1]);
    }
}

@end
