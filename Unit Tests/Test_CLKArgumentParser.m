//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "ArgumentParsingResultSpec.h"
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

@interface Test_CLKArgumentParser : XCTestCase

@end

@implementation Test_CLKArgumentParser

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
    
    ArgumentParsingResultSpec *spec = [ArgumentParsingResultSpec specWithEmptyManifest];
    [self performTestWithArgumentVector:@[] options:options spec:spec];
}

- (void)testUnrecognizedOption
{
    NSArray *options = @[
         [CLKOption optionWithName:@"bar" flag:@"b"],
    ];
    
    NSError *longError = [NSError clk_POSIXErrorWithCode:EINVAL description:@"unrecognized option: '--foo'"];
    NSError *shortError = [NSError clk_POSIXErrorWithCode:EINVAL description:@"unrecognized option: '-f'"];
    
    ArgumentParsingResultSpec *spec = [ArgumentParsingResultSpec specWithError:longError];
    [self performTestWithArgumentVector:@[ @"--foo", @"flarn" ] options:options spec:spec];
    
    spec = [ArgumentParsingResultSpec specWithError:longError];
    [self performTestWithArgumentVector:@[ @"--bar", @"--foo", @"flarn" ] options:options spec:spec];
    
    spec = [ArgumentParsingResultSpec specWithError:shortError];
    [self performTestWithArgumentVector:@[ @"-f", @"flarn" ] options:options spec:spec];
    
    spec = [ArgumentParsingResultSpec specWithError:shortError];
    [self performTestWithArgumentVector:@[ @"-b", @"-f", @"flarn" ] options:options spec:spec];
    
    spec = [ArgumentParsingResultSpec specWithErrors:@[ longError, shortError ]];
    [self performTestWithArgumentVector:@[ @"--foo", @"quone", @"-b", @"-f", @"flarn" ] options:options spec:spec];
}

- (void)testEmptyOptionsArray
{
    ArgumentParsingResultSpec *spec = [ArgumentParsingResultSpec specWithEmptyManifest];
    [self performTestWithArgumentVector:@[] options:@[] spec:spec];
    
    spec = [ArgumentParsingResultSpec specWithPositionalArguments:@[ @"flarn.txt" ]];
    [self performTestWithArgumentVector:@[ @"flarn.txt" ] options:@[] spec:spec];
    
    NSError *expectedError = [NSError clk_POSIXErrorWithCode:EINVAL description:@"unrecognized option: '--barf'"];
    spec = [ArgumentParsingResultSpec specWithError:expectedError];
    [self performTestWithArgumentVector:@[ @"--barf" ] options:@[] spec:spec];
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
    
    ArgumentParsingResultSpec *spec = [ArgumentParsingResultSpec specWithOptionManifest:expectedOptionManifest];
    [self performTestWithArgumentVector:argv options:options spec:spec];
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
    
    ArgumentParsingResultSpec *spec = [ArgumentParsingResultSpec specWithOptionManifest:expectedOptionManifest];
    [self performTestWithArgumentVector:argv options:options spec:spec];
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
    ArgumentParsingResultSpec *spec = [ArgumentParsingResultSpec specWithError:longError];
    [self performTestWithArgumentVector:argv options:options spec:spec];

    argv = @[ @"-b" ];
    spec = [ArgumentParsingResultSpec specWithError:shortError];
    [self performTestWithArgumentVector:argv options:options spec:spec];
    
    argv = @[ @"--flarn", @"quone", @"--barf" ];
    spec = [ArgumentParsingResultSpec specWithError:longError];
    [self performTestWithArgumentVector:argv options:options spec:spec];
    
    argv = @[ @"--flarn", @"quone", @"-b" ];
    spec = [ArgumentParsingResultSpec specWithError:shortError];
    [self performTestWithArgumentVector:argv options:options spec:spec];
    
    argv = @[ @"--flarn", @"--barf", @"what" ];
    NSError *error = [NSError clk_POSIXErrorWithCode:EINVAL description:@"expected argument but encountered option-like token '--barf'"];
    spec = [ArgumentParsingResultSpec specWithError:error];
    [self performTestWithArgumentVector:argv options:options spec:spec];
    
    argv = @[ @"--flarn", @"-b", @"what" ];
    error = [NSError clk_POSIXErrorWithCode:EINVAL description:@"expected argument but encountered option-like token '-b'"];
    spec = [ArgumentParsingResultSpec specWithError:error];
    [self performTestWithArgumentVector:argv options:options spec:spec];
    
    argv = @[ @"--flarn", @"-lol", @"what" ];
    error = [NSError clk_POSIXErrorWithCode:EINVAL description:@"expected argument but encountered option-like token '-lol'"];
    spec = [ArgumentParsingResultSpec specWithError:error];
    [self performTestWithArgumentVector:argv options:options spec:spec];
    
    argv = @[ @"--flarn", @"-0x0", @"what" ];
    error = [NSError clk_POSIXErrorWithCode:EINVAL description:@"expected argument but encountered option-like token '-0x0'"];
    spec = [ArgumentParsingResultSpec specWithError:error];
    [self performTestWithArgumentVector:argv options:options spec:spec];
    
    argv = @[ @"--flarn", @"--w hat", @"what" ];
    error = [NSError clk_POSIXErrorWithCode:EINVAL description:@"expected argument but encountered option-like token '--w hat'"];
    spec = [ArgumentParsingResultSpec specWithError:error];
    [self performTestWithArgumentVector:argv options:options spec:spec];
    
    argv = @[ @"--flarn", @"--barf", @"what", @"--flarn", @"-q" ];
    NSArray *errors = @[
        [NSError clk_POSIXErrorWithCode:EINVAL description:@"expected argument but encountered option-like token '--barf'"],
        [NSError clk_POSIXErrorWithCode:EINVAL description:@"expected argument but encountered option-like token '-q'"]
    ];
    
    spec = [ArgumentParsingResultSpec specWithErrors:errors];
    [self performTestWithArgumentVector:argv options:options spec:spec];
}

