//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CLKArgumentTransformer.h"
#import "CLKOption.h"
#import "CLKOption_Private.h"


@interface Test_CLKOption : XCTestCase

@end


@implementation Test_CLKOption

- (void)testInitOption
{
    CLKOption *option = [CLKOption optionWithName:@"flarn" flag:@"f"];
    XCTAssertNotNil(option);
    XCTAssertEqualObjects(option.name, @"flarn");
    XCTAssertEqualObjects(option.flag, @"f");
    XCTAssertNil(option.transformer);
    XCTAssertTrue(option.expectsArgument);

    option = [CLKOption optionWithName:@"flarn" flag:nil];
    XCTAssertNotNil(option);
    XCTAssertEqualObjects(option.name, @"flarn");
    XCTAssertNil(option.flag);
    
    option = [CLKOption optionWithName:@"flarn" flag:@"f" transformer:nil];
    XCTAssertNotNil(option);
    XCTAssertNil(option.transformer);
    
    CLKArgumentTransformer *transformer = [CLKArgumentTransformer transformer];
    option = [CLKOption optionWithName:@"flarn" flag:@"f" transformer:transformer];
    XCTAssertNotNil(option);
    XCTAssertNotNil(option.transformer);
    XCTAssertEqual(option.transformer, transformer);
    
    XCTAssertThrows([CLKOption optionWithName:@"--flarn" flag:@"f"]);
    XCTAssertThrows([CLKOption optionWithName:@"flarn" flag:@"-f"]);
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    XCTAssertThrows([CLKOption optionWithName:nil flag:nil]);
    XCTAssertThrows([CLKOption optionWithName:nil flag:@"x"]);
    XCTAssertThrows([CLKOption optionWithName:@"" flag:@"x"]);
    XCTAssertThrows([CLKOption optionWithName:@"flarn" flag:@""]);
    XCTAssertThrows([CLKOption optionWithName:@"flarn" flag:@"xx"]);
#pragma clang diagnostic pop
}

- (void)testInitFreeOption
{
    CLKOption *option = [CLKOption freeOptionWithName:@"flarn" flag:@"f"];
    XCTAssertNotNil(option);
    XCTAssertEqualObjects(option.name, @"flarn");
    XCTAssertEqualObjects(option.flag, @"f");
    XCTAssertNil(option.transformer);
    XCTAssertFalse(option.expectsArgument);

    option = [CLKOption freeOptionWithName:@"flarn" flag:nil];
    XCTAssertNotNil(option);
    XCTAssertEqualObjects(option.name, @"flarn");
    XCTAssertNil(option.flag);
    
    XCTAssertThrows([CLKOption freeOptionWithName:@"--flarn" flag:@"f"]);
    XCTAssertThrows([CLKOption freeOptionWithName:@"flarn" flag:@"-f"]);
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    XCTAssertThrows([CLKOption freeOptionWithName:nil flag:nil]);
    XCTAssertThrows([CLKOption freeOptionWithName:nil flag:@"x"]);
    XCTAssertThrows([CLKOption freeOptionWithName:@"" flag:@"x"]);
    XCTAssertThrows([CLKOption freeOptionWithName:@"flarn" flag:@""]);
    XCTAssertThrows([CLKOption freeOptionWithName:@"flarn" flag:@"xx"]);
#pragma clang diagnostic pop
}

- (void)testEquality
{
    // flags are just conveniences -- the canoical identifier of an option is its name
    CLKOption *alphaA = [CLKOption optionWithName:@"alpha" flag:@"a"];
    CLKOption *alphaB = [CLKOption optionWithName:@"alpha" flag:@"a"];
    CLKOption *alphaC = [CLKOption optionWithName:@"alpha" flag:@"A"];
    CLKOption *bravo = [CLKOption optionWithName:@"bravo" flag:@"a"];
    
    XCTAssertTrue([alphaA isEqual:alphaA]);
    XCTAssertTrue([alphaA isEqual:alphaB]);
    XCTAssertTrue([alphaA isEqual:alphaC]);
    XCTAssertFalse([alphaA isEqual:bravo]);
}

- (void)testCollectionSupport
{
    // flags are just conveniences -- the full identity of an option is related only to its name
    CLKOption *alphaA = [CLKOption optionWithName:@"alpha" flag:@"a"];
    CLKOption *alphaB = [CLKOption optionWithName:@"alpha" flag:@"a"];
    CLKOption *alphaC = [CLKOption optionWithName:@"alpha" flag:@"A"];
    CLKOption *bravo = [CLKOption optionWithName:@"bravo" flag:@"b"];
    
    NSSet *set = [NSSet setWithObjects:alphaA, alphaB, alphaC, bravo, nil];
    XCTAssertEqual(set.count, 2);
    XCTAssertTrue([set containsObject:alphaA]);
    XCTAssertTrue([set containsObject:bravo]);
    
    int alphaCount = 0;
    for (CLKOption *opt in set.allObjects) {
        if ([opt.name isEqualToString:@"alpha"]) {
            alphaCount++;
        }
    }
    
    XCTAssertEqual(alphaCount, 1, @"expected only one --alpha option, found: %@", set);
}

@end
