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

@property (readonly) NSDictionary<NSString *, id> *standardSwitchOptionPrototype;
@property (readonly) NSDictionary<NSString *, id> *standardParameterOptionPrototype;

- (CLKOption *)switchOptionFromDictionaryRepresentation:(NSDictionary<NSString *, id> *)representation;
- (CLKOption *)parameterOptionFromDictionaryRepresentation:(NSDictionary<NSString *, id> *)representation;

- (void)verifyParameterOption:(CLKOption *)option
                         name:(NSString *)name
                         flag:(nullable NSString *)flag
                     required:(BOOL)required
                    recurrent:(BOOL)recurrent
                   restricted:(BOOL)restricted
                  transformer:(nullable CLKArgumentTransformer *)transformer
                 dependencies:(nullable NSArray<NSString *> *)dependencies;

- (void)verifySwitchOption:(CLKOption *)option
                      name:(NSString *)name
                      flag:(nullable NSString *)flag
                restricted:(BOOL)restricted
              dependencies:(nullable NSArray<NSString *> *)dependencies;

- (void)verifyOption:(CLKOption *)option
                type:(CLKOptionType)type
                name:(NSString *)name
                flag:(nullable NSString *)flag
            required:(BOOL)required
           recurrent:(BOOL)recurrent
          restricted:(BOOL)restricted
         transformer:(nullable CLKArgumentTransformer *)transformer
        dependencies:(nullable NSArray<NSString *> *)dependencies;

@end

NS_ASSUME_NONNULL_END


@implementation Test_CLKOption

#warning combinatorial tests need restriction support

- (NSDictionary<NSString *, id> *)standardSwitchOptionPrototype
{
    return @{
        @"name" : @[ @"flarn", @"barf" ],
        @"flag" : @[ CEPrototypeNoValue, @"a", @"b" ],
        @"dependencies" : @[ CEPrototypeNoValue, @[ @"confound" ], @[ @"delivery" ] ]
    };
}

- (NSDictionary<NSString *, id> *)standardParameterOptionPrototype
{
    return @{
        @"name" : @[ @"flarn", @"barf" ],
        @"flag" : @[ CEPrototypeNoValue, @"a", @"b" ],
        @"required" : @[ @(NO), @(YES) ],
        @"recurrent" : @[ @(NO), @(YES) ],
        @"dependencies" : @[ CEPrototypeNoValue, @[ @"confound" ], @[ @"delivery" ] ]
    };
}

- (CLKOption *)switchOptionFromDictionaryRepresentation:(NSDictionary<NSString *, id> *)representation
{
    NSString *name = representation[@"name"];
    NSString *flag = representation[@"flag"];
    NSArray<NSString *> *dependencies = representation[@"dependencies"];
    return [CLKOption optionWithName:name flag:flag dependencies:dependencies];
}

- (CLKOption *)parameterOptionFromDictionaryRepresentation:(NSDictionary<NSString *, id> *)representation
{
    NSString *name = representation[@"name"];
    NSString *flag = representation[@"flag"];
    BOOL required = [representation[@"required"] boolValue];
    BOOL recurrent = [representation[@"recurrent"] boolValue];
    NSArray<NSString *> *dependencies = representation[@"dependencies"];
    return [CLKOption parameterOptionWithName:name flag:flag required:required recurrent:recurrent transformer:nil dependencies:dependencies];
}

- (void)verifyParameterOption:(CLKOption *)option
                         name:(NSString *)name
                         flag:(NSString *)flag
                     required:(BOOL)required
                    recurrent:(BOOL)recurrent
                   restricted:(BOOL)restricted
                  transformer:(CLKArgumentTransformer *)transformer
                 dependencies:(NSArray<NSString *> *)dependencies
{
    [self verifyOption:option type:CLKOptionTypeParameter name:name flag:flag required:required recurrent:recurrent restricted:restricted transformer:transformer dependencies:dependencies];
}

- (void)verifySwitchOption:(CLKOption *)option
                      name:(NSString *)name
                      flag:(NSString *)flag
                restricted:(BOOL)restricted
              dependencies:(NSArray<NSString *> *)dependencies
{
    // switch options:
    //    - are always recurrent
    //    - are never required
    //    - do not support transformers
    [self verifyOption:option type:CLKOptionTypeSwitch name:name flag:flag required:NO recurrent:YES restricted:restricted transformer:nil dependencies:dependencies];
}

