//
//  MochaTests.m
//  MochaTests
//
//  Created by Adam Fedor on 2/19/15.
//  Copyright (c) 2015 Sunflower Softworks. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "Mocha.h"

@interface MochaTests : XCTestCase

@end

@implementation MochaTests
{
    Mocha *runtime;
    NSURL *testScriptURL;
}

- (void)setUp {
    [super setUp];
    testScriptURL = [[NSBundle bundleForClass: [self class]] URLForResource:@"Tests" withExtension:@""];
    runtime = [[Mocha alloc] init];
}

- (void)tearDown {
    [super tearDown];
}

#pragma mark Simple Scripts
- (void)testCallFunctionWithName_WithSimpleAdd
{
    [runtime evalString: @"function add() { return 1 + 1}"];
    
    id result = [runtime callFunctionWithName: @"add"];
    XCTAssertTrue([result isEqualTo: @(2)], @"Adding doesnt work");
}

- (void)testCallFunctionWithName_WithSimpleAddMultipleTimes
{
    [runtime evalString: @"function add() { return 1 + 1}"];
    
    id result;
    for (NSInteger i = 0; i < 1000; i++) {
        result = [runtime callFunctionWithName: @"add"];
    }
    XCTAssertTrue([result isEqualTo: @(2)], @"Adding multiple doesnt work");
}

- (void)testCallFunctionWithName_WithObjectFunction
{
    [runtime evalString: @"function myfunc() { var dict = NSMutableDictionary.dictionary(); \
     dict.setObject_forKey_(\"foobar\", \"string\"); return 2;}"];
    
    id result = [runtime callFunctionWithName: @"myfunc"];
    XCTAssertTrue([result isEqualTo: @(2)], @"Myfunc doesnt work");
}

- (void)testCallFunctionWithName_WithObjectFunctionMultipleTimes
{
    [runtime evalString: @"function myfunc() { var dict = NSMutableDictionary.dictionary(); \
     dict.setObject_forKey_(\"foobar\", \"string\"); return 2;}"];
    
    id result;
    for (NSInteger i = 0; i < 1000; i++) {
        result = [runtime callFunctionWithName: @"myfunc"];
    }
    XCTAssertTrue([result isEqualTo: @(2)], @"Myfunc multiple doesnt work");
}

- (void)testCallFunctionWithName_WithIdenticalProperties_CanChangeEachPropertySeperately
{
    [runtime evalString: @"function myfunc() { \
     var dict1 = NSMutableDictionary.dictionary(); \
     var dict2 = NSMutableDictionary.dictionary(); \
     dict1.setObject_forKey_(\"foobar\", \"string\"); \
     print(\"dict1 is \" + dict1); \
     print(\"dict2 is \" + dict2); \
     return dict2.count;}"];
    
    id result = [runtime callFunctionWithName: @"myfunc"];
    XCTAssertTrue([result isEqualTo: @(0)], @"Myfunc doesnt work");
}


@end
