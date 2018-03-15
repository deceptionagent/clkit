//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CEVariantTag.h"


@interface Test_CEVariantTag : XCTestCase

@end


@implementation Test_CEVariantTag

- (void)testInit
{
    CEVariantTag *tag = [CEVariantTag tag];
    XCTAssertNotNil(tag);
}

- (void)testCopying
{
    CEVariantTag *alpha = [CEVariantTag tag];
    CEVariantTag *bravo = [[alpha copy] autorelease];
    XCTAssertEqual(alpha, bravo); // CEVariantTag is immutable; -copy should return the receiver retained
}

- (void)testEquality
{
    CEVariantTag *alpha = [CEVariantTag tag];
    CEVariantTag *bravo = [CEVariantTag tag];
    XCTAssertEqualObjects(alpha, alpha);
    XCTAssertTrue([alpha isEqualToVariantTag:alpha]);
    
    XCTAssertNotEqualObjects(alpha, bravo);
    XCTAssertFalse([alpha isEqualToVariantTag:bravo]);
    
    XCTAssertEqual(alpha.hash, alpha.hash);
    XCTAssertNotEqual(alpha.hash, bravo.hash);
}

- (void)testCollectionSupport_dictionaryKey
{
    CEVariantTag *alpha = [CEVariantTag tag];
    CEVariantTag *bravo = [CEVariantTag tag];
    NSDictionary *dict = @{
        alpha : @"flarn",
        bravo : @"barf"
    };
    
    XCTAssertEqualObjects(dict[alpha], @"flarn");
    XCTAssertEqualObjects(dict[bravo], @"barf");
}

- (void)testComparison
{
    CEVariantTag *alpha = [CEVariantTag tag];
    CEVariantTag *bravo = [CEVariantTag tag];
    
    XCTAssertEqual([alpha compare:alpha], NSOrderedSame);
    XCTAssertEqual([alpha compare:bravo], NSOrderedAscending);
    XCTAssertEqual([bravo compare:alpha], NSOrderedDescending);
}

@end
