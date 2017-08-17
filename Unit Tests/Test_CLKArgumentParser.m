//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CLKArgumentTransformer.h"
#import "CLKOption.h"
#import "CLKArgumentManifest.h"
#import "CLKArgumentParser.h"


NS_ASSUME_NONNULL_BEGIN

@interface Test_CLKArgumentParser : XCTestCase

- (void)performTestWithArgv:(NSArray<NSString *> *)argv
                    options:(NSArray<CLKOption *> *)options
        expectedFreeOptions:(NSDictionary<NSString *, NSNumber *> *)expectedFreeOptions
    expectedOptionArguments:(NSDictionary<NSString *, NSArray *> *)expectedOptionArguments
expectedPositionalArguments:(NSArray<NSString *> *)expectedPositionalArguments;

@end

NS_ASSUME_NONNULL_END


@implementation Test_CLKArgumentParser

- (void)performTestWithArgv:(NSArray<NSString *> *)argv
                    options:(NSArray<CLKOption *> *)options
        expectedFreeOptions:(NSDictionary<NSString *, NSNumber *> *)expectedFreeOptions
    expectedOptionArguments:(NSDictionary<NSString *, NSArray *> *)expectedOptionArguments
expectedPositionalArguments:(NSArray<NSString *> *)expectedPositionalArguments
{
    CLKArgumentParser *parser = [CLKArgumentParser parserWithArgumentVector:argv options:options];
    NSError *error = nil;
    CLKArgumentManifest *manifest = [parser parseArguments:&error];
    XCTAssertNotNil(manifest);
    XCTAssertNil(error);
    XCTAssertEqualObjects(manifest.freeOptions, expectedFreeOptions);
    XCTAssertEqualObjects(manifest.optionArguments, expectedOptionArguments);
    XCTAssertEqualObjects(manifest.positionalArguments, expectedPositionalArguments);
}

#pragma mark -

- (void)testInit
{
    NSArray *argv = @[ @"--flarn" ];
    NSArray *options = @[
         [CLKOption freeOptionWithName:@"barf" flag:@"b"],
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
         [CLKOption optionWithName:@"foo" flag:@"f"],
    ];
    
    [self performTestWithArgv:@[] options:options expectedFreeOptions:@{} expectedOptionArguments:@{} expectedPositionalArguments:@[]];
}

- (void)testUnrecognizedOption
{
    NSArray *argv = @[ @"--foo", @"flarn" ];
    NSArray *options = @[
         [CLKOption freeOptionWithName:@"bar" flag:@"b"],
    ];
    
    CLKArgumentParser *parser = [CLKArgumentParser parserWithArgumentVector:argv options:options];
    
    NSError *error = nil;
    CLKArgumentManifest *manifest = [parser parseArguments:&error];
    XCTAssertNil(manifest);
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, EINVAL);
    XCTAssertEqualObjects(error.domain, NSPOSIXErrorDomain);
    XCTAssertEqualObjects(error.localizedDescription, @"unrecognized option: 'foo'");
}

- (void)testFreeOptions
{
    NSArray *argv = @[ @"--foo", @"-f", @"-bfb" ];
    NSArray *options = @[
        [CLKOption freeOptionWithName:@"foo" flag:@"f"],
        [CLKOption freeOptionWithName:@"bar" flag:@"b"]
    ];
    
    NSDictionary *expectedFreeOptions = @{
        @"foo" : @(3),
        @"bar" : @(2)
    };
    
    [self performTestWithArgv:argv options:options expectedFreeOptions:expectedFreeOptions expectedOptionArguments:@{} expectedPositionalArguments:@[]];
}

- (void)testOptionArguments
{
    NSArray *argv = @[ @"--foo", @"alpha", @"-f", @"bravo", @"-b", @"charlie" ];
    NSArray *options = @[
        [CLKOption optionWithName:@"foo" flag:@"f"],
        [CLKOption optionWithName:@"bar" flag:@"b"]
    ];
    
    NSDictionary *expectedOptionArguments = @{
        @"foo" : @[ @"alpha", @"bravo" ],
        @"bar" : @[ @"charlie" ]
    };
    
    [self performTestWithArgv:argv options:options expectedFreeOptions:@{} expectedOptionArguments:expectedOptionArguments expectedPositionalArguments:@[]];
}

