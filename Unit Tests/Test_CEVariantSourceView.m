//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CEVariantSource.h"
#import "CEVariantSourceView.h"


@interface Test_CEVariantSourceView : XCTestCase <CEVariantSourceViewObserver>
{
    CEVariantSourceView *_callbackSourceView;
}

@end

@implementation Test_CEVariantSourceView

#pragma mark <CEVariantSourceViewObserver>

- (void)variantSourceViewDidAdvanceToInitialValue:(CEVariantSourceView *)sourceView
{
    _callbackSourceView = sourceView;
}

#pragma mark -

- (void)testInit
{
    CEVariantSource *flarn = [[CEVariantSource alloc] initWithIdentifier:@"flarn" values:@[ @"barf" ]];
    CEVariantSource *quone = [[CEVariantSource alloc] initWithIdentifier:@"flarn" values:@[ @"confound", @"delivery" ]];
    
    CEVariantSourceView *view = [[CEVariantSourceView alloc] initWithVariantSource:flarn];
    XCTAssertNotNil(view);
    XCTAssertEqual(view.variantSource, flarn);
    XCTAssertEqualObjects(view.value, @"barf");
    
    view = [[CEVariantSourceView alloc] initWithVariantSource:quone];
    XCTAssertNotNil(view);
    XCTAssertEqual(view.variantSource, quone);
    XCTAssertEqualObjects(view.value, @"confound");
}

- (void)testAdvancing
{
    CEVariantSource *source = [[CEVariantSource alloc] initWithIdentifier:@"xyzzy" values:@[ @"flarn", @"barf", @"quone" ]];
    CEVariantSourceView *view = [[CEVariantSourceView alloc] initWithVariantSource:source];
    [view addObserver:self];
    
    XCTAssertEqualObjects(view.value, @"flarn");
    XCTAssertNil(_callbackSourceView);
    for (int i = 0 ; i < 2 ; i++) {
        [view advance];
        XCTAssertEqualObjects(view.value, @"barf");
        XCTAssertNil(_callbackSourceView);
        
        [view advance];
        XCTAssertEqualObjects(view.value, @"quone");
        XCTAssertNil(_callbackSourceView);
        
        [view advance];
        XCTAssertEqualObjects(view.value, @"flarn");
        XCTAssertEqual(_callbackSourceView, view);
        _callbackSourceView = nil;
    }
}

- (void)testAdvancing_singleValue
{
    CEVariantSource *source = [[CEVariantSource alloc] initWithIdentifier:@"xyzzy" values:@[ @"flarn" ]];
    CEVariantSourceView *view = [[CEVariantSourceView alloc] initWithVariantSource:source];
    [view addObserver:self];
    
    XCTAssertEqualObjects(view.value, @"flarn");
    XCTAssertNil(_callbackSourceView);
    for (int i = 0 ; i < 2 ; i++) {
        [view advance];
        XCTAssertEqualObjects(view.value, @"flarn");
        XCTAssertEqual(_callbackSourceView, view);
        _callbackSourceView = nil;
    }
}

- (void)testRemoveObserver
{
    CEVariantSource *source = [[CEVariantSource alloc] initWithIdentifier:@"flarn" values:@[ @"barf" ]];
    CEVariantSourceView *view = [[CEVariantSourceView alloc] initWithVariantSource:source];
    [view addObserver:self];
    [view removeObserver:self];
    
    XCTAssertNil(_callbackSourceView);
    [view advance];
    XCTAssertNil(_callbackSourceView);
    
    // safe to do when the parameter is not an observer
    [view removeObserver:self];
}

@end
