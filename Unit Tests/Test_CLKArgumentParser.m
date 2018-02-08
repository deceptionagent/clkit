//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "ArgumentParserSpec.h"
#import "CLKArgumentManifest.h"
#import "CLKArgumentManifest_Private.h"
#import "CLKArgumentParser.h"
#import "CLKArgumentTransformer.h"
#import "CLKOption.h"
#import "CLKOptionGroup.h"
#import "NSError+CLKAdditions.h"
#import "XCTestCase+CLKAdditions.h"


NS_ASSUME_NONNULL_BEGIN

@interface Test_CLKArgumentParser : XCTestCase

- (void)evaluateSpec:(ArgumentParserSpec *)spec usingParser:(CLKArgumentParser *)parser;

@end

NS_ASSUME_NONNULL_END


@implementation Test_CLKArgumentParser

- (void)evaluateSpec:(ArgumentParserSpec *)spec usingParser:(CLKArgumentParser *)parser
{
    CLKArgumentManifest *manifest = [parser parseArguments];
    if (spec.parserShouldSucceed) {
        XCTAssertNotNil(manifest);
        XCTAssertNil(parser.errors);
        XCTAssertEqualObjects(manifest.optionManifestKeyedByName, spec.optionManifest);
        XCTAssertEqualObjects(manifest.positionalArguments, spec.positionalArguments);
    } else {
        XCTAssertNil(manifest);
        XCTAssertEqualObjects(parser.errors, spec.errors);
    }
}

#pragma mark -

- (void)testInit
{
    NSArray *argv = @[ @"--flarn" ];
    NSArray *options = @[
         [CLKOption optionWithName:@"barf" flag:@"b"],
    ];
    
    CLKArgumentParser *parser = [CLKArgumentParser parserWithArgumentVector:argv options:options];
    XCTAssertNotNil(parser);
    XCTAssertNil(parser.errors);
    
    XCTAssertNotNil([CLKArgumentParser parserWithArgumentVector:argv options:@[]]);
    XCTAssertNotNil([CLKArgumentParser parserWithArgumentVector:argv options:options optionGroups:nil]);
    XCTAssertNotNil([CLKArgumentParser parserWithArgumentVector:argv options:options optionGroups:@[]]);
    
    CLKOptionGroup *group = [CLKOptionGroup groupForOptionsNamed:@[ @"barf" ]];
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
    
    CLKArgumentParser *parser = [CLKArgumentParser parserWithArgumentVector:@[] options:options];
    ArgumentParserSpec *spec = [ArgumentParserSpec specWithOptionManifest:@{} positionalArguments:@[]];
    [self evaluateSpec:spec usingParser:parser];
}

- (void)testUnrecognizedOption
{
    NSArray *argv = @[ @"--foo", @"flarn" ];
    NSArray *options = @[
         [CLKOption optionWithName:@"bar" flag:@"b"],
    ];
    
    CLKArgumentParser *parser = [CLKArgumentParser parserWithArgumentVector:argv options:options];
    NSError *error = [NSError clk_POSIXErrorWithCode:EINVAL description:@"unrecognized option: 'foo'"];
    ArgumentParserSpec *spec = [ArgumentParserSpec specWithErrors:@[ error ]];
    [self evaluateSpec:spec usingParser:parser];
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
    
    CLKArgumentParser *parser = [CLKArgumentParser parserWithArgumentVector:argv options:options];
    ArgumentParserSpec *spec = [ArgumentParserSpec specWithOptionManifest:expectedOptionManifest positionalArguments:@[]];
    [self evaluateSpec:spec usingParser:parser];
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
    
    CLKArgumentParser *parser = [CLKArgumentParser parserWithArgumentVector:argv options:options];
    ArgumentParserSpec *spec = [ArgumentParserSpec specWithOptionManifest:expectedOptionManifest positionalArguments:@[]];
    [self evaluateSpec:spec usingParser:parser];
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
    
    CLKArgumentParser *parser = [CLKArgumentParser parserWithArgumentVector:argv options:options];
    ArgumentParserSpec *spec = [ArgumentParserSpec specWithOptionManifest:expectedOptionManifest positionalArguments:@[]];
    [self evaluateSpec:spec usingParser:parser];
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
    
    CLKArgumentParser *parser = [CLKArgumentParser parserWithArgumentVector:argv options:options];
    ArgumentParserSpec *spec = [ArgumentParserSpec specWithOptionManifest:expectedOptionManifest positionalArguments:@[]];
    [self evaluateSpec:spec usingParser:parser];
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
    
    CLKArgumentParser *parser = [CLKArgumentParser parserWithArgumentVector:argv options:options];
    ArgumentParserSpec *spec = [ArgumentParserSpec specWithOptionManifest:expectedOptionManifest positionalArguments:expectedPositionalArguments];
    [self evaluateSpec:spec usingParser:parser];
}

