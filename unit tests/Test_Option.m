//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "Option.h"


@interface OptionTests : XCTestCase

@end


@implementation OptionTests

- (void)testInit
{
    Option *option = [Option optionWithLongName:@"flarn" shortName:@"f" hasArgument:YES];
    XCTAssertNotNil(option);
    XCTAssertEqualObjects(option.longName, @"flarn");
    XCTAssertEqualObjects(option.shortName, @"f");
    XCTAssertTrue(option.hasArgument);

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    XCTAssertThrows([Option optionWithLongName:nil shortName:nil hasArgument:NO]);
    XCTAssertThrows([Option optionWithLongName:nil shortName:@"x" hasArgument:NO]);
    XCTAssertThrows([Option optionWithLongName:@"" shortName:@"x" hasArgument:NO]);
    XCTAssertThrows([Option optionWithLongName:@"flarn" shortName:nil hasArgument:NO]);
    XCTAssertThrows([Option optionWithLongName:@"flarn" shortName:@"" hasArgument:NO]);
    XCTAssertThrows([Option optionWithLongName:@"flarn" shortName:@"xx" hasArgument:NO]);
#pragma clang diagnostic pop
}

@end
