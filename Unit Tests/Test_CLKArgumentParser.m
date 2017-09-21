//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CLKArgumentManifest.h"
#import "CLKArgumentParser.h"
#import "CLKArgumentTransformer.h"
#import "CLKOption.h"
#import "XCTestCase+CLKAdditions.h"


NS_ASSUME_NONNULL_BEGIN

@interface Test_CLKArgumentParser : XCTestCase

- (void)performTestWithArgv:(NSArray<NSString *> *)argv
                    options:(NSArray<CLKOption *> *)options
        expectedSwitchOptions:(NSDictionary<NSString *, NSNumber *> *)expectedSwitchOptions
    expectedOptionArguments:(NSDictionary<NSString *, NSArray *> *)expectedOptionArguments
expectedPositionalArguments:(NSArray<NSString *> *)expectedPositionalArguments;

@end

NS_ASSUME_NONNULL_END


@implementation Test_CLKArgumentParser

- (void)performTestWithArgv:(NSArray<NSString *> *)argv
                    options:(NSArray<CLKOption *> *)options
        expectedSwitchOptions:(NSDictionary<NSString *, NSNumber *> *)expectedSwitchOptions
    expectedOptionArguments:(NSDictionary<NSString *, NSArray *> *)expectedOptionArguments
expectedPositionalArguments:(NSArray<NSString *> *)expectedPositionalArguments
{
    CLKArgumentParser *parser = [CLKArgumentParser parserWithArgumentVector:argv options:options];
    NSError *error = nil;
    CLKArgumentManifest *manifest = [parser parseArguments:&error];
    XCTAssertNotNil(manifest);
    XCTAssertNil(error);
    XCTAssertEqualObjects(manifest.switchOptions, expectedSwitchOptions);
    XCTAssertEqualObjects(manifest.optionArguments, expectedOptionArguments);
    XCTAssertEqualObjects(manifest.positionalArguments, expectedPositionalArguments);
}

#pragma mark -

- (void)testInit
{
    NSArray *argv = @[ @"--flarn" ];
    NSArray *options = @[
         [CLKOption optionWithName:@"barf" flag:@"b"],
    ];
    
    XCTAssertNotNil([CLKArgumentParser parserWithArgumentVector:argv options:options]);
    XCTAssertNotNil([CLKArgumentParser parserWithArgumentVector:argv options:@[]]);
    XCTAssertNotNil([CLKArgumentParser parserWithArgumentVector:argv options:@[]]);
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    XCTAssertThrows([CLKArgumentParser parserWithArgumentVector:nil options:nil]);
    XCTAssertThrows([CLKArgumentParser parserWithArgumentVector:nil options:options]);
    XCTAssertThrows([CLKArgumentParser parserWithArgumentVector:argv options:nil]);
#pragma clang diagnostic pop
}

- (void)testEmptyArgv
{
    NSArray *options = @[
         [CLKOption parameterOptionWithName:@"foo" flag:@"f"],
    ];
    
    [self performTestWithArgv:@[] options:options expectedSwitchOptions:@{} expectedOptionArguments:@{} expectedPositionalArguments:@[]];
}

- (void)testUnrecognizedOption
{
    NSArray *argv = @[ @"--foo", @"flarn" ];
    NSArray *options = @[
         [CLKOption optionWithName:@"bar" flag:@"b"],
    ];
    
    CLKArgumentParser *parser = [CLKArgumentParser parserWithArgumentVector:argv options:options];
    
    NSError *error = nil;
    CLKArgumentManifest *manifest = [parser parseArguments:&error];
    XCTAssertNil(manifest);
    [self verifyError:error domain:NSPOSIXErrorDomain code:EINVAL description:@"unrecognized option: 'foo'"];
}

- (void)testSwitchOptions
{
    NSArray *argv = @[ @"--foo", @"-f", @"-bfb" ];
    NSArray *options = @[
        [CLKOption optionWithName:@"foo" flag:@"f"],
        [CLKOption optionWithName:@"bar" flag:@"b"]
    ];
    
    NSDictionary *expectedSwitchOptions = @{
        @"foo" : @(3),
        @"bar" : @(2)
    };
    
    [self performTestWithArgv:argv options:options expectedSwitchOptions:expectedSwitchOptions expectedOptionArguments:@{} expectedPositionalArguments:@[]];
}