- (void)testPositionalArgumentsOnly
{
    NSArray *argv = @[ @"/flarn.txt", @"/bort.txt" ];
    NSArray *options = @[
        [CLKOption parameterOptionWithName:@"foo" flag:@"f"],
        [CLKOption parameterOptionWithName:@"bar" flag:@"b"]
    ];
    
    CLKArgumentParser *parser = [CLKArgumentParser parserWithArgumentVector:argv options:options];
    ArgumentParserSpec *spec = [ArgumentParserSpec specWithOptionManifest:@{} positionalArguments:argv];
    [self evaluateSpec:spec usingParser:parser];
}

- (void)testPositionalArgumentsOnly_noParserOptions
{
    NSArray *argv = @[ @"alpha", @"bravo", @"charlie" ];
    CLKArgumentParser *parser = [CLKArgumentParser parserWithArgumentVector:argv options:@[]];
    ArgumentParserSpec *spec = [ArgumentParserSpec specWithOptionManifest:@{} positionalArguments:argv];
    [self evaluateSpec:spec usingParser:parser];
}

- (void)testOptionArgumentNotProvided
{
    NSArray *argv = @[ @"--foo", @"--bar", @"what" ];
    NSArray *options = @[
        [CLKOption parameterOptionWithName:@"foo" flag:@"f"],
        [CLKOption parameterOptionWithName:@"bar" flag:@"b"]
    ];
    
    CLKArgumentParser *parser = [CLKArgumentParser parserWithArgumentVector:argv options:options];
    NSError *error = [NSError clk_POSIXErrorWithCode:EINVAL description:@"expected argument but encountered option-like token '--bar'"];
    ArgumentParserSpec *spec = [ArgumentParserSpec specWithErrors:@[ error ]];
    [self evaluateSpec:spec usingParser:parser];
}

- (void)testZeroLengthStringsInArgumentVector
{
    CLKOption *option = [CLKOption parameterOptionWithName:@"foo" flag:@"f"];
    
    NSArray *argv = @[ @"--foo", @"", @"what" ];
    CLKArgumentParser *parser = [CLKArgumentParser parserWithArgumentVector:argv options:@[ option ]];
    NSError *error = [NSError clk_POSIXErrorWithCode:EINVAL description:@"encountered zero-length argument"];
    ArgumentParserSpec *spec = [ArgumentParserSpec specWithErrors:@[ error ]];
    [self evaluateSpec:spec usingParser:parser];
    
    argv = @[ @"--foo", @"bar", @"" ];
    parser = [CLKArgumentParser parserWithArgumentVector:argv options:@[ option ]];
    error = [NSError clk_POSIXErrorWithCode:EINVAL description:@"encountered zero-length argument"];
    spec = [ArgumentParserSpec specWithErrors:@[ error ]];
    [self evaluateSpec:spec usingParser:parser];
    
    argv = @[ @"", @"--foo", @"bar" ];
    parser = [CLKArgumentParser parserWithArgumentVector:argv options:@[ option ]];
    error = [NSError clk_POSIXErrorWithCode:EINVAL description:@"encountered zero-length argument"];
    spec = [ArgumentParserSpec specWithErrors:@[ error ]];
    [self evaluateSpec:spec usingParser:parser];
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
    
    CLKArgumentParser *parser = [CLKArgumentParser parserWithArgumentVector:argv options:options];
    ArgumentParserSpec *spec = [ArgumentParserSpec specWithOptionManifest:expectedOptionManifest positionalArguments:expectedPositionalArguments];
    [self evaluateSpec:spec usingParser:parser];
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
    
    CLKArgumentParser *parser = [CLKArgumentParser parserWithArgumentVector:argv options:options];
    ArgumentParserSpec *spec = [ArgumentParserSpec specWithOptionManifest:expectedOptionManifest positionalArguments:expectedPositionalArguments];
    [self evaluateSpec:spec usingParser:parser];
}

