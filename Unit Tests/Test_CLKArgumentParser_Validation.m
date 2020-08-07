//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "ArgumentParsingResultSpec.h"
#import "CLKArgumentParser.h"
#import "CLKOption.h"
#import "CLKOptionGroup.h"
#import "NSError+CLKAdditions.h"
#import "XCTestCase+CLKAdditions.h"

@interface Test_CLKArgumentParser_Validation : XCTestCase

@end

@implementation Test_CLKArgumentParser_Validation

- (void)testValidation_requiredOption
{
    NSArray *options = @[
         [CLKOption optionWithName:@"alpha" flag:@"a"],
         [CLKOption requiredParameterOptionWithName:@"bravo" flag:@"b"]
    ];
    
    ArgumentParsingResultSpec *spec = [ArgumentParsingResultSpec specWithCLKErrorCode:CLKErrorRequiredOptionNotProvided description:@"--bravo: required option not provided"];
    [self performTestWithArgumentVector:@[] options:options spec:spec];
    
    spec = [ArgumentParsingResultSpec specWithCLKErrorCode:CLKErrorRequiredOptionNotProvided description:@"--bravo: required option not provided"];
    [self performTestWithArgumentVector:@[ @"--alpha" ] options:options spec:spec];
    
    NSDictionary *expectedOptionManifest = @{
        @"bravo" : @[ @"flarn" ]
    };
    
    spec = [ArgumentParsingResultSpec specWithOptionManifest:expectedOptionManifest];
    [self performTestWithArgumentVector:@[ @"--bravo", @"flarn" ] options:options spec:spec];
}

- (void)testValidation_recurrentOption
{
    CLKOption *flarn = [CLKOption parameterOptionWithName:@"flarn" flag:@"f"];
    NSArray *argv = @[ @"--flarn", @"barf", @"--flarn", @"barf" ];
    
    ArgumentParsingResultSpec *spec = [ArgumentParsingResultSpec specWithCLKErrorCode:CLKErrorTooManyOccurrencesOfOption description:@"--flarn may not be provided more than once"];
    [self performTestWithArgumentVector:argv options:@[ flarn ] spec:spec];
    
    flarn = [CLKOption parameterOptionWithName:@"flarn" flag:@"f" required:NO recurrent:YES transformer:nil];
    NSDictionary *expectedOptionManifest = @{
        @"flarn" : @[ @"barf", @"barf" ]
    };
    
    spec = [ArgumentParsingResultSpec specWithOptionManifest:expectedOptionManifest];
    [self performTestWithArgumentVector:argv options:@[ flarn ] spec:spec];
}