- (void)verifyOption:(CLKOption *)option
                type:(CLKOptionType)type
                name:(NSString *)name
                flag:(NSString *)flag
            required:(BOOL)required
           recurrent:(BOOL)recurrent
          restricted:(BOOL)restricted
         transformer:(CLKArgumentTransformer *)transformer
        dependencies:(NSArray<NSString *> *)dependencies
{
    XCTAssertNotNil(option);
    XCTAssertEqual(option.type, type);
    XCTAssertEqualObjects(option.name, name);
    XCTAssertEqualObjects(option.flag, flag);
    XCTAssertEqual(option.required, required);
    XCTAssertEqual(option.recurrent, recurrent);
    XCTAssertEqual(option.restricted, restricted);
    XCTAssertEqual(option.transformer, transformer); // transformers don't support equality
    XCTAssertEqualObjects(option.dependencies, dependencies);
}

#pragma mark -

- (void)testInitParameterOption
{
    CLKOption *option = [CLKOption parameterOptionWithName:@"flarn" flag:@"f"];
    [self verifyParameterOption:option name:@"flarn" flag:@"f" required:NO recurrent:NO restricted:NO transformer:nil dependencies:nil];
    
    option = [CLKOption parameterOptionWithName:@"flarn" flag:nil];
    [self verifyParameterOption:option name:@"flarn" flag:nil required:NO recurrent:NO restricted:NO transformer:nil dependencies:nil];
    
    option = [CLKOption parameterOptionWithName:@"flarn" flag:@"f" required:YES];
    [self verifyParameterOption:option name:@"flarn" flag:@"f" required:YES recurrent:NO restricted:NO transformer:nil dependencies:nil];
    
    option = [CLKOption parameterOptionWithName:@"flarn" flag:@"f" restricted:YES];
    [self verifyParameterOption:option name:@"flarn" flag:@"f" required:YES recurrent:NO restricted:YES transformer:nil dependencies:nil];
    
    option = [CLKOption parameterOptionWithName:@"flarn" flag:@"f" dependencies:nil];
    [self verifyParameterOption:option name:@"flarn" flag:@"f" required:NO recurrent:NO restricted:NO transformer:nil dependencies:nil];
    
    option = [CLKOption parameterOptionWithName:@"flarn" flag:@"f" dependencies:@[ @"barf" ]];
    [self verifyParameterOption:option name:@"flarn" flag:@"f" required:NO recurrent:NO restricted:NO transformer:nil dependencies:@[ @"barf" ]];
    
    CLKArgumentTransformer *transformer = [CLKArgumentTransformer transformer];
    option = [CLKOption parameterOptionWithName:@"flarn" flag:@"f" transformer:transformer];
    [self verifyParameterOption:option name:@"flarn" flag:@"f" required:NO recurrent:NO restricted:NO transformer:transformer dependencies:nil];
    
    option = [CLKOption parameterOptionWithName:@"flarn" flag:@"f" transformer:nil];
    [self verifyParameterOption:option name:@"flarn" flag:@"f" required:NO recurrent:NO restricted:NO transformer:nil dependencies:nil];
    
    option = [CLKOption parameterOptionWithName:@"flarn" flag:@"f" recurrent:YES restricted:YES transformer:transformer];
    [self verifyParameterOption:option name:@"flarn" flag:@"f" required:NO recurrent:YES restricted:YES transformer:transformer dependencies:nil];
    
    option = [CLKOption parameterOptionWithName:@"flarn" flag:@"f" required:YES recurrent:YES transformer:transformer dependencies:nil];
    [self verifyParameterOption:option name:@"flarn" flag:@"f" required:YES recurrent:YES restricted:NO transformer:transformer dependencies:nil];
    
    option = [CLKOption parameterOptionWithName:@"flarn" flag:@"f" required:YES recurrent:YES transformer:transformer dependencies:@[ @"barf" ]];
    [self verifyParameterOption:option name:@"flarn" flag:@"f" required:YES recurrent:YES restricted:NO transformer:transformer dependencies:@[ @"barf" ]];
    
    XCTAssertThrows([CLKOption parameterOptionWithName:@"--flarn" flag:@"f"]);
    XCTAssertThrows([CLKOption parameterOptionWithName:@"flarn" flag:@"-f"]);
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    XCTAssertThrows([CLKOption parameterOptionWithName:nil flag:nil]);
    XCTAssertThrows([CLKOption parameterOptionWithName:nil flag:@"x"]);
    XCTAssertThrows([CLKOption parameterOptionWithName:@"" flag:@"x"]);
    XCTAssertThrows([CLKOption parameterOptionWithName:@"flarn" flag:@""]);
    XCTAssertThrows([CLKOption parameterOptionWithName:@"flarn" flag:@"xx"]);
    XCTAssertThrows([CLKOption parameterOptionWithName:@"flarn" flag:@"f" dependencies:@[ @"flarn" ]]);
#pragma clang diagnostic pop
}