- (void)testParserReuseNotAllowed
{
    CLKArgumentParser *parser = [CLKArgumentParser parserWithArgumentVector:@[] options:@[]];
    CLKArgumentManifest *manifest = [parser parseArguments];
    XCTAssertNotNil(manifest);
    XCTAssertThrows([parser parseArguments]);
    
    CLKOption *flarn = [CLKOption parameterOptionWithName:@"flarn" flag:@"f" required:YES];
    parser = [CLKArgumentParser parserWithArgumentVector:@[] options:@[ flarn ]];
    manifest = [parser parseArguments];
    XCTAssertNil(manifest);
    XCTAssertNotNil(parser.errors);
    XCTAssertThrows([parser parseArguments]);
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
         [CLKOption optionWithName:@"xylo" flag:@"x"],
    ];
    
    XCTAssertThrows([CLKArgumentParser parserWithArgumentVector:@[] options:options]);
}

- (void)testUnregisteredGroupOptions
{
    NSArray *options = @[
         [CLKOption parameterOptionWithName:@"ack" flag:@"a"],
         [CLKOption parameterOptionWithName:@"syn" flag:@"s"],
    ];
    
    CLKOptionGroup *subgroup = [CLKOptionGroup groupForOptionsNamed:@[ @"barf" ]];
    CLKOptionGroup *group = [CLKOptionGroup mutexedGroupForOptionsNamed:@[ @"syn" ] subgroups:@[ subgroup ] required:NO];
    XCTAssertThrows([CLKArgumentParser parserWithArgumentVector:@[] options:options optionGroups:@[ group ]]);
}

/*
    the primary goal of validation tests involving the parser is verifying the parser:
 
        - invokes the validator
        - passes constraints to the validator
        - correctly handles the validator's result
 
    CLKOption and CLKArgumentManifestValidator have comprehensive tests for constraints,
    but while we're here we cover some full-stack examples.
*/

- (void)testValidation_required
{
    NSArray *options = @[
         [CLKOption optionWithName:@"alpha" flag:@"a"],
         [CLKOption parameterOptionWithName:@"bravo" flag:@"b" required:YES]
    ];

    CLKArgumentParser *parser = [CLKArgumentParser parserWithArgumentVector:@[] options:options];
    NSError *error = [NSError clk_CLKErrorWithCode:CLKErrorRequiredOptionNotProvided description:@"--bravo: required option not provided"];;
    ArgumentParserSpec *spec = [ArgumentParserSpec specWithErrors:@[ error ]];
    [self evaluateSpec:spec usingParser:parser];

    parser = [CLKArgumentParser parserWithArgumentVector:@[ @"--alpha" ] options:options];
    error = [NSError clk_CLKErrorWithCode:CLKErrorRequiredOptionNotProvided description:@"--bravo: required option not provided"];;
    spec = [ArgumentParserSpec specWithErrors:@[ error ]];
    [self evaluateSpec:spec usingParser:parser];
}

- (void)testValidation_dependencies
{
    CLKOption *alpha = [CLKOption optionWithName:@"alpha" flag:@"a"];
    CLKOption *bravo = [CLKOption parameterOptionWithName:@"bravo" flag:@"b"];
    CLKOption *charlie = [CLKOption optionWithName:@"charlie" flag:@"c" dependencies:@[ bravo ]];
    NSArray *options = @[ alpha, bravo, charlie ];
    
    CLKArgumentParser *parser = [CLKArgumentParser parserWithArgumentVector:@[ @"--charlie" ] options:options];
    NSError *error = [NSError clk_CLKErrorWithCode:CLKErrorRequiredOptionNotProvided description:@"--bravo is required when using --charlie"];;
    ArgumentParserSpec *spec = [ArgumentParserSpec specWithErrors:@[ error ]];
    [self evaluateSpec:spec usingParser:parser];
    
    parser = [CLKArgumentParser parserWithArgumentVector:@[ @"--charlie", @"--bravo", @"flarn" ] options:options];
    XCTAssertNotNil([parser parseArguments]);
    XCTAssertNil(parser.errors);
}

- (void)testValidation_recurrent
{
    CLKOption *flarn = [CLKOption parameterOptionWithName:@"flarn" flag:@"f"];
    NSArray *argv = @[ @"--flarn", @"barf", @"--flarn", @"barf" ];
    
    CLKArgumentParser *parser = [CLKArgumentParser parserWithArgumentVector:argv options:@[ flarn ]];
    NSError *error = [NSError clk_CLKErrorWithCode:CLKErrorTooManyOccurrencesOfOption description:@"--flarn may not be provided more than once"];;
    ArgumentParserSpec *spec = [ArgumentParserSpec specWithErrors:@[ error ]];
    [self evaluateSpec:spec usingParser:parser];
}

