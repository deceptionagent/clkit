//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CLKArgumentManifest.h"
#import "CLKArgumentManifest_Private.h"
#import "CLKArgumentParser.h"
#import "CLKArgumentTransformer.h"
#import "CLKOption.h"
#import "CLKOptionGroup.h"
#import "XCTestCase+CLKAdditions.h"


NS_ASSUME_NONNULL_BEGIN

@interface Test_CLKArgumentParser : XCTestCase

- (void)performTestWithArgv:(NSArray<NSString *> *)argv
                    options:(NSArray<CLKOption *> *)options
     expectedOptionManifest:(NSDictionary<NSString *, id> *)expectedOptionManifest
expectedPositionalArguments:(NSArray<NSString *> *)expectedPositionalArguments;

@end

NS_ASSUME_NONNULL_END


@implementation Test_CLKArgumentParser

- (void)performTestWithArgv:(NSArray<NSString *> *)argv
                    options:(NSArray<CLKOption *> *)options
     expectedOptionManifest:(NSDictionary<NSString *, id> *)expectedOptionManifest
expectedPositionalArguments:(NSArray<NSString *> *)expectedPositionalArguments
{
    CLKArgumentParser *parser = [CLKArgumentParser parserWithArgumentVector:argv options:options];
    NSError *error = nil;
    CLKArgumentManifest *manifest = [parser parseArguments:&error];
    XCTAssertNotNil(manifest);
    XCTAssertNil(error);
    XCTAssertEqualObjects(manifest.optionManifestKeyedByName, expectedOptionManifest);
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
    
    XCTAssertNotNil([CLKArgumentParser parserWithArgumentVector:argv options:options optionGroups:nil]);
    XCTAssertNotNil([CLKArgumentParser parserWithArgumentVector:argv options:options optionGroups:@[]]);
    
    CLKOptionGroup *group = [CLKOptionGroup groupWithOptions:options required:NO];
    XCTAssertNotNil([CLKArgumentParser parserWithArgumentVector:argv options:options optionGroups:@[ group ]]);
    
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
    
    [self performTestWithArgv:@[] options:options expectedOptionManifest:@{} expectedPositionalArguments:@[]];
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
    NSArray *argv = @[ @"--foo", @"-f", @"-bfb", @"-qqq" ];
    NSArray *options = @[
        [CLKOption optionWithName:@"foo" flag:@"f"],
        [CLKOption optionWithName:@"bar" flag:@"b"],
        [CLKOption optionWithName:@"quone" flag:@"q"]
    ];
    
    NSDictionary *expectedOptionManifest = @{
        @"foo" : @(3),
        @"bar" : @(2),
        @"quone" : @(3)
    };
    
    [self performTestWithArgv:argv options:options expectedOptionManifest:expectedOptionManifest expectedPositionalArguments:@[]];
}

- (void)testParameterOptions
{
    NSArray *argv = @[ @"--foo", @"alpha", @"-f", @"bravo", @"-b", @"charlie" ];
    NSArray *options = @[
        [CLKOption parameterOptionWithName:@"foo" flag:@"f" required:NO recurrent:YES transformer:nil dependencies:nil],
        [CLKOption parameterOptionWithName:@"bar" flag:@"b"]
    ];
    
    NSDictionary *expectedOptionManifest = @{
        @"foo" : @[ @"alpha", @"bravo" ],
        @"bar" : @[ @"charlie" ]
    };
    
    [self performTestWithArgv:argv options:options expectedOptionManifest:expectedOptionManifest expectedPositionalArguments:@[]];
}

- (void)testNoFlag
{
    NSArray *argv = @[ @"--alpha", @"bravo", @"--charlie", @"--charlie" ];
    NSArray *options = @[
        [CLKOption parameterOptionWithName:@"alpha" flag:nil],
        [CLKOption optionWithName:@"charlie" flag:nil]
    ];
    
    NSDictionary *expectedOptionManifest = @{
        @"charlie" : @(2),
        @"alpha" : @[ @"bravo" ]
    };
    
    [self performTestWithArgv:argv options:options expectedOptionManifest:expectedOptionManifest expectedPositionalArguments:@[]];
}

// very edge-casey
- (void)testSingleCharacterNames
{
    NSArray *argv = @[ @"--a", @"-a", @"--b", @"-aa" ];
    NSArray *options = @[
        [CLKOption optionWithName:@"a" flag:@"a"],
        [CLKOption optionWithName:@"b" flag:nil]
    ];
    
    NSDictionary *expectedOptionManifest = @{
        @"a" : @(4),
        @"b" : @(1)
    };
    
    [self performTestWithArgv:argv options:options expectedOptionManifest:expectedOptionManifest expectedPositionalArguments:@[]];
}