- (void)testValidation_standaloneOption
{
    NSArray *options = @[
        [CLKOption optionWithName:@"flarn" flag:@"f"],
        [CLKOption parameterOptionWithName:@"barf" flag:@"b"],
        [CLKOption standaloneOptionWithName:@"quone" flag:@"q"],
        [CLKOption standaloneParameterOptionWithName:@"xyzzy" flag:@"x" recurrent:YES transformer:nil]
    ];
    
    /* success: no standalone option provided */
    
    ArgumentParsingResultSpec *spec = [ArgumentParsingResultSpec specWithEmptyManifest];
    [self performTestWithArgumentVector:@[] options:options spec:spec];
    
    NSArray *argv = @[ @"--flarn" ];
    spec = [ArgumentParsingResultSpec specWithSwitchOption:@"flarn" occurrences:1];
    [self performTestWithArgumentVector:argv options:options spec:spec];
    
    /* success: standalone switch option provided */
    
    argv = @[ @"--quone" ];
    spec = [ArgumentParsingResultSpec specWithSwitchOption:@"quone" occurrences:1];
    [self performTestWithArgumentVector:argv options:options spec:spec];
    
    argv = @[ @"-qq" ];
    spec = [ArgumentParsingResultSpec specWithSwitchOption:@"quone" occurrences:2];
    [self performTestWithArgumentVector:argv options:options spec:spec];
    
    argv = @[ @"--quone", @"confound.mak" ];
    spec = [ArgumentParsingResultSpec specWithSwitchOption:@"quone" occurrences:1 positionalArguments:@[ @"confound.mak" ]];
    [self performTestWithArgumentVector:argv options:options spec:spec];
    
    /* success: standalone parameter option provided */
    
    argv = @[ @"--xyzzy", @"what" ];
    spec = [ArgumentParsingResultSpec specWithOptionManifest:@{ @"xyzzy" : @[ @"what" ] }];
    [self performTestWithArgumentVector:argv options:options spec:spec];
    
    argv = @[ @"--xyzzy", @"what", @"confound.mak" ];
    spec = [ArgumentParsingResultSpec specWithOptionManifest:@{ @"xyzzy" : @[ @"what" ] } positionalArguments:@[ @"confound.mak" ]];
    [self performTestWithArgumentVector:argv options:options spec:spec];
    
    argv = @[ @"--xyzzy", @"syn", @"--xyzzy", @"ack" ];
    NSDictionary *expectedManifest = @{
        @"xyzzy" : @[ @"syn", @"ack" ],
    };
    
    spec = [ArgumentParsingResultSpec specWithOptionManifest:expectedManifest];
    [self performTestWithArgumentVector:argv options:options spec:spec];
    
    /* validation failures */
    
    argv = @[ @"--flarn", @"--quone" ];
    spec = [ArgumentParsingResultSpec specWithCLKErrorCode:CLKErrorMutuallyExclusiveOptionsPresent description:@"--quone may not be provided with other options"];
    [self performTestWithArgumentVector:argv options:options spec:spec];
    
    argv = @[ @"--flarn", @"--xyzzy", @"what" ];
    spec = [ArgumentParsingResultSpec specWithCLKErrorCode:CLKErrorMutuallyExclusiveOptionsPresent description:@"--xyzzy may not be provided with other options"];
    [self performTestWithArgumentVector:argv options:options spec:spec];
    
    argv = @[ @"--quone", @"--xyzzy", @"what" ];
    NSArray *errors = @[
        [NSError clk_CLKErrorWithCode:CLKErrorMutuallyExclusiveOptionsPresent description:@"--quone may not be provided with other options"],
        [NSError clk_CLKErrorWithCode:CLKErrorMutuallyExclusiveOptionsPresent description:@"--xyzzy may not be provided with other options"]
    ];
    
    spec = [ArgumentParsingResultSpec specWithErrors:errors];
    [self performTestWithArgumentVector:argv options:options spec:spec];
    
    argv = @[ @"--flarn", @"--quone", @"--xyzzy", @"what" ];
    spec = [ArgumentParsingResultSpec specWithErrors:errors];
    [self performTestWithArgumentVector:argv options:options spec:spec];
    
    argv = @[ @"--quone", @"--xyzzy", @"what", @"confound.mak" ];
    spec = [ArgumentParsingResultSpec specWithErrors:errors];
    [self performTestWithArgumentVector:argv options:options spec:spec];
    
    argv = @[ @"--flarn", @"--quone", @"--xyzzy", @"what", @"confound.mak" ];
    spec = [ArgumentParsingResultSpec specWithErrors:errors];
    [self performTestWithArgumentVector:argv options:options spec:spec];
}

- (void)testValidation_dependencies
{
    NSArray *options = @[
        [CLKOption optionWithName:@"alpha" flag:@"a"],
        [CLKOption parameterOptionWithName:@"bravo" flag:@"b"],
        [CLKOption optionWithName:@"charlie" flag:@"c"]
    ];
    
    NSArray *groups = @[
        [CLKOptionGroup groupForOptionNamed:@"charlie" requiringDependency:@"bravo"]
    ];
    
    NSArray *argv = @[ @"--charlie" ];
    ArgumentParsingResultSpec *spec = [ArgumentParsingResultSpec specWithCLKErrorCode:CLKErrorRequiredOptionNotProvided description:@"--bravo is required when using --charlie"];
    [self performTestWithArgumentVector:argv options:options optionGroups:groups spec:spec];
    
    NSDictionary *expectedOptionManifest = @{
        @"charlie" : @(1),
        @"bravo" : @[ @"flarn" ]
    };
    
    argv = @[ @"--charlie", @"--bravo", @"flarn" ];
    spec = [ArgumentParsingResultSpec specWithOptionManifest:expectedOptionManifest];
    [self performTestWithArgumentVector:argv options:options optionGroups:groups spec:spec];
}