- (void)testOptionArguments
{
    NSArray *argv = @[ @"--foo", @"alpha", @"-f", @"bravo", @"-b", @"charlie" ];
    NSArray *options = @[
        [CLKOption parameterOptionWithName:@"foo" flag:@"f"],
        [CLKOption parameterOptionWithName:@"bar" flag:@"b"]
    ];
    
    NSDictionary *expectedOptionArguments = @{
        @"foo" : @[ @"alpha", @"bravo" ],
        @"bar" : @[ @"charlie" ]
    };
    
    [self performTestWithArgv:argv options:options expectedSwitchOptions:@{} expectedOptionArguments:expectedOptionArguments expectedPositionalArguments:@[]];
}

- (void)testNoFlag
{
    NSArray *argv = @[ @"--alpha", @"bravo", @"--charlie", @"--charlie" ];
    NSArray *options = @[
        [CLKOption parameterOptionWithName:@"alpha" flag:nil],
        [CLKOption optionWithName:@"charlie" flag:nil]
    ];
    
    NSDictionary *expectedSwitchOptions = @{ @"charlie" : @(2) };
    NSDictionary *expectedOptionArguments = @{ @"alpha" : @[ @"bravo" ] };
    [self performTestWithArgv:argv options:options expectedSwitchOptions:expectedSwitchOptions expectedOptionArguments:expectedOptionArguments expectedPositionalArguments:@[]];
}

// very edge-casey
- (void)testSingleCharacterNames
{
    NSArray *argv = @[ @"--a", @"-a", @"--b", @"-aa" ];
    NSArray *options = @[
        [CLKOption optionWithName:@"a" flag:@"a"],
        [CLKOption optionWithName:@"b" flag:nil]
    ];
    
    NSDictionary *expectedSwitchOptions = @{
        @"a" : @(4),
        @"b" : @(1)
    };
    
    [self performTestWithArgv:argv options:options expectedSwitchOptions:expectedSwitchOptions expectedOptionArguments:@{} expectedPositionalArguments:@[]];
}

- (void)testPositionalArguments
{
    NSArray *argv = @[ @"--foo", @"bar", @"/flarn.txt", @"/bort.txt" ];
    NSArray *options = @[
        [CLKOption parameterOptionWithName:@"foo" flag:@"f"],
    ];
    
    NSDictionary *expectedOptionArguments = @{
        @"foo" : @[ @"bar" ]
    };
    
    NSArray *expectedPositionalArguments = @[ @"/flarn.txt", @"/bort.txt" ];
    [self performTestWithArgv:argv options:options expectedSwitchOptions:@{} expectedOptionArguments:expectedOptionArguments expectedPositionalArguments:expectedPositionalArguments];
}

- (void)testPositionalArgumentsOnly
{
    NSArray *argv = @[ @"/flarn.txt", @"/bort.txt" ];
    NSArray *options = @[
        [CLKOption parameterOptionWithName:@"foo" flag:@"f"],
        [CLKOption parameterOptionWithName:@"bar" flag:@"b"]
    ];
    
    [self performTestWithArgv:argv options:options expectedSwitchOptions:@{} expectedOptionArguments:@{} expectedPositionalArguments:argv];
}

- (void)testPositionalArgumentsOnly_noParserOptions
{
    NSArray *argv = @[ @"alpha", @"bravo", @"charlie" ];
    [self performTestWithArgv:argv options:@[] expectedSwitchOptions:@{} expectedOptionArguments:@{} expectedPositionalArguments:argv];
}

- (void)testOptionArgumentNotProvided
{
    NSArray *argv = @[ @"--foo", @"--bar", @"what" ];
    NSArray *options = @[
        [CLKOption parameterOptionWithName:@"foo" flag:@"f"],
        [CLKOption parameterOptionWithName:@"bar" flag:@"b"]
    ];
    
    CLKArgumentParser *parser = [CLKArgumentParser parserWithArgumentVector:argv options:options];
    NSError *error = nil;
    CLKArgumentManifest *manifest = [parser parseArguments:&error];
    XCTAssertNil(manifest);
    [self verifyError:error domain:NSPOSIXErrorDomain code:EINVAL description:@"expected argument but encountered option-like token '--bar'"];
}