- (void)testValidation_mutualExclusionGroup
{
    CLKOption *flarn = [CLKOption optionWithName:@"flarn" flag:@"f"];
    CLKOption *barf = [CLKOption optionWithName:@"barf" flag:@"b"];
    CLKOption *quone = [CLKOption optionWithName:@"quone" flag:@"q"];
    CLKOption *xyzzy = [CLKOption optionWithName:@"xyzzy" flag:@"x"];
    NSArray *options = @[ flarn, barf, quone, xyzzy ];
    CLKOptionGroup *group = [CLKOptionGroup mutexedGroupForOptionsNamed:@[ @"flarn", @"barf" ]];
    CLKOptionGroup *requiredGroup = [CLKOptionGroup mutexedGroupForOptionsNamed:@[ @"quone", @"xyzzy" ] required:YES];

    CLKArgumentParser *parser = [CLKArgumentParser parserWithArgumentVector:@[ @"--quone", @"--flarn", @"--barf" ] options:options optionGroups:@[ group, requiredGroup ]];
    NSError *error = [NSError clk_CLKErrorWithCode:CLKErrorMutuallyExclusiveOptionsPresent description:@"--flarn --barf: mutually exclusive options encountered"];;
    ArgumentParserSpec *spec = [ArgumentParserSpec specWithErrors:@[ error ]];
    [self evaluateSpec:spec usingParser:parser];
    
    parser = [CLKArgumentParser parserWithArgumentVector:@[ @"--flarn" ] options:options optionGroups:@[ group, requiredGroup ]];
    error = [NSError clk_CLKErrorWithCode:CLKErrorRequiredOptionNotProvided description:@"one or more of the following options must be provided: --quone --xyzzy"];;
    spec = [ArgumentParserSpec specWithErrors:@[ error ]];
    [self evaluateSpec:spec usingParser:parser];
}