- (void)testValidation_requiredGroup
{
    NSArray *options = @[
        [CLKOption optionWithName:@"flarn" flag:@"f"],
        [CLKOption parameterOptionWithName:@"barf" flag:@"b"],
        [CLKOption optionWithName:@"xyzzy" flag:@"x"]
    ];
    
    CLKOptionGroup *group = [CLKOptionGroup requiredGroupForOptionsNamed:@[ @"flarn", @"barf" ]];
    
    ArgumentParsingResultSpec *spec = [ArgumentParsingResultSpec specWithCLKErrorCode:CLKErrorRequiredOptionNotProvided description:@"one or more of the following options must be provided: --flarn --barf"];
    [self performTestWithArgumentVector:@[] options:options optionGroups:@[ group ] spec:spec];
    
    spec = [ArgumentParsingResultSpec specWithCLKErrorCode:CLKErrorRequiredOptionNotProvided description:@"one or more of the following options must be provided: --flarn --barf"];
    [self performTestWithArgumentVector:@[ @"--xyzzy" ] options:options optionGroups:@[ group ] spec:spec];
    
    NSDictionary *expectedOptionManifest = @{
        @"flarn" : @(1),
        @"xyzzy" : @(1)
    };
    
    spec = [ArgumentParsingResultSpec specWithOptionManifest:expectedOptionManifest];
    [self performTestWithArgumentVector:@[ @"--flarn", @"--xyzzy" ] options:options optionGroups:@[ group ] spec:spec];
}

- (void)testValidation_mutualExclusionGroup
{
    NSArray *options = @[
        [CLKOption optionWithName:@"flarn" flag:@"f"],
        [CLKOption optionWithName:@"barf"  flag:@"b"],
        [CLKOption optionWithName:@"quone" flag:@"q"],
        [CLKOption optionWithName:@"xyzzy" flag:@"x"] // not part of any mutex groups
    ];
    
    NSArray *groups = @[
        [CLKOptionGroup mutexedGroupForOptionsNamed:@[ @"flarn", @"barf" ]],
    ];
    
    NSArray *argv = @[ @"--quone", @"--flarn", @"--barf" ];
    ArgumentParsingResultSpec *spec = [ArgumentParsingResultSpec specWithCLKErrorCode:CLKErrorMutuallyExclusiveOptionsPresent description:@"--flarn --barf: mutually exclusive options encountered"];
    [self performTestWithArgumentVector:argv options:options optionGroups:groups spec:spec];
    
    argv = @[ @"--flarn" ];
    spec = [ArgumentParsingResultSpec specWithOptionManifest:@{ @"flarn" : @(1) }];
    [self performTestWithArgumentVector:argv options:options optionGroups:groups spec:spec];
    
    groups = @[
        [CLKOptionGroup mutexedGroupForOptionsNamed:@[ @"flarn", @"barf", @"quone" ]],
    ];
    
    argv = @[ @"--quone", @"--flarn", @"--barf" ];
    spec = [ArgumentParsingResultSpec specWithCLKErrorCode:CLKErrorMutuallyExclusiveOptionsPresent description:@"--flarn --barf --quone: mutually exclusive options encountered"];
    [self performTestWithArgumentVector:argv options:options optionGroups:groups spec:spec];
    
    argv = @[ @"--flarn", @"--xyzzy", @"--quone" ];
    spec = [ArgumentParsingResultSpec specWithCLKErrorCode:CLKErrorMutuallyExclusiveOptionsPresent description:@"--flarn --quone: mutually exclusive options encountered"];
    [self performTestWithArgumentVector:argv options:options optionGroups:groups spec:spec];
    
    groups = @[
        [CLKOptionGroup mutexedGroupForOptionsNamed:@[ @"flarn", @"barf" ]],
    ];
    
    NSDictionary *expectedOptionManifest = @{
        @"flarn" : @(1),
        @"quone" : @(1)
    };
    
    argv = @[ @"--flarn", @"--quone" ];
    spec = [ArgumentParsingResultSpec specWithOptionManifest:expectedOptionManifest];
    [self performTestWithArgumentVector:argv options:options optionGroups:groups spec:spec];
}

