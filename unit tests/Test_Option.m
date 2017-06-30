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
    Option *option = [Option optionWithLongName:@"flarn" shortName:@"f"];
    XCTAssertNotNil(option);
    XCTAssertEqualObjects(option.longName, @"flarn");
    XCTAssertEqualObjects(option.shortName, @"f");
    XCTAssertTrue(option.hasArgument);

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    XCTAssertThrows([Option optionWithLongName:nil shortName:nil]);
    XCTAssertThrows([Option optionWithLongName:nil shortName:@"x"]);
    XCTAssertThrows([Option optionWithLongName:@"" shortName:@"x"]);
    XCTAssertThrows([Option optionWithLongName:@"flarn" shortName:nil]);
    XCTAssertThrows([Option optionWithLongName:@"flarn" shortName:@""]);
    XCTAssertThrows([Option optionWithLongName:@"flarn" shortName:@"xx"]);
#pragma clang diagnostic pop
}

@end