- (void)testInitSwitchOption
{
    CLKOption *option = [CLKOption optionWithName:@"flarn" flag:@"f"];
    [self verifySwitchOption:option name:@"flarn" flag:@"f" restricted:NO dependencies:nil];
    
    option = [CLKOption optionWithName:@"flarn" flag:nil];
    [self verifySwitchOption:option name:@"flarn" flag:nil restricted:NO dependencies:nil];
    
    option = [CLKOption optionWithName:@"flarn" flag:nil restricted:YES];
    [self verifySwitchOption:option name:@"flarn" flag:nil restricted:YES dependencies:nil];
    
    option = [CLKOption optionWithName:@"flarn" flag:@"f" dependencies:nil];
    [self verifySwitchOption:option name:@"flarn" flag:@"f" restricted:NO dependencies:nil];
    
    option = [CLKOption optionWithName:@"flarn" flag:@"f" dependencies:@[ @"alpha", @"bravo" ]];
    [self verifySwitchOption:option name:@"flarn" flag:@"f" restricted:NO dependencies:@[ @"alpha", @"bravo" ]];
    
    XCTAssertThrows([CLKOption optionWithName:@"--flarn" flag:@"f"]);
    XCTAssertThrows([CLKOption optionWithName:@"flarn" flag:@"-f"]);
    XCTAssertThrows([CLKOption optionWithName:@"flarn" flag:@"f" dependencies:@[ @"flarn" ]]);
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    XCTAssertThrows([CLKOption optionWithName:nil flag:nil]);
    XCTAssertThrows([CLKOption optionWithName:nil flag:@"x"]);
    XCTAssertThrows([CLKOption optionWithName:@"" flag:@"x"]);
    XCTAssertThrows([CLKOption optionWithName:@"flarn" flag:@""]);
    XCTAssertThrows([CLKOption optionWithName:@"flarn" flag:@"xx"]);
    XCTAssertThrows([CLKOption optionWithName:@"flarn" flag:@"f" dependencies:@[ @"flarn" ]]);
    
    // switch options do not support transformers
    XCTAssertThrows([[[CLKOption alloc] initWithType:CLKOptionTypeSwitch name:@"flarn" flag:@"f" required:NO recurrent:NO restricted:NO transformer:[CLKArgumentTransformer transformer] dependencies:nil] autorelease]);
    
    // restricted options can't have dependencies
    XCTAssertThrows([[[CLKOption alloc] initWithType:CLKOptionTypeSwitch name:@"flarn" flag:@"f" required:NO recurrent:NO restricted:YES transformer:nil dependencies:@[ @"barf" ]] autorelease]);
#pragma clang diagnostic pop
}

- (void)testCopying
{
    CLKOption *alphaA = [CLKOption optionWithName:@"flarn" flag:@"f"];
    CLKOption *alphaB = [[alphaA copy] autorelease];
    XCTAssertEqual(alphaA, alphaB); // CLKOption is immutable; -copy should return the receiver retained
}

#warning add restricted