- (void)testValidation_standaloneGroup
{
    NSArray *options = @[
        [CLKOption optionWithName:@"flarn" flag:@"f"],
        [CLKOption optionWithName:@"barf" flag:@"b"],
        [CLKOption parameterOptionWithName:@"quone" flag:@"q"],
        [CLKOption parameterOptionWithName:@"xyzzy" flag:@"x"],
    ];
    
    /* success: no standalone option provided */
    
    CLKOptionGroup *group = [CLKOptionGroup standaloneGroupForOptionNamed:@"flarn" allowing:@[]];
    ArgumentParsingResultSpec *spec = [ArgumentParsingResultSpec specWithEmptyManifest];
    [self performTestWithArgumentVector:@[] options:options optionGroups:@[ group ] spec:spec];
    
    spec = [ArgumentParsingResultSpec specWithSwitchOption:@"barf" occurrences:1];
    [self performTestWithArgumentVector:@[ @"--barf" ] options:options optionGroups:@[ group ] spec:spec];
    
    group = [CLKOptionGroup standaloneGroupForOptionNamed:@"flarn" allowing:@[ @"barf" ]];
    [self performTestWithArgumentVector:@[ @"--barf" ] options:options optionGroups:@[ group ] spec:spec];
    
    /* success: standalone option provided */
    
    spec = [ArgumentParsingResultSpec specWithSwitchOption:@"flarn" occurrences:1];
    [self performTestWithArgumentVector:@[ @"--flarn" ] options:options optionGroups:@[ group ] spec:spec];
    
    spec = [ArgumentParsingResultSpec specWithSwitchOption:@"flarn" occurrences:2];
    [self performTestWithArgumentVector:@[ @"--flarn", @"--flarn" ] options:options optionGroups:@[ group ] spec:spec];
    
    /* success: standalone option provided with whitelist option */
    
    NSDictionary *expectedManifest = @{
        @"flarn" : @(1),
        @"barf" : @(1)
    };
    
    group = [CLKOptionGroup standaloneGroupForOptionNamed:@"flarn" allowing:@[ @"barf" ]];
    spec = [ArgumentParsingResultSpec specWithOptionManifest:expectedManifest];
    [self performTestWithArgumentVector:@[ @"--flarn", @"--barf" ] options:options optionGroups:@[ group ] spec:spec];

    expectedManifest = @{
        @"flarn" : @(1),
        @"barf" : @(2)
    };
    
    spec = [ArgumentParsingResultSpec specWithOptionManifest:expectedManifest];
    [self performTestWithArgumentVector:@[ @"--barf", @"--flarn", @"--barf" ] options:options optionGroups:@[ group ] spec:spec];
    
    expectedManifest = @{
        @"flarn" : @(1),
        @"barf" : @(1),
        @"quone" : @[ @"xyzzy" ]
    };
    
    group = [CLKOptionGroup standaloneGroupForOptionNamed:@"flarn" allowing:@[ @"barf", @"quone" ]];
    spec = [ArgumentParsingResultSpec specWithOptionManifest:expectedManifest];
    [self performTestWithArgumentVector:@[ @"--flarn", @"--barf", @"--quone", @"xyzzy" ] options:options optionGroups:@[ group ] spec:spec];
    
    /* validation failures */
    
    group = [CLKOptionGroup standaloneGroupForOptionNamed:@"flarn" allowing:@[]];
    spec = [ArgumentParsingResultSpec specWithCLKErrorCode:CLKErrorMutuallyExclusiveOptionsPresent description:@"--flarn may not be provided with other options"];
    [self performTestWithArgumentVector:@[ @"--flarn", @"--barf" ] options:options optionGroups:@[ group ] spec:spec];
    
    group = [CLKOptionGroup standaloneGroupForOptionNamed:@"flarn" allowing:@[ @"barf" ]];
    spec = [ArgumentParsingResultSpec specWithCLKErrorCode:CLKErrorMutuallyExclusiveOptionsPresent description:@"--flarn may not be provided with options other than the following: --barf"];
    [self performTestWithArgumentVector:@[ @"--flarn", @"--quone", @"confound.mak" ] options:options optionGroups:@[ group ] spec:spec];
    
    NSArray *groups = @[
        [CLKOptionGroup standaloneGroupForOptionNamed:@"flarn" allowing:@[ @"barf" ]],
        [CLKOptionGroup standaloneGroupForOptionNamed:@"quone" allowing:@[ @"barf" ]]
    ];
    
    NSArray *errors = @[
        [NSError clk_CLKErrorWithCode:CLKErrorMutuallyExclusiveOptionsPresent description:@"--flarn may not be provided with options other than the following: --barf"],
        [NSError clk_CLKErrorWithCode:CLKErrorMutuallyExclusiveOptionsPresent description:@"--quone may not be provided with options other than the following: --barf"],
    ];
    
    spec = [ArgumentParsingResultSpec specWithErrors:errors];
    [self performTestWithArgumentVector:@[ @"--flarn", @"--quone", @"confound.mak" ] options:options optionGroups:groups spec:spec];
    
    groups = @[
        [CLKOptionGroup standaloneGroupForOptionNamed:@"flarn" allowing:@[ @"barf" ]],
        [CLKOptionGroup standaloneGroupForOptionNamed:@"quone" allowing:@[ @"xyzzy" ]]
    ];
    
    errors = @[
        [NSError clk_CLKErrorWithCode:CLKErrorMutuallyExclusiveOptionsPresent description:@"--flarn may not be provided with options other than the following: --barf"],
        [NSError clk_CLKErrorWithCode:CLKErrorMutuallyExclusiveOptionsPresent description:@"--quone may not be provided with options other than the following: --xyzzy"],
    ];
    
    spec = [ArgumentParsingResultSpec specWithErrors:errors];
    [self performTestWithArgumentVector:@[ @"--flarn", @"--quone", @"confound.mak" ] options:options optionGroups:groups spec:spec];
    
    groups = @[
        [CLKOptionGroup standaloneGroupForOptionNamed:@"flarn" allowing:@[ @"barf" ]],
        [CLKOptionGroup mutexedGroupForOptionsNamed:@[ @"flarn", @"quone" ]]
    ];
    
    errors = @[
        [NSError clk_CLKErrorWithCode:CLKErrorMutuallyExclusiveOptionsPresent description:@"--flarn may not be provided with options other than the following: --barf"],
        [NSError clk_CLKErrorWithCode:CLKErrorMutuallyExclusiveOptionsPresent description:@"--flarn --quone: mutually exclusive options encountered"],
    ];
    
    spec = [ArgumentParsingResultSpec specWithErrors:errors];
    [self performTestWithArgumentVector:@[ @"--flarn", @"--quone", @"confound.mak" ] options:options optionGroups:groups spec:spec];
    
    /*
        a whitelist that contains a standalone option is a nonsensical configuration that we don't currently guard against.
        test it here so we at least know how it behaves and that it doesn't explode.
     
        [TACK] constraint coherency checking would define this away.
    */
    
    groups = @[
        [CLKOptionGroup standaloneGroupForOptionNamed:@"flarn" allowing:@[ @"barf" ]],
        [CLKOptionGroup standaloneGroupForOptionNamed:@"quone" allowing:@[ @"flarn" ]]
    ];
    
    spec = [ArgumentParsingResultSpec specWithCLKErrorCode:CLKErrorMutuallyExclusiveOptionsPresent description:@"--flarn may not be provided with options other than the following: --barf"];
    [self performTestWithArgumentVector:@[ @"--flarn", @"--quone", @"confound.mak" ] options:options optionGroups:groups spec:spec];
}