- (void)testFlaglessOptions
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
    
    ArgumentParsingResultSpec *spec = [ArgumentParsingResultSpec specWithOptionManifest:expectedOptionManifest];
    [self performTestWithArgumentVector:argv options:options spec:spec];
}

// very edge-casey
- (void)testSingleCharacterOptionNames
{
    NSArray *argv = @[ @"--a", @"-a", @"--b", @"-aa" ];
    NSArray *options = @[
        [CLKOption optionWithName:@"a" flag:@"a"],
        [CLKOption optionWithName:@"b" flag:nil],
        [CLKOption optionWithName:@"barf" flag:@"b"] // make sure this `-b` is not confused for `--b`
    ];
    
    NSDictionary *expectedOptionManifest = @{
        @"a" : @(4),
        @"b" : @(1)
    };
    
    ArgumentParsingResultSpec *spec = [ArgumentParsingResultSpec specWithOptionManifest:expectedOptionManifest];
    [self performTestWithArgumentVector:argv options:options spec:spec];
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
    
    ArgumentParsingResultSpec *spec = [ArgumentParsingResultSpec specWithOptionManifest:expectedOptionManifest positionalArguments:expectedPositionalArguments];
    [self performTestWithArgumentVector:argv options:options spec:spec];
}

- (void)testPositionalArguments_withRegisteredOptions_onlyPositionalArgv
{
    NSArray *argv = @[ @"/flarn.txt", @"/bort.txt" ];
    NSArray *options = @[
        [CLKOption parameterOptionWithName:@"foo" flag:@"f"],
        [CLKOption parameterOptionWithName:@"bar" flag:@"b"]
    ];
    
    ArgumentParsingResultSpec *spec = [ArgumentParsingResultSpec specWithPositionalArguments:argv];
    [self performTestWithArgumentVector:argv options:options spec:spec];
}

- (void)testPositionalArgumentsOnly_noRegisteredOptions
{
    NSArray *argv = @[ @"alpha", @"bravo", @"charlie" ];
    ArgumentParsingResultSpec *spec = [ArgumentParsingResultSpec specWithPositionalArguments:argv];
    [self performTestWithArgumentVector:argv options:@[] spec:spec];
}

