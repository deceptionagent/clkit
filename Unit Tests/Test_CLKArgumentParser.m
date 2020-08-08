//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "AssignmentFormParsingSpec.h"
#import "ArgumentParsingResultSpec.h"
#import "CLKArgumentParser.h"
#import "CLKArgumentTransformer.h"
#import "CLKOption.h"
#import "CLKOptionGroup.h"
#import "NSError+CLKAdditions.h"
#import "StuntTransformer.h"
#import "XCTestCase+CLKAdditions.h"

@interface Test_CLKArgumentParser : XCTestCase

@end

@implementation Test_CLKArgumentParser

- (void)testInit
{
    NSArray *argv = @[ @"--flarn" ];
    NSArray *options = @[
         [CLKOption optionWithName:@"flarn" flag:@"f"],
         [CLKOption optionWithName:@"barf" flag:@"b"]
    ];
    
    CLKArgumentParser *parser = [CLKArgumentParser parserWithArgumentVector:argv options:options];
    XCTAssertNotNil(parser);
    XCTAssertNil(parser.errors);
    
    XCTAssertNotNil([CLKArgumentParser parserWithArgumentVector:argv options:@[]]);
    XCTAssertNotNil([CLKArgumentParser parserWithArgumentVector:argv options:options optionGroups:nil]);
    XCTAssertNotNil([CLKArgumentParser parserWithArgumentVector:argv options:options optionGroups:@[]]);
    
    CLKOptionGroup *group = [CLKOptionGroup mutexedGroupForOptionsNamed:@[ @"flarn", @"barf" ]];
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
        [CLKOption parameterOptionWithName:@"foo" flag:@"f" required:NO recurrent:YES transformer:nil],
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
    NSError *error = [NSError clk_POSIXErrorWithCode:EINVAL description:@"expected argument for option but encountered option-like token '--barf'"];
    spec = [ArgumentParsingResultSpec specWithError:error];
    [self performTestWithArgumentVector:argv options:options spec:spec];
    
    argv = @[ @"--flarn", @"-b", @"what" ];
    error = [NSError clk_POSIXErrorWithCode:EINVAL description:@"expected argument for option but encountered option-like token '-b'"];
    spec = [ArgumentParsingResultSpec specWithError:error];
    [self performTestWithArgumentVector:argv options:options spec:spec];
    
    argv = @[ @"--flarn", @"-lol", @"what" ];
    error = [NSError clk_POSIXErrorWithCode:EINVAL description:@"expected argument for option but encountered option-like token '-lol'"];
    spec = [ArgumentParsingResultSpec specWithError:error];
    [self performTestWithArgumentVector:argv options:options spec:spec];
    
    argv = @[ @"--flarn", @"-0x0", @"what" ];
    error = [NSError clk_POSIXErrorWithCode:EINVAL description:@"expected argument for option but encountered option-like token '-0x0'"];
    spec = [ArgumentParsingResultSpec specWithError:error];
    [self performTestWithArgumentVector:argv options:options spec:spec];
    
    argv = @[ @"--flarn", @"--w hat", @"what" ];
    error = [NSError clk_POSIXErrorWithCode:EINVAL description:@"expected argument for option but encountered option-like token '--w hat'"];
    spec = [ArgumentParsingResultSpec specWithError:error];
    [self performTestWithArgumentVector:argv options:options spec:spec];
    
    argv = @[ @"--flarn", @"--barf", @"what", @"--flarn", @"-q" ];
    NSArray *errors = @[
        [NSError clk_POSIXErrorWithCode:EINVAL description:@"expected argument for option but encountered option-like token '--barf'"],
        [NSError clk_POSIXErrorWithCode:EINVAL description:@"expected argument for option but encountered option-like token '-q'"]
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

- (void)testParameterOptionAssignmentForm_tokenAnalysis
{
    NSArray *options = @[
        [CLKOption parameterOptionWithName:@"flarn" flag:@"f"],
        [CLKOption parameterOptionWithName:@"barf" flag:@"b"]
    ];
    
    NSArray *optionSegments = @[ @"--flarn", @"-f" ];
    NSArray *operators = @[ @"=", @":" ];
    NSArray *argumentSegments = @[
        @"barf",
        @"-barf",
        @"7",
        @"4.20",
        @"-7",
        @"-4.20",
        @"-4-2:0",
        
        // registered option forms
        @"--flarn",
        @"-f",
        @"--barf",
        @"-b",
        
        // argument segments containing assignment operators
        @"barf:",
        @"barf=",
        @"barf:quone",
        @"barf=quone",
        
        // standalone interesting characters
        @"-",
        @"=",
        @":"
    ];
    
    // combine the above input segments to generate parser input
    NSMutableArray<AssignmentFormParsingSpec *> *formSpecs = [NSMutableArray array];
    for (NSString *optionSegment in optionSegments) {
        for (NSString *operator in operators) {
            for (NSString *argumentSegment in argumentSegments) {
                AssignmentFormParsingSpec *spec = [[AssignmentFormParsingSpec alloc] initWithOptionSegment:optionSegment operator:operator argumentSegment:argumentSegment];
                [formSpecs addObject:spec];
                
                // malformed version where the option flag is missing, e.g., `-=barf`
                spec = [[AssignmentFormParsingSpec alloc] initWithOptionSegment:@"-" operator:operator argumentSegment:argumentSegment];
                [formSpecs addObject:spec];
                
                // malformed version where the option name is missing, e.g., `--=barf`
                spec = [[AssignmentFormParsingSpec alloc] initWithOptionSegment:@"--" operator:operator argumentSegment:argumentSegment];
                [formSpecs addObject:spec];
            }
        }
    }
    
    for (AssignmentFormParsingSpec *formSpec in formSpecs) {
        NSArray *argv = @[ formSpec.composedToken ];
        ArgumentParsingResultSpec *resultSpec;
        
        if (formSpec.malformed) {
            NSString *error = [NSString stringWithFormat:@"unexpected token in argument vector: '%@'", formSpec.composedToken];
            resultSpec = [ArgumentParsingResultSpec specWithPOSIXErrorCode:EINVAL description:error];
        } else {
             NSDictionary *expectedManifest = @{
                @"flarn" : @[ formSpec.argumentSegment ]
            };
            
            resultSpec = [ArgumentParsingResultSpec specWithOptionManifest:expectedManifest];
        }
        
        [self performTestWithArgumentVector:argv options:options spec:resultSpec];
    }
}

- (void)testParameterOptionAssignmentForm_argumentTransformation
{
    StuntTransformer *flarnTransformer = [StuntTransformer transformerWithTransformedObject:@(7)];
    StuntTransformer *barfTransformer  = [StuntTransformer transformerWithTransformedObject:@(420)];
    StuntTransformer *quoneTransformer = [StuntTransformer transformerWithTransformedObject:@(666)];
    StuntTransformer *xyzzyTransformer = [StuntTransformer transformerWithTransformedObject:@(-7)];
    
    NSArray *options = @[
        [CLKOption parameterOptionWithName:@"flarn" flag:@"f" required:NO recurrent:NO transformer:flarnTransformer],
        [CLKOption parameterOptionWithName:@"barf"  flag:@"b" required:NO recurrent:NO transformer:barfTransformer],
        [CLKOption parameterOptionWithName:@"quone" flag:@"q" required:NO recurrent:NO transformer:quoneTransformer],
        [CLKOption parameterOptionWithName:@"xyzzy" flag:@"x" required:NO recurrent:NO transformer:xyzzyTransformer]
    ];
    
    NSDictionary *expectedManifest = @{
        @"flarn" : @[ @(7) ],
        @"barf" : @[ @(420) ],
        @"quone" : @[ @(666) ],
        @"xyzzy" : @[ @(-7) ],
    };
    
    ArgumentParsingResultSpec *spec = [ArgumentParsingResultSpec specWithOptionManifest:expectedManifest];
    [self performTestWithArgumentVector:@[ @"--flarn=marathon", @"--barf:dank", @"-q=devil", @"-x:nohtaram" ] options:options spec:spec];
    
    flarnTransformer = [StuntTransformer erroringTransformerWithPOSIXErrorCode:EINVAL description:@"--flarn error"];
    barfTransformer  = [StuntTransformer erroringTransformerWithPOSIXErrorCode:EINVAL description:@"--barf error"];
    quoneTransformer = [StuntTransformer erroringTransformerWithPOSIXErrorCode:EINVAL description:@"-q error"];
    xyzzyTransformer = [StuntTransformer erroringTransformerWithPOSIXErrorCode:EINVAL description:@"-x error"];
    
    options = @[
        [CLKOption parameterOptionWithName:@"flarn" flag:@"f" required:NO recurrent:NO transformer:flarnTransformer],
        [CLKOption parameterOptionWithName:@"barf"  flag:@"b" required:NO recurrent:NO transformer:barfTransformer],
        [CLKOption parameterOptionWithName:@"quone" flag:@"q" required:NO recurrent:NO transformer:quoneTransformer],
        [CLKOption parameterOptionWithName:@"xyzzy" flag:@"x" required:NO recurrent:NO transformer:xyzzyTransformer]
    ];
    
    NSArray *errors = @[
        flarnTransformer.error,
        barfTransformer.error,
        quoneTransformer.error,
        xyzzyTransformer.error,
    ];
    
    NSArray *argv = @[ @"--flarn=7", @"--barf:420", @"-q=666", @"-x:-7" ];
    spec = [ArgumentParsingResultSpec specWithErrors:errors];
    [self performTestWithArgumentVector:argv options:options spec:spec];
}

- (void)testParameterOptionAssignmentForm_missingArgument
{
    NSArray *options = @[
        [CLKOption parameterOptionWithName:@"flarn" flag:@"f"],
        [CLKOption parameterOptionWithName:@"barf" flag:@"b"],
        [CLKOption parameterOptionWithName:@"quone" flag:@"q"],
        [CLKOption parameterOptionWithName:@"xyzzy" flag:@"x"]
    ];
    
    NSArray *errors = @[
        [NSError clk_POSIXErrorWithCode:EINVAL description:@"expected argument for option '--flarn'"],
        [NSError clk_POSIXErrorWithCode:EINVAL description:@"expected argument for option '--barf'"],
        [NSError clk_POSIXErrorWithCode:EINVAL description:@"expected argument for option '-q'"],
        [NSError clk_POSIXErrorWithCode:EINVAL description:@"expected argument for option '-x'"],
    ];
    
    ArgumentParsingResultSpec *spec = [ArgumentParsingResultSpec specWithErrors:errors];
    [self performTestWithArgumentVector:@[ @"--flarn=", @"--barf:", @"-q=", @"-x:" ] options:options spec:spec];
}

- (void)testParameterOptionAssignmentForm_switchAssignment
{
    NSArray *options = @[
        [CLKOption optionWithName:@"flarn" flag:@"f"],
        [CLKOption optionWithName:@"barf" flag:@"b"],
        [CLKOption optionWithName:@"quone" flag:@"q"],
        [CLKOption optionWithName:@"xyzzy" flag:@"x"]
    ];
    
    NSArray *errors = @[
        [NSError clk_POSIXErrorWithCode:EINVAL description:@"option '--flarn' does not accept arguments"],
        [NSError clk_POSIXErrorWithCode:EINVAL description:@"option '--barf' does not accept arguments"],
        [NSError clk_POSIXErrorWithCode:EINVAL description:@"option '-q' does not accept arguments"],
        [NSError clk_POSIXErrorWithCode:EINVAL description:@"option '-x' does not accept arguments"]
    ];
    
    ArgumentParsingResultSpec *spec = [ArgumentParsingResultSpec specWithErrors:errors];
    [self performTestWithArgumentVector:@[ @"--flarn=what", @"--barf:what", @"-q=what", @"-x:what" ] options:options spec:spec];
}

- (void)testParameterOptionAssignmentForm_unregisteredOptions
{
    NSArray *options = @[
        [CLKOption optionWithName:@"what" flag:@"w"],
    ];
    
    NSArray *errors = @[
        [NSError clk_POSIXErrorWithCode:EINVAL description:@"unrecognized option: '--flarn'"],
        [NSError clk_POSIXErrorWithCode:EINVAL description:@"unrecognized option: '--barf'"],
        [NSError clk_POSIXErrorWithCode:EINVAL description:@"unrecognized option: '-q'"],
        [NSError clk_POSIXErrorWithCode:EINVAL description:@"unrecognized option: '-x'"]
    ];
    
    ArgumentParsingResultSpec *spec = [ArgumentParsingResultSpec specWithErrors:errors];
    [self performTestWithArgumentVector:@[ @"--flarn=what", @"--barf:what", @"-q=what", @"-x:what" ] options:options spec:spec];
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

- (void)testMalformedOptionTokens
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
    
    argv = @[ @"-- flarn:what" ];
    error = [NSError clk_POSIXErrorWithCode:EINVAL description:@"unexpected token in argument vector: '-- flarn:what'"];
    spec = [ArgumentParsingResultSpec specWithError:error];
    [self performTestWithArgumentVector:argv options:options spec:spec];
}

- (void)testOptionParsingSentinel
{
    CLKOption *flarn = [CLKOption parameterOptionWithName:@"flarn" flag:@"f"];
    CLKOption *barf = [CLKOption requiredParameterOptionWithName:@"barf" flag:@"b"];
    CLKOption *quone = [CLKOption optionWithName:@"quone" flag:@"q"];
    CLKOption *confound = [CLKOption parameterOptionWithName:@"confound" flag:@"c"];
    CLKOption *delivery = [CLKOption parameterOptionWithName:@"delivery" flag:@"d"];
    CLKOptionGroup *confoundDeliveryGroup = [CLKOptionGroup groupForOptionNamed:@"confound" requiringDependency:@"delivery"];
    
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
    
    argv = @[ @"--flarn", @"--", @"--quone" ];
    spec = [ArgumentParsingResultSpec specWithOptionManifest:@{ @"flarn" : @[ @"--quone" ] }];
    [self performTestWithArgumentVector:argv options:@[ flarn ] spec:spec];
    
    argv = @[ @"--flarn", @"--", @"-q" ];
    spec = [ArgumentParsingResultSpec specWithOptionManifest:@{ @"flarn" : @[ @"-q" ] }];
    [self performTestWithArgumentVector:argv options:@[ flarn ] spec:spec];
    
    argv = @[ @"--flarn", @"--", @"--xyzzy" ]; // --xyzzy is unregistered
    spec = [ArgumentParsingResultSpec specWithOptionManifest:@{ @"flarn" : @[ @"--xyzzy" ] }];
    [self performTestWithArgumentVector:argv options:@[ flarn ] spec:spec];
    
    argv = @[ @"--flarn", @"--", @"-x" ]; // -x is unregistered
    spec = [ArgumentParsingResultSpec specWithOptionManifest:@{ @"flarn" : @[ @"-x" ] }];
    [self performTestWithArgumentVector:argv options:@[ flarn ] spec:spec];
    
    argv = @[ @"--flarn", @"--", @"-x", @"-y" ]; // not interpreting `-y` as an argument to --flarn
    spec = [ArgumentParsingResultSpec specWithOptionManifest:@{ @"flarn" : @[ @"-x" ] } positionalArguments:@[ @"-y" ]];
    [self performTestWithArgumentVector:argv options:@[ flarn ] spec:spec];
    
    argv = @[ @"--flarn", @"--", @"", @"-y" ]; // processing first post-sentinel argument to --flarn, zero-length argument (error condition)
    spec = [ArgumentParsingResultSpec specWithPOSIXErrorCode:EINVAL description:@"encountered zero-length argument"];
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
    [self performTestWithArgumentVector:argv options:@[ confound, delivery ] optionGroups:@[ confoundDeliveryGroup ] spec:spec];
    
    /* option declaring dependency provided after sentinel, dependency not provided before sentinel (success) */
    
    argv = @[ @"--flarn", @"acme", @"--", @"--confound", @"station" ];
    spec = [ArgumentParsingResultSpec specWithOptionManifest:@{ @"flarn" : @[ @"acme" ] } positionalArguments:@[ @"--confound", @"station" ]];
    [self performTestWithArgumentVector:argv options:@[ flarn, confound, delivery ] optionGroups:@[ confoundDeliveryGroup ] spec:spec];
    
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
    
    /* zero-length argument provided after sentinel (error) */
    
    argv = @[ @"--flarn", @"acme", @"--", @"", @"station" ];
    NSError *error = [NSError clk_POSIXErrorWithCode:EINVAL description:@"encountered zero-length argument"];
    spec = [ArgumentParsingResultSpec specWithError:error];
    [self performTestWithArgumentVector:argv options:@[ flarn ] spec:spec];
    
    /* argument to parameter option not supplied after sentinel (error) */
    
    argv = @[ @"--flarn", @"--"];
    error = [NSError clk_POSIXErrorWithCode:EINVAL description:@"expected option argument following sentinel"];
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
    CLKIntArgumentTransformer *transformer = [[CLKIntArgumentTransformer alloc] init];
    
    NSArray *options = @[
        [CLKOption parameterOptionWithName:@"strange" flag:@"s" required:NO recurrent:NO transformer:transformer],
        [CLKOption parameterOptionWithName:@"aeons" flag:@"a" required:NO recurrent:NO transformer:transformer]
    ];
    
    NSDictionary *expectedOptionManifest = @{
        @"strange" : @[ @(7) ],
        @"aeons" : @[ @(819) ],
    };
    
    NSArray *expectedPositionalArguments = @[ @"/fatum/iustum/stultorum" ];
    
    NSArray *argv = @[ @"--strange", @"7", @"--aeons", @"819", @"/fatum/iustum/stultorum" ];
    ArgumentParsingResultSpec *spec = [ArgumentParsingResultSpec specWithOptionManifest:expectedOptionManifest positionalArguments:expectedPositionalArguments];
    [self performTestWithArgumentVector:argv options:options spec:spec];
    
    CLKArgumentTransformer *acmeTransformer = [[CLKArgumentTransformer alloc] init];
    StuntTransformer *confoundTransformer = [StuntTransformer erroringTransformerWithPOSIXErrorCode:EINVAL description:@"confound error"];
    
    options = @[
        [CLKOption parameterOptionWithName:@"acme" flag:@"a" required:NO recurrent:NO transformer:acmeTransformer],
        [CLKOption parameterOptionWithName:@"confound" flag:@"c" required:NO recurrent:NO transformer:confoundTransformer]
    ];
    
    argv = @[ @"--acme", @"station", @"--confound", @"819", @"/fatum/iustum/stultorum" ];
    [self performTestWithArgumentVector:argv options:options error:confoundTransformer.error];
    
    // verify the parser bails before running the transformer
    NSError *earlyError = [NSError clk_POSIXErrorWithCode:EINVAL description:@"expected argument for option but encountered option-like token '-a'"];
    [self performTestWithArgumentVector:@[ @"--confound", @"-a" ] options:options error:earlyError];
}

- (void)testComplexMix
{
    CLKIntArgumentTransformer *synTransformer = [[CLKIntArgumentTransformer alloc] init];
    
    NSArray *options = @[
         [CLKOption parameterOptionWithName:@"ack" flag:@"a"],
         [CLKOption parameterOptionWithName:@"noise" flag:@"n" required:NO recurrent:NO transformer:nil],
         [CLKOption parameterOptionWithName:@"ghost" flag:@"g"], // not provided in argv
         [CLKOption parameterOptionWithName:@"syn" flag:@"s" required:NO recurrent:YES transformer:synTransformer],
         [CLKOption optionWithName:@"quone" flag:@"q"],
         [CLKOption optionWithName:@"xyzzy" flag:@"x"],
         [CLKOption optionWithName:@"spline" flag:@"p"],
    ];
    
    NSArray *groups = @[
        [CLKOptionGroup groupForOptionNamed:@"quone" requiringDependency:@"noise"]
    ];
    
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
        @"--syn=420",
        @"-s:-666",
        @"--noise", @"ex cathedra",
        @"--quone",
        @"confound", @"delivery",
        @"--",
        @"-wormfood", @"--dude", @"--syn=7"
    ];
    
    NSDictionary *expectedOptionManifest = @{
        @"xyzzy" : @(4),
        @"spline" : @(1),
        @"syn" : @[ @(819), @(420), @(-666) ],
        @"ack" : @[ @"hack" ],
        @"noise" : @[ @"ex cathedra" ],
        @"quone" : @(1)
    };
    
    NSArray *expectedPositionalArguments = @[ @"acme", @"-", @"thrud", @"confound", @"delivery", @"-wormfood", @"--dude", @"--syn=7" ];
    
    ArgumentParsingResultSpec *spec = [ArgumentParsingResultSpec specWithOptionManifest:expectedOptionManifest positionalArguments:expectedPositionalArguments];
    [self performTestWithArgumentVector:argv options:options optionGroups:groups spec:spec];
}

- (void)testMultipleMixedErrors
{
    CLKOption *flarn = [CLKOption parameterOptionWithName:@"flarn" flag:@"f" required:NO recurrent:YES transformer:nil];
    
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
        [NSError clk_POSIXErrorWithCode:EINVAL description:@"expected argument for option but encountered option-like token '-f'"],
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
    
    CLKOptionGroup *group = [CLKOptionGroup requiredGroupForOptionsNamed:@[ @"barf" ]];
    XCTAssertThrows([CLKArgumentParser parserWithArgumentVector:@[] options:options optionGroups:@[ group ]]);
    
    group = [CLKOptionGroup mutexedGroupForOptionsNamed:@[ @"ack", @"barf" ]];
    XCTAssertThrows([CLKArgumentParser parserWithArgumentVector:@[] options:options optionGroups:@[ group ]]);
    
    group = [CLKOptionGroup standaloneGroupForOptionNamed:@"barf" allowing:@[ @"syn" ]];
    XCTAssertThrows([CLKArgumentParser parserWithArgumentVector:@[] options:options optionGroups:@[ group ]]);
    
    group = [CLKOptionGroup standaloneGroupForOptionNamed:@"syn" allowing:@[ @"barf" ]];
    XCTAssertThrows([CLKArgumentParser parserWithArgumentVector:@[] options:options optionGroups:@[ group ]]);
}

- (void)testInvalidDependencies
{
    // dependencies can't reference unregistered options
    NSArray *options = @[
         [CLKOption parameterOptionWithName:@"ack" flag:@"a"],
         [CLKOption parameterOptionWithName:@"syn" flag:@"f"]
    ];
    
    NSArray *groups = @[
        [CLKOptionGroup groupForOptionNamed:@"syn" requiringDependency:@"flarn"]
    ];
    
    XCTAssertThrows([CLKArgumentParser parserWithArgumentVector:@[] options:options optionGroups:groups]);
}

- (void)testValidationErrorElidingForParsingErrors
{
    /*
        expanding on a brief explanation in ArgumentParser.m:
        
        there exists a class of failure where a parsing issue and a validation issue
        can happen for a single occurence of a parameter option. when this occurs, we
        generate two errors for what, to the user, is a single problem.
        
        there are several cases below, each involving required parameter options:
        
        #1: the option is supplied as the last element of the vector
        #2: a zero-length argument is supplied
        #3: an option-like token is supplied
        #4: the transformer fails on the supplied argument
        #5: parsing fails for the argument slice of an assignment form option
        
        first, the option fails to parse fully. no value is placed into the manifest.
        if there are no other occurrences of the option, or all other occurrences also
        encounter parsing issues, the manifest will have no data for the option.
        
        second, when parsing completes and the validator is run, validation detects that
        the manifest has no data for the option. that generates a second error that is
        accumulated by the parser.
        
        we don't want to display "required option not provided" after the parse error
        because that is confusing.
        
        if the validation error is one where a required option is not present in the
        manifest, and we previously saw a parsing error for that option, we know we
        could not have put anything into the manifest and expect the validation error.
        drop the validation error on the floor.
    */
    
    NSArray<CLKOption *> *options = @[
        [CLKOption optionWithName:@"flarn" flag:@"f"],
        [CLKOption requiredParameterOptionWithName:@"barf" flag:@"b"]
    ];
    
    /* #1: option supplied as the last element of the vector */
    
    NSError *error = [NSError clk_POSIXErrorWithCode:EINVAL description:@"expected argument for option '--barf'"];
    [self performTestWithArgumentVector:@[ @"-f", @"--barf" ] options:options error:error];
    
    /* #2: zero-length argument supplied */
    
    error = [NSError clk_POSIXErrorWithCode:EINVAL description:@"encountered zero-length argument"];
    [self performTestWithArgumentVector:@[ @"--barf", @"", @"-f" ] options:options error:error];
    
    /* #3: option-like token supplied */
    
    error = [NSError clk_POSIXErrorWithCode:EINVAL description:@"expected argument for option but encountered option-like token '-f'"];
    [self performTestWithArgumentVector:@[ @"--barf", @"-f" ] options:options error:error];
    
    /* #4: transformer fails on the supplied argument */
    
    StuntTransformer *transformer = [StuntTransformer erroringTransformerWithPOSIXErrorCode:EINVAL description:@"transformer error"];
    options = @[
        [CLKOption optionWithName:@"flarn" flag:@"f"],
        [CLKOption parameterOptionWithName:@"quone" flag:@"q" required:YES recurrent:NO transformer:transformer]
    ];
    
    error = [NSError clk_POSIXErrorWithCode:EINVAL description:@"transformer error"];
    [self performTestWithArgumentVector:@[ @"-f", @"-q", @"666" ] options:options error:error];
    
    /* #5: parsing fails for the argument slice of an assignment form option */
    
    options = @[
        [CLKOption optionWithName:@"flarn" flag:@"f"],
        [CLKOption requiredParameterOptionWithName:@"barf" flag:@"b"]
    ];
    
    error = [NSError clk_POSIXErrorWithCode:EINVAL description:@"expected argument for option '-b'"];
    [self performTestWithArgumentVector:@[ @"-b=", @"-f" ] options:options error:error];
    
    error = [NSError clk_POSIXErrorWithCode:EINVAL description:@"expected argument for option '--barf'"];
    [self performTestWithArgumentVector:@[ @"--barf=", @"-f" ] options:options error:error];
    
    /* combine all of the above cases */
    
    options = @[
        [CLKOption optionWithName:@"alpha" flag:@"a"],
        [CLKOption parameterOptionWithName:@"bravo" flag:@"b" required:YES recurrent:NO transformer:transformer],
        [CLKOption requiredParameterOptionWithName:@"charlie" flag:@"c"],
        [CLKOption requiredParameterOptionWithName:@"delta" flag:@"d"],
        [CLKOption requiredParameterOptionWithName:@"echo" flag:@"e"]
    ];
    
    NSArray *argv = @[ @"--alpha=", @"--bravo", @"666", @"--charlie", @"-x", @"--delta", @"", @"--echo" ];
    NSArray *errors = @[
        [NSError clk_POSIXErrorWithCode:EINVAL description:@"expected argument for option '--alpha'"],
        [NSError clk_POSIXErrorWithCode:EINVAL description:@"transformer error"],
        [NSError clk_POSIXErrorWithCode:EINVAL description:@"expected argument for option but encountered option-like token '-x'"],
        [NSError clk_POSIXErrorWithCode:EINVAL description:@"encountered zero-length argument"],
        [NSError clk_POSIXErrorWithCode:EINVAL description:@"expected argument for option '--echo'"]
    ];
    
    ArgumentParsingResultSpec *spec = [ArgumentParsingResultSpec specWithErrors:errors];
    [self performTestWithArgumentVector:argv options:options spec:spec];
    
    /* required group  */
    
    options = @[
        [CLKOption parameterOptionWithName:@"flarn" flag:@"f"],
        [CLKOption parameterOptionWithName:@"barf"  flag:@"b"],
        [CLKOption parameterOptionWithName:@"quone" flag:@"q"]
    ];
    
    CLKOptionGroup *group = [CLKOptionGroup requiredGroupForOptionsNamed:@[ @"flarn", @"barf", @"quone" ]];
    
    error = [NSError clk_POSIXErrorWithCode:EINVAL description:@"expected argument for option '--flarn'"];
    [self performTestWithArgumentVector:@[ @"--flarn" ] options:options optionGroups:@[ group ] error:error];
}

@end