- (void)testValidation_standaloneOptionAndGroup
{
    NSArray *options = @[
        [CLKOption optionWithName:@"flarn" flag:@"f"],
        [CLKOption optionWithName:@"barf" flag:@"b"],
        [CLKOption standaloneOptionWithName:@"quone" flag:@"q"],
        [CLKOption optionWithName:@"xyzzy" flag:@"x"]
    ];
    
    /* success: no standalone option provided */
    
    CLKOptionGroup *group = [CLKOptionGroup standaloneGroupForOptionNamed:@"flarn" allowing:@[ @"barf" ]];
    ArgumentParsingResultSpec *spec = [ArgumentParsingResultSpec specWithEmptyManifest];
    [self performTestWithArgumentVector:@[] options:options optionGroups:@[ group ] spec:spec];
    
    spec = [ArgumentParsingResultSpec specWithSwitchOption:@"barf" occurrences:1];
    [self performTestWithArgumentVector:@[ @"--barf" ] options:options optionGroups:@[ group ] spec:spec];

    /* success: standalone option provided */
    
    spec = [ArgumentParsingResultSpec specWithSwitchOption:@"flarn" occurrences:1];
    [self performTestWithArgumentVector:@[ @"--flarn" ] options:options optionGroups:@[ group ] spec:spec];
    
    spec = [ArgumentParsingResultSpec specWithSwitchOption:@"quone" occurrences:1];
    [self performTestWithArgumentVector:@[ @"--quone" ] options:options optionGroups:@[ group ] spec:spec];
    
    /* validation failures */
    
    spec = [ArgumentParsingResultSpec specWithCLKErrorCode:CLKErrorMutuallyExclusiveOptionsPresent description:@"--quone may not be provided with other options"];
    [self performTestWithArgumentVector:@[ @"--quone", @"--xyzzy" ] options:options optionGroups:@[ group ] spec:spec];
    
    spec = [ArgumentParsingResultSpec specWithCLKErrorCode:CLKErrorMutuallyExclusiveOptionsPresent description:@"--flarn may not be provided with options other than the following: --barf"];
    [self performTestWithArgumentVector:@[ @"--flarn", @"--xyzzy" ] options:options optionGroups:@[ group ] spec:spec];
    
    NSArray *errors = @[
        [NSError clk_CLKErrorWithCode:CLKErrorMutuallyExclusiveOptionsPresent description:@"--quone may not be provided with other options"],
        [NSError clk_CLKErrorWithCode:CLKErrorMutuallyExclusiveOptionsPresent description:@"--flarn may not be provided with options other than the following: --barf"]
    ];
    
    spec = [ArgumentParsingResultSpec specWithErrors:errors];
    [self performTestWithArgumentVector:@[ @"--flarn", @"--quone" ] options:options optionGroups:@[ group ] spec:spec];

    NSArray *groups = @[
        [CLKOptionGroup standaloneGroupForOptionNamed:@"flarn" allowing:@[ @"barf" ]],
        [CLKOptionGroup mutexedGroupForOptionsNamed:@[ @"barf", @"xyzzy" ]]
    ];
    
    errors = @[
        [NSError clk_CLKErrorWithCode:CLKErrorMutuallyExclusiveOptionsPresent description:@"--quone may not be provided with other options"],
        [NSError clk_CLKErrorWithCode:CLKErrorMutuallyExclusiveOptionsPresent description:@"--flarn may not be provided with options other than the following: --barf"],
        [NSError clk_CLKErrorWithCode:CLKErrorMutuallyExclusiveOptionsPresent description:@"--barf --xyzzy: mutually exclusive options encountered"],
    ];
    
    spec = [ArgumentParsingResultSpec specWithErrors:errors];
    [self performTestWithArgumentVector:@[ @"--flarn", @"--quone", @"--barf", @"--xyzzy" ] options:options optionGroups:groups spec:spec];
}