- (void)testZeroLengthStringsInArgumentVector
{
    CLKOption *option = [CLKOption parameterOptionWithName:@"flarn" flag:@"f"];
    
    NSArray *argv = @[ @"--flarn", @"", @"what" ];
    NSError *error = [NSError clk_POSIXErrorWithCode:EINVAL description:@"encountered zero-length argument"];
    ArgumentParsingResultSpec *spec = [ArgumentParsingResultSpec specWithError:error];
    [self performTestWithArgumentVector:argv options:@[ option ] spec:spec];
    
    argv = @[ @"--flarn", @"barf", @"" ];
    error = [NSError clk_POSIXErrorWithCode:EINVAL description:@"encountered zero-length argument"];
    spec = [ArgumentParsingResultSpec specWithError:error];
    [self performTestWithArgumentVector:argv options:@[ option ] spec:spec];
    
    argv = @[ @"", @"--flarn", @"barf" ];
    error = [NSError clk_POSIXErrorWithCode:EINVAL description:@"encountered zero-length argument"];
    spec = [ArgumentParsingResultSpec specWithError:error];
    [self performTestWithArgumentVector:argv options:@[ option ] spec:spec];
    
    argv = @[ @"syn", @"", @"ack" ];
    error = [NSError clk_POSIXErrorWithCode:EINVAL description:@"encountered zero-length argument"];
    spec = [ArgumentParsingResultSpec specWithError:error];
    [self performTestWithArgumentVector:argv options:@[] spec:spec];
    
    argv = @[ @"", @"syn", @"ack", @"--flarn", @"" ];
    NSArray *errors = @[
        [NSError clk_POSIXErrorWithCode:EINVAL description:@"encountered zero-length argument"],
        [NSError clk_POSIXErrorWithCode:EINVAL description:@"encountered zero-length argument"]
    ];
    
    spec = [ArgumentParsingResultSpec specWithErrors:errors];
    [self performTestWithArgumentVector:argv options:@[ option ] spec:spec];
}

- (void)testMalformedOptionToken_whitespace
{
    NSArray *options = @[
        [CLKOption parameterOptionWithName:@"flarn" flag:@"f"],
        [CLKOption parameterOptionWithName:@"quone" flag:@"q"]
    ];
    
    NSArray *argv = @[ @"-w hat", @"--flarn", @"barf" ];
    NSError *error = [NSError clk_POSIXErrorWithCode:EINVAL description:@"unexpected token in argument vector: '-w hat'"];
    ArgumentParsingResultSpec *spec = [ArgumentParsingResultSpec specWithError:error];
    [self performTestWithArgumentVector:argv options:options spec:spec];
    
    argv = @[ @"--flarn", @"barf", @"-w :hat" ];
    error = [NSError clk_POSIXErrorWithCode:EINVAL description:@"unexpected token in argument vector: '-w :hat'"];
    spec = [ArgumentParsingResultSpec specWithError:error];
    [self performTestWithArgumentVector:argv options:options spec:spec];
    
    argv = @[ @"--flarn", @"barf", @"-q-one" ];
    error = [NSError clk_POSIXErrorWithCode:EINVAL description:@"unexpected token in argument vector: '-q-one'"];
    spec = [ArgumentParsingResultSpec specWithError:error];
    [self performTestWithArgumentVector:argv options:options spec:spec];
    
    argv = @[ @"-y o", @"--flarn", @"barf", @"-w :hat" ];
    NSArray *errors = @[
        [NSError clk_POSIXErrorWithCode:EINVAL description:@"unexpected token in argument vector: '-y o'"],
        [NSError clk_POSIXErrorWithCode:EINVAL description:@"unexpected token in argument vector: '-w :hat'"]
    ];

    spec = [ArgumentParsingResultSpec specWithErrors:errors];
    [self performTestWithArgumentVector:argv options:options spec:spec];
}

