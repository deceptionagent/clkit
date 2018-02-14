//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CLKOption.h"
#import "CLKOptionRegistry.h"


@interface Test_CLKOptionRegistry : XCTestCase

@end


@implementation Test_CLKOptionRegistry

- (void)testInit
{
    CLKOption *flarn = [CLKOption optionWithName:@"flarn" flag:@"f"];
    CLKOption *barf = [CLKOption optionWithName:@"barf" flag:@"b"];
    NSArray *options = @[ flarn, barf ];
    
    XCTAssertNotNil([CLKOptionRegistry registryWithOptions:@[]]);
    XCTAssertNotNil([CLKOptionRegistry registryWithOptions:options]);
    
    XCTAssertNotNil([[[CLKOptionRegistry alloc] initWithOptions:options] autorelease]);
    XCTAssertNotNil([[[CLKOptionRegistry alloc] initWithOptions:@[]] autorelease]);
}

- (void)testOptionCollisionGuard
{
    // name collision: two --ack opt names, different flags
    NSArray *options = @[
         [CLKOption parameterOptionWithName:@"ack" flag:@"a"],
         [CLKOption parameterOptionWithName:@"syn" flag:@"s"],
         [CLKOption optionWithName:@"ack" flag:@"c"],
    ];
    
    XCTAssertThrowsSpecificNamed([[[CLKOptionRegistry alloc] initWithOptions:options] autorelease], NSException, NSInvalidArgumentException);

    // flag collision: two -x opt flags, different names
    options = @[
         [CLKOption parameterOptionWithName:@"xyzzy" flag:@"x"],
         [CLKOption optionWithName:@"spline" flag:@"p"],
         [CLKOption optionWithName:@"xylo" flag:@"x"],
    ];
    
    XCTAssertThrowsSpecificNamed([[[CLKOptionRegistry alloc] initWithOptions:options] autorelease], NSException, NSInvalidArgumentException);
}

- (void)testOptionLookup
{
    CLKOption *flarn = [CLKOption optionWithName:@"flarn" flag:@"f"];
    CLKOption *barf = [CLKOption parameterOptionWithName:@"barf" flag:@"b"];
    NSArray *options = @[ flarn, barf ];
    
    CLKOptionRegistry *registry = [[[CLKOptionRegistry alloc] initWithOptions:options] autorelease];
    XCTAssertEqual([registry optionNamed:@"flarn"], flarn);
    XCTAssertEqual([registry optionNamed:@"barf"], barf);
    XCTAssertEqual([registry optionForFlag:@"f"], flarn);
    XCTAssertEqual([registry optionForFlag:@"b"], barf);
    XCTAssertNil([registry optionNamed:@"xyzzy"]);
    XCTAssertNil([registry optionForFlag:@"x"]);
}

- (void)test_hasOptionNamed
{
    CLKOption *flarn = [CLKOption optionWithName:@"flarn" flag:@"f"];
    CLKOption *barf = [CLKOption parameterOptionWithName:@"barf" flag:@"b"];
    NSArray *options = @[ flarn, barf ];
    
    CLKOptionRegistry *registry = [[[CLKOptionRegistry alloc] initWithOptions:options] autorelease];
    XCTAssertTrue([registry hasOptionNamed:@"flarn"]);
    XCTAssertTrue([registry hasOptionNamed:@"barf"]);
    XCTAssertFalse([registry hasOptionNamed:@"xyzzy"]);
}

@end
