//
//  Created by mikey on 28/6/17.
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CLKArgumentTransformer.h"
#import "CLKOption.h"
#import "CLKOptArgManifest.h"
#import "CLKOptArgParser.h"


NS_ASSUME_NONNULL_BEGIN

@interface Test_CLKOptArgParser : XCTestCase

- (void)performTestWithArgv:(NSArray<NSString *> *)argv
                    options:(NSArray<CLKOption *> *)options
        expectedFreeOptions:(NSDictionary<NSString *, NSNumber *> *)expectedFreeOptions
    expectedOptionArguments:(NSDictionary<NSString *, NSArray *> *)expectedOptionArguments
 expectedRemainderArguments:(NSArray<NSString *> *)expectedRemainderArguments;

@end

NS_ASSUME_NONNULL_END


@implementation Test_CLKOptArgParser

- (void)performTestWithArgv:(NSArray<NSString *> *)argv
                    options:(NSArray<CLKOption *> *)options
        expectedFreeOptions:(NSDictionary<NSString *, NSNumber *> *)expectedFreeOptions
    expectedOptionArguments:(NSDictionary<NSString *, NSArray *> *)expectedOptionArguments
 expectedRemainderArguments:(NSArray<NSString *> *)expectedRemainderArguments
{
    CLKOptArgParser *parser = [CLKOptArgParser parserWithArgumentVector:argv options:options];
    NSError *error = nil;
    CLKOptArgManifest *manifest = [parser parseArguments:&error];
    XCTAssertNotNil(manifest);
    XCTAssertNil(error);
    XCTAssertEqualObjects(manifest.freeOptions, expectedFreeOptions);
    XCTAssertEqualObjects(manifest.optionArguments, expectedOptionArguments);
    XCTAssertEqualObjects(manifest.remainderArguments, expectedRemainderArguments);
}

#pragma mark -

- (void)testInit
{
    NSArray *argv = @[ @"--flarn" ];
    NSArray *options = @[
         [CLKOption freeOptionWithLongName:@"barf" shortName:@"b"],
    ];
    
    XCTAssertNotNil([CLKOptArgParser parserWithArgumentVector:argv options:options]);
    XCTAssertNotNil([CLKOptArgParser parserWithArgumentVector:argv options:@[]]);
    XCTAssertNotNil([CLKOptArgParser parserWithArgumentVector:argv options:@[]]);
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    XCTAssertThrows([CLKOptArgParser parserWithArgumentVector:nil options:nil]);
    XCTAssertThrows([CLKOptArgParser parserWithArgumentVector:nil options:options]);
    XCTAssertThrows([CLKOptArgParser parserWithArgumentVector:argv options:nil]);
#pragma clang diagnostic pop
}

- (void)testEmptyArgv
{
    NSArray *options = @[
         [CLKOption optionWithLongName:@"foo" shortName:@"f"],
    ];
    
    [self performTestWithArgv:@[] options:options expectedFreeOptions:@{} expectedOptionArguments:@{} expectedRemainderArguments:@[]];
}

- (void)testUnrecognizedOption
{
    NSArray *argv = @[ @"--foo", @"flarn" ];
    NSArray *options = @[
         [CLKOption freeOptionWithLongName:@"bar" shortName:@"b"],
    ];
    
    CLKOptArgParser *parser = [CLKOptArgParser parserWithArgumentVector:argv options:options];
    
    NSError *error = nil;
    CLKOptArgManifest *manifest = [parser parseArguments:&error];
    XCTAssertNil(manifest);
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, EINVAL);
    XCTAssertEqualObjects(error.domain, NSPOSIXErrorDomain);
    XCTAssertEqualObjects(error.localizedDescription, @"unrecognized option: 'foo'");
}

- (void)testFreeOptions
{
    NSArray *argv = @[ @"--foo", @"-f", @"-b" ];
    NSArray *options = @[
        [CLKOption freeOptionWithLongName:@"foo" shortName:@"f"],
        [CLKOption freeOptionWithLongName:@"bar" shortName:@"b"]
    ];
    
    NSDictionary *expectedFreeOptions = @{
        @"foo" : @(2),
        @"bar" : @(1)
    };
    
    [self performTestWithArgv:argv options:options expectedFreeOptions:expectedFreeOptions expectedOptionArguments:@{} expectedRemainderArguments:@[]];
}

- (void)testOptionArguments
{
    NSArray *argv = @[ @"--foo", @"alpha", @"-f", @"bravo", @"-b", @"charlie" ];
    NSArray *options = @[
        [CLKOption optionWithLongName:@"foo" shortName:@"f"],
        [CLKOption optionWithLongName:@"bar" shortName:@"b"]
    ];
    
    NSDictionary *expectedOptionArguments = @{
        @"foo" : @[ @"alpha", @"bravo" ],
        @"bar" : @[ @"charlie" ]
    };
    
    [self performTestWithArgv:argv options:options expectedFreeOptions:@{} expectedOptionArguments:expectedOptionArguments expectedRemainderArguments:@[]];
}