- (void)testOptionParsingSentinel
{
    CLKOption *flarn = [CLKOption parameterOptionWithName:@"flarn" flag:@"f"];
    CLKOption *barf = [CLKOption requiredParameterOptionWithName:@"barf" flag:@"b"];
    CLKOption *quone = [CLKOption optionWithName:@"quone" flag:@"q"];
    CLKOption *confound = [CLKOption parameterOptionWithName:@"confound" flag:@"c" required:NO recurrent:NO dependencies:@[ @"delivery" ] transformer:nil];
    CLKOption *delivery = [CLKOption parameterOptionWithName:@"delivery" flag:@"d"];
    
    /* sentinel alone in argv */
    
    NSArray *argv = @[ @"--" ];
    ArgumentParsingResultSpec *spec = [ArgumentParsingResultSpec specWithEmptyManifest];
    [self performTestWithArgumentVector:argv options:@[ flarn ] spec:spec];
    
    /* two `--` tokens in argv and nothing else */
    
    argv = @[ @"--", @"--" ];
    spec = [ArgumentParsingResultSpec specWithPositionalArguments:@[ @"--" ]];
    [self performTestWithArgumentVector:argv options:@[ flarn ] spec:spec];
    
    /* some basics -- option or option-like token after a switch */
    
    argv = @[ @"--quone", @"--", @"-xyzzy" ];
    spec = [ArgumentParsingResultSpec specWithOptionManifest:@{ @"quone" : @(1) } positionalArguments:@[ @"-xyzzy" ]];
    [self performTestWithArgumentVector:argv options:@[ quone ] spec:spec];
    
    argv = @[ @"--quone", @"--", @"--xyzzy" ];
    spec = [ArgumentParsingResultSpec specWithOptionManifest:@{ @"quone" : @(1) } positionalArguments:@[ @"--xyzzy" ]];
    [self performTestWithArgumentVector:argv options:@[ quone ] spec:spec];
    
    argv = @[ @"--quone", @"--", @"--quone" ];
    spec = [ArgumentParsingResultSpec specWithOptionManifest:@{ @"quone" : @(1) } positionalArguments:@[ @"--quone" ]];
    [self performTestWithArgumentVector:argv options:@[ quone ] spec:spec];
    
    argv = @[ @"--quone", @"--", @"-q" ];
    spec = [ArgumentParsingResultSpec specWithOptionManifest:@{ @"quone" : @(1) } positionalArguments:@[ @"-q" ]];
    [self performTestWithArgumentVector:argv options:@[ quone ] spec:spec];
    
    /* no constraints, parameter option separated from its argument by sentinel (success) */
    
    argv = @[ @"--flarn", @"--", @"what" ];
    spec = [ArgumentParsingResultSpec specWithOptionManifest:@{ @"flarn" : @[ @"what" ] }];
    [self performTestWithArgumentVector:argv options:@[ flarn ] spec:spec];
    
    argv = @[ @"--flarn", @"--", @"--quone" ]; // interpreting `--quone` as an argument, not an option
    spec = [ArgumentParsingResultSpec specWithOptionManifest:@{ @"flarn" : @[ @"--quone" ] }];
    [self performTestWithArgumentVector:argv options:@[ flarn ] spec:spec];
    
    argv = @[ @"--flarn", @"--", @"-q" ]; // interpreting `-q` as an argument, not an option
    spec = [ArgumentParsingResultSpec specWithOptionManifest:@{ @"flarn" : @[ @"-q" ] }];
    [self performTestWithArgumentVector:argv options:@[ flarn ] spec:spec];
    
    argv = @[ @"--flarn", @"--", @"--xyzzy" ]; // interpreting `--xyzzy` (unregistered) as an argument, not an option
    spec = [ArgumentParsingResultSpec specWithOptionManifest:@{ @"flarn" : @[ @"--xyzzy" ] }];
    [self performTestWithArgumentVector:argv options:@[ flarn ] spec:spec];
    
    argv = @[ @"--flarn", @"--", @"-x" ]; // interpreting `-x` (unregistered) as an argument, not an option
    spec = [ArgumentParsingResultSpec specWithOptionManifest:@{ @"flarn" : @[ @"-x" ] }];
    [self performTestWithArgumentVector:argv options:@[ flarn ] spec:spec];
    
    /* no constraints, sentinel at argv.firstObject (success) */
    
    argv = @[ @"--", @"-q", @"--flarn", @"what" ];
    spec = [ArgumentParsingResultSpec specWithPositionalArguments:@[ @"-q", @"--flarn", @"what" ]];
    [self performTestWithArgumentVector:argv options:@[ flarn, quone ] spec:spec];
    
    /* no constraints, sentinel at argv.lastObject (success) */
    
    argv = @[ @"-q", @"--flarn", @"what", @"--" ];
    NSDictionary *expectedOptionManifest = @{
        @"flarn" : @[ @"what" ],
        @"quone" : @(1)
    };
    
    spec = [ArgumentParsingResultSpec specWithOptionManifest:expectedOptionManifest];
    [self performTestWithArgumentVector:argv options:@[ flarn, quone ] spec:spec];
    
    /* two `--` tokens in argv separated by stuff */
    
    argv = @[ @"--flarn", @"what", @"--", @"-x", @"--", @"y"];
    spec = [ArgumentParsingResultSpec specWithOptionManifest:@{ @"flarn" : @[ @"what" ] } positionalArguments:@[ @"-x", @"--", @"y" ]];
    [self performTestWithArgumentVector:argv options:@[ flarn ] spec:spec];
    
    /* required option appears after sentinel (error) */
    
    argv = @[ @"--flarn", @"what", @"--", @"--barf" ];
    spec = [ArgumentParsingResultSpec specWithCLKErrorCode:CLKErrorRequiredOptionNotProvided description:@"--barf: required option not provided"];
    [self performTestWithArgumentVector:argv options:@[ flarn, barf ] spec:spec];
    
    /* option declaring dependency provided before sentinel, dependency provided after sentinel (error) */
    
    argv = @[ @"--confound", @"acme", @"--", @"--delivery", @"station" ];
    spec = [ArgumentParsingResultSpec specWithCLKErrorCode:CLKErrorRequiredOptionNotProvided description:@"--delivery is required when using --confound"];
    [self performTestWithArgumentVector:argv options:@[ confound, delivery ] spec:spec];
    
    /* option declaring dependency provided after sentinel, dependency not provided before sentinel (success) */
    
    argv = @[ @"--flarn", @"acme", @"--", @"--confound", @"station" ];
    spec = [ArgumentParsingResultSpec specWithOptionManifest:@{ @"flarn" : @[ @"acme" ] } positionalArguments:@[ @"--confound", @"station" ]];
    [self performTestWithArgumentVector:argv options:@[ flarn, confound, delivery ] spec:spec];
    
    /* mutually exclusive options divided by sentinel (success) */
    
    CLKOptionGroup *mutex = [CLKOptionGroup mutexedGroupForOptionsNamed:@[ @"flarn", @"quone" ]];
    argv = @[ @"--flarn", @"acme", @"--", @"--quone", @"station" ];
    spec = [ArgumentParsingResultSpec specWithOptionManifest:@{ @"flarn" : @[ @"acme" ] } positionalArguments:@[ @"--quone", @"station" ]];
    [self performTestWithArgumentVector:argv options:@[ flarn, quone ] optionGroups:@[ mutex ] spec:spec];
    
    /* required group member provided after sentinel (error) */
    
    CLKOptionGroup *requiredGroup = [CLKOptionGroup requiredGroupForOptionsNamed:@[ @"quone", @"delivery" ]];
    argv = @[ @"--flarn", @"acme", @"--", @"--quone", @"xyzzy" ];
    spec = [ArgumentParsingResultSpec specWithCLKErrorCode:CLKErrorRequiredOptionNotProvided description:@"one or more of the following options must be provided: --quone --delivery"];
    [self performTestWithArgumentVector:argv options:@[ flarn, quone, delivery ] optionGroups:@[ requiredGroup ] spec:spec];
    
    /* zero-length argument provided after sentinel */
    argv = @[ @"--flarn", @"acme", @"--", @"", @"station" ];
    NSError *error = [NSError clk_POSIXErrorWithCode:EINVAL description:@"encountered zero-length argument"];
    spec = [ArgumentParsingResultSpec specWithError:error];
    [self performTestWithArgumentVector:argv options:@[ flarn ] spec:spec];
}

