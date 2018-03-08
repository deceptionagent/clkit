//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CEVariantSource.h"


@interface Test_CEVariantSource : XCTestCase <CEVariantSourceObserver>

@end


@implementation Test_CEVariantSource
{
    BOOL _receivedDidAdvanceToInitialValue;
}

#pragma mark <CEVariantSourceObserver>

- (void)variantSourceDidAdvanceToInitialValue:(CEVariantSource *)source
{
    XCTAssertNotNil(source);
    XCTAssertNotNil(source.identifier);
    _receivedDidAdvanceToInitialValue = YES;
}

#pragma mark -

- (void)testInit
{
    CEVariantSource *source = [[[CEVariantSource alloc] initWithIdentifier:@"barf" values:@[ @"flarn" ]] autorelease];
    XCTAssertNotNil(source);
    XCTAssertEqualObjects(source.identifier, @"barf");
    XCTAssertEqualObjects(source.currentValue, @"flarn");
    
    source = [[[CEVariantSource alloc] initWithIdentifier:@"quone" values:@[ @"flarn", @"barf" ]] autorelease];
    XCTAssertNotNil(source);
    XCTAssertEqualObjects(source.identifier, @"quone");
    XCTAssertEqualObjects(source.currentValue, @"flarn");
    
    XCTAssertThrows([[[CEVariantSource alloc] initWithIdentifier:@"flarn" values:@[]] autorelease]);
    XCTAssertThrows([[[CEVariantSource alloc] initWithIdentifier:@"" values:@[ @"barf" ]] autorelease]);
}

- (void)test_variantSourceDidAdvanceToInitialPosition
{
    CEVariantSource *source = [[[CEVariantSource alloc] initWithIdentifier:@"xyzzy" values:@[ @"flarn", @"barf", @"quone" ]] autorelease];
    [source addObserver:self];
    
    XCTAssertEqualObjects(source.currentValue, @"flarn");
    XCTAssertFalse(_receivedDidAdvanceToInitialValue);
    for (int i = 0 ; i < 2 ; i++) {
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
    CEVariantSource *source = [[[CEVariantSource alloc] initWithIdentifier:@"xyzzy" values:@[ @"flarn" ]] autorelease];
    [source addObserver:self];
    
    XCTAssertEqualObjects(source.currentValue, @"flarn");
    XCTAssertFalse(_receivedDidAdvanceToInitialValue);
    for (int i = 0 ; i < 2 ; i++) {
        [source advanceToNextValue];
        XCTAssertEqualObjects(source.currentValue, @"flarn");
        XCTAssertTrue(_receivedDidAdvanceToInitialValue);
        _receivedDidAdvanceToInitialValue = NO;
    }
}

- (void)testRemoveObserver
{
    CEVariantSource *source = [[[CEVariantSource alloc] initWithIdentifier:@"xyzzy" values:@[ @"flarn" ]] autorelease];
    [source addObserver:self];
    [source removeObserver:self];
    
    [source advanceToNextValue];
    XCTAssertFalse(_receivedDidAdvanceToInitialValue);
    
    // safe to do when the parameter is not an observer
    [source removeObserver:self];
}

@end
