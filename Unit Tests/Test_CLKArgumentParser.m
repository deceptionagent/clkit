//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "ArgumentParsingResultSpec.h"
#import "CLKArgumentManifest.h"
#import "CLKArgumentManifest_Private.h"
#import "CLKArgumentParser.h"
#import "CLKArgumentTransformer.h"
#import "CLKOption.h"
#import "CLKOptionGroup.h"
#import "NSError+CLKAdditions.h"
#import "XCTestCase+CLKAdditions.h"


NS_ASSUME_NONNULL_BEGIN

@interface StuntTransformer : CLKArgumentTransformer

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)transformer NS_UNAVAILABLE;

- (instancetype)initWithError:(NSError *)error NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END

@implementation StuntTransformer
{
    NSError *_error;
}

- (instancetype)initWithError:(NSError *)error
{
    self = [super init];
    if (self != nil) {
        _error = [error retain];
    }
    
    return self;
}

- (void)dealloc
{
    [_error release];
    [super dealloc];
}

- (id)transformedArgument:(__unused NSString *)argument error:(NSError **)outError
{
    NSParameterAssert(outError != nil);
    *outError = _error;
    return nil;
}

@end

NS_ASSUME_NONNULL_BEGIN

#pragma mark -

@interface Test_CLKArgumentParser : XCTestCase

- (void)evaluateSpec:(ArgumentParsingResultSpec *)spec usingParser:(CLKArgumentParser *)parser;

@end

NS_ASSUME_NONNULL_END

@implementation Test_CLKArgumentParser