- (void)testNonSentinelOrphanedDashes
{
    NSArray *options = @[
        [CLKOption parameterOptionWithName:@"flarn" flag:@"f"],
        [CLKOption optionWithName:@"barf" flag:@"b"]
    ];
    
    NSArray *argv = @[ @"-" ];
    ArgumentParsingResultSpec *spec = [ArgumentParsingResultSpec specWithPositionalArguments:argv];
    [self performTestWithArgumentVector:argv options:options spec:spec];
    
    argv = @[ @"-", @"-" ];
    spec = [ArgumentParsingResultSpec specWithPositionalArguments:argv];
    [self performTestWithArgumentVector:argv options:options spec:spec];
    
    argv = @[ @"-", @"quone" ];
    spec = [ArgumentParsingResultSpec specWithPositionalArguments:argv];
    [self performTestWithArgumentVector:argv options:options spec:spec];
    
    argv = @[ @"quone", @"-" ];
    spec = [ArgumentParsingResultSpec specWithPositionalArguments:argv];
    [self performTestWithArgumentVector:argv options:options spec:spec];
    
    argv = @[ @"-b", @"-", @"-b" ];
    spec = [ArgumentParsingResultSpec specWithOptionManifest:@{ @"barf" : @(2) } positionalArguments:@[ @"-" ]];
    [self performTestWithArgumentVector:argv options:options spec:spec];
    
    argv = @[ @"-", @"-b", @"-" ];
    spec = [ArgumentParsingResultSpec specWithOptionManifest:@{ @"barf" : @(1) } positionalArguments:@[ @"-", @"-" ]];
    [self performTestWithArgumentVector:argv options:options spec:spec];
    
    argv = @[ @"-", @"--flarn", @"-" ];
    NSDictionary *expectedOptionManifest = @{
        @"flarn" : @[ @"-" ],
    };
    
    spec = [ArgumentParsingResultSpec specWithOptionManifest:expectedOptionManifest positionalArguments:@[ @"-" ]];
    [self performTestWithArgumentVector:argv options:options spec:spec];
    
    argv = @[ @"-", @"--flarn", @"-" ];
    expectedOptionManifest = @{
        @"flarn" : @[ @"-" ],
    };
    
    spec = [ArgumentParsingResultSpec specWithOptionManifest:expectedOptionManifest positionalArguments:@[ @"-" ]];
    [self performTestWithArgumentVector:argv options:options spec:spec];
    
    argv = @[ @"quone", @"---", @"xyzzy"];
    NSError *error = [NSError clk_POSIXErrorWithCode:EINVAL description:@"unrecognized option: '---'"];
    spec = [ArgumentParsingResultSpec specWithError:error];
    [self performTestWithArgumentVector:argv options:options spec:spec];
    
    argv = @[ @"quone", @"---", @"--flarn", @"-"];
    spec = [ArgumentParsingResultSpec specWithError:error];
    [self performTestWithArgumentVector:argv options:options spec:spec];
}

