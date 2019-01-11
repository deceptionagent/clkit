//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CECombination_Private.h"
#import "CEVariantTag.h"


@interface Test_CECombination : XCTestCase

@end

@implementation Test_CECombination

- (void)testInit
{
    NSDictionary *backing = @{ @"flarn" : @"barf" };
    
    CECombination *combination = [[CECombination alloc] initWithBacking:backing variant:@"variant"];
    XCTAssertNotNil(combination);
    XCTAssertEqualObjects(combination.variant, @"variant");
    XCTAssertEqualObjects(combination.backing, backing);

    combination = [CECombination combinationWithBacking:backing variant:@"variant"];
    XCTAssertNotNil(combination);
    XCTAssertEqualObjects(combination.variant, @"variant");
    XCTAssertEqualObjects(combination.backing, backing);
}

- (void)testSubscripting
{
    NSDictionary *backing = @{
        @"flarn" : @"barf",
        @"confound" : @"delivery"
    };
    
    CECombination *combination = [[CECombination alloc] initWithBacking:backing variant:@"variant"];
    XCTAssertEqualObjects(combination[@"flarn"], @"barf");
    XCTAssertEqualObjects(combination[@"confound"], @"delivery");
}

- (void)testEquality
{
    NSDictionary *alphaBacking = @{
        @"flarn" : @"barf",
        @"confound" : @"delivery"
    };
    
    NSDictionary *bravoBacking = @{
        @"flarn" : @"barf",
    };
    
    CECombination *alpha_alpha_a = [[CECombination alloc] initWithBacking:alphaBacking variant:@"alpha"];
    CECombination *alpha_alpha_b = [[CECombination alloc] initWithBacking:alphaBacking variant:@"alpha"];
    CECombination *bravo_bravo = [[CECombination alloc] initWithBacking:bravoBacking variant:@"bravo"];
    CECombination *alpha_alpha = [[CECombination alloc] initWithBacking:alphaBacking variant:@"alpha"];
    CECombination *alpha_bravo = [[CECombination alloc] initWithBacking:alphaBacking variant:@"bravo"];
    CECombination *bravo_alpha = [[CECombination alloc] initWithBacking:bravoBacking variant:@"alpha"];
    
    XCTAssertEqualObjects(alpha_alpha_a, alpha_alpha_a);
    XCTAssertEqualObjects(alpha_alpha_a, alpha_alpha_b);
    XCTAssertTrue([alpha_alpha_a isEqualToCombination:alpha_alpha_b]);
    
    XCTAssertNotEqualObjects(alpha_alpha_a, bravo_bravo);
    XCTAssertFalse([alpha_alpha_a isEqualToCombination:bravo_bravo]);
    
    XCTAssertNotEqualObjects(alpha_alpha, alpha_bravo);
    XCTAssertFalse([alpha_alpha isEqualToCombination:alpha_bravo]);
    
    XCTAssertNotEqualObjects(alpha_alpha, bravo_alpha);
    XCTAssertFalse([alpha_alpha isEqualToCombination:bravo_alpha]);
    
    XCTAssertEqual(alpha_alpha_a.hash, alpha_alpha_b.hash);
}

@end