- (void)testValidation_multipleMixedGroupErrors
{
    NSArray *options = @[
        [CLKOption optionWithName:@"flarn" flag:@"f"],
        [CLKOption optionWithName:@"barf"  flag:@"b"],
        [CLKOption optionWithName:@"quone" flag:@"q"],
        [CLKOption optionWithName:@"xyzzy" flag:@"x"],
        [CLKOption optionWithName:@"syn"  flag:@"s"],
        [CLKOption optionWithName:@"ack"  flag:@"a"],
    ];
    
    NSArray *groups = @[
        [CLKOptionGroup requiredGroupForOptionsNamed:@[ @"flarn", @"barf" ]],
        [CLKOptionGroup mutexedGroupForOptionsNamed:@[ @"quone", @"xyzzy" ]],
        [CLKOptionGroup standaloneGroupForOptionNamed:@"syn" allowing:@[ @"ack" ]]
    ];
    
    NSArray *errors = @[
        [NSError clk_CLKErrorWithCode:CLKErrorRequiredOptionNotProvided description:@"one or more of the following options must be provided: --flarn --barf"],
        [NSError clk_CLKErrorWithCode:CLKErrorMutuallyExclusiveOptionsPresent description:@"--quone --xyzzy: mutually exclusive options encountered"],
        [NSError clk_CLKErrorWithCode:CLKErrorMutuallyExclusiveOptionsPresent description:@"--syn may not be provided with options other than the following: --ack"],
    ];
    
    ArgumentParsingResultSpec *spec = [ArgumentParsingResultSpec specWithErrors:errors];
    [self performTestWithArgumentVector:@[ @"--quone", @"--xyzzy", @"--syn" ] options:options optionGroups:groups spec:spec];
}

@end
