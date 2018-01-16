//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CLKArgumentManifest.h"
#import "CLKArgumentManifest_Private.h"
#import "CLKOption.h"


@interface Test_CLKArgumentManifest : XCTestCase

@end


@implementation Test_CLKArgumentManifest

- (void)testSwitchOptions
{
    CLKOption *flarn = [CLKOption optionWithName:@"flarn" flag:nil];
    CLKOption *barf = [CLKOption optionWithName:@"barf" flag:@"b"];
    CLKOption *parameterOption = [CLKOption parameterOptionWithName:@"parameter" flag:@"p"];
    CLKArgumentManifest *manifest = [[[CLKArgumentManifest alloc] init] autorelease];
    
    // parameter options and positional arguments should not affect switch options
    [manifest accumulateArgument:@"foo" forParameterOption:parameterOption];
    [manifest accumulatePositionalArgument:@"barf"];
    
    XCTAssertNil(manifest[@"flarn"]);
    
    [manifest accumulateSwitchOption:flarn];
    XCTAssertEqualObjects(manifest[@"flarn"], @(1));
    XCTAssertNil(manifest[@"barf"]);
    
    [manifest accumulateSwitchOption:flarn];
    [manifest accumulateSwitchOption:barf];
    XCTAssertEqualObjects(manifest[@"flarn"], @(2));
    XCTAssertEqualObjects(manifest[@"barf"], @(1));
}

- (void)testParameterOptions
{
    CLKOption *switchOption = [CLKOption optionWithName:@"switch" flag:@"f"];
    CLKOption *lorem = [CLKOption parameterOptionWithName:@"lorem" flag:@"l" required:NO recurrent:YES transformer:nil dependencies:nil];
    CLKOption *ipsum = [CLKOption parameterOptionWithName:@"ipsum" flag:@"i" required:NO recurrent:YES transformer:nil dependencies:nil];
    CLKOption *solo = [CLKOption parameterOptionWithName:@"solo" flag:@"s" required:NO recurrent:YES transformer:nil dependencies:nil];
    CLKOption *oneshot = [CLKOption parameterOptionWithName:@"oneshot" flag:nil];
    CLKArgumentManifest *manifest = [[[CLKArgumentManifest alloc] init] autorelease];
    
    // switch options and positional arguments should not affect parameter options
    [manifest accumulateSwitchOption:switchOption];
    [manifest accumulatePositionalArgument:@"positional"];
    
    XCTAssertNil(manifest[@"lorem"]);
    
    [manifest accumulateArgument:@"alpha" forParameterOption:lorem];
    [manifest accumulateArgument:@"bravo" forParameterOption:lorem];
    [manifest accumulateArgument:@"echo" forParameterOption:ipsum];
    [manifest accumulateArgument:@"echo" forParameterOption:ipsum];
    [manifest accumulateArgument:@"foxtrot" forParameterOption:solo];
    [manifest accumulateArgument:@"bang" forParameterOption:oneshot];
    XCTAssertEqualObjects(manifest[@"lorem"], (@[ @"alpha", @"bravo" ]));
    XCTAssertEqualObjects(manifest[@"ipsum"], (@[ @"echo", @"echo" ]));
    XCTAssertEqualObjects(manifest[@"solo"], @[ @"foxtrot" ]);
    XCTAssertEqualObjects(manifest[@"oneshot"], @"bang");
    XCTAssertNil(manifest[@"flarn"]);
}

- (void)testPositionalArguments
{
    CLKOption *parameterOption = [CLKOption parameterOptionWithName:@"parameter" flag:@"p"];
    CLKOption *switchOption = [CLKOption optionWithName:@"switch" flag:@"f"];
    CLKArgumentManifest *manifest = [[[CLKArgumentManifest alloc] init] autorelease];
    
    // switch options and parameter options should not affect positional arguments
    [manifest accumulateArgument:@"flarn" forParameterOption:parameterOption];
    [manifest accumulateSwitchOption:switchOption];
    
    XCTAssertEqualObjects(manifest.positionalArguments, @[]);
    
    [manifest accumulatePositionalArgument:@"alpha"];
    [manifest accumulatePositionalArgument:@"bravo"];
    [manifest accumulatePositionalArgument:@"alpha"];
    XCTAssertEqualObjects(manifest.positionalArguments, (@[ @"alpha", @"bravo", @"alpha"]));
}