- (void)testArgumentTransformation
{
    NSArray *argv = @[ @"--strange", @"7", @"--aeons", @"819", @"/fatum/iustum/stultorum" ];
    CLKIntArgumentTransformer *transformer = [CLKIntArgumentTransformer transformer];
    CLKOption *strange = [CLKOption parameterOptionWithName:@"strange" flag:@"s" required:NO recurrent:NO dependencies:nil transformer:transformer];
    CLKOption *aeons = [CLKOption parameterOptionWithName:@"aeons" flag:@"a" required:NO recurrent:NO dependencies:nil transformer:transformer];
    NSArray *options = @[ strange, aeons ];
    
    NSDictionary *expectedOptionManifest = @{
        @"strange" : @[ @(7) ],
        @"aeons" : @[ @(819) ],
    };
    
    NSArray *expectedPositionalArguments = @[ @"/fatum/iustum/stultorum" ];
    
    ArgumentParsingResultSpec *spec = [ArgumentParsingResultSpec specWithOptionManifest:expectedOptionManifest positionalArguments:expectedPositionalArguments];
    [self performTestWithArgumentVector:argv options:options spec:spec];
}

- (void)testArgumentTransformationFailure
{
    NSArray *argv = @[ @"--acme", @"station", @"--confound", @"819", @"/fatum/iustum/stultorum" ];
    NSError *confoundError = [NSError clk_POSIXErrorWithCode:EINVAL description:@"confound error"];
    StuntTransformer *confoundTransformer = [[[StuntTransformer alloc] initWithError:confoundError] autorelease];
    NSArray *options = @[
        [CLKOption parameterOptionWithName:@"acme" flag:@"a" required:NO recurrent:NO dependencies:nil transformer:[CLKArgumentTransformer transformer]],
        [CLKOption parameterOptionWithName:@"confound" flag:@"c" required:NO recurrent:NO dependencies:nil transformer:confoundTransformer]
    ];
    
    ArgumentParsingResultSpec *spec = [ArgumentParsingResultSpec specWithError:confoundError];
    [self performTestWithArgumentVector:argv options:options spec:spec];
}

