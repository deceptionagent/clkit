//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CLKArgumentTransformer.h"
#import "CLKOption.h"


@interface Test_CLKOption : XCTestCase

@end


@implementation Test_CLKOption

- (void)testInitOption
{
    CLKOption *option = [CLKOption optionWithLongName:@"flarn" shortName:@"f"];
    XCTAssertNotNil(option);
    XCTAssertEqualObjects(option.longName, @"flarn");
    XCTAssertEqualObjects(option.shortName, @"f");
    XCTAssertNil(option.transformer);
    XCTAssertTrue(option.expectsArgument);

    option = [CLKOption optionWithLongName:@"flarn" shortName:@"f" transformer:nil];
    XCTAssertNotNil(option);
    XCTAssertNil(option.transformer);
    
    CLKArgumentTransformer *transformer = [CLKArgumentTransformer transformer];
    option = [CLKOption optionWithLongName:@"flarn" shortName:@"f" transformer:transformer];
    XCTAssertNotNil(option);
    XCTAssertNotNil(option.transformer);
    XCTAssertEqual(option.transformer, transformer);
    
    XCTAssertThrows([CLKOption optionWithLongName:@"--flarn" shortName:@"f"]);
    XCTAssertThrows([CLKOption optionWithLongName:@"flarn" shortName:@"-f"]);
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    XCTAssertThrows([CLKOption optionWithLongName:nil shortName:nil]);
    XCTAssertThrows([CLKOption optionWithLongName:nil shortName:@"x"]);
    XCTAssertThrows([CLKOption optionWithLongName:@"" shortName:@"x"]);
    XCTAssertThrows([CLKOption optionWithLongName:@"flarn" shortName:nil]);
    XCTAssertThrows([CLKOption optionWithLongName:@"flarn" shortName:@""]);
    XCTAssertThrows([CLKOption optionWithLongName:@"flarn" shortName:@"xx"]);
#pragma clang diagnostic pop
}

- (void)testInitFreeOption
{
    CLKOption *option = [CLKOption freeOptionWithLongName:@"flarn" shortName:@"f"];
    XCTAssertNotNil(option);
    XCTAssertEqualObjects(option.longName, @"flarn");
    XCTAssertEqualObjects(option.shortName, @"f");
    XCTAssertNil(option.transformer);
    XCTAssertFalse(option.expectsArgument);

    XCTAssertThrows([CLKOption freeOptionWithLongName:@"--flarn" shortName:@"f"]);
    XCTAssertThrows([CLKOption freeOptionWithLongName:@"flarn" shortName:@"-f"]);
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    XCTAssertThrows([CLKOption freeOptionWithLongName:nil shortName:nil]);
    XCTAssertThrows([CLKOption freeOptionWithLongName:nil shortName:@"x"]);
    XCTAssertThrows([CLKOption freeOptionWithLongName:@"" shortName:@"x"]);
    XCTAssertThrows([CLKOption freeOptionWithLongName:@"flarn" shortName:nil]);
    XCTAssertThrows([CLKOption freeOptionWithLongName:@"flarn" shortName:@""]);
    XCTAssertThrows([CLKOption freeOptionWithLongName:@"flarn" shortName:@"xx"]);
#pragma clang diagnostic pop
}

- (void)testEquality
{
    CLKOption *alphaA = [CLKOption optionWithLongName:@"alpha" shortName:@"a"];
    CLKOption *alphaB = [CLKOption optionWithLongName:@"alpha" shortName:@"a"];
    CLKOption *alphaC = [CLKOption optionWithLongName:@"alpha" shortName:@"c"];
    CLKOption *bravo = [CLKOption optionWithLongName:@"bravo" shortName:@"a"];

    XCTAssertTrue([alphaA isEqual:alphaA]);
    XCTAssertTrue([alphaA isEqual:alphaB]);
    XCTAssertTrue([alphaA isEqual:alphaC]);
    XCTAssertFalse([alphaA isEqual:bravo]);
}

@end
