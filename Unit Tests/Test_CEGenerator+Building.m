//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CECombination_Private.h"
#import "CombinationEngine.h"


@interface Test_CEGenerator_Building : XCTestCase

@end


@implementation Test_CEGenerator_Building

- (void)testBuildAndRunGenerator
{
    CEVariantTag *tag = [CEVariantTag tag];
    CETemplateSeries *series = [CETemplateSeries seriesWithIdentifier:@"flarn" values:@[ @(420) ] variantTags:@[ tag ]];
    CETemplate *template = [CETemplate templateWithSeries:@[ series ]];
    NSArray *expectedCombinations = @[
        [CECombination combinationWithBacking:@{ @"flarn" : @(420) } tag:tag]
    ];
    
    CEGenerator *generator = [CEGenerator generatorWithTemplate:template];
    XCTAssertNotNil(generator);
    
    __block NSMutableArray *combinations = [NSMutableArray array];
    [generator enumerateCombinations:^(CECombination *combination) {
        [combinations addObject:combination];
    }];
    
    XCTAssertEqualObjects(combinations, expectedCombinations);
}

@end