- (void)testComplexMix
{
    // organized by how they should be interpreted by the parser
    NSArray *argv = @[
        @"acme",
        @"--syn", @"819",
        @"--xyzzy",
        @"-",
        @"thrud",
        @"-a", @"hack",
        @"-x",
        @"-xpx",
#warning use assign form
//        @"-s", @"-666",
        @"--noise", @"ex cathedra",
        @"--quone",
        @"confound", @"delivery",
        @"--",
        @"-wormfood", @"--dude"
    ];
    
    NSArray *options = @[
         [CLKOption parameterOptionWithName:@"ack" flag:@"a"],
         [CLKOption parameterOptionWithName:@"noise" flag:@"n" required:NO recurrent:NO dependencies:nil transformer:nil],
         [CLKOption parameterOptionWithName:@"ghost" flag:@"g"], // not provided in argv
         [CLKOption parameterOptionWithName:@"syn" flag:@"s" required:NO recurrent:YES dependencies:nil transformer:[CLKIntArgumentTransformer transformer]],
         [CLKOption optionWithName:@"quone" flag:@"q" dependencies:@[ @"noise" ]],
         [CLKOption optionWithName:@"xyzzy" flag:@"x"],
         [CLKOption optionWithName:@"spline" flag:@"p"],
    ];
    
    NSDictionary *expectedOptionManifest = @{
        @"xyzzy" : @(4),
        @"spline" : @(1),
        @"syn" : @[ @(819) ],
        @"ack" : @[ @"hack" ],
        @"noise" : @[ @"ex cathedra" ],
        @"quone" : @(1)
    };
    
    NSArray *expectedPositionalArguments = @[ @"acme", @"-", @"thrud", @"confound", @"delivery", @"-wormfood", @"--dude" ];
    
    ArgumentParsingResultSpec *spec = [ArgumentParsingResultSpec specWithOptionManifest:expectedOptionManifest positionalArguments:expectedPositionalArguments];
    [self performTestWithArgumentVector:argv options:options spec:spec];
}

- (void)testMultipleMixedErrors
{
    CLKOption *flarn = [CLKOption parameterOptionWithName:@"flarn" flag:@"f" required:NO recurrent:YES dependencies:nil transformer:nil];
    
    NSArray *argv = @[
        @"-o k", // malformed token
        @"--xyzzy", // unrecognized option
        @"-x", // unrecognized option
        @"--flarn", @"", // zero-length argument
        @"--flarn", @"-f", // expected argument (option-like token)
        @"--flarn" // expected argument (end of vector)
    ];
    
    NSArray *errors = @[
        [NSError clk_POSIXErrorWithCode:EINVAL description:@"unexpected token in argument vector: '-o k'"],
        [NSError clk_POSIXErrorWithCode:EINVAL description:@"unrecognized option: '--xyzzy'"],
        [NSError clk_POSIXErrorWithCode:EINVAL description:@"unrecognized option: '-x'"],
        [NSError clk_POSIXErrorWithCode:EINVAL description:@"encountered zero-length argument"],
        [NSError clk_POSIXErrorWithCode:EINVAL description:@"expected argument but encountered option-like token '-f'"],
        [NSError clk_POSIXErrorWithCode:EINVAL description:@"expected argument for option '--flarn'"]
    ];
    
    ArgumentParsingResultSpec *spec = [ArgumentParsingResultSpec specWithErrors:errors];
    [self performTestWithArgumentVector:argv options:@[ flarn ] spec:spec];
}

- (void)testParserReuseNotAllowed
{
    CLKArgumentParser *parser = [CLKArgumentParser parserWithArgumentVector:@[] options:@[]];
    CLKArgumentManifest *manifest = [parser parseArguments];
    XCTAssertNotNil(manifest);
    XCTAssertThrows([parser parseArguments]);
    
    CLKOption *flarn = [CLKOption requiredParameterOptionWithName:@"flarn" flag:@"f"];
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

@end
