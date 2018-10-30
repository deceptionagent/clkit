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

- (void)performTestWithArgumentVector:(NSArray<NSString *> *)argv options:(NSArray<CLKOption *> *)options spec:(ArgumentParsingResultSpec *)spec;
- (void)performTestWithArgumentVector:(NSArray<NSString *> *)argv
                              options:(NSArray<CLKOption *> *)options
                         optionGroups:(NSArray<CLKOptionGroup *> *)groups
                                 spec:(ArgumentParsingResultSpec *)spec;

- (void)evaluateSpec:(ArgumentParsingResultSpec *)spec usingParser:(CLKArgumentParser *)parser;

@end

NS_ASSUME_NONNULL_END

@implementation Test_CLKArgumentParser

- (void)performTestWithArgumentVector:(NSArray<NSString *> *)argv options:(NSArray<CLKOption *> *)options spec:(ArgumentParsingResultSpec *)spec
{
    [self performTestWithArgumentVector:argv options:options optionGroups:@[] spec:spec];
}

- (void)performTestWithArgumentVector:(NSArray<NSString *> *)argv
                              options:(NSArray<CLKOption *> *)options
                         optionGroups:(NSArray<CLKOptionGroup *> *)groups
                                 spec:(ArgumentParsingResultSpec *)spec
{
    CLKArgumentParser *parser = [CLKArgumentParser parserWithArgumentVector:argv options:options optionGroups:groups];
    [self evaluateSpec:spec usingParser:parser];
}

