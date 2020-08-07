//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CLKAssert.h"

@interface Test_CLKAssert : XCTestCase

@end

@implementation Test_CLKAssert

- (void)testCLKHardAssert
{
    XCTAssertNoThrow(CLKHardAssert((1 == 1), @"FooError", @"lorem %@", @"ipsum"));
    XCTAssertThrowsSpecificNamed((CLKHardAssert(1 == 2, @"FooError", @"lorem %@", @"ipsum")), NSException, @"FooError");
    XCTAssertThrowsSpecificNamed((CLKHardAssert((1 == 2), @"FooError", @"lorem %@", @"ipsum")), NSException, @"FooError");
    XCTAssertThrowsSpecificNamed((CLKHardAssert((1 == 2), @"FooError", @"lorem")), NSException, @"FooError");
}

- (void)testCLKHardParameterAssert
{
    XCTAssertNoThrow(CLKHardParameterAssert((1 == 1)));
    XCTAssertThrowsSpecificNamed(CLKHardParameterAssert(1 == 2), NSException, NSInvalidArgumentException);
    XCTAssertThrowsSpecificNamed(CLKHardParameterAssert((1 == 2)), NSException, NSInvalidArgumentException);
    XCTAssertThrowsSpecificNamed(CLKHardParameterAssert(1 == 2, @"you can't do this"), NSException, NSInvalidArgumentException);
    XCTAssertThrowsSpecificNamed(CLKHardParameterAssert(1 == 2, @"you can't do this -- %@", @"because reasons"), NSException, NSInvalidArgumentException);
}

@end