- (void)test_hasOption
{
    CLKOption *parameterOptionAlpha = [CLKOption parameterOptionWithName:@"parameterAlpha" flag:@"p"];
    CLKOption *parameterOptionBravo = [CLKOption parameterOptionWithName:@"parameterBravo" flag:@"a"];
    CLKOption *switchOptionAlpha = [CLKOption optionWithName:@"switchAlpha" flag:@"f"];
    CLKOption *switchOptionBravo = [CLKOption optionWithName:@"switchBravo" flag:@"r"];
    CLKArgumentManifest *manifest = [[[CLKArgumentManifest alloc] init] autorelease];
    
    XCTAssertFalse([manifest hasOption:parameterOptionAlpha]);
    XCTAssertFalse([manifest hasOptionNamed:parameterOptionAlpha.name]);
    XCTAssertFalse([manifest hasOption:switchOptionAlpha]);
    XCTAssertFalse([manifest hasOptionNamed:switchOptionAlpha.name]);
    
    [manifest accumulateArgument:@"flarn" forParameterOption:parameterOptionAlpha];
    [manifest accumulateSwitchOption:switchOptionAlpha];
    
    XCTAssertTrue([manifest hasOption:parameterOptionAlpha]);
    XCTAssertTrue([manifest hasOptionNamed:parameterOptionAlpha.name]);
    XCTAssertFalse([manifest hasOption:parameterOptionBravo]);
    XCTAssertFalse([manifest hasOptionNamed:parameterOptionBravo.name]);
    XCTAssertTrue([manifest hasOption:switchOptionAlpha]);
    XCTAssertTrue([manifest hasOptionNamed:switchOptionAlpha.name]);
    XCTAssertFalse([manifest hasOption:switchOptionBravo]);
    XCTAssertFalse([manifest hasOptionNamed:switchOptionBravo.name]);
}

- (void)test_occurrencesOfOption
{
    CLKOption *parameterOptionAlpha = [CLKOption parameterOptionWithName:@"parameterAlpha" flag:@"p"];
    CLKOption *parameterOptionBravo = [CLKOption parameterOptionWithName:@"parameterBravo" flag:@"a"];
    CLKOption *switchOptionAlpha = [CLKOption optionWithName:@"switchAlpha" flag:@"f"];
    CLKOption *switchOptionBravo = [CLKOption optionWithName:@"switchBravo" flag:@"r"];
    CLKArgumentManifest *manifest = [[[CLKArgumentManifest alloc] init] autorelease];
    
    XCTAssertEqual([manifest occurrencesOfOption:parameterOptionAlpha], 0);
    XCTAssertEqual([manifest occurrencesOfOptionNamed:parameterOptionAlpha.name], 0);
    XCTAssertEqual([manifest occurrencesOfOption:switchOptionAlpha], 0);
    XCTAssertEqual([manifest occurrencesOfOptionNamed:switchOptionAlpha.name], 0);

    [manifest accumulateArgument:@"flarn" forParameterOption:parameterOptionAlpha];
    [manifest accumulateArgument:@"flarn" forParameterOption:parameterOptionAlpha];
    [manifest accumulateSwitchOption:switchOptionAlpha];
    [manifest accumulateSwitchOption:switchOptionAlpha];
    [manifest accumulateSwitchOption:switchOptionAlpha];

    XCTAssertEqual([manifest occurrencesOfOption:parameterOptionAlpha], 2);
    XCTAssertEqual([manifest occurrencesOfOptionNamed:parameterOptionAlpha.name], 2);
    XCTAssertEqual([manifest occurrencesOfOption:parameterOptionBravo], 0);
    XCTAssertEqual([manifest occurrencesOfOptionNamed:parameterOptionBravo.name], 0);
    XCTAssertEqual([manifest occurrencesOfOption:switchOptionAlpha], 3);
    XCTAssertEqual([manifest occurrencesOfOptionNamed:switchOptionAlpha.name], 3);
    XCTAssertEqual([manifest occurrencesOfOption:switchOptionBravo], 0);
    XCTAssertEqual([manifest occurrencesOfOptionNamed:switchOptionBravo.name], 0);
}

@end
