//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CLKArgumentManifestConstraint.h"
#import "CLKArgumentTransformer.h"
#import "CLKOption.h"
#import "CLKOption_Private.h"
#import "CombinationEngine.h"
#import "XCTestCase+CLKAdditions.h"


NS_ASSUME_NONNULL_BEGIN

@interface Test_CLKOption : XCTestCase

@property (readonly) CETemplate *optionTemplate;

- (CLKOption *)optionFromCombination:(CECombination *)combination;

- (void)verifyParameterOption:(CLKOption *)option
                         name:(NSString *)name
                         flag:(nullable NSString *)flag
                     required:(BOOL)required
                    recurrent:(BOOL)recurrent
                 dependencies:(nullable NSArray<NSString *> *)dependencies
                  transformer:(nullable CLKArgumentTransformer *)transformer;

- (void)verifySwitchOption:(CLKOption *)option
                      name:(NSString *)name
                      flag:(nullable NSString *)flag
              dependencies:(nullable NSArray<NSString *> *)dependencies;

- (void)verifyOption:(CLKOption *)option
                type:(CLKOptionType)type
                name:(NSString *)name
                flag:(nullable NSString *)flag
            required:(BOOL)required
           recurrent:(BOOL)recurrent
        dependencies:(nullable NSArray<NSString *> *)dependencies
         transformer:(nullable CLKArgumentTransformer *)transformer;

@end

NS_ASSUME_NONNULL_END

@implementation Test_CLKOption

- (CETemplate *)optionTemplate
{
    NSArray *series = @[
        [CETemplateSeries seriesWithIdentifier:@"name" values:@[ @"flarn", @"barf" ] variants:@[ @"switch", @"parameter", @"standalone_switch", @"standalone_parameter" ]],
        [CETemplateSeries elidableSeriesWithIdentifier:@"flag" values:@[ @"a", @"b" ] variants:@[ @"switch", @"parameter", @"standalone_switch", @"standalone_parameter" ]],
        [CETemplateSeries seriesWithIdentifier:@"required" values:@[ @YES, @NO ] variant:@"parameter"],
        [CETemplateSeries seriesWithIdentifier:@"recurrent" values:@[ @YES, @NO ] variants:@[ @"parameter", @"standalone_parameter" ]],
        [CETemplateSeries elidableSeriesWithIdentifier:@"dependencies" values:@[ @[ @"confound" ], @[ @"delivery" ] ] variants:@[ @"switch", @"parameter" ]]
    ];
    
    return [CETemplate templateWithSeries:series];
}

- (CLKOption *)optionFromCombination:(CECombination *)combination
{
    CLKOption *option = nil;
    NSString *name = combination[@"name"];
    NSString *flag = combination[@"flag"];
    
    if ([combination.variant isEqualToString:@"switch"]) {
        NSArray<NSString *> *dependencies = combination[@"dependencies"];
        option = [CLKOption optionWithName:name flag:flag dependencies:dependencies];
    } else if ([combination.variant isEqualToString:@"parameter"]) {
        BOOL required = [combination[@"required"] boolValue];
        BOOL recurrent = [combination[@"recurrent"] boolValue];
        NSArray<NSString *> *dependencies = combination[@"dependencies"];
        option = [CLKOption parameterOptionWithName:name flag:flag required:required recurrent:recurrent dependencies:dependencies transformer:nil];
    } else if ([combination.variant isEqualToString:@"standalone_switch"]) {
        option = [CLKOption standaloneOptionWithName:name flag:flag];
    } else if ([combination.variant isEqualToString:@"standalone_parameter"]) {
        BOOL recurrent = [combination[@"recurrent"] boolValue];
        option = [CLKOption standaloneParameterOptionWithName:name flag:flag recurrent:recurrent transformer:nil];
    } else {
        XCTFail(@"unknown combination variant: '%@'", combination.variant);
    }
    
    XCTAssertNotNil(option);
    
    return option;
}