- (void)testNoFlag
{
    NSArray *argv = @[ @"--alpha", @"bravo", @"--charlie", @"--charlie" ];
    NSArray *options = @[
        [CLKOption optionWithName:@"alpha" flag:nil],
        [CLKOption freeOptionWithName:@"charlie" flag:nil]
    ];
    
    NSDictionary *expectedFreeOptions = @{ @"charlie" : @(2) };
    NSDictionary *expectedOptionArguments = @{ @"alpha" : @[ @"bravo" ] };
    [self performTestWithArgv:argv options:options expectedFreeOptions:expectedFreeOptions expectedOptionArguments:expectedOptionArguments expectedPositionalArguments:@[]];
}

// very edge-casey
- (void)testSingleCharacterNames
{
    NSArray *argv = @[ @"--a", @"-a", @"--b", @"-aa" ];
    NSArray *options = @[
        [CLKOption freeOptionWithName:@"a" flag:@"a"],
        [CLKOption freeOptionWithName:@"b" flag:nil]
    ];
    
    NSDictionary *expectedFreeOptions = @{
        @"a" : @(4),
        @"b" : @(1)
    };
    
    [self performTestWithArgv:argv options:options expectedFreeOptions:expectedFreeOptions expectedOptionArguments:@{} expectedPositionalArguments:@[]];
}

- (void)testPositionalArguments
{
    NSArray *argv = @[ @"--foo", @"bar", @"/flarn.txt", @"/bort.txt" ];
    NSArray *options = @[
        [CLKOption optionWithName:@"foo" flag:@"f"],
    ];
    
    NSDictionary *expectedOptionArguments = @{
        @"foo" : @[ @"bar" ]
    };
    
    NSArray *expectedPositionalArguments = @[ @"/flarn.txt", @"/bort.txt" ];
    [self performTestWithArgv:argv options:options expectedFreeOptions:@{} expectedOptionArguments:expectedOptionArguments expectedPositionalArguments:expectedPositionalArguments];
}

- (void)testPositionalArgumentsOnly
{
    NSArray *argv = @[ @"/flarn.txt", @"/bort.txt" ];
    NSArray *options = @[
        [CLKOption optionWithName:@"foo" flag:@"f"],
        [CLKOption optionWithName:@"bar" flag:@"b"]
    ];
    
    [self performTestWithArgv:argv options:options expectedFreeOptions:@{} expectedOptionArguments:@{} expectedPositionalArguments:argv];
}

- (void)testPositionalArgumentsOnly_noParserOptions
{
    NSArray *argv = @[ @"alpha", @"bravo", @"charlie" ];
    [self performTestWithArgv:argv options:@[] expectedFreeOptions:@{} expectedOptionArguments:@{} expectedPositionalArguments:argv];
}

- (void)testOptionArgumentNotProvided
{
    NSArray *argv = @[ @"--foo", @"--bar", @"what" ];
    NSArray *options = @[
        [CLKOption optionWithName:@"foo" flag:@"f"],
        [CLKOption optionWithName:@"bar" flag:@"b"]
    ];
    
    CLKArgumentParser *parser = [CLKArgumentParser parserWithArgumentVector:argv options:options];
    NSError *error = nil;
    CLKArgumentManifest *manifest = [parser parseArguments:&error];
    XCTAssertNil(manifest);
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, EINVAL);
    XCTAssertEqualObjects(error.localizedDescription, @"expected argument but encountered option-like token '--bar'");
}

