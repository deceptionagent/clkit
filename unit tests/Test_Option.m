//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "ArgumentTransformer.h"
#import "Option.h"


@interface OptionTests : XCTestCase

@end


@implementation OptionTests

- (void)testInitOption
{
    Option *option = [Option optionWithLongName:@"flarn" shortName:@"f"];
    XCTAssertNotNil(option);
    XCTAssertEqualObjects(option.longName, @"flarn");
    XCTAssertEqualObjects(option.shortName, @"f");
    XCTAssertNil(option.transformer);
    XCTAssertTrue(option.hasArgument);

    option = [Option optionWithLongName:@"flarn" shortName:@"f" transformer:nil];
    XCTAssertNotNil(option);
    XCTAssertNil(option.transformer);
    
    ArgumentTransformer *transformer = [ArgumentTransformer transformer];
    option = [Option optionWithLongName:@"flarn" shortName:@"f" transformer:transformer];
    XCTAssertNotNil(option);
    XCTAssertNotNil(option.transformer);
    XCTAssertEqual(option.transformer, transformer);
    
    XCTAssertThrows([Option optionWithLongName:@"--flarn" shortName:@"f"]);
    XCTAssertThrows([Option optionWithLongName:@"flarn" shortName:@"-f"]);
    
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

- (void)testInitFreeOption
{
    Option *option = [Option freeOptionWithLongName:@"flarn" shortName:@"f"];
    XCTAssertNotNil(option);
    XCTAssertEqualObjects(option.longName, @"flarn");
    XCTAssertEqualObjects(option.shortName, @"f");
    XCTAssertNil(option.transformer);
    XCTAssertFalse(option.hasArgument);

    XCTAssertThrows([Option freeOptionWithLongName:@"--flarn" shortName:@"f"]);
    XCTAssertThrows([Option freeOptionWithLongName:@"flarn" shortName:@"-f"]);
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    XCTAssertThrows([Option freeOptionWithLongName:nil shortName:nil]);
    XCTAssertThrows([Option freeOptionWithLongName:nil shortName:@"x"]);
    XCTAssertThrows([Option freeOptionWithLongName:@"" shortName:@"x"]);
    XCTAssertThrows([Option freeOptionWithLongName:@"flarn" shortName:nil]);
    XCTAssertThrows([Option freeOptionWithLongName:@"flarn" shortName:@""]);
    XCTAssertThrows([Option freeOptionWithLongName:@"flarn" shortName:@"xx"]);
#pragma clang diagnostic pop
}

@end
