//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CEVariant.h"
#import "CEVariantSource.h"
#import "CEVariantTag.h"


@interface Test_CEVariant : XCTestCase

@end


@implementation Test_CEVariant

- (void)testInit
{
    CEVariantSource *flarn = [[[CEVariantSource alloc] initWithIdentifier:@"flarn" values:@[ @"barf" ]] autorelease];
    CEVariantSource *quone = [[[CEVariantSource alloc] initWithIdentifier:@"flarn" values:@[ @"xyzzy" ]] autorelease];

    CEVariant *variant = [[[CEVariant alloc] initWithTag:@"tag" sources:@[ flarn ]] autorelease];
    XCTAssertNotNil(variant);
    XCTAssertEqualObjects(variant.sources, @[ flarn ]);
    
    variant = [[[CEVariant alloc] initWithTag:@"tag" sources:@[ flarn, quone ]] autorelease];
    XCTAssertNotNil(variant);
    XCTAssertEqualObjects(variant.sources, (@[ flarn, quone ]));
    
    variant = [CEVariant variantWithTag:@"tag" sources:@[ flarn, quone]];
    XCTAssertNotNil(variant);
    XCTAssertEqualObjects(variant.sources, (@[ flarn, quone ]));
    
    XCTAssertThrows([[[CEVariant alloc] initWithTag:@"tag" sources:@[]] autorelease]);
}

@end