- (void)testRemainderArguments
{
    NSArray *argv = @[ @"--foo", @"bar", @"/flarn.txt", @"/bort.txt" ];
    NSArray *options = @[
        [CLKOption optionWithLongName:@"foo" shortName:@"f"],
    ];
    
    NSDictionary *expectedOptionArguments = @{
        @"foo" : @[ @"bar" ]
    };
    
    NSArray *expectedRemainderArguments = @[ @"/flarn.txt", @"/bort.txt" ];
    [self performTestWithArgv:argv options:options expectedFreeOptions:@{} expectedOptionArguments:expectedOptionArguments expectedRemainderArguments:expectedRemainderArguments];
}

- (void)testRemainderArgumentsOnly
{
    NSArray *argv = @[ @"/flarn.txt", @"/bort.txt" ];
    NSArray *options = @[
        [CLKOption optionWithLongName:@"foo" shortName:@"f"],
        [CLKOption optionWithLongName:@"bar" shortName:@"b"]
    ];
    
    [self performTestWithArgv:argv options:options expectedFreeOptions:@{} expectedOptionArguments:@{} expectedRemainderArguments:argv];
}

- (void)testRemainderArgumentsOnly_noParserOptions
{
    NSArray *argv = @[ @"alpha", @"bravo", @"charlie" ];
    [self performTestWithArgv:argv options:@[] expectedFreeOptions:@{} expectedOptionArguments:@{} expectedRemainderArguments:argv];
}

- (void)testOptionArgumentNotProvided
{
    NSArray *argv = @[ @"--foo", @"--bar", @"what" ];
    NSArray *options = @[
        [CLKOption optionWithLongName:@"foo" shortName:@"f"],
        [CLKOption optionWithLongName:@"bar" shortName:@"b"]
    ];
    
    CLKOptArgParser *parser = [CLKOptArgParser parserWithArgumentVector:argv options:options];
    NSError *error = nil;
    CLKOptArgManifest *manifest = [parser parseArguments:&error];
    XCTAssertNil(manifest);
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, EINVAL);
    XCTAssertEqualObjects(error.localizedDescription, @"expected argument but encountered option-like token '--bar'");
}

- (void)testArgumentTransformation
{
    NSArray *argv = @[ @"--strange", @"7", @"--aeons", @"819", @"/fatum/iustum/stultorum" ];
    
    CLKIntegerArgumentTransformer *transformer = [CLKIntegerArgumentTransformer transformer];
    CLKOption *syn = [CLKOption optionWithLongName:@"strange" shortName:@"s" transformer:transformer];
    CLKOption *ack = [CLKOption optionWithLongName:@"aeons" shortName:@"a" transformer:transformer];
    NSArray *options = @[ syn, ack ];
    
    NSDictionary *expectedOptionArguments = @{
        @"strange" : @[ @(7) ],
        @"aeons" : @[ @(819) ],
    };
    
    NSArray *expectedRemainderArguments = @[ @"/fatum/iustum/stultorum" ];
    [self performTestWithArgv:argv options:options expectedFreeOptions:@{} expectedOptionArguments:expectedOptionArguments expectedRemainderArguments:expectedRemainderArguments];
}

- (void)testComplexMix
{
    NSArray *argv = @[
        @"acme", @"--syn", @"aeons", @"--xyzzy", @"thrud", @"-a", @"hack", @"-x", @"-xpx",
        @"--syn", @"cathedra", @"--noise", @"819", @"confound", @"delivery"
    ];
    
    NSArray *options = @[
         [CLKOption optionWithLongName:@"syn" shortName:@"s"],
         [CLKOption optionWithLongName:@"ack" shortName:@"a"],
         [CLKOption optionWithLongName:@"noise" shortName:@"n" transformer:[CLKIntegerArgumentTransformer transformer]],
         [CLKOption optionWithLongName:@"ghost" shortName:@"g"], // not provided in argv
         [CLKOption freeOptionWithLongName:@"xyzzy" shortName:@"x"],
         [CLKOption freeOptionWithLongName:@"spline" shortName:@"p"],
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
    
    NSArray *expectedRemainderArguments = @[ @"acme", @"thrud", @"confound", @"delivery" ];
    [self performTestWithArgv:argv options:options expectedFreeOptions:expectedFreeOptions expectedOptionArguments:expectedOptionArguments expectedRemainderArguments:expectedRemainderArguments];
}

- (void)testParserReuseNotAllowed
{
    CLKOptArgParser *parser = [CLKOptArgParser parserWithArgumentVector:@[] options:@[]];
    CLKOptArgManifest *manifest = [parser parseArguments:nil];
    XCTAssertNotNil(manifest);
    XCTAssertThrows([parser parseArguments:nil]);
}

- (void)testOptionCollisionGuard
{
    // two --ack opts, different short names
    NSArray *options = @[
         [CLKOption optionWithLongName:@"ack" shortName:@"a"],
         [CLKOption optionWithLongName:@"syn" shortName:@"s"],
         [CLKOption freeOptionWithLongName:@"ack" shortName:@"c"],
    ];
    
    XCTAssertThrows([CLKOptArgParser parserWithArgumentVector:@[] options:options]);
    
    // two -x opts, different long names
    options = @[
         [CLKOption optionWithLongName:@"xyzzy" shortName:@"x"],
         [CLKOption freeOptionWithLongName:@"spline" shortName:@"p"],
         [CLKOption freeOptionWithLongName:@"yzzyx" shortName:@"x"],
    ];
    
    XCTAssertThrows([CLKOptArgParser parserWithArgumentVector:@[] options:options]);
}

@end