- (void)verifyParameterOption:(CLKOption *)option
                         name:(NSString *)name
                         flag:(NSString *)flag
                     required:(BOOL)required
                    recurrent:(BOOL)recurrent
                 dependencies:(NSArray<NSString *> *)dependencies
                  transformer:(CLKArgumentTransformer *)transformer
{
    [self verifyOption:option type:CLKOptionTypeParameter name:name flag:flag required:required recurrent:recurrent dependencies:dependencies transformer:transformer];
}

- (void)verifySwitchOption:(CLKOption *)option
                      name:(NSString *)name
                      flag:(NSString *)flag
              dependencies:(NSArray<NSString *> *)dependencies
{
    // switch options:
    //    - are always recurrent
    //    - are never required
    //    - do not support transformers
    [self verifyOption:option type:CLKOptionTypeSwitch name:name flag:flag required:NO recurrent:YES dependencies:dependencies transformer:nil];
}

- (void)verifyOption:(CLKOption *)option
                type:(CLKOptionType)type
                name:(NSString *)name
                flag:(NSString *)flag
            required:(BOOL)required
           recurrent:(BOOL)recurrent
        dependencies:(NSArray<NSString *> *)dependencies
         transformer:(CLKArgumentTransformer *)transformer
{
    XCTAssertNotNil(option);
    XCTAssertEqual(option.type, type);
    XCTAssertEqualObjects(option.name, name);
    XCTAssertEqualObjects(option.flag, flag);
    XCTAssertEqual(option.required, required);
    XCTAssertEqual(option.recurrent, recurrent);
    XCTAssertEqualObjects(option.dependencies, dependencies);
    XCTAssertEqual(option.transformer, transformer); // transformers don't support equality
}

#pragma mark -

- (void)testInitSwitchOption
{
    CLKOption *option = [CLKOption optionWithName:@"flarn" flag:@"f"];
    [self verifySwitchOption:option name:@"flarn" flag:@"f" dependencies:nil];

    option = [CLKOption optionWithName:@"zero" flag:@"0"];
    [self verifySwitchOption:option name:@"zero" flag:@"0" dependencies:nil];
    
    option = [CLKOption optionWithName:@"flarn" flag:nil];
    [self verifySwitchOption:option name:@"flarn" flag:nil dependencies:nil];
    
    option = [CLKOption optionWithName:@"flarn" flag:@"f" dependencies:nil];
    [self verifySwitchOption:option name:@"flarn" flag:@"f" dependencies:nil];
    
    option = [CLKOption optionWithName:@"flarn" flag:@"f" dependencies:@[ @"alpha", @"bravo" ]];
    [self verifySwitchOption:option name:@"flarn" flag:@"f" dependencies:@[ @"alpha", @"bravo" ]];
    
    // option names can include numeric characters and dashes
    XCTAssertNotNil([CLKOption optionWithName:@"mode7" flag:nil]);
    XCTAssertNotNil([CLKOption optionWithName:@"pit-pat" flag:nil]);
    
    XCTAssertThrows([CLKOption optionWithName:@"" flag:@"x"]);
    XCTAssertThrows([CLKOption optionWithName:@"flarn" flag:@""]);
    XCTAssertThrows([CLKOption optionWithName:@"flarn" flag:@"xx"]);
    XCTAssertThrows([CLKOption optionWithName:@"flarn" flag:@"-"]);
    XCTAssertThrows([CLKOption optionWithName:@"flarn" flag:@"--"]);
    XCTAssertThrows([CLKOption optionWithName:@"flarn" flag:@":"]);
    XCTAssertThrows([CLKOption optionWithName:@"flarn" flag:@"="]);
    XCTAssertThrows([CLKOption optionWithName:@"flarn" flag:@" "]);
    XCTAssertThrows([CLKOption optionWithName:@"w hat" flag:@"w"]);
    XCTAssertThrows([CLKOption optionWithName:@"w:hat" flag:@"w"]);
    XCTAssertThrows([CLKOption optionWithName:@"w=hat" flag:@"w"]);
    XCTAssertThrows([CLKOption optionWithName:@"--flarn" flag:@"f"]);
    XCTAssertThrows([CLKOption optionWithName:@"flarn" flag:@"-f"]);
    XCTAssertThrows([CLKOption optionWithName:@"flarn" flag:@"f" dependencies:@[ @"flarn" ]]);
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    XCTAssertThrows([CLKOption optionWithName:nil flag:nil]);
    XCTAssertThrows([CLKOption optionWithName:nil flag:@"x"]);
    XCTAssertThrows([CLKOption optionWithName:@"flarn" flag:@"f" dependencies:@[ @"flarn" ]]);
#pragma clang diagnostic pop
}