- (void)testZeroLengthStringsInArgumentVector
{
    CLKOption *option = [CLKOption parameterOptionWithName:@"foo" flag:@"f"];
    
    NSArray *argv = @[ @"--foo", @"", @"what" ];
    CLKArgumentParser *parser = [CLKArgumentParser parserWithArgumentVector:argv options:@[ option ]];
    NSError *error = nil;
    CLKArgumentManifest *manifest = [parser parseArguments:&error];
    XCTAssertNil(manifest);
    [self verifyError:error domain:NSPOSIXErrorDomain code:EINVAL description:@"encountered zero-length argument"];
    
    argv = @[ @"--foo", @"bar", @"" ];
    parser = [CLKArgumentParser parserWithArgumentVector:argv options:@[ option ]];
    error = nil;
    manifest = [parser parseArguments:&error];
    XCTAssertNil(manifest);
    [self verifyError:error domain:NSPOSIXErrorDomain code:EINVAL description:@"encountered zero-length argument"];
    
    argv = @[ @"", @"--foo", @"bar" ];
    parser = [CLKArgumentParser parserWithArgumentVector:argv options:@[ option ]];
    error = nil;
    manifest = [parser parseArguments:&error];
    XCTAssertNil(manifest);
    [self verifyError:error domain:NSPOSIXErrorDomain code:EINVAL description:@"encountered zero-length argument"];
}

- (void)testArgumentTransformation
{
    NSArray *argv = @[ @"--strange", @"7", @"--aeons", @"819", @"/fatum/iustum/stultorum" ];
    
    CLKIntArgumentTransformer *transformer = [CLKIntArgumentTransformer transformer];
    CLKOption *strange = [CLKOption parameterOptionWithName:@"strange" flag:@"s" transformer:transformer];
    CLKOption *aeons = [CLKOption parameterOptionWithName:@"aeons" flag:@"a" transformer:transformer];
    NSArray *options = @[ strange, aeons ];
    
    NSDictionary *expectedOptionArguments = @{
        @"strange" : @[ @(7) ],
        @"aeons" : @[ @(819) ],
    };
    
    NSArray *expectedPositionalArguments = @[ @"/fatum/iustum/stultorum" ];
    [self performTestWithArgv:argv options:options expectedSwitchOptions:@{} expectedOptionArguments:expectedOptionArguments expectedPositionalArguments:expectedPositionalArguments];
}

- (void)testComplexMix
{
    NSArray *argv = @[
        @"acme", @"--syn", @"aeons", @"--xyzzy", @"thrud", @"-a", @"hack", @"-x", @"-xpx",
        @"--syn", @"cathedra", @"--noise", @"819", @"confound", @"delivery"
    ];
    
    NSArray *options = @[
         [CLKOption parameterOptionWithName:@"syn" flag:@"s"],
         [CLKOption parameterOptionWithName:@"ack" flag:@"a"],
         [CLKOption parameterOptionWithName:@"noise" flag:@"n" transformer:[CLKIntArgumentTransformer transformer]],
         [CLKOption parameterOptionWithName:@"ghost" flag:@"g"], // not provided in argv
         [CLKOption optionWithName:@"xyzzy" flag:@"x"],
         [CLKOption optionWithName:@"spline" flag:@"p"],
    ];
    
    NSDictionary *expectedSwitchOptions = @{
        @"xyzzy" : @(4),
        @"spline" : @(1)
    };
    
    NSDictionary *expectedOptionArguments = @{
        @"syn" : @[ @"aeons", @"cathedra" ],
        @"ack" : @[ @"hack" ],
        @"noise" : @[ @(819) ]
    };
    
    NSArray *expectedPositionalArguments = @[ @"acme", @"thrud", @"confound", @"delivery" ];
    [self performTestWithArgv:argv options:options expectedSwitchOptions:expectedSwitchOptions expectedOptionArguments:expectedOptionArguments expectedPositionalArguments:expectedPositionalArguments];
}

- (void)testParserReuseNotAllowed
{
    CLKArgumentParser *parser = [CLKArgumentParser parserWithArgumentVector:@[] options:@[]];
    CLKArgumentManifest *manifest = [parser parseArguments:nil];
    XCTAssertNotNil(manifest);
    XCTAssertThrows([parser parseArguments:nil]);
}

- (void)testOptionCollisionCheck
{
    // two --ack opt names, different flags
    NSArray *options = @[
         [CLKOption parameterOptionWithName:@"ack" flag:@"a"],
         [CLKOption parameterOptionWithName:@"syn" flag:@"s"],
         [CLKOption optionWithName:@"ack" flag:@"c"],
    ];
    
    XCTAssertThrows([CLKArgumentParser parserWithArgumentVector:@[] options:options]);
    
    // two -x opt flags, different names
    options = @[
         [CLKOption parameterOptionWithName:@"xyzzy" flag:@"x"],
         [CLKOption optionWithName:@"spline" flag:@"p"],
         [CLKOption optionWithName:@"yzzyx" flag:@"x"],
    ];
    
    XCTAssertThrows([CLKArgumentParser parserWithArgumentVector:@[] options:options]);
}

@end