- (void)testEquality_switchOptions
{
    __block NSMutableArray *options = [NSMutableArray array];
    
    CombinationEngine *engine = [[[CombinationEngine alloc] initWithPrototype:self.standardSwitchOptionPrototype] autorelease];
    [engine enumerateCombinations:^(NSDictionary<NSString *, id> *combination) {
        CLKOption *option = [self switchOptionFromDictionaryRepresentation:combination];
        CLKOption *clone = [self switchOptionFromDictionaryRepresentation:combination];
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

- (void)testEquality_parameterOptions
{
    __block NSMutableArray *options = [NSMutableArray array];
    
    CombinationEngine *engine = [[[CombinationEngine alloc] initWithPrototype:self.standardParameterOptionPrototype] autorelease];
    [engine enumerateCombinations:^(NSDictionary<NSString *, id> *combination) {
        CLKOption *option = [self parameterOptionFromDictionaryRepresentation:combination];
        CLKOption *clone = [self parameterOptionFromDictionaryRepresentation:combination];
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

- (void)testEqualty_differentTypes
{
    CLKOption *switchOption = [CLKOption optionWithName:@"flarn" flag:@"f"];
    CLKOption *parameterOption = [CLKOption parameterOptionWithName:@"flarn" flag:@"f"];
    XCTAssertNotEqualObjects(switchOption, parameterOption);
}

- (void)testEquality_misc
{
    CLKOption *option = [CLKOption optionWithName:@"flarn" flag:@"f"];
    XCTAssertNotEqualObjects(option, nil);
    XCTAssertNotEqualObjects(option, @"not an option");
}

- (void)testCollectionSupport_set
{
    __block NSMutableArray *options = [NSMutableArray array];
    __block NSMutableArray<CLKOption *> *optionClones = [NSMutableArray array]; // verify lookup works for identical instances
    
    CombinationEngine *engine = [[[CombinationEngine alloc] initWithPrototype:self.standardSwitchOptionPrototype] autorelease];
    [engine enumerateCombinations:^(NSDictionary<NSString *, id> *combination) {
        CLKOption *option = [self switchOptionFromDictionaryRepresentation:combination];
        [options addObject:option];
        CLKOption *clone = [self switchOptionFromDictionaryRepresentation:combination];
        [optionClones addObject:clone];
    }];
    
    engine = [[[CombinationEngine alloc] initWithPrototype:self.standardParameterOptionPrototype] autorelease];
    [engine enumerateCombinations:^(NSDictionary<NSString *, id> *combination) {
        CLKOption *option = [self parameterOptionFromDictionaryRepresentation:combination];
        [options addObject:option];
        CLKOption *clone = [self parameterOptionFromDictionaryRepresentation:combination];
        [optionClones addObject:clone];
    }];
    
    NSSet *optionSet = [NSSet setWithArray:options];
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
    
    CombinationEngine *engine = [[[CombinationEngine alloc] initWithPrototype:self.standardSwitchOptionPrototype] autorelease];
    [engine enumerateCombinations:^(NSDictionary<NSString *, id> *combination) {
        CLKOption *option = [self switchOptionFromDictionaryRepresentation:combination];
        [options addObject:option];
        CLKOption *clone = [self switchOptionFromDictionaryRepresentation:combination];
        [optionClones addObject:clone];
    }];
    
    engine = [[[CombinationEngine alloc] initWithPrototype:self.standardParameterOptionPrototype] autorelease];
    [engine enumerateCombinations:^(NSDictionary<NSString *, id> *combination) {
        CLKOption *option = [self parameterOptionFromDictionaryRepresentation:combination];
        [options addObject:option];
        CLKOption *clone = [self parameterOptionFromDictionaryRepresentation:combination];
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
    #warning add restricted
    
    CLKOption *switchA = [CLKOption optionWithName:@"switchA" flag:@"a"];
    CLKOption *switchB = [CLKOption optionWithName:@"switchB" flag:nil];
    CLKOption *switchC = [CLKOption optionWithName:@"switchC" flag:@"a" dependencies:@[ @"flarn", @"barf" ]];
    CLKOption *paramA = [CLKOption parameterOptionWithName:@"paramA" flag:@"p" required:NO recurrent:NO transformer:nil dependencies:nil];
    CLKOption *paramB = [CLKOption parameterOptionWithName:@"paramB" flag:nil required:YES recurrent:YES transformer:nil dependencies:nil];
    CLKOption *paramC = [CLKOption parameterOptionWithName:@"paramC" flag:@"p" required:YES recurrent:YES transformer:nil dependencies:@[ @"flarn", @"barf" ]];
    
    XCTAssertEqualObjects(switchA.description, ([NSString stringWithFormat:@"<CLKOption: %p> { --switchA | -a | switch, recurrent | dependencies: (null) }", switchA]));
    XCTAssertEqualObjects(switchB.description, ([NSString stringWithFormat:@"<CLKOption: %p> { --switchB | -(null) | switch, recurrent | dependencies: (null) }", switchB]));
    XCTAssertEqualObjects(switchC.description, ([NSString stringWithFormat:@"<CLKOption: %p> { --switchC | -a | switch, recurrent | dependencies: flarn, barf }", switchC]));
    XCTAssertEqualObjects(paramA.description, ([NSString stringWithFormat:@"<CLKOption: %p> { --paramA | -p | parameter | dependencies: (null) }", paramA]));
    XCTAssertEqualObjects(paramB.description, ([NSString stringWithFormat:@"<CLKOption: %p> { --paramB | -(null) | parameter, required, recurrent | dependencies: (null) }", paramB]));
    XCTAssertEqualObjects(paramC.description, ([NSString stringWithFormat:@"<CLKOption: %p> { --paramC | -p | parameter, required, recurrent | dependencies: flarn, barf }", paramC]));
}

#warning add restricted to testConstraints_*

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
    
    # warning i think this was moved to testConstraints_parameterOptions
    /* parameter options */
    
    quone = [CLKOption parameterOptionWithName:@"quone" flag:@"q" required:NO recurrent:YES transformer:nil dependencies:nil];
    XCTAssertEqualObjects(quone.constraints, @[]);
    
    quone = [CLKOption parameterOptionWithName:@"quone" flag:@"q" required:NO recurrent:NO transformer:nil dependencies:nil];
    expectedConstraints = @[
        [CLKArgumentManifestConstraint constraintLimitingOccurrencesForOption:@"quone"]
    ];
    
    XCTAssertEqualObjects(quone.constraints, expectedConstraints);
    
    quone = [CLKOption parameterOptionWithName:@"quone" flag:@"q" required:YES recurrent:NO transformer:nil dependencies:nil];
    expectedConstraints = @[
        [CLKArgumentManifestConstraint constraintForRequiredOption:@"quone"],
        [CLKArgumentManifestConstraint constraintLimitingOccurrencesForOption:@"quone"]
    ];
    
    XCTAssertEqualObjects(quone.constraints, expectedConstraints);
    
    quone = [CLKOption parameterOptionWithName:@"quone" flag:@"q" required:YES recurrent:YES transformer:nil dependencies:@[ @"barf", @"flarn"]];
    expectedConstraints = @[
        [CLKArgumentManifestConstraint constraintForRequiredOption:@"quone"],
        [CLKArgumentManifestConstraint constraintForConditionallyRequiredOption:@"barf" associatedOption:@"quone"],
        [CLKArgumentManifestConstraint constraintForConditionallyRequiredOption:@"flarn" associatedOption:@"quone"]
    ];
    
    XCTAssertEqualObjects(quone.constraints, expectedConstraints);
}

- (void)testConstraints_parameterOptions
{
    CLKOption *quone = [CLKOption parameterOptionWithName:@"quone" flag:@"q" required:NO recurrent:YES transformer:nil dependencies:nil];
    XCTAssertEqualObjects(quone.constraints, @[]);
    
    quone = [CLKOption parameterOptionWithName:@"quone" flag:@"q" required:NO recurrent:NO transformer:nil dependencies:nil];
    NSArray<CLKArgumentManifestConstraint *> *expectedConstraints = @[
        [CLKArgumentManifestConstraint constraintLimitingOccurrencesForOption:@"quone"]
    ];
    
    XCTAssertEqualObjects(quone.constraints, expectedConstraints);
    
    quone = [CLKOption parameterOptionWithName:@"quone" flag:@"q" required:YES recurrent:NO transformer:nil dependencies:nil];
    expectedConstraints = @[
        [CLKArgumentManifestConstraint constraintForRequiredOption:@"quone"],
        [CLKArgumentManifestConstraint constraintLimitingOccurrencesForOption:@"quone"]
    ];
    
    XCTAssertEqualObjects(quone.constraints, expectedConstraints);
    
    quone = [CLKOption parameterOptionWithName:@"quone" flag:@"q" required:YES recurrent:YES transformer:nil dependencies:@[ @"barf", @"flarn"]];
    expectedConstraints = @[
        [CLKArgumentManifestConstraint constraintForRequiredOption:@"quone"],
        [CLKArgumentManifestConstraint constraintForConditionallyRequiredOption:@"barf" associatedOption:@"quone"],
        [CLKArgumentManifestConstraint constraintForConditionallyRequiredOption:@"flarn" associatedOption:@"quone"]
    ];
    
    XCTAssertEqualObjects(quone.constraints, expectedConstraints);
}

@end
