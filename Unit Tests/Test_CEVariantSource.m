//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CEVariantSource.h"


@interface Test_CEVariantSource : XCTestCase <CEVariantSourceDelegate>

@end


@implementation Test_CEVariantSource
{
    BOOL _receivedDidAdvanceToInitialValue;
}

#pragma mark <CEVariantSourceDelegate>

- (void)variantSourceDidAdvanceToInitialValue:(CEVariantSource *)source
{
    XCTAssertNotNil(source);
    XCTAssertNotNil(source.identifier);
    _receivedDidAdvanceToInitialValue = YES;
}

#pragma mark -

- (void)testInit
{
    CEVariantSource *source = [[[CEVariantSource alloc] initWithIdentifier:@"barf" values:@[ @"flarn" ] delegate:self] autorelease];
    XCTAssertNotNil(source);
    XCTAssertEqualObjects(source.identifier, @"barf");
    XCTAssertEqualObjects(source.currentValue, @"flarn");
    
    source = [[[CEVariantSource alloc] initWithIdentifier:@"quone" values:@[ @"flarn", @"barf" ] delegate:self] autorelease];
    XCTAssertNotNil(source);
    XCTAssertEqualObjects(source.identifier, @"quone");
    XCTAssertEqualObjects(source.currentValue, @"flarn");
    
    XCTAssertThrows([[[CEVariantSource alloc] initWithIdentifier:@"flarn" values:@[] delegate:self] autorelease]);
    XCTAssertThrows([[[CEVariantSource alloc] initWithIdentifier:@"" values:@[ @"barf" ] delegate:self] autorelease]);
}

- (void)test_variantSourceDidAdvanceToInitialPosition
{
    CEVariantSource *source = [[[CEVariantSource alloc] initWithIdentifier:@"xyzzy" values:@[ @"flarn", @"barf", @"quone" ] delegate:self] autorelease];
    XCTAssertEqualObjects(source.currentValue, @"flarn");
    XCTAssertFalse(_receivedDidAdvanceToInitialValue);
    for (int i = 0 ; i < 3 ; i++) {
        [source advanceToNextValue];
        XCTAssertEqualObjects(source.currentValue, @"barf");
        XCTAssertFalse(_receivedDidAdvanceToInitialValue);
        [source advanceToNextValue];
        XCTAssertEqualObjects(source.currentValue, @"quone");
        XCTAssertFalse(_receivedDidAdvanceToInitialValue);
        [source advanceToNextValue];
        XCTAssertEqualObjects(source.currentValue, @"flarn");
        XCTAssertTrue(_receivedDidAdvanceToInitialValue);
        _receivedDidAdvanceToInitialValue = NO;
    }
}

- (void)test_variantSourceDidAdvanceToInitialPosition_singleValue
{
    CEVariantSource *source = [[[CEVariantSource alloc] initWithIdentifier:@"xyzzy" values:@[ @"flarn" ] delegate:self] autorelease];
    XCTAssertEqualObjects(source.currentValue, @"flarn");
    XCTAssertFalse(_receivedDidAdvanceToInitialValue);
    for (int i = 0 ; i < 3 ; i++) {
        [source advanceToNextValue];
        XCTAssertEqualObjects(source.currentValue, @"flarn");
        XCTAssertTrue(_receivedDidAdvanceToInitialValue);
        _receivedDidAdvanceToInitialValue = NO;
    }
}

@end
