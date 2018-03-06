//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CEVariant.h"
#import "CEVariantSource.h"
#import "CEVariantTag.h"


@interface Test_CEVariant : XCTestCase <CEVariantSourceDelegate>

@end


@implementation Test_CEVariant

#pragma mark <CEVariantSourceDelegate>

- (void)variantSourceDidAdvanceToInitialValue:(__unused CEVariantSource *)source
{
    // protocol compliance only
}

#pragma mark -

- (void)testInit
{
    CEVariantTag *tag = [CEVariantTag tag];
    CEVariantSource *source = [[[CEVariantSource alloc] initWithIdentifier:@"flarn" values:@[ @"barf" ] delegate:self] autorelease];
    CEVariant *variant = [[[CEVariant alloc] initWithTag:tag rootSource:source] autorelease];
    XCTAssertNotNil(variant);
    XCTAssertEqualObjects(variant.sources, [NSSet setWithObject: source]);
}

- (void)testVariantSourceToolbox
{
    CEVariantTag *tag = [CEVariantTag tag];
    CEVariantSource *alpha = [[[CEVariantSource alloc] initWithIdentifier:@"alpha" values:@[ @"barf" ] delegate:self] autorelease];
    CEVariantSource *bravo = [[[CEVariantSource alloc] initWithIdentifier:@"bravo" values:@[ @"barf" ] delegate:self] autorelease];
    CEVariantSource *charlie = [[[CEVariantSource alloc] initWithIdentifier:@"charlie" values:@[ @"barf" ] delegate:self] autorelease];
    
    CEVariant *variant = [[[CEVariant alloc] initWithTag:tag rootSource:alpha] autorelease];
    XCTAssertNil([variant sourceSuperiorToSource:alpha]);
    
    [variant addSource:bravo superiorToSource:alpha];
    XCTAssertEqual([variant sourceSuperiorToSource:alpha], bravo);
    XCTAssertNil([variant sourceSuperiorToSource:bravo]);
    
    [variant addSource:charlie superiorToSource:bravo];
    XCTAssertEqual([variant sourceSuperiorToSource:alpha], bravo);
    XCTAssertEqual([variant sourceSuperiorToSource:bravo], charlie);
    XCTAssertNil([variant sourceSuperiorToSource:charlie]);
    
    XCTAssertEqualObjects(variant.sources, ([NSSet setWithArray:@[ alpha, bravo, charlie]]));
}

@end
