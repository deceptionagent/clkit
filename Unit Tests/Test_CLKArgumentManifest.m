//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CLKArgumentManifest.h"
#import "CLKArgumentManifest_Private.h"
#import "CLKOption.h"
#import "CLKOptionRegistry.h"


NS_ASSUME_NONNULL_BEGIN

@interface Test_CLKArgumentManifest : XCTestCase

- (CLKArgumentManifest *)manifestWithRegisteredOptions:(NSArray<CLKOption *> *)options;

@end

NS_ASSUME_NONNULL_END

@implementation Test_CLKArgumentManifest

- (CLKArgumentManifest *)manifestWithRegisteredOptions:(NSArray<CLKOption *> *)options
{
    CLKOptionRegistry *registry = [CLKOptionRegistry registryWithOptions:options];
    return [[[CLKArgumentManifest alloc] initWithOptionRegistry:registry] autorelease];
}

- (void)testSwitchOptions
{
    CLKOption *flarn = [CLKOption optionWithName:@"flarn" flag:nil];
    CLKOption *barf = [CLKOption optionWithName:@"barf" flag:@"b"];
    CLKOption *parameterOption = [CLKOption parameterOptionWithName:@"parameter" flag:@"p"];
    CLKArgumentManifest *manifest = [self manifestWithRegisteredOptions:@[ barf, flarn, parameterOption ]];
    
    // parameter options and positional arguments should not affect switch options
    [manifest accumulateArgument:@"foo" forParameterOptionNamed:parameterOption.name];
    [manifest accumulatePositionalArgument:@"barf"];
    
    XCTAssertNil(manifest[@"flarn"]);
    
    [manifest accumulateSwitchOptionNamed:flarn.name];
    XCTAssertEqualObjects(manifest[@"flarn"], @(1));
    XCTAssertNil(manifest[@"barf"]);
    
    [manifest accumulateSwitchOptionNamed:flarn.name];
    [manifest accumulateSwitchOptionNamed:barf.name];
    XCTAssertEqualObjects(manifest[@"flarn"], @(2));
    XCTAssertEqualObjects(manifest[@"barf"], @(1));
    
    // it's reasonable to query the manifest for an unregistered option.
    // this makes it easier to write tools with varying configurations, special factoring, etc.
    XCTAssertNil(manifest[@"xyzzy"]);
}

- (void)testParameterOptions
{
    CLKOption *switchOption = [CLKOption optionWithName:@"switch" flag:@"f"];
    CLKOption *lorem = [CLKOption parameterOptionWithName:@"lorem" flag:@"l" required:NO recurrent:YES dependencies:nil transformer:nil];
    CLKOption *ipsum = [CLKOption parameterOptionWithName:@"ipsum" flag:@"i" required:NO recurrent:YES dependencies:nil transformer:nil];
    CLKOption *solo = [CLKOption parameterOptionWithName:@"solo" flag:@"s" required:NO recurrent:YES dependencies:nil transformer:nil];
    CLKOption *oneshot = [CLKOption parameterOptionWithName:@"oneshot" flag:nil];
    CLKOption *never = [CLKOption parameterOptionWithName:@"never" flag:nil];
    CLKArgumentManifest *manifest = [self manifestWithRegisteredOptions:@[ switchOption, lorem, ipsum, solo, oneshot, never ]];
    
    // switch options and positional arguments should not affect parameter options
    [manifest accumulateSwitchOptionNamed:switchOption.name];
    [manifest accumulatePositionalArgument:@"positional"];
    
    XCTAssertNil(manifest[@"lorem"]);
    XCTAssertNil(manifest[@"never"]);
    
    [manifest accumulateArgument:@"alpha" forParameterOptionNamed:lorem.name];
    [manifest accumulateArgument:@"bravo" forParameterOptionNamed:lorem.name];
    [manifest accumulateArgument:@"echo" forParameterOptionNamed:ipsum.name];
    [manifest accumulateArgument:@"echo" forParameterOptionNamed:ipsum.name];
    [manifest accumulateArgument:@"foxtrot" forParameterOptionNamed:solo.name];
    [manifest accumulateArgument:@"bang" forParameterOptionNamed:oneshot.name];
    XCTAssertEqualObjects(manifest[@"lorem"], (@[ @"alpha", @"bravo" ]));
    XCTAssertEqualObjects(manifest[@"ipsum"], (@[ @"echo", @"echo" ]));
    XCTAssertEqualObjects(manifest[@"solo"], @[ @"foxtrot" ]);
    XCTAssertEqualObjects(manifest[@"oneshot"], @"bang");
    XCTAssertNil(manifest[@"never"]);
    
    // it's reasonable to query the manifest for an unregistered option.
    // this makes it easier to write tools with varying configurations, special factoring, etc.
    XCTAssertNil(manifest[@"xyzzy"]);
}