- (void)testInitParameterOption
{
    CLKOption *option = [CLKOption parameterOptionWithName:@"flarn" flag:@"f"];
    [self verifyParameterOption:option name:@"flarn" flag:@"f" required:NO recurrent:NO dependencies:nil transformer:nil];

    option = [CLKOption parameterOptionWithName:@"zero" flag:@"0"];
    [self verifyParameterOption:option name:@"zero" flag:@"0" required:NO recurrent:NO dependencies:nil transformer:nil];

    option = [CLKOption parameterOptionWithName:@"flarn" flag:nil];
    [self verifyParameterOption:option name:@"flarn" flag:nil required:NO recurrent:NO dependencies:nil transformer:nil];
    
    option = [CLKOption requiredParameterOptionWithName:@"flarn" flag:@"f"];
    [self verifyParameterOption:option name:@"flarn" flag:@"f" required:YES recurrent:NO dependencies:nil transformer:nil];
    
    option = [CLKOption parameterOptionWithName:@"flarn" flag:@"f" required:NO recurrent:NO dependencies:nil transformer:nil];
    [self verifyParameterOption:option name:@"flarn" flag:@"f" required:NO recurrent:NO dependencies:nil transformer:nil];
    
    option = [CLKOption parameterOptionWithName:@"flarn" flag:@"f" required:YES recurrent:YES dependencies:nil transformer:nil];
    [self verifyParameterOption:option name:@"flarn" flag:@"f" required:YES recurrent:YES dependencies:nil transformer:nil];
    
    CLKArgumentTransformer *transformer = [CLKArgumentTransformer transformer];
    option = [CLKOption parameterOptionWithName:@"flarn" flag:@"f" required:YES recurrent:YES dependencies:nil transformer:transformer];
    [self verifyParameterOption:option name:@"flarn" flag:@"f" required:YES recurrent:YES dependencies:nil transformer:transformer];
    
    option = [CLKOption parameterOptionWithName:@"flarn" flag:@"f" required:YES recurrent:YES dependencies:@[ @"barf" ] transformer:transformer];
    [self verifyParameterOption:option name:@"flarn" flag:@"f" required:YES recurrent:YES dependencies:@[ @"barf" ] transformer:transformer];
    
    // option names can include numeric characters and dashes
    XCTAssertNotNil([CLKOption parameterOptionWithName:@"mode7" flag:nil]);
    XCTAssertNotNil([CLKOption parameterOptionWithName:@"pit-pat" flag:nil]);
    
    XCTAssertThrows([CLKOption parameterOptionWithName:@"" flag:@"x"]);
    XCTAssertThrows([CLKOption parameterOptionWithName:@"flarn" flag:@""]);
    XCTAssertThrows([CLKOption parameterOptionWithName:@"flarn" flag:@"xx"]);
    XCTAssertThrows([CLKOption parameterOptionWithName:@"flarn" flag:@"-"]);
    XCTAssertThrows([CLKOption parameterOptionWithName:@"flarn" flag:@":"]);
    XCTAssertThrows([CLKOption parameterOptionWithName:@"f:larn" flag:@"f"]);
    XCTAssertThrows([CLKOption parameterOptionWithName:@"f=larn" flag:@"f"]);
    XCTAssertThrows([CLKOption parameterOptionWithName:@"--flarn" flag:@"f"]);
    XCTAssertThrows([CLKOption parameterOptionWithName:@"flarn" flag:@"-f"]);
    XCTAssertThrows([CLKOption parameterOptionWithName:@"w:hat" flag:@"w"]);
    XCTAssertThrows([CLKOption parameterOptionWithName:@"w=hat" flag:@"-w"]);
    XCTAssertThrows([CLKOption parameterOptionWithName:@"flarn" flag:@"f" required:NO recurrent:NO dependencies:@[ @"flarn" ] transformer:nil]);
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    XCTAssertThrows([CLKOption parameterOptionWithName:nil flag:nil]);
    XCTAssertThrows([CLKOption parameterOptionWithName:nil flag:@"x"]);
#pragma clang diagnostic pop
}

