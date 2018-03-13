//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CEVariantSource.h"


@interface Test_CEVariantSource : XCTestCase

@end


@implementation Test_CEVariantSource

- (void)testInit
{
    CEVariantSource *source = [[[CEVariantSource alloc] initWithIdentifier:@"barf" values:@[ @"flarn" ]] autorelease];
    XCTAssertNotNil(source);
    XCTAssertEqualObjects(source.identifier, @"barf");
    XCTAssertEqualObjects(source.values, @[ @"flarn" ]);
    
    source = [[[CEVariantSource alloc] initWithIdentifier:@"quone" values:@[ @"flarn", @"barf" ]] autorelease];
    XCTAssertNotNil(source);
    XCTAssertEqualObjects(source.identifier, @"quone");
    XCTAssertEqualObjects(source.values, (@[ @"flarn", @"barf" ]));
    
    source = [CEVariantSource sourceWithIdentifier:@"quone" values:@[ @"flarn", @"barf" ]];
    XCTAssertNotNil(source);
    XCTAssertEqualObjects(source.identifier, @"quone");
    XCTAssertEqualObjects(source.values, (@[ @"flarn", @"barf" ]));
    
    XCTAssertThrows([[[CEVariantSource alloc] initWithIdentifier:@"flarn" values:@[]] autorelease]);
    XCTAssertThrows([[[CEVariantSource alloc] initWithIdentifier:@"" values:@[ @"barf" ]] autorelease]);
}

@end