- (void)testPositionalArguments
{
    NSArray *argv = @[ @"--foo", @"bar", @"/flarn.txt", @"/bort.txt" ];
    NSArray *options = @[
        [CLKOption parameterOptionWithName:@"foo" flag:@"f"],
    ];
    
    NSDictionary *expectedOptionManifest = @{
        @"foo" : @[ @"bar" ]
    };
    
    NSArray *expectedPositionalArguments = @[ @"/flarn.txt", @"/bort.txt" ];
    [self performTestWithArgv:argv options:options expectedOptionManifest:expectedOptionManifest expectedPositionalArguments:expectedPositionalArguments];
}

- (void)testPositionalArgumentsOnly
{
    NSArray *argv = @[ @"/flarn.txt", @"/bort.txt" ];
    NSArray *options = @[
        [CLKOption parameterOptionWithName:@"foo" flag:@"f"],
        [CLKOption parameterOptionWithName:@"bar" flag:@"b"]
    ];
    
    [self performTestWithArgv:argv options:options expectedOptionManifest:@{} expectedPositionalArguments:argv];
}

- (void)testPositionalArgumentsOnly_noParserOptions
{
    NSArray *argv = @[ @"alpha", @"bravo", @"charlie" ];
    [self performTestWithArgv:argv options:@[] expectedOptionManifest:@{} expectedPositionalArguments:argv];
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
    
    NSDictionary *expectedOptionManifest = @{
        @"strange" : @[ @(7) ],
        @"aeons" : @[ @(819) ],
    };
    
    NSArray *expectedPositionalArguments = @[ @"/fatum/iustum/stultorum" ];
    [self performTestWithArgv:argv options:options expectedOptionManifest:expectedOptionManifest expectedPositionalArguments:expectedPositionalArguments];
}

- (void)testComplexMix
{
    NSArray *argv = @[
        @"acme", @"--syn", @"aeons", @"--xyzzy", @"thrud", @"-a", @"hack", @"-x", @"-xpx",
        @"--syn", @"cathedra", @"--noise", @"819", @"confound", @"delivery"
    ];
    
    NSArray *options = @[
         [CLKOption parameterOptionWithName:@"ack" flag:@"a"],
         [CLKOption parameterOptionWithName:@"noise" flag:@"n" transformer:[CLKIntArgumentTransformer transformer]],
         [CLKOption parameterOptionWithName:@"ghost" flag:@"g"], // not provided in argv
         [CLKOption parameterOptionWithName:@"syn" flag:@"s" required:NO recurrent:YES transformer:nil dependencies:nil],
         [CLKOption optionWithName:@"xyzzy" flag:@"x"],
         [CLKOption optionWithName:@"spline" flag:@"p"],
    ];
    
    NSDictionary *expectedOptionManifest = @{
        @"xyzzy" : @(4),
        @"spline" : @(1),
        @"syn" : @[ @"aeons", @"cathedra" ],
        @"ack" : @[ @"hack" ],
        @"noise" : @[ @(819) ]
    };
    
    NSArray *expectedPositionalArguments = @[ @"acme", @"thrud", @"confound", @"delivery" ];
    [self performTestWithArgv:argv options:options expectedOptionManifest:expectedOptionManifest expectedPositionalArguments:expectedPositionalArguments];
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

- (void)testValidationError_requiredOption
{
    NSArray *options = @[
         [CLKOption optionWithName:@"alpha" flag:@"a"],
         [CLKOption parameterOptionWithName:@"bravo" flag:@"b" required:YES]
    ];
    
    CLKArgumentParser *parser = [CLKArgumentParser parserWithArgumentVector:@[] options:options];
    XCTAssertFalse([parser parseArguments:nil]);
    
    parser = [CLKArgumentParser parserWithArgumentVector:@[] options:options];
    NSError *error = nil;
    XCTAssertFalse([parser parseArguments:&error]);
    [self verifyCLKError:error code:CLKErrorRequiredOptionNotProvided description:@"--bravo: required option not provided"];
    
    parser = [CLKArgumentParser parserWithArgumentVector:@[ @"--alpha" ] options:options];
    error = nil;
    XCTAssertFalse([parser parseArguments:&error]);
    [self verifyCLKError:error code:CLKErrorRequiredOptionNotProvided description:@"--bravo: required option not provided"];
}

- (void)testValidationError_optionDependency
{
    CLKOption *alpha = [CLKOption optionWithName:@"alpha" flag:@"a"];
    CLKOption *bravo = [CLKOption parameterOptionWithName:@"bravo" flag:@"b"];
    CLKOption *charlie = [CLKOption optionWithName:@"charlie" flag:@"c" dependencies:@[ bravo ]];
    NSArray *options = @[ alpha, bravo, charlie ];
    
    CLKArgumentParser *parser = [CLKArgumentParser parserWithArgumentVector:@[ @"--charlie" ] options:options];
    NSError *error = nil;
    XCTAssertFalse([parser parseArguments:&error]);
    [self verifyCLKError:error code:CLKErrorRequiredOptionNotProvided description:@"--bravo is required when using --charlie"];
}

@end
