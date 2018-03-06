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
    CEVariantTag *tag = [CEVariantTag tag];
    CECombination *combination = [[[CECombination alloc] initWithCombinationDictionary:@{ @"flarn" : @"barf" } tag:tag] autorelease];
    XCTAssertNotNil(combination);
    XCTAssertEqualObjects(combination.tag, tag);
}

- (void)testSubscripting
{
    CEVariantTag *tag = [CEVariantTag tag];
    NSDictionary *dict = @{
        @"flarn" : @"barf",
        @"confound" : @"delivery"
    };
    
    CECombination *combination = [[[CECombination alloc] initWithCombinationDictionary:dict tag:tag] autorelease];
    XCTAssertEqualObjects(combination[@"flarn"], @"barf");
    XCTAssertEqualObjects(combination[@"confound"], @"delivery");
    XCTAssertThrowsSpecificNamed(combination[@"xyzzy"], NSException, NSInvalidArgumentException);
}

@end
