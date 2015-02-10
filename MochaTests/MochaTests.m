//
//  MochaTests.m
//  MochaTests
//
//  Created by Logan Collins on 12/1/14.
//  Copyright (c) 2014 Sunflower Softworks. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import <Mocha/Mocha.h>


@interface MochaTests : XCTestCase

@end


@implementation MochaTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    NSURL *testScriptURL = [[NSBundle bundleForClass:[MochaTests class]] URLForResource:@"Tests" withExtension:@""];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSArray *contents = [fileManager contentsOfDirectoryAtURL:testScriptURL includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
    
    for (NSURL *fileURL in contents) {
        MORuntime *runtime = [[MORuntime alloc] init];
        
        NSError *error = nil;
        NSString *testScript = [NSString stringWithContentsOfURL:fileURL usedEncoding:NULL error:&error];
        
        NSLog(@"Starting test script: %@", [[fileURL lastPathComponent] stringByDeletingPathExtension]);
        
        XCTAssertNotNil(testScript, @"Error loading test script: %@", error);
        
        [runtime evaluateString:testScript];
        
        id callable = runtime.globalObject[@"main"];
        NSArray *result = [callable callWithArguments:nil];
        
        XCTAssertTrue([result[0] boolValue]);
    }
}

@end