- (void)evaluateSpec:(ArgumentParsingResultSpec *)spec usingParser:(CLKArgumentParser *)parser
{
    CLKArgumentManifest *manifest = [parser parseArguments];
    if (spec.parserShouldSucceed) {
        XCTAssertNotNil(manifest);
        XCTAssertNil(parser.errors);
        XCTAssertEqualObjects(manifest.optionManifest, spec.optionManifest);
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

- (void)test_debugDescription
{
    NSArray *argv = @[ @"--flarn", @"--barf" ];
    CLKArgumentParser *parser = [CLKArgumentParser parserWithArgumentVector:argv options:@[]];
    XCTAssertEqualObjects(parser.debugDescription, ([NSString stringWithFormat:@"<CLKArgumentParser: %p> { state: 0 | argvec: %@ }", parser, argv]));
}

- (void)testEmptyArgv
{
    NSArray *options = @[
         [CLKOption parameterOptionWithName:@"foo" flag:@"f"],
    ];
    
    CLKArgumentParser *parser = [CLKArgumentParser parserWithArgumentVector:@[] options:options];
    ArgumentParsingResultSpec *spec = [ArgumentParsingResultSpec specWithOptionManifest:@{} positionalArguments:@[]];
    [self evaluateSpec:spec usingParser:parser];
}

- (void)testUnrecognizedOption
{
    NSArray *options = @[
         [CLKOption optionWithName:@"bar" flag:@"b"],
    ];
    
    NSError *longError = [NSError clk_POSIXErrorWithCode:EINVAL description:@"unrecognized option: '--foo'"];
    NSError *shortError = [NSError clk_POSIXErrorWithCode:EINVAL description:@"unrecognized option: '-f'"];
    
    CLKArgumentParser *parser = [CLKArgumentParser parserWithArgumentVector:@[ @"--foo", @"flarn" ] options:options];
    ArgumentParsingResultSpec *spec = [ArgumentParsingResultSpec specWithErrors:@[ longError ]];
    [self evaluateSpec:spec usingParser:parser];
    
    parser = [CLKArgumentParser parserWithArgumentVector:@[ @"--bar", @"--foo", @"flarn" ] options:options];
    spec = [ArgumentParsingResultSpec specWithErrors:@[ longError ]];
    [self evaluateSpec:spec usingParser:parser];
    
    parser = [CLKArgumentParser parserWithArgumentVector:@[ @"-f", @"flarn" ] options:options];
    spec = [ArgumentParsingResultSpec specWithErrors:@[ shortError ]];
    [self evaluateSpec:spec usingParser:parser];
    
    parser = [CLKArgumentParser parserWithArgumentVector:@[ @"-b", @"-f", @"flarn" ] options:options];
    spec = [ArgumentParsingResultSpec specWithErrors:@[ shortError ]];
    [self evaluateSpec:spec usingParser:parser];
}

- (void)testEmptyOptionsArray
{
    CLKArgumentParser *parser = [CLKArgumentParser parserWithArgumentVector:@[] options:@[]];
    ArgumentParsingResultSpec *spec = [ArgumentParsingResultSpec specWithOptionManifest:@{} positionalArguments:@[]];
    [self evaluateSpec:spec usingParser:parser];
    
    parser = [CLKArgumentParser parserWithArgumentVector:@[ @"flarn.txt" ] options:@[]];
    spec = [ArgumentParsingResultSpec specWithOptionManifest:@{} positionalArguments:@[ @"flarn.txt" ]];
    [self evaluateSpec:spec usingParser:parser];
    
    parser = [CLKArgumentParser parserWithArgumentVector:@[ @"--barf" ] options:@[]];
    NSError *expectedError = [NSError clk_POSIXErrorWithCode:EINVAL description:@"unrecognized option: '--barf'"];
    spec = [ArgumentParsingResultSpec specWithErrors:@[ expectedError ]];
    [self evaluateSpec:spec usingParser:parser];
}

- (void)testSwitchOptions
{
    NSArray *argv = @[ @"--foo", @"-f", @"-bfb", @"-qqq",  @"--syn-ack", @"--ack--syn" ];
    NSArray *options = @[
        [CLKOption optionWithName:@"foo" flag:@"f"],
        [CLKOption optionWithName:@"bar" flag:@"b"],
        [CLKOption optionWithName:@"quone" flag:@"q"],
        [CLKOption optionWithName:@"syn-ack" flag:@"s"],
        [CLKOption optionWithName:@"ack--syn" flag:@"a"]
    ];
    
    NSDictionary *expectedOptionManifest = @{
        @"foo" : @(3),
        @"bar" : @(2),
        @"quone" : @(3),
        @"syn-ack" : @(1),
        @"ack--syn" : @(1)
    };
    
    CLKArgumentParser *parser = [CLKArgumentParser parserWithArgumentVector:argv options:options];
    ArgumentParsingResultSpec *spec = [ArgumentParsingResultSpec specWithOptionManifest:expectedOptionManifest positionalArguments:@[]];
    [self evaluateSpec:spec usingParser:parser];
}

- (void)testParameterOptions
{
    NSArray *argv = @[ @"--foo", @"alpha", @"-f", @"bravo", @"-b", @"charlie", @"--syn-ack", @"quone", @"--ack--syn", @"xyzzy" ];
    NSArray *options = @[
        [CLKOption parameterOptionWithName:@"foo" flag:@"f" required:NO recurrent:YES dependencies:nil transformer:nil],
        [CLKOption parameterOptionWithName:@"bar" flag:@"b"],
        [CLKOption parameterOptionWithName:@"syn-ack" flag:@"s"],
        [CLKOption parameterOptionWithName:@"ack--syn" flag:@"a"]
    ];
    
    NSDictionary *expectedOptionManifest = @{
        @"foo" : @[ @"alpha", @"bravo" ],
        @"bar" : @[ @"charlie" ],
        @"syn-ack" : @[ @"quone" ],
        @"ack--syn" : @[ @"xyzzy" ]
    };
    
    CLKArgumentParser *parser = [CLKArgumentParser parserWithArgumentVector:argv options:options];
    ArgumentParsingResultSpec *spec = [ArgumentParsingResultSpec specWithOptionManifest:expectedOptionManifest positionalArguments:@[]];
    [self evaluateSpec:spec usingParser:parser];
}

- (void)testParameterOptions_argumentNotProvided
{
    NSArray *options = @[
        [CLKOption parameterOptionWithName:@"flarn" flag:@"f"],
        [CLKOption parameterOptionWithName:@"barf" flag:@"b"]
    ];
    
    NSError *longError = [NSError clk_POSIXErrorWithCode:EINVAL description:@"expected argument for option '--barf'"];
    NSError *shortError = [NSError clk_POSIXErrorWithCode:EINVAL description:@"expected argument for option '-b'"];
    
    NSArray *argv = @[ @"--barf" ];
    CLKArgumentParser *parser = [CLKArgumentParser parserWithArgumentVector:argv options:options];
    ArgumentParsingResultSpec *spec = [ArgumentParsingResultSpec specWithErrors:@[ longError ]];
    [self evaluateSpec:spec usingParser:parser];
    
    argv = @[ @"-b" ];
    parser = [CLKArgumentParser parserWithArgumentVector:argv options:options];
    spec = [ArgumentParsingResultSpec specWithErrors:@[ shortError ]];
    [self evaluateSpec:spec usingParser:parser];
    
    argv = @[ @"--flarn", @"quone", @"--barf" ];
    parser = [CLKArgumentParser parserWithArgumentVector:argv options:options];
    spec = [ArgumentParsingResultSpec specWithErrors:@[ longError ]];
    [self evaluateSpec:spec usingParser:parser];
    
    argv = @[ @"--flarn", @"quone", @"-b" ];
    parser = [CLKArgumentParser parserWithArgumentVector:argv options:options];
    spec = [ArgumentParsingResultSpec specWithErrors:@[ shortError ]];
    [self evaluateSpec:spec usingParser:parser];
    
    argv = @[ @"--flarn", @"--barf", @"what" ];
    parser = [CLKArgumentParser parserWithArgumentVector:argv options:options];
    NSError *error = [NSError clk_POSIXErrorWithCode:EINVAL description:@"expected argument but encountered option-like token '--barf'"];
    spec = [ArgumentParsingResultSpec specWithErrors:@[ error ]];
    [self evaluateSpec:spec usingParser:parser];
    
    argv = @[ @"--flarn", @"-b", @"what" ];
    parser = [CLKArgumentParser parserWithArgumentVector:argv options:options];
    error = [NSError clk_POSIXErrorWithCode:EINVAL description:@"expected argument but encountered option-like token '-b'"];
    spec = [ArgumentParsingResultSpec specWithErrors:@[ error ]];
    [self evaluateSpec:spec usingParser:parser];
    
    argv = @[ @"--flarn", @"-lol", @"what" ];
    parser = [CLKArgumentParser parserWithArgumentVector:argv options:options];
    error = [NSError clk_POSIXErrorWithCode:EINVAL description:@"expected argument but encountered option-like token '-lol'"];
    spec = [ArgumentParsingResultSpec specWithErrors:@[ error ]];
    [self evaluateSpec:spec usingParser:parser];
    
    argv = @[ @"--flarn", @"-0x0", @"what" ];
    parser = [CLKArgumentParser parserWithArgumentVector:argv options:options];
    error = [NSError clk_POSIXErrorWithCode:EINVAL description:@"expected argument but encountered option-like token '-0x0'"];
    spec = [ArgumentParsingResultSpec specWithErrors:@[ error ]];
    [self evaluateSpec:spec usingParser:parser];
    
    argv = @[ @"--flarn", @"--w hat", @"what" ];
    parser = [CLKArgumentParser parserWithArgumentVector:argv options:options];
    error = [NSError clk_POSIXErrorWithCode:EINVAL description:@"expected argument but encountered option-like token '--w hat'"];
    spec = [ArgumentParsingResultSpec specWithErrors:@[ error ]];
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
    ArgumentParsingResultSpec *spec = [ArgumentParsingResultSpec specWithOptionManifest:expectedOptionManifest positionalArguments:@[]];
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
    ArgumentParsingResultSpec *spec = [ArgumentParsingResultSpec specWithOptionManifest:expectedOptionManifest positionalArguments:@[]];
    [self evaluateSpec:spec usingParser:parser];
}

- (void)testPositionalArguments_withRegisteredOptions
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
    ArgumentParsingResultSpec *spec = [ArgumentParsingResultSpec specWithOptionManifest:expectedOptionManifest positionalArguments:expectedPositionalArguments];
    [self evaluateSpec:spec usingParser:parser];
}

- (void)testPositionalArguments_withRegisteredOptions_onlyPositionalArgv
{
    NSArray *argv = @[ @"/flarn.txt", @"/bort.txt" ];
    NSArray *options = @[
        [CLKOption parameterOptionWithName:@"foo" flag:@"f"],
        [CLKOption parameterOptionWithName:@"bar" flag:@"b"]
    ];
    
    CLKArgumentParser *parser = [CLKArgumentParser parserWithArgumentVector:argv options:options];
    ArgumentParsingResultSpec *spec = [ArgumentParsingResultSpec specWithOptionManifest:@{} positionalArguments:argv];
    [self evaluateSpec:spec usingParser:parser];
}

- (void)testPositionalArgumentsOnly_noRegisteredOptions
{
    NSArray *argv = @[ @"alpha", @"bravo", @"charlie" ];
    CLKArgumentParser *parser = [CLKArgumentParser parserWithArgumentVector:argv options:@[]];
    ArgumentParsingResultSpec *spec = [ArgumentParsingResultSpec specWithOptionManifest:@{} positionalArguments:argv];
    [self evaluateSpec:spec usingParser:parser];
}

- (void)testZeroLengthStringsInArgumentVector
{
    CLKOption *option = [CLKOption parameterOptionWithName:@"foo" flag:@"f"];
    
    NSArray *argv = @[ @"--foo", @"", @"what" ];
    CLKArgumentParser *parser = [CLKArgumentParser parserWithArgumentVector:argv options:@[ option ]];
    NSError *error = [NSError clk_POSIXErrorWithCode:EINVAL description:@"encountered zero-length argument"];
    ArgumentParsingResultSpec *spec = [ArgumentParsingResultSpec specWithErrors:@[ error ]];
    [self evaluateSpec:spec usingParser:parser];
    
    argv = @[ @"--foo", @"bar", @"" ];
    parser = [CLKArgumentParser parserWithArgumentVector:argv options:@[ option ]];
    error = [NSError clk_POSIXErrorWithCode:EINVAL description:@"encountered zero-length argument"];
    spec = [ArgumentParsingResultSpec specWithErrors:@[ error ]];
    [self evaluateSpec:spec usingParser:parser];
    
    argv = @[ @"", @"--foo", @"bar" ];
    parser = [CLKArgumentParser parserWithArgumentVector:argv options:@[ option ]];
    error = [NSError clk_POSIXErrorWithCode:EINVAL description:@"encountered zero-length argument"];
    spec = [ArgumentParsingResultSpec specWithErrors:@[ error ]];
    [self evaluateSpec:spec usingParser:parser];
    
    argv = @[ @"foo", @"", @"bar" ];
    parser = [CLKArgumentParser parserWithArgumentVector:argv options:@[]];
    error = [NSError clk_POSIXErrorWithCode:EINVAL description:@"encountered zero-length argument"];
    spec = [ArgumentParsingResultSpec specWithErrors:@[ error ]];
    [self evaluateSpec:spec usingParser:parser];
}

- (void)testOptionParsingSentinel
{
    CLKOption *flarn = [CLKOption parameterOptionWithName:@"flarn" flag:@"f"];
    CLKOption *barf = [CLKOption parameterOptionWithName:@"barf" flag:@"b" required:YES];
    CLKOption *quone = [CLKOption optionWithName:@"quone" flag:@"q"];
    CLKOption *confound = [CLKOption parameterOptionWithName:@"confound" flag:@"c" dependencies:@[ @"delivery" ]];
    CLKOption *delivery = [CLKOption parameterOptionWithName:@"delivery" flag:@"d"];
    
    /* sentinel alone in argv */
    
    NSArray *argv = @[ @"--" ];
    
    /* two `--` tokens in argv and nothing else */
    
    argv = @[ @"--", @"--" ];
    
    /* no constraints, parameter option separated from its argument by sentinel (success) */
    
    argv = @[ @"--flarn", @"--", @"what" ];
    
    argv = @[ @"--flarn", @"--", @"--quone" ]; // interpreting `--quone` as an argument, not an option
    
    argv = @[ @"--flarn", @"--", @"-q" ]; // interpreting `-q` as an argument, not an option
    
    argv = @[ @"--flarn", @"--", @"--xyzzy" ]; // interpreting `--xyzzy` (unregistered) as an argument, not an option
    
    argv = @[ @"--flarn", @"--", @"-x" ]; // interpreting `-x` (unregistered) as an argument, not an option
    
    /* no constraints, sentinel at argv.firstObject (success) */
    
    argv = @[ @"--", @"-q", @"--flarn", @"what" ];
    
    /* no constraints, sentinel at argv.lastObject (success) */
    
    argv = @[ @"-q", @"--flarn", @"what", @"--" ];

    /* two `--` tokens in argv separated by stuff */
    
    argv = @[ @"--flarn", @"what", @"--", @"-x", @"--", @"y"];
    
    /* required option appears after sentinel (error) */
    
    argv = @[ @"--flarn", @"what", @"--", @"--barf" ];
    
    /* option declaring dependency provided before sentinel, dependency provided after sentinel (error) */
    
    argv = @[ @"--confound", @"acme", @"--", @"--delivery", @"station" ];
    
    /* option declaring dependency provided after sentinel, dependency not provided before sentinel (success) */
    
    argv = @[ @"--flarn", @"acme", @"--", @"--confound", @"station" ];
    
    /* mutually exclusive options divided by sentinel (success) */
    
    CLKOptionGroup *mutex = [CLKOptionGroup mutexedGroupForOptionsNamed:@[ @"flarn", @"quone" ]];
    argv = @[ @"--flarn", @"acme", @"--", @"--quone", @"station" ];
    
    /* required group member provided after sentinel (error) */
    
    CLKOptionGroup *requiredGroup = [CLKOptionGroup groupForOptionsNamed:@[ @"confound", @"delivery" ] required:YES];
    argv = @[ @"--flarn", @"acme", @"--", @"--confound", @"station" ];
}

- (void)testNonSentinelOrphanedDashes
{
    NSArray *options = @[
        [CLKOption parameterOptionWithName:@"flarn" flag:@"f"],
        [CLKOption optionWithName:@"barf" flag:@"b"]
    ];
    
    NSArray *argv = @[ @"-" ];
    ArgumentParsingResultSpec *spec = [ArgumentParsingResultSpec specWithPositionalArguments:argv];
    CLKArgumentParser *parser = [CLKArgumentParser parserWithArgumentVector:argv options:options];
    [self evaluateSpec:spec usingParser:parser];
    
    argv = @[ @"-", @"-" ];
    spec = [ArgumentParsingResultSpec specWithPositionalArguments:argv];
    parser = [CLKArgumentParser parserWithArgumentVector:argv options:options];
    [self evaluateSpec:spec usingParser:parser];
    
    argv = @[ @"-", @"quone" ];
    spec = [ArgumentParsingResultSpec specWithPositionalArguments:argv];
    parser = [CLKArgumentParser parserWithArgumentVector:argv options:options];
    [self evaluateSpec:spec usingParser:parser];
    
    argv = @[ @"quone", @"-" ];
    spec = [ArgumentParsingResultSpec specWithPositionalArguments:argv];
    parser = [CLKArgumentParser parserWithArgumentVector:argv options:options];
    [self evaluateSpec:spec usingParser:parser];
    
    argv = @[ @"-b", @"-", @"-b" ];
    spec = [ArgumentParsingResultSpec specWithOptionManifest:@{ @"barf" : @(2) } positionalArguments:@[ @"-" ]];
    parser = [CLKArgumentParser parserWithArgumentVector:argv options:options];
    [self evaluateSpec:spec usingParser:parser];
    
    argv = @[ @"-", @"-b", @"-" ];
    spec = [ArgumentParsingResultSpec specWithOptionManifest:@{ @"barf" : @(1) } positionalArguments:@[ @"-", @"-" ]];
    parser = [CLKArgumentParser parserWithArgumentVector:argv options:options];
    [self evaluateSpec:spec usingParser:parser];

    argv = @[ @"-", @"--flarn", @"-" ];
    NSDictionary *expectedOptionManifest = @{
        @"flarn" : @[ @"-" ],
    };
    
    spec = [ArgumentParsingResultSpec specWithOptionManifest:expectedOptionManifest positionalArguments:@[ @"-" ]];
    parser = [CLKArgumentParser parserWithArgumentVector:argv options:options];
    [self evaluateSpec:spec usingParser:parser];
    
    argv = @[ @"-", @"--flarn", @"-" ];
    expectedOptionManifest = @{
        @"flarn" : @[ @"-" ],
    };
    
    spec = [ArgumentParsingResultSpec specWithOptionManifest:expectedOptionManifest positionalArguments:@[ @"-" ]];
    parser = [CLKArgumentParser parserWithArgumentVector:argv options:options];
    [self evaluateSpec:spec usingParser:parser];
    
    argv = @[ @"quone", @"---", @"xyzzy"];
    NSError *error = [NSError clk_POSIXErrorWithCode:EINVAL description:@"unrecognized option: '---'"];
    spec = [ArgumentParsingResultSpec specWithErrors:@[ error ]];
    parser = [CLKArgumentParser parserWithArgumentVector:argv options:options];
    [self evaluateSpec:spec usingParser:parser];
    
    argv = @[ @"quone", @"---", @"--flarn", @"-"];
    spec = [ArgumentParsingResultSpec specWithErrors:@[ error ]];
    parser = [CLKArgumentParser parserWithArgumentVector:argv options:options];
    [self evaluateSpec:spec usingParser:parser];
}

- (void)testNegativeNumericalArguments
{
    NSArray *options = @[
        [CLKOption parameterOptionWithName:@"flarn" flag:@"f"],
        [CLKOption optionWithName:@"barf" flag:@"b"]
    ];
    
    NSArray *argv = @[ @"-7" ];
    ArgumentParsingResultSpec *spec = [ArgumentParsingResultSpec specWithPositionalArguments:argv];
    CLKArgumentParser *parser = [CLKArgumentParser parserWithArgumentVector:argv options:options];
    [self evaluateSpec:spec usingParser:parser];
    
    argv = @[ @"-7", @"quone" ];
    spec = [ArgumentParsingResultSpec specWithPositionalArguments:argv];
    parser = [CLKArgumentParser parserWithArgumentVector:argv options:options];
    [self evaluateSpec:spec usingParser:parser];
    
    argv = @[ @"-4", @"-2.0" ];
    spec = [ArgumentParsingResultSpec specWithPositionalArguments:argv];
    parser = [CLKArgumentParser parserWithArgumentVector:argv options:options];
    [self evaluateSpec:spec usingParser:parser];
    
    argv = @[ @"-b", @"-0" ];
    spec = [ArgumentParsingResultSpec specWithOptionManifest:@{ @"barf" : @(1) } positionalArguments:@[ @"-0" ]];
    parser = [CLKArgumentParser parserWithArgumentVector:argv options:options];
    [self evaluateSpec:spec usingParser:parser];
    
    argv = @[ @"-0", @"-b" ];
    spec = [ArgumentParsingResultSpec specWithOptionManifest:@{ @"barf" : @(1) } positionalArguments:@[ @"-0" ]];
    parser = [CLKArgumentParser parserWithArgumentVector:argv options:options];
    [self evaluateSpec:spec usingParser:parser];
    
    argv = @[ @"--flarn", @"-7", ];
    spec = [ArgumentParsingResultSpec specWithOptionManifest:@{ @"flarn" : @[ @"-7" ] }];
    parser = [CLKArgumentParser parserWithArgumentVector:argv options:options];
    [self evaluateSpec:spec usingParser:parser];

    argv = @[ @"--flarn", @"-7", @"-b"];
    NSDictionary *expectedOptionManifest = @{
        @"flarn" : @[ @"-7" ],
        @"barf" : @(1)
    };
    
    spec = [ArgumentParsingResultSpec specWithOptionManifest:expectedOptionManifest];
    parser = [CLKArgumentParser parserWithArgumentVector:argv options:options];
    [self evaluateSpec:spec usingParser:parser];
    
    argv = @[ @"-7.7.7", @"--flarn", @"-4:2:0" ];
    spec = [ArgumentParsingResultSpec specWithOptionManifest:@{ @"flarn" : @[ @"-4:2:0" ] } positionalArguments:@[ @"-7.7.7" ]];
    parser = [CLKArgumentParser parserWithArgumentVector:argv options:options];
    [self evaluateSpec:spec usingParser:parser];
    
    argv = @[ @"--flarn", @"-4:2:0:6.6.6", @"-b" ];
    expectedOptionManifest = @{
        @"flarn" : @[ @"-4:2:0:6.6.6" ],
        @"barf" : @(1)
    };
    
    spec = [ArgumentParsingResultSpec specWithOptionManifest:expectedOptionManifest];
    parser = [CLKArgumentParser parserWithArgumentVector:argv options:options];
    [self evaluateSpec:spec usingParser:parser];

    argv = @[ @"--flarn", @"-7", @"-4:20" ];
    spec = [ArgumentParsingResultSpec specWithOptionManifest:@{ @"flarn" : @[ @"-7" ] } positionalArguments:@[ @"-4:20" ]];
    parser = [CLKArgumentParser parserWithArgumentVector:argv options:options];
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
    ArgumentParsingResultSpec *spec = [ArgumentParsingResultSpec specWithOptionManifest:expectedOptionManifest positionalArguments:expectedPositionalArguments];
    [self evaluateSpec:spec usingParser:parser];
}

- (void)testArgumentTransformationFailure
{
    NSArray *argv = @[ @"--acme", @"station", @"--confound", @"819", @"/fatum/iustum/stultorum" ];
    NSError *confoundError = [NSError clk_POSIXErrorWithCode:EINVAL description:@"confound error"];
    StuntTransformer *confoundTransformer = [[[StuntTransformer alloc] initWithError:confoundError] autorelease];
    NSArray *options = @[
        [CLKOption parameterOptionWithName:@"acme" flag:@"a" transformer:[CLKArgumentTransformer transformer]],
        [CLKOption parameterOptionWithName:@"confound" flag:@"c" transformer:confoundTransformer]
    ];
    
    CLKArgumentParser *parser = [CLKArgumentParser parserWithArgumentVector:argv options:options];
    ArgumentParsingResultSpec *spec = [ArgumentParsingResultSpec specWithErrors:@[ confoundError ]];
    [self evaluateSpec:spec usingParser:parser];
}

- (void)testComplexMix
{
    // organized by how they should be interpreted by the parser
    NSArray *argv = @[
        @"acme",
        @"--syn", @"aeons",
        @"--xyzzy",
        @"-",
        @"thrud",
        @"-a", @"hack",
        @"-x",
        @"-xpx",
        @"--syn", @"cathedra",
        @"--noise", @"819",
        @"--quone",
        @"confound", @"delivery"
    ];
    
    NSArray *options = @[
         [CLKOption parameterOptionWithName:@"ack" flag:@"a"],
         [CLKOption parameterOptionWithName:@"noise" flag:@"n" transformer:[CLKIntArgumentTransformer transformer]],
         [CLKOption parameterOptionWithName:@"ghost" flag:@"g"], // not provided in argv
         [CLKOption parameterOptionWithName:@"syn" flag:@"s" required:NO recurrent:YES dependencies:nil transformer:nil],
         [CLKOption optionWithName:@"quone" flag:@"q" dependencies:@[ @"noise" ]],
         [CLKOption optionWithName:@"xyzzy" flag:@"x"],
         [CLKOption optionWithName:@"spline" flag:@"p"],
    ];
    
    NSDictionary *expectedOptionManifest = @{
        @"xyzzy" : @(4),
        @"spline" : @(1),
        @"syn" : @[ @"aeons", @"cathedra" ],
        @"ack" : @[ @"hack" ],
        @"noise" : @[ @(819) ],
        @"quone" : @(1)
    };
    
    NSArray *expectedPositionalArguments = @[ @"acme", @"-", @"thrud", @"confound", @"delivery" ];
    
    CLKArgumentParser *parser = [CLKArgumentParser parserWithArgumentVector:argv options:options];
    ArgumentParsingResultSpec *spec = [ArgumentParsingResultSpec specWithOptionManifest:expectedOptionManifest positionalArguments:expectedPositionalArguments];
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

- (void)testUnregisteredGroupOptions
{
    NSArray *options = @[
         [CLKOption parameterOptionWithName:@"ack" flag:@"a"],
         [CLKOption parameterOptionWithName:@"syn" flag:@"s"],
    ];
    
    CLKOptionGroup *group = [CLKOptionGroup groupForOptionsNamed:@[ @"barf" ]];
    XCTAssertThrows([CLKArgumentParser parserWithArgumentVector:@[] options:options optionGroups:@[ group ]]);
    
    CLKOptionGroup *subgroup = [CLKOptionGroup groupForOptionsNamed:@[ @"barf" ]];
    group = [CLKOptionGroup mutexedGroupWithSubgroups:@[ subgroup ]];
    XCTAssertThrows([CLKArgumentParser parserWithArgumentVector:@[] options:options optionGroups:@[ group ]]);
}

- (void)testInvalidDependencies
{
    // dependencies can't reference unregistered options
    NSArray *options = @[
         [CLKOption parameterOptionWithName:@"ack" flag:@"a"],
         [CLKOption parameterOptionWithName:@"syn" flag:@"f" required:NO recurrent:NO dependencies:@[ @"flarn" ] transformer:nil]
    ];
    
    XCTAssertThrows([CLKArgumentParser parserWithArgumentVector:@[] options:options optionGroups:nil]);
    
    // switches can't be dependencies
    options = @[
         [CLKOption optionWithName:@"ack" flag:@"a"],
         [CLKOption parameterOptionWithName:@"syn" flag:@"f" required:NO recurrent:NO dependencies:@[ @"ack" ] transformer:nil]
    ];
    
    XCTAssertThrows([CLKArgumentParser parserWithArgumentVector:@[] options:options optionGroups:nil]);
}

#pragma mark -
#pragma mark Validation

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
    ArgumentParsingResultSpec *spec = [ArgumentParsingResultSpec specWithErrors:@[ error ]];
    [self evaluateSpec:spec usingParser:parser];
    
    parser = [CLKArgumentParser parserWithArgumentVector:@[ @"--alpha" ] options:options];
    error = [NSError clk_CLKErrorWithCode:CLKErrorRequiredOptionNotProvided description:@"--bravo: required option not provided"];;
    spec = [ArgumentParsingResultSpec specWithErrors:@[ error ]];
    [self evaluateSpec:spec usingParser:parser];
    
    NSDictionary *expectedOptionManifest = @{
        @"bravo" : @[ @"flarn" ]
    };
    
    parser = [CLKArgumentParser parserWithArgumentVector:@[ @"--bravo", @"flarn" ] options:options];
    spec = [ArgumentParsingResultSpec specWithOptionManifest:expectedOptionManifest positionalArguments:@[]];
    [self evaluateSpec:spec usingParser:parser];
}

- (void)testValidation_dependencies
{
    CLKOption *alpha = [CLKOption optionWithName:@"alpha" flag:@"a"];
    CLKOption *bravo = [CLKOption parameterOptionWithName:@"bravo" flag:@"b"];
    CLKOption *charlie = [CLKOption optionWithName:@"charlie" flag:@"c" dependencies:@[ @"bravo" ]];
    NSArray *options = @[ alpha, bravo, charlie ];
    
    CLKArgumentParser *parser = [CLKArgumentParser parserWithArgumentVector:@[ @"--charlie" ] options:options];
    NSError *error = [NSError clk_CLKErrorWithCode:CLKErrorRequiredOptionNotProvided description:@"--bravo is required when using --charlie"];;
    ArgumentParsingResultSpec *spec = [ArgumentParsingResultSpec specWithErrors:@[ error ]];
    [self evaluateSpec:spec usingParser:parser];
    
    NSDictionary *expectedOptionManifest = @{
        @"charlie" : @(1),
        @"bravo" : @[ @"flarn" ]
    };
    
    parser = [CLKArgumentParser parserWithArgumentVector:@[ @"--charlie", @"--bravo", @"flarn" ] options:options];
    spec = [ArgumentParsingResultSpec specWithOptionManifest:expectedOptionManifest positionalArguments:@[]];
    [self evaluateSpec:spec usingParser:parser];
}

- (void)testValidation_recurrent
{
    CLKOption *flarn = [CLKOption parameterOptionWithName:@"flarn" flag:@"f"];
    NSArray *argv = @[ @"--flarn", @"barf", @"--flarn", @"barf" ];
    
    CLKArgumentParser *parser = [CLKArgumentParser parserWithArgumentVector:argv options:@[ flarn ]];
    NSError *error = [NSError clk_CLKErrorWithCode:CLKErrorTooManyOccurrencesOfOption description:@"--flarn may not be provided more than once"];;
    ArgumentParsingResultSpec *spec = [ArgumentParsingResultSpec specWithErrors:@[ error ]];
    [self evaluateSpec:spec usingParser:parser];
    
    flarn = [CLKOption parameterOptionWithName:@"flarn" flag:@"f" required:NO recurrent:YES dependencies:nil transformer:nil];
    NSDictionary *expectedOptionManifest = @{
        @"flarn" : @[ @"barf", @"barf" ]
    };
    
    parser = [CLKArgumentParser parserWithArgumentVector:argv options:@[ flarn ] optionGroups:nil];
    spec = [ArgumentParsingResultSpec specWithOptionManifest:expectedOptionManifest positionalArguments:@[]];
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
    ArgumentParsingResultSpec *spec = [ArgumentParsingResultSpec specWithErrors:@[ error ]];
    [self evaluateSpec:spec usingParser:parser];
    
    parser = [CLKArgumentParser parserWithArgumentVector:@[ @"--flarn" ] options:options optionGroups:@[ group, requiredGroup ]];
    error = [NSError clk_CLKErrorWithCode:CLKErrorRequiredOptionNotProvided description:@"one or more of the following options must be provided: --quone --xyzzy"];;
    spec = [ArgumentParsingResultSpec specWithErrors:@[ error ]];
    [self evaluateSpec:spec usingParser:parser];
    
    NSDictionary *expectedOptionManifest = @{
        @"flarn" : @(1),
        @"quone" : @(1)
    };
    
    parser = [CLKArgumentParser parserWithArgumentVector:@[ @"--flarn", @"--quone" ] options:options optionGroups:@[ group, requiredGroup ]];
    spec = [ArgumentParsingResultSpec specWithOptionManifest:expectedOptionManifest positionalArguments:@[]];
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
    CLKOptionGroup *mutexedSubgroup = [CLKOptionGroup mutexedGroupForOptionsNamed:@[ @"flarn", @"barf" ]];
    CLKOptionGroup *subgroupQuoneXyzzy = [CLKOptionGroup groupForOptionsNamed:@[ @"quone", @"xyzzy" ]];
    CLKOptionGroup *subgroupSynAck = [CLKOptionGroup groupForOptionsNamed:@[ @"syn", @"ack" ]];
    CLKOptionGroup *mutexedGroup = [CLKOptionGroup mutexedGroupWithSubgroups:@[ mutexedSubgroup, subgroupQuoneXyzzy, subgroupSynAck ]];
    
    CLKArgumentParser *parser = [CLKArgumentParser parserWithArgumentVector:@[ @"--flarn", @"--barf" ] options:options optionGroups:@[ mutexedGroup ]];
    NSError *error = [NSError clk_CLKErrorWithCode:CLKErrorMutuallyExclusiveOptionsPresent description:@"--flarn --barf: mutually exclusive options encountered"];;
    ArgumentParsingResultSpec *spec = [ArgumentParsingResultSpec specWithErrors:@[ error ]];
    [self evaluateSpec:spec usingParser:parser];
    
    parser = [CLKArgumentParser parserWithArgumentVector:@[ @"--flarn", @"--quone" ] options:options optionGroups:@[ mutexedGroup ]];
    error = [NSError clk_CLKErrorWithCode:CLKErrorMutuallyExclusiveOptionsPresent description:@"--flarn --quone: mutually exclusive options encountered"];;
    spec = [ArgumentParsingResultSpec specWithErrors:@[ error ]];
    [self evaluateSpec:spec usingParser:parser];
    
    parser = [CLKArgumentParser parserWithArgumentVector:@[ @"--quone", @"--ack" ] options:options optionGroups:@[ mutexedGroup ]];
    error = [NSError clk_CLKErrorWithCode:CLKErrorMutuallyExclusiveOptionsPresent description:@"--quone --ack: mutually exclusive options encountered"];;
    spec = [ArgumentParsingResultSpec specWithErrors:@[ error ]];
    [self evaluateSpec:spec usingParser:parser];
    
    parser = [CLKArgumentParser parserWithArgumentVector:@[ @"--ack", @"--quone" ] options:options optionGroups:@[ mutexedGroup ]];
    error = [NSError clk_CLKErrorWithCode:CLKErrorMutuallyExclusiveOptionsPresent description:@"--quone --ack: mutually exclusive options encountered"];;
    spec = [ArgumentParsingResultSpec specWithErrors:@[ error ]];
    [self evaluateSpec:spec usingParser:parser];
    
    NSDictionary *expectedOptionManifest = @{
        @"syn" : @(1),
        @"ack" : @(1)
    };
    
    parser = [CLKArgumentParser parserWithArgumentVector:@[ @"--syn", @"--ack" ] options:options optionGroups:@[ mutexedGroup ]];
    spec = [ArgumentParsingResultSpec specWithOptionManifest:expectedOptionManifest positionalArguments:@[]];
    [self evaluateSpec:spec usingParser:parser];
    
    parser = [CLKArgumentParser parserWithArgumentVector:@[ @"--barf", @"--xyzzy", @"--syn" ] options:options optionGroups:@[ mutexedGroup ]];
    NSArray *errors = @[
        [NSError clk_CLKErrorWithCode:CLKErrorMutuallyExclusiveOptionsPresent description:@"--barf --xyzzy: mutually exclusive options encountered"],
        [NSError clk_CLKErrorWithCode:CLKErrorMutuallyExclusiveOptionsPresent description:@"--barf --syn: mutually exclusive options encountered"],
        [NSError clk_CLKErrorWithCode:CLKErrorMutuallyExclusiveOptionsPresent description:@"--xyzzy --syn: mutually exclusive options encountered"]
    ];
    
    spec = [ArgumentParsingResultSpec specWithErrors:errors];
    [self evaluateSpec:spec usingParser:parser];
    
    parser = [CLKArgumentParser parserWithArgumentVector:@[ @"--what", @"--xyzzy", @"--syn" ] options:options optionGroups:@[ mutexedGroup ]];
    error = [NSError clk_CLKErrorWithCode:CLKErrorMutuallyExclusiveOptionsPresent description:@"--xyzzy --syn: mutually exclusive options encountered"];;
    spec = [ArgumentParsingResultSpec specWithErrors:@[ error ]];
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
    ArgumentParsingResultSpec *spec = [ArgumentParsingResultSpec specWithErrors:@[ error ]];
    [self evaluateSpec:spec usingParser:parser];
    
    parser = [CLKArgumentParser parserWithArgumentVector:@[ @"--xyzzy" ] options:@[ flarn, barf, xyzzy ] optionGroups:@[ group ]];
    error = [NSError clk_CLKErrorWithCode:CLKErrorRequiredOptionNotProvided description:@"one or more of the following options must be provided: --flarn --barf"];
    spec = [ArgumentParsingResultSpec specWithErrors:@[ error ]];
    [self evaluateSpec:spec usingParser:parser];
    
    NSDictionary *expectedOptionManifest = @{
        @"flarn" : @(1),
        @"xyzzy" : @(1)
    };
    
    parser = [CLKArgumentParser parserWithArgumentVector:@[ @"--flarn", @"--xyzzy" ] options:@[ flarn, barf, xyzzy ] optionGroups:@[ group ]];
    spec = [ArgumentParsingResultSpec specWithOptionManifest:expectedOptionManifest positionalArguments:@[]];
    [self evaluateSpec:spec usingParser:parser];
}

@end