- (void)testValidation_mutualExclusionGroupWithSubgroups
{
    CLKOption *flarn = [CLKOption optionWithName:@"flarn" flag:@"f"];
    CLKOption *barf = [CLKOption optionWithName:@"barf" flag:@"b"];
    CLKOption *quone = [CLKOption optionWithName:@"quone" flag:@"q"];
    CLKOption *xyzzy = [CLKOption optionWithName:@"xyzzy" flag:@"x"];
    CLKOption *syn = [CLKOption optionWithName:@"syn" flag:@"s"];
    CLKOption *ack = [CLKOption optionWithName:@"ack" flag:@"a"];
    CLKOption *what = [CLKOption optionWithName:@"what" flag:@"w"];
    NSArray *options = @[ flarn, barf, quone, xyzzy, syn, ack, what ];
    CLKOptionGroup *subgroupQuoneXyzzy = [CLKOptionGroup groupForOptionsNamed:@[ @"quone", @"xyzzy" ]];
    CLKOptionGroup *subgroupSynAck = [CLKOptionGroup groupForOptionsNamed:@[ @"syn", @"ack" ]];
    CLKOptionGroup *mutexGroup = [CLKOptionGroup mutexedGroupForOptionsNamed:@[ @"flarn", @"barf" ] subgroups:@[ subgroupQuoneXyzzy, subgroupSynAck ] required:NO];
    
    CLKArgumentParser *parser = [CLKArgumentParser parserWithArgumentVector:@[ @"--flarn", @"--barf" ] options:options optionGroups:@[ mutexGroup ]];
    NSError *error = [NSError clk_CLKErrorWithCode:CLKErrorMutuallyExclusiveOptionsPresent description:@"--flarn --barf: mutually exclusive options encountered"];;
    ArgumentParserSpec *spec = [ArgumentParserSpec specWithErrors:@[ error ]];
    [self evaluateSpec:spec usingParser:parser];
    
    parser = [CLKArgumentParser parserWithArgumentVector:@[ @"--flarn", @"--quone" ] options:options optionGroups:@[ mutexGroup ]];
    error = [NSError clk_CLKErrorWithCode:CLKErrorMutuallyExclusiveOptionsPresent description:@"--flarn --quone: mutually exclusive options encountered"];;
    spec = [ArgumentParserSpec specWithErrors:@[ error ]];
    [self evaluateSpec:spec usingParser:parser];
    
    parser = [CLKArgumentParser parserWithArgumentVector:@[ @"--quone", @"--ack" ] options:options optionGroups:@[ mutexGroup ]];
    error = [NSError clk_CLKErrorWithCode:CLKErrorMutuallyExclusiveOptionsPresent description:@"--quone --ack: mutually exclusive options encountered"];;
    spec = [ArgumentParserSpec specWithErrors:@[ error ]];
    [self evaluateSpec:spec usingParser:parser];
    
    parser = [CLKArgumentParser parserWithArgumentVector:@[ @"--ack", @"--quone" ] options:options optionGroups:@[ mutexGroup ]];
    error = [NSError clk_CLKErrorWithCode:CLKErrorMutuallyExclusiveOptionsPresent description:@"--quone --ack: mutually exclusive options encountered"];;
    spec = [ArgumentParserSpec specWithErrors:@[ error ]];
    [self evaluateSpec:spec usingParser:parser];
    
    parser = [CLKArgumentParser parserWithArgumentVector:@[ @"--syn", @"--ack" ] options:options optionGroups:@[ mutexGroup ]];
    XCTAssertNotNil([parser parseArguments]);
    XCTAssertNil(parser.errors);
    
    parser = [CLKArgumentParser parserWithArgumentVector:@[ @"--barf", @"--xyzzy", @"--syn" ] options:options optionGroups:@[ mutexGroup ]];
    NSArray *errors = @[
        [NSError clk_CLKErrorWithCode:CLKErrorMutuallyExclusiveOptionsPresent description:@"--barf --xyzzy: mutually exclusive options encountered"],
        [NSError clk_CLKErrorWithCode:CLKErrorMutuallyExclusiveOptionsPresent description:@"--barf --syn: mutually exclusive options encountered"],
        [NSError clk_CLKErrorWithCode:CLKErrorMutuallyExclusiveOptionsPresent description:@"--xyzzy --syn: mutually exclusive options encountered"]
    ];
    
    spec = [ArgumentParserSpec specWithErrors:errors];
    [self evaluateSpec:spec usingParser:parser];
    
    parser = [CLKArgumentParser parserWithArgumentVector:@[ @"--what", @"--xyzzy", @"--syn" ] options:options optionGroups:@[ mutexGroup ]];
    error = [NSError clk_CLKErrorWithCode:CLKErrorMutuallyExclusiveOptionsPresent description:@"--xyzzy --syn: mutually exclusive options encountered"];;
    spec = [ArgumentParserSpec specWithErrors:@[ error ]];
    [self evaluateSpec:spec usingParser:parser];
}

- (void)testValidation_boringRequiredGroup
{
    CLKOption *flarn = [CLKOption optionWithName:@"flarn" flag:@"f"];
    CLKOption *barf = [CLKOption parameterOptionWithName:@"barf" flag:@"b"];
    CLKOption *xyzzy = [CLKOption optionWithName:@"xyzzy" flag:@"x"];
    CLKOptionGroup *group = [CLKOptionGroup groupForOptionsNamed:@[ @"flarn", @"barf" ] required:YES];
    
    CLKArgumentParser *parser = [CLKArgumentParser parserWithArgumentVector:@[] options:@[ flarn, barf, xyzzy ] optionGroups:@[ group ]];
    NSError *error = [NSError clk_CLKErrorWithCode:CLKErrorRequiredOptionNotProvided description:@"one or more of the following options must be provided: --flarn --barf"];
    ArgumentParserSpec *spec = [ArgumentParserSpec specWithErrors:@[ error ]];
    [self evaluateSpec:spec usingParser:parser];
    
    parser = [CLKArgumentParser parserWithArgumentVector:@[ @"--xyzzy" ] options:@[ flarn, barf, xyzzy ] optionGroups:@[ group ]];
    error = [NSError clk_CLKErrorWithCode:CLKErrorRequiredOptionNotProvided description:@"one or more of the following options must be provided: --flarn --barf"];
    spec = [ArgumentParserSpec specWithErrors:@[ error ]];
    [self evaluateSpec:spec usingParser:parser];
    
    parser = [CLKArgumentParser parserWithArgumentVector:@[ @"--flarn", @"--xyzzy" ] options:@[ flarn, barf, xyzzy ] optionGroups:@[ group ]];
    XCTAssertNotNil([parser parseArguments]);
    XCTAssertNil(parser.errors);
}

@end