- (void)evaluateSpec:(ArgumentParsingResultSpec *)spec usingParser:(CLKArgumentParser *)parser
{
    CLKArgumentManifest *manifest = [parser parseArguments];
    if (spec.parserShouldSucceed) {
        XCTAssertNotNil(manifest);
        if (manifest == nil) {
            return;
        }
        
        XCTAssertNil(parser.errors);
        XCTAssertEqualObjects(manifest.optionManifest, spec.optionManifest);
        XCTAssertEqualObjects(manifest.positionalArguments, spec.positionalArguments);
    } else {
        XCTAssertNil(manifest);
        if (manifest != nil) {
            return;
        }
        
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
    NSArray *options =  @[
        [CLKOption parameterOptionWithName:@"flarn" flag:@"f"],
        [CLKOption parameterOptionWithName:@"what" flag:@"w"]
    ];
    
    NSArray *argv = @[ @"--w hat", @"barf" ];
    NSError *error = [NSError clk_POSIXErrorWithCode:EINVAL description:@"unexpected token in argument vector: '--w hat'"];
    ArgumentParsingResultSpec *spec = [ArgumentParsingResultSpec specWithError:error];
    [self performTestWithArgumentVector:argv options:options spec:spec];
    
    argv = @[ @"--what", @"barf", @"-w hat" ];
    error = [NSError clk_POSIXErrorWithCode:EINVAL description:@"unexpected token in argument vector: '-w hat'"];
    spec = [ArgumentParsingResultSpec specWithError:error];
    [self performTestWithArgumentVector:argv options:options spec:spec];
    
    argv = @[ @"--w hat", @"barf", @"--flarn", @"barf", @"-w hat" ];
    NSArray *errors = @[
        [NSError clk_POSIXErrorWithCode:EINVAL description:@"unexpected token in argument vector: '--w hat'"],
        [NSError clk_POSIXErrorWithCode:EINVAL description:@"unexpected token in argument vector: '-w hat'"]
    ];
    
    spec = [ArgumentParsingResultSpec specWithErrors:errors];
    [self performTestWithArgumentVector:argv options:options spec:spec];
}

- (void)testMalformedOptionToken_numericArgumentCharacters
{
    NSArray *options = @[
        [CLKOption parameterOptionWithName:@"flarn" flag:@"f"],
        [CLKOption parameterOptionWithName:@"quone" flag:@"q"]
    ];
    
    NSArray *argv = @[ @"-w0t", @"--flarn", @"barf" ];
    NSError *error = [NSError clk_POSIXErrorWithCode:EINVAL description:@"unexpected token in argument vector: '-w0t'"];
    ArgumentParsingResultSpec *spec = [ArgumentParsingResultSpec specWithError:error];
    [self performTestWithArgumentVector:argv options:options spec:spec];
    
    argv = @[ @"--flarn", @"barf", @"-w0t" ];
    error = [NSError clk_POSIXErrorWithCode:EINVAL description:@"unexpected token in argument vector: '-w0t'"];
    spec = [ArgumentParsingResultSpec specWithError:error];
    [self performTestWithArgumentVector:argv options:options spec:spec];
    
    argv = @[ @"--flarn", @"barf", @"-q-one" ];
    error = [NSError clk_POSIXErrorWithCode:EINVAL description:@"unexpected token in argument vector: '-q-one'"];
    spec = [ArgumentParsingResultSpec specWithError:error];
    [self performTestWithArgumentVector:argv options:options spec:spec];
    
    argv = @[ @"--flarn", @"barf", @"-q:one" ];
    error = [NSError clk_POSIXErrorWithCode:EINVAL description:@"unexpected token in argument vector: '-q:one'"];
    spec = [ArgumentParsingResultSpec specWithError:error];
    [self performTestWithArgumentVector:argv options:options spec:spec];
    
    argv = @[ @"--flarn", @"barf", @"-q.one" ];
    error = [NSError clk_POSIXErrorWithCode:EINVAL description:@"unexpected token in argument vector: '-q.one'"];
    spec = [ArgumentParsingResultSpec specWithError:error];
    [self performTestWithArgumentVector:argv options:options spec:spec];
    
    argv = @[ @"-y0", @"-420", @"--flarn", @"-7", @"-w0t" ];
    NSArray *errors = @[
        [NSError clk_POSIXErrorWithCode:EINVAL description:@"unexpected token in argument vector: '-y0'"],
        [NSError clk_POSIXErrorWithCode:EINVAL description:@"unexpected token in argument vector: '-w0t'"]
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
    NSError *error = [NSError clk_CLKErrorWithCode:CLKErrorRequiredOptionNotProvided description:@"--barf: required option not provided"];;
    spec = [ArgumentParsingResultSpec specWithError:error];
    [self performTestWithArgumentVector:argv options:@[ flarn, barf ] spec:spec];
    
    /* option declaring dependency provided before sentinel, dependency provided after sentinel (error) */
    
    argv = @[ @"--confound", @"acme", @"--", @"--delivery", @"station" ];
    error = [NSError clk_CLKErrorWithCode:CLKErrorRequiredOptionNotProvided description:@"--delivery is required when using --confound"];;
    spec = [ArgumentParsingResultSpec specWithError:error];
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
    
    CLKOptionGroup *requiredGroup = [CLKOptionGroup groupForOptionsNamed:@[ @"quone", @"delivery" ] required:YES];
    argv = @[ @"--flarn", @"acme", @"--", @"--quone", @"xyzzy" ];
    error = [NSError clk_CLKErrorWithCode:CLKErrorRequiredOptionNotProvided description:@"one or more of the following options must be provided: --quone --delivery"];
    spec = [ArgumentParsingResultSpec specWithError:error];
    [self performTestWithArgumentVector:argv options:@[ flarn, quone, delivery ] optionGroups:@[ requiredGroup ] spec:spec];
    
    /* zero-length argument provided after sentinel */
    argv = @[ @"--flarn", @"acme", @"--", @"", @"station" ];
    error = [NSError clk_POSIXErrorWithCode:EINVAL description:@"encountered zero-length argument"];
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

- (void)testNegativeNumericalArguments
{
    NSArray *options = @[
        [CLKOption parameterOptionWithName:@"flarn" flag:@"f"],
        [CLKOption optionWithName:@"barf" flag:@"b"]
    ];
    
    NSArray *argv = @[ @"-7" ];
    ArgumentParsingResultSpec *spec = [ArgumentParsingResultSpec specWithPositionalArguments:argv];
    [self performTestWithArgumentVector:argv options:options spec:spec];
    
    argv = @[ @"-7", @"quone" ];
    spec = [ArgumentParsingResultSpec specWithPositionalArguments:argv];
    [self performTestWithArgumentVector:argv options:options spec:spec];
    
    argv = @[ @"-4", @"-2.0" ];
    spec = [ArgumentParsingResultSpec specWithPositionalArguments:argv];
    [self performTestWithArgumentVector:argv options:options spec:spec];
    
    argv = @[ @"-b", @"-0" ];
    spec = [ArgumentParsingResultSpec specWithOptionManifest:@{ @"barf" : @(1) } positionalArguments:@[ @"-0" ]];
    [self performTestWithArgumentVector:argv options:options spec:spec];
    
    argv = @[ @"-0", @"-b" ];
    spec = [ArgumentParsingResultSpec specWithOptionManifest:@{ @"barf" : @(1) } positionalArguments:@[ @"-0" ]];
    [self performTestWithArgumentVector:argv options:options spec:spec];
    
    argv = @[ @"--flarn", @"-7", ];
    spec = [ArgumentParsingResultSpec specWithOptionManifest:@{ @"flarn" : @[ @"-7" ] }];
    [self performTestWithArgumentVector:argv options:options spec:spec];
    
    argv = @[ @"--flarn", @"-7", @"-b"];
    NSDictionary *expectedOptionManifest = @{
        @"flarn" : @[ @"-7" ],
        @"barf" : @(1)
    };
    
    spec = [ArgumentParsingResultSpec specWithOptionManifest:expectedOptionManifest];
    [self performTestWithArgumentVector:argv options:options spec:spec];
    
    argv = @[ @"-7.7.7", @"--flarn", @"-4:2:0" ];
    spec = [ArgumentParsingResultSpec specWithOptionManifest:@{ @"flarn" : @[ @"-4:2:0" ] } positionalArguments:@[ @"-7.7.7" ]];
    [self performTestWithArgumentVector:argv options:options spec:spec];
    
    argv = @[ @"--flarn", @"-4:2:0:6.6.6", @"-b" ];
    expectedOptionManifest = @{
        @"flarn" : @[ @"-4:2:0:6.6.6" ],
        @"barf" : @(1)
    };
    
    spec = [ArgumentParsingResultSpec specWithOptionManifest:expectedOptionManifest];
    [self performTestWithArgumentVector:argv options:options spec:spec];
    
    argv = @[ @"--flarn", @"-7", @"-4:20" ];
    spec = [ArgumentParsingResultSpec specWithOptionManifest:@{ @"flarn" : @[ @"-7" ] } positionalArguments:@[ @"-4:20" ]];
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
        @"-420",
        @"-xpx",
        @"-s", @"-666",
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
        @"syn" : @[ @(819), @(-666) ],
        @"ack" : @[ @"hack" ],
        @"noise" : @[ @"ex cathedra" ],
        @"quone" : @(1)
    };
    
    NSArray *expectedPositionalArguments = @[ @"acme", @"-", @"thrud", @"-420", @"confound", @"delivery", @"-wormfood", @"--dude" ];
    
    ArgumentParsingResultSpec *spec = [ArgumentParsingResultSpec specWithOptionManifest:expectedOptionManifest positionalArguments:expectedPositionalArguments];
    [self performTestWithArgumentVector:argv options:options spec:spec];
}

- (void)testMultipleMixedErrors
{
    CLKOption *flarn = [CLKOption parameterOptionWithName:@"flarn" flag:@"f" required:NO recurrent:YES dependencies:nil transformer:nil];
    
    NSArray *argv = @[
        @"-w0t", // malformed token
        @"--xyzzy", // unrecognized option
        @"-x", // unrecognized option
        @"--flarn", @"", // zero-length argument
        @"--flarn", @"-f", // expected argument (option-like token)
        @"--flarn" // expected argument (end of vector)
    ];
    
    NSArray *errors = @[
        [NSError clk_POSIXErrorWithCode:EINVAL description:@"unexpected token in argument vector: '-w0t'"],
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

#pragma mark -

/*
    the primary goal of validation tests involving the parser is verifying the parser:
 
        - invokes the validator
        - passes constraints to the validator
        - correctly handles the validator's results
 
    CLKOption, CLKOptionGroup, and CLKArgumentManifestValidator have comprehensive tests
    for constraints.
*/

- (void)testValidation_required
{
    NSArray *options = @[
         [CLKOption optionWithName:@"alpha" flag:@"a"],
         [CLKOption requiredParameterOptionWithName:@"bravo" flag:@"b"]
    ];
    
    NSError *error = [NSError clk_CLKErrorWithCode:CLKErrorRequiredOptionNotProvided description:@"--bravo: required option not provided"];;
    ArgumentParsingResultSpec *spec = [ArgumentParsingResultSpec specWithError:error];
    [self performTestWithArgumentVector:@[] options:options spec:spec];
    
    error = [NSError clk_CLKErrorWithCode:CLKErrorRequiredOptionNotProvided description:@"--bravo: required option not provided"];;
    spec = [ArgumentParsingResultSpec specWithError:error];
    [self performTestWithArgumentVector:@[ @"--alpha" ] options:options spec:spec];
    
    NSDictionary *expectedOptionManifest = @{
        @"bravo" : @[ @"flarn" ]
    };
    
    spec = [ArgumentParsingResultSpec specWithOptionManifest:expectedOptionManifest];
    [self performTestWithArgumentVector:@[ @"--bravo", @"flarn" ] options:options spec:spec];
}

- (void)testValidation_dependencies
{
    NSArray *options = @[
        [CLKOption optionWithName:@"alpha" flag:@"a"],
        [CLKOption parameterOptionWithName:@"bravo" flag:@"b"],
        [CLKOption optionWithName:@"charlie" flag:@"c" dependencies:@[ @"bravo" ]]
    ];
    
    NSArray *argv = @[ @"--charlie" ];
    NSError *error = [NSError clk_CLKErrorWithCode:CLKErrorRequiredOptionNotProvided description:@"--bravo is required when using --charlie"];;
    ArgumentParsingResultSpec *spec = [ArgumentParsingResultSpec specWithError:error];
    [self performTestWithArgumentVector:argv options:options spec:spec];
    
    NSDictionary *expectedOptionManifest = @{
        @"charlie" : @(1),
        @"bravo" : @[ @"flarn" ]
    };
    
    argv = @[ @"--charlie", @"--bravo", @"flarn" ];
    spec = [ArgumentParsingResultSpec specWithOptionManifest:expectedOptionManifest];
    [self performTestWithArgumentVector:argv options:options spec:spec];
}

- (void)testValidation_recurrent
{
    CLKOption *flarn = [CLKOption parameterOptionWithName:@"flarn" flag:@"f"];
    NSArray *argv = @[ @"--flarn", @"barf", @"--flarn", @"barf" ];
    
    NSError *error = [NSError clk_CLKErrorWithCode:CLKErrorTooManyOccurrencesOfOption description:@"--flarn may not be provided more than once"];;
    ArgumentParsingResultSpec *spec = [ArgumentParsingResultSpec specWithError:error];
    [self performTestWithArgumentVector:argv options:@[ flarn ] spec:spec];
    
    flarn = [CLKOption parameterOptionWithName:@"flarn" flag:@"f" required:NO recurrent:YES dependencies:nil transformer:nil];
    NSDictionary *expectedOptionManifest = @{
        @"flarn" : @[ @"barf", @"barf" ]
    };
    
    spec = [ArgumentParsingResultSpec specWithOptionManifest:expectedOptionManifest];
    [self performTestWithArgumentVector:argv options:@[ flarn ] spec:spec];
}

- (void)testValidation_mutualExclusionGroup
{
    NSArray *options = @[
        [CLKOption optionWithName:@"flarn" flag:@"f"],
        [CLKOption optionWithName:@"barf" flag:@"b"],
        [CLKOption optionWithName:@"quone" flag:@"q"],
        [CLKOption optionWithName:@"xyzzy" flag:@"x"]
    ];
    
    NSArray *groups = @[
        [CLKOptionGroup mutexedGroupForOptionsNamed:@[ @"flarn", @"barf" ]],
        [CLKOptionGroup mutexedGroupForOptionsNamed:@[ @"quone", @"xyzzy" ] required:YES]
    ];
    
    NSArray *argv = @[ @"--quone", @"--flarn", @"--barf" ];
    NSError *error = [NSError clk_CLKErrorWithCode:CLKErrorMutuallyExclusiveOptionsPresent description:@"--flarn --barf: mutually exclusive options encountered"];;
    ArgumentParsingResultSpec *spec = [ArgumentParsingResultSpec specWithError:error];
    [self performTestWithArgumentVector:argv options:options optionGroups:groups spec:spec];

    argv = @[ @"--flarn" ];
    error = [NSError clk_CLKErrorWithCode:CLKErrorRequiredOptionNotProvided description:@"one or more of the following options must be provided: --quone --xyzzy"];;
    spec = [ArgumentParsingResultSpec specWithError:error];
    [self performTestWithArgumentVector:argv options:options optionGroups:groups spec:spec];
    
    NSDictionary *expectedOptionManifest = @{
        @"flarn" : @(1),
        @"quone" : @(1)
    };
    
    argv = @[ @"--flarn", @"--quone" ];
    spec = [ArgumentParsingResultSpec specWithOptionManifest:expectedOptionManifest];
    [self performTestWithArgumentVector:argv options:options optionGroups:groups spec:spec];
}

- (void)testValidation_mutualExclusionGroupWithSubgroups
{
    NSArray *options = @[
        [CLKOption optionWithName:@"flarn" flag:@"f"],
        [CLKOption optionWithName:@"barf" flag:@"b"],
        [CLKOption optionWithName:@"quone" flag:@"q"],
        [CLKOption optionWithName:@"xyzzy" flag:@"x"],
        [CLKOption optionWithName:@"syn" flag:@"s"],
        [CLKOption optionWithName:@"ack" flag:@"a"],
        [CLKOption optionWithName:@"what" flag:@"w"]
    ];
    
    CLKOptionGroup *mutexedSubgroup = [CLKOptionGroup mutexedGroupForOptionsNamed:@[ @"flarn", @"barf" ]];
    CLKOptionGroup *subgroupQuoneXyzzy = [CLKOptionGroup groupForOptionsNamed:@[ @"quone", @"xyzzy" ]];
    CLKOptionGroup *subgroupSynAck = [CLKOptionGroup groupForOptionsNamed:@[ @"syn", @"ack" ]];
    CLKOptionGroup *mutexedGroup = [CLKOptionGroup mutexedGroupWithSubgroups:@[ mutexedSubgroup, subgroupQuoneXyzzy, subgroupSynAck ]];
    
    NSArray *argv = @[ @"--flarn", @"--barf" ];
    NSError *error = [NSError clk_CLKErrorWithCode:CLKErrorMutuallyExclusiveOptionsPresent description:@"--flarn --barf: mutually exclusive options encountered"];;
    ArgumentParsingResultSpec *spec = [ArgumentParsingResultSpec specWithError:error];
    [self performTestWithArgumentVector:argv options:options optionGroups:@[ mutexedGroup ] spec:spec];
    
    argv = @[ @"--flarn", @"--quone" ];
    error = [NSError clk_CLKErrorWithCode:CLKErrorMutuallyExclusiveOptionsPresent description:@"--flarn --quone: mutually exclusive options encountered"];;
    spec = [ArgumentParsingResultSpec specWithError:error];
    [self performTestWithArgumentVector:argv options:options optionGroups:@[ mutexedGroup ] spec:spec];

    argv = @[ @"--quone", @"--ack" ];
    error = [NSError clk_CLKErrorWithCode:CLKErrorMutuallyExclusiveOptionsPresent description:@"--quone --ack: mutually exclusive options encountered"];;
    spec = [ArgumentParsingResultSpec specWithError:error];
    [self performTestWithArgumentVector:argv options:options optionGroups:@[ mutexedGroup ] spec:spec];
    
    argv = @[ @"--ack", @"--quone" ];
    error = [NSError clk_CLKErrorWithCode:CLKErrorMutuallyExclusiveOptionsPresent description:@"--quone --ack: mutually exclusive options encountered"];;
    spec = [ArgumentParsingResultSpec specWithError:error];
    [self performTestWithArgumentVector:argv options:options optionGroups:@[ mutexedGroup ] spec:spec];

    NSDictionary *expectedOptionManifest = @{
        @"syn" : @(1),
        @"ack" : @(1)
    };
    
    argv = @[ @"--syn", @"--ack" ];
    spec = [ArgumentParsingResultSpec specWithOptionManifest:expectedOptionManifest];
    [self performTestWithArgumentVector:argv options:options optionGroups:@[ mutexedGroup ] spec:spec];

    argv = @[ @"--barf", @"--xyzzy", @"--syn" ];
    NSArray *errors = @[
        [NSError clk_CLKErrorWithCode:CLKErrorMutuallyExclusiveOptionsPresent description:@"--barf --xyzzy: mutually exclusive options encountered"],
        [NSError clk_CLKErrorWithCode:CLKErrorMutuallyExclusiveOptionsPresent description:@"--barf --syn: mutually exclusive options encountered"],
        [NSError clk_CLKErrorWithCode:CLKErrorMutuallyExclusiveOptionsPresent description:@"--xyzzy --syn: mutually exclusive options encountered"]
    ];
    
    spec = [ArgumentParsingResultSpec specWithErrors:errors];
    [self performTestWithArgumentVector:argv options:options optionGroups:@[ mutexedGroup ] spec:spec];
    
    argv = @[ @"--what", @"--xyzzy", @"--syn" ];
    error = [NSError clk_CLKErrorWithCode:CLKErrorMutuallyExclusiveOptionsPresent description:@"--xyzzy --syn: mutually exclusive options encountered"];;
    spec = [ArgumentParsingResultSpec specWithError:error];
    [self performTestWithArgumentVector:argv options:options optionGroups:@[ mutexedGroup ] spec:spec];
}

- (void)testValidation_boringRequiredGroup
{
    NSArray *options = @[
        [CLKOption optionWithName:@"flarn" flag:@"f"],
        [CLKOption parameterOptionWithName:@"barf" flag:@"b"],
        [CLKOption optionWithName:@"xyzzy" flag:@"x"]
    ];
    
    CLKOptionGroup *group = [CLKOptionGroup groupForOptionsNamed:@[ @"flarn", @"barf" ] required:YES];
    
    NSError *error = [NSError clk_CLKErrorWithCode:CLKErrorRequiredOptionNotProvided description:@"one or more of the following options must be provided: --flarn --barf"];
    ArgumentParsingResultSpec *spec = [ArgumentParsingResultSpec specWithError:error];
    [self performTestWithArgumentVector:@[] options:options optionGroups:@[ group ] spec:spec];
    
    error = [NSError clk_CLKErrorWithCode:CLKErrorRequiredOptionNotProvided description:@"one or more of the following options must be provided: --flarn --barf"];
    spec = [ArgumentParsingResultSpec specWithError:error];
    [self performTestWithArgumentVector:@[ @"--xyzzy" ] options:options optionGroups:@[ group ] spec:spec];
    
    NSDictionary *expectedOptionManifest = @{
        @"flarn" : @(1),
        @"xyzzy" : @(1)
    };
    
    spec = [ArgumentParsingResultSpec specWithOptionManifest:expectedOptionManifest];
    [self performTestWithArgumentVector:@[ @"--flarn", @"--xyzzy" ] options:options optionGroups:@[ group ] spec:spec];
}

@end