- (void)testCopying
{
    CLKOption *alphaA = [CLKOption optionWithName:@"flarn" flag:@"f"];
    CLKOption *alphaB = [[alphaA copy] autorelease];
    XCTAssertEqual(alphaA, alphaB); // CLKOption is immutable; -copy should return the receiver retained
}

- (void)testEquality
{
    __block NSMutableArray *options = [NSMutableArray array];
    
    CEGenerator *generator = [CEGenerator generatorWithTemplate:self.optionTemplate];
    [generator enumerateCombinations:^(CECombination *combination) {
        CLKOption *option = [self optionFromCombination:combination];
        CLKOption *clone = [self optionFromCombination:combination];
        XCTAssertEqualObjects(option, clone);
        XCTAssertEqual(option.hash, clone.hash);
        [options addObject:option];
    }];
    
    for (NSUInteger i = 0 ; i < options.count ; i++) {
        CLKOption *alpha = options[i];
        for (NSUInteger r = i + 1 ; r < options.count ; r++) {
            CLKOption *bravo = options[r];
            XCTAssertNotEqualObjects(alpha, bravo);
        }
    }
}

- (void)testEquality_misc
{
    // different types
    CLKOption *switchOption = [CLKOption optionWithName:@"flarn" flag:@"f"];
    CLKOption *parameterOption = [CLKOption parameterOptionWithName:@"flarn" flag:@"f"];
    XCTAssertNotEqualObjects(switchOption, parameterOption);
    
    // option vs not-option
    CLKOption *option = [CLKOption optionWithName:@"flarn" flag:@"f"];
    XCTAssertNotEqualObjects(option, nil);
    XCTAssertNotEqualObjects(option, @"not an option");
}

- (void)testCollectionSupport_set
{
    __block NSMutableArray<CLKOption *> *options = [NSMutableArray array];
    __block NSMutableArray<CLKOption *> *optionClones = [NSMutableArray array]; // verify lookup works for identical instances
    
    CEGenerator *generator = [CEGenerator generatorWithTemplate:self.optionTemplate];
    [generator enumerateCombinations:^(CECombination *combination) {
        CLKOption *option = [self optionFromCombination:combination];
        CLKOption *clone = [self optionFromCombination:combination];
        [options addObject:option];
        [optionClones addObject:clone];
    }];
    
    // verify deduplication
    NSArray<CLKOption *> *redundantOptions = [options arrayByAddingObjectsFromArray:optionClones];
    NSSet *optionSet = [NSSet setWithArray:redundantOptions];
    XCTAssertEqual(optionSet.count, options.count);
    
    for (NSUInteger i = 0 ; i < options.count ; i++) {
        CLKOption *option = options[i];
        CLKOption *clone = optionClones[i];
        XCTAssertTrue([optionSet containsObject:option]);
        XCTAssertTrue([optionSet containsObject:clone]);
    }
}