- (void)testPositionalArguments
{
    CLKOption *parameterOption = [CLKOption parameterOptionWithName:@"parameter" flag:@"p"];
    CLKOption *switchOption = [CLKOption optionWithName:@"switch" flag:@"f"];
    CLKOptionRegistry *registry = [CLKOptionRegistry registryWithOptions:@[ parameterOption, switchOption ]];
    CLKArgumentManifest *manifest = [[[CLKArgumentManifest alloc] initWithOptionRegistry:registry] autorelease];
    
    // switch options and parameter options should not affect positional arguments
    [manifest accumulateArgument:@"flarn" forParameterOptionNamed:parameterOption.name];
    [manifest accumulateSwitchOptionNamed:switchOption.name];
    
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
    NSArray *options = @[ parameterOptionAlpha, parameterOptionBravo, switchOptionAlpha, switchOptionBravo ];
    CLKOptionRegistry *registry = [CLKOptionRegistry registryWithOptions:options];
    CLKArgumentManifest *manifest = [[[CLKArgumentManifest alloc] initWithOptionRegistry:registry] autorelease];
    
    XCTAssertFalse([manifest hasOptionNamed:parameterOptionAlpha.name]);
    XCTAssertFalse([manifest hasOptionNamed:switchOptionAlpha.name]);
    
    [manifest accumulateArgument:@"flarn" forParameterOptionNamed:parameterOptionAlpha.name];
    [manifest accumulateSwitchOptionNamed:switchOptionAlpha.name];
    
    XCTAssertTrue([manifest hasOptionNamed:parameterOptionAlpha.name]);
    XCTAssertFalse([manifest hasOptionNamed:parameterOptionBravo.name]);
    XCTAssertTrue([manifest hasOptionNamed:switchOptionAlpha.name]);
    XCTAssertFalse([manifest hasOptionNamed:switchOptionBravo.name]);
}

- (void)test_occurrencesOfOption
{
    CLKOption *parameterOptionAlpha = [CLKOption parameterOptionWithName:@"parameterAlpha" flag:@"p"];
    CLKOption *parameterOptionBravo = [CLKOption parameterOptionWithName:@"parameterBravo" flag:@"a"];
    CLKOption *switchOptionAlpha = [CLKOption optionWithName:@"switchAlpha" flag:@"f"];
    CLKOption *switchOptionBravo = [CLKOption optionWithName:@"switchBravo" flag:@"r"];
    NSArray *options = @[ parameterOptionAlpha, parameterOptionBravo, switchOptionAlpha, switchOptionBravo ];
    CLKOptionRegistry *registry = [CLKOptionRegistry registryWithOptions:options];
    CLKArgumentManifest *manifest = [[[CLKArgumentManifest alloc] initWithOptionRegistry:registry] autorelease];
    
    XCTAssertEqual([manifest occurrencesOfOptionNamed:parameterOptionAlpha.name], 0UL);
    XCTAssertEqual([manifest occurrencesOfOptionNamed:switchOptionAlpha.name], 0UL);
    
    [manifest accumulateArgument:@"flarn" forParameterOptionNamed:parameterOptionAlpha.name];
    [manifest accumulateArgument:@"flarn" forParameterOptionNamed:parameterOptionAlpha.name];
    [manifest accumulateSwitchOptionNamed:switchOptionAlpha.name];
    [manifest accumulateSwitchOptionNamed:switchOptionAlpha.name];
    [manifest accumulateSwitchOptionNamed:switchOptionAlpha.name];
    
    XCTAssertEqual([manifest occurrencesOfOptionNamed:parameterOptionAlpha.name], 2UL);
    XCTAssertEqual([manifest occurrencesOfOptionNamed:parameterOptionBravo.name], 0UL);
    XCTAssertEqual([manifest occurrencesOfOptionNamed:switchOptionAlpha.name], 3UL);
    XCTAssertEqual([manifest occurrencesOfOptionNamed:switchOptionBravo.name], 0UL);
}

@end
