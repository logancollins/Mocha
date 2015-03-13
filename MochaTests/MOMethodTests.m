//
//  MOMethodTests.m
//  Mocha
//
//  Created by Adam Fedor on 2/19/15.
//  Copyright (c) 2015 Sunflower Softworks. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "MOMethod.h"

@interface MOMethodTests : XCTestCase

@end

@implementation MOMethodTests

- (void)setUp {
  [super setUp];
}

- (void)tearDown {
  [super tearDown];
}

- (void)testInitWithTargetSelector_ShouldSetupObject {
  NSString *target = @"Hello";
  MOMethod *momethod = [MOMethod methodWithTarget: target selector: @selector(length)];
  
  XCTAssertEqual(momethod.target, target, @"Target not equal");
  XCTAssertEqual(momethod.selector, @selector(length), @"Selectors not equal");
}

@end