- (void)testCollectionSupport_dictionaryKey
{
    __block NSMutableArray<CLKOption *> *options = [NSMutableArray array];
    __block NSMutableArray<CLKOption *> *optionClones = [NSMutableArray array]; // verify lookup works for identical instances
    
    CEGenerator *generator = [CEGenerator generatorWithTemplate:self.optionTemplate];
    [generator enumerateCombinations:^(CECombination *combination) {
        CLKOption *option = [self optionFromCombination:combination];
        CLKOption *clone = [self optionFromCombination:combination];
        [options addObject:option];
        [optionClones addObject:clone];
    }];
    
    NSMutableDictionary<CLKOption *, NSNumber *> *dict = [NSMutableDictionary dictionary];
    NSUInteger assignedRecord = 1;
    for (CLKOption *option in options) {
        dict[option] = @(assignedRecord);
        assignedRecord++;
    }
    
    XCTAssertEqual(dict.count, options.count);
    NSUInteger expectedRecord = 1;
    for (NSUInteger i = 0 ; i < options.count ; i++) {
        CLKOption *option = options[i];
        CLKOption *clone = optionClones[i];
        NSUInteger record = [dict[option] unsignedIntegerValue];
        XCTAssertEqual(record, expectedRecord);
        record = [dict[clone] unsignedIntegerValue];
        XCTAssertEqual(record, expectedRecord);
        expectedRecord++;
    }
}

- (void)testDescription
{
    CLKOption *switchA = [CLKOption optionWithName:@"switchA" flag:@"s"];
    CLKOption *switchB = [CLKOption optionWithName:@"switchB" flag:nil];
    CLKOption *switchC = [CLKOption optionWithName:@"switchC" flag:@"s" dependencies:@[ @"flarn", @"barf" ]];
    CLKOption *switchD = [CLKOption standaloneOptionWithName:@"switchD" flag:@"s"];
    CLKOption *paramA = [CLKOption parameterOptionWithName:@"paramA" flag:@"p" required:NO recurrent:NO dependencies:nil transformer:nil];
    CLKOption *paramB = [CLKOption parameterOptionWithName:@"paramB" flag:nil required:YES recurrent:YES dependencies:nil transformer:nil];
    CLKOption *paramC = [CLKOption parameterOptionWithName:@"paramC" flag:@"p" required:YES recurrent:YES dependencies:@[ @"flarn", @"barf" ] transformer:nil];
    CLKOption *paramD = [CLKOption standaloneParameterOptionWithName:@"paramD" flag:@"p" recurrent:YES transformer:nil];
    
    XCTAssertEqualObjects(switchA.description, ([NSString stringWithFormat:@"<CLKOption: %p> { --switchA | -s | switch, recurrent | dependencies: (null) }", switchA]));
    XCTAssertEqualObjects(switchB.description, ([NSString stringWithFormat:@"<CLKOption: %p> { --switchB | -(null) | switch, recurrent | dependencies: (null) }", switchB]));
    XCTAssertEqualObjects(switchC.description, ([NSString stringWithFormat:@"<CLKOption: %p> { --switchC | -s | switch, recurrent | dependencies: flarn, barf }", switchC]));
    XCTAssertEqualObjects(switchD.description, ([NSString stringWithFormat:@"<CLKOption: %p> { --switchD | -s | switch, recurrent, standalone | dependencies: (null) }", switchD]));
    XCTAssertEqualObjects(paramA.description, ([NSString stringWithFormat:@"<CLKOption: %p> { --paramA | -p | parameter | dependencies: (null) }", paramA]));
    XCTAssertEqualObjects(paramB.description, ([NSString stringWithFormat:@"<CLKOption: %p> { --paramB | -(null) | parameter, required, recurrent | dependencies: (null) }", paramB]));
    XCTAssertEqualObjects(paramC.description, ([NSString stringWithFormat:@"<CLKOption: %p> { --paramC | -p | parameter, required, recurrent | dependencies: flarn, barf }", paramC]));
    XCTAssertEqualObjects(paramD.description, ([NSString stringWithFormat:@"<CLKOption: %p> { --paramD | -p | parameter, recurrent, standalone | dependencies: (null) }", paramD]));
}

