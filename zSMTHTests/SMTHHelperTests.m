//
//  SMTHHelperTests.m
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-3-12.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "SMTHHelper.h"

@interface SMTHHelperTests : XCTestCase
{
    SMTHHelper *helper;
}

@end

@implementation SMTHHelperTests

- (void)setUp {
    [super setUp];
    helper = [SMTHHelper sharedManager];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)testUpdateNetworkStatus {
    [helper updateNetworkStatus];
    XCTAssert([helper nNetworkStatus] == 0, @"Using Wifi network");
}

- (void)testLogin {
    XCTAssert([helper login:@"mozilla" password:@"my.bbs"] == 1, @"Wrong Login");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