- (void)testZeroLengthStringsInArgumentVector
{
    CLKOption *option = [CLKOption optionWithName:@"foo" flag:@"f"];
    
    NSArray *argv = @[ @"--foo", @"", @"what" ];
    CLKArgumentParser *parser = [CLKArgumentParser parserWithArgumentVector:argv options:@[ option ]];
    NSError *error = nil;
    CLKArgumentManifest *manifest = [parser parseArguments:&error];
    XCTAssertNil(manifest);
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, EINVAL);
    XCTAssertEqualObjects(error.localizedDescription, @"encountered zero-length argument");
    
    argv = @[ @"--foo", @"bar", @"" ];
    parser = [CLKArgumentParser parserWithArgumentVector:argv options:@[ option ]];
    error = nil;
    manifest = [parser parseArguments:&error];
    XCTAssertNil(manifest);
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, EINVAL);
    XCTAssertEqualObjects(error.localizedDescription, @"encountered zero-length argument");
    
    argv = @[ @"", @"--foo", @"bar" ];
    parser = [CLKArgumentParser parserWithArgumentVector:argv options:@[ option ]];
    error = nil;
    manifest = [parser parseArguments:&error];
    XCTAssertNil(manifest);
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, EINVAL);
    XCTAssertEqualObjects(error.localizedDescription, @"encountered zero-length argument");
}

- (void)testArgumentTransformation
{
    NSArray *argv = @[ @"--strange", @"7", @"--aeons", @"819", @"/fatum/iustum/stultorum" ];
    
    CLKIntArgumentTransformer *transformer = [CLKIntArgumentTransformer transformer];
    CLKOption *strange = [CLKOption optionWithName:@"strange" flag:@"s" transformer:transformer];
    CLKOption *aeons = [CLKOption optionWithName:@"aeons" flag:@"a" transformer:transformer];
    NSArray *options = @[ strange, aeons ];
    
    NSDictionary *expectedOptionArguments = @{
        @"strange" : @[ @(7) ],
        @"aeons" : @[ @(819) ],
    };
    
    NSArray *expectedPositionalArguments = @[ @"/fatum/iustum/stultorum" ];
    [self performTestWithArgv:argv options:options expectedFreeOptions:@{} expectedOptionArguments:expectedOptionArguments expectedPositionalArguments:expectedPositionalArguments];
}

- (void)testComplexMix
{
    NSArray *argv = @[
        @"acme", @"--syn", @"aeons", @"--xyzzy", @"thrud", @"-a", @"hack", @"-x", @"-xpx",
        @"--syn", @"cathedra", @"--noise", @"819", @"confound", @"delivery"
    ];
    
    NSArray *options = @[
         [CLKOption optionWithName:@"syn" flag:@"s"],
         [CLKOption optionWithName:@"ack" flag:@"a"],
         [CLKOption optionWithName:@"noise" flag:@"n" transformer:[CLKIntArgumentTransformer transformer]],
         [CLKOption optionWithName:@"ghost" flag:@"g"], // not provided in argv
         [CLKOption freeOptionWithName:@"xyzzy" flag:@"x"],
         [CLKOption freeOptionWithName:@"spline" flag:@"p"],
    ];
    
    NSDictionary *expectedFreeOptions = @{
        @"xyzzy" : @(4),
        @"spline" : @(1)
    };
    
    NSDictionary *expectedOptionArguments = @{
        @"syn" : @[ @"aeons", @"cathedra" ],
        @"ack" : @[ @"hack" ],
        @"noise" : @[ @(819) ]
    };
    
    NSArray *expectedPositionalArguments = @[ @"acme", @"thrud", @"confound", @"delivery" ];
    [self performTestWithArgv:argv options:options expectedFreeOptions:expectedFreeOptions expectedOptionArguments:expectedOptionArguments expectedPositionalArguments:expectedPositionalArguments];
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
         [CLKOption optionWithName:@"ack" flag:@"a"],
         [CLKOption optionWithName:@"syn" flag:@"s"],
         [CLKOption freeOptionWithName:@"ack" flag:@"c"],
    ];
    
    XCTAssertThrows([CLKArgumentParser parserWithArgumentVector:@[] options:options]);
    
    // two -x opt flags, different names
    options = @[
         [CLKOption optionWithName:@"xyzzy" flag:@"x"],
         [CLKOption freeOptionWithName:@"spline" flag:@"p"],
         [CLKOption freeOptionWithName:@"yzzyx" flag:@"x"],
    ];
    
    XCTAssertThrows([CLKArgumentParser parserWithArgumentVector:@[] options:options]);
}

@end