- (void)testConstraints_switchOptions
{
    /* switch options */
    
    CLKOption *quone = [CLKOption optionWithName:@"quone" flag:@"q" dependencies:@[ @"barf" ]];
    NSArray<CLKArgumentManifestConstraint *> *expectedConstraints = @[
        [CLKArgumentManifestConstraint constraintForConditionallyRequiredOption:@"barf" associatedOption:@"quone"]
    ];
    
    XCTAssertEqualObjects(quone.constraints, expectedConstraints);
    
    quone = [CLKOption optionWithName:@"quone" flag:@"q" dependencies:@[ @"barf", @"flarn" ]];
    expectedConstraints = @[
        [CLKArgumentManifestConstraint constraintForConditionallyRequiredOption:@"barf" associatedOption:@"quone"],
        [CLKArgumentManifestConstraint constraintForConditionallyRequiredOption:@"flarn" associatedOption:@"quone"]
    ];
    
    XCTAssertEqualObjects(quone.constraints, expectedConstraints);
    
    quone = [CLKOption standaloneOptionWithName:@"quone" flag:@"q"];
    expectedConstraints = @[
        [CLKArgumentManifestConstraint constraintForStandaloneOption:@"quone" allowingOptions:nil]
    ];
    
    XCTAssertEqualObjects(quone.constraints, expectedConstraints);
}

- (void)testConstraints_parameterOptions
{
    CLKOption *quone = [CLKOption parameterOptionWithName:@"quone" flag:@"q" required:NO recurrent:YES dependencies:nil transformer:nil];
    XCTAssertEqualObjects(quone.constraints, @[]);
    
    quone = [CLKOption parameterOptionWithName:@"quone" flag:@"q" required:NO recurrent:NO dependencies:nil transformer:nil];
    NSArray<CLKArgumentManifestConstraint *> *expectedConstraints = @[
        [CLKArgumentManifestConstraint constraintLimitingOccurrencesForOption:@"quone"]
    ];
    
    XCTAssertEqualObjects(quone.constraints, expectedConstraints);
    
    quone = [CLKOption parameterOptionWithName:@"quone" flag:@"q" required:YES recurrent:NO dependencies:nil transformer:nil];
    expectedConstraints = @[
        [CLKArgumentManifestConstraint constraintForRequiredOption:@"quone"],
        [CLKArgumentManifestConstraint constraintLimitingOccurrencesForOption:@"quone"]
    ];
    
    XCTAssertEqualObjects(quone.constraints, expectedConstraints);
    
    quone = [CLKOption parameterOptionWithName:@"quone" flag:@"q" required:YES recurrent:YES dependencies:@[ @"barf", @"flarn"] transformer:nil];
    expectedConstraints = @[
        [CLKArgumentManifestConstraint constraintForRequiredOption:@"quone"],
        [CLKArgumentManifestConstraint constraintForConditionallyRequiredOption:@"barf" associatedOption:@"quone"],
        [CLKArgumentManifestConstraint constraintForConditionallyRequiredOption:@"flarn" associatedOption:@"quone"]
    ];
    
    XCTAssertEqualObjects(quone.constraints, expectedConstraints);
    
    quone = [CLKOption standaloneParameterOptionWithName:@"quone" flag:@"q" recurrent:NO transformer:nil];
    expectedConstraints = @[
        [CLKArgumentManifestConstraint constraintLimitingOccurrencesForOption:@"quone"],
        [CLKArgumentManifestConstraint constraintForStandaloneOption:@"quone" allowingOptions:nil]
    ];

    quone = [CLKOption standaloneParameterOptionWithName:@"quone" flag:@"q" recurrent:YES transformer:nil];
    expectedConstraints = @[
        [CLKArgumentManifestConstraint constraintForStandaloneOption:@"quone" allowingOptions:nil]
    ];
    
    XCTAssertEqualObjects(quone.constraints, expectedConstraints);
}

@end
