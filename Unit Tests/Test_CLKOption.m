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

- (void)verifyOption:(CLKOption *)option type:(CLKOptionType)type name:(NSString *)name flag:(nullable NSString *)flag required:(BOOL)required;
- (void)verifyOption:(CLKOption *)option type:(CLKOptionType)type name:(NSString *)name flag:(nullable NSString *)flag dependencies:(nullable NSArray<NSString *> *)dependencies;

- (void)verifyOption:(CLKOption *)option
                type:(CLKOptionType)type
                name:(NSString *)name
                flag:(nullable NSString *)flag
            required:(BOOL)required
         transformer:(nullable CLKArgumentTransformer *)transformer;

- (void)verifyOption:(CLKOption *)option
                type:(CLKOptionType)type
                name:(NSString *)name
                flag:(nullable NSString *)flag
            required:(BOOL)required
           recurrent:(BOOL)recurrent
         transformer:(nullable CLKArgumentTransformer *)transformer
        dependencies:(nullable NSArray<NSString *> *)dependencies;

@end

NS_ASSUME_NONNULL_END


@implementation Test_CLKOption

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

- (void)verifyOption:(CLKOption *)option type:(CLKOptionType)type name:(NSString *)name flag:(NSString *)flag required:(BOOL)required
{
    // switch options are always recurrent
    [self verifyOption:option type:type name:name flag:flag required:required recurrent:(type == CLKOptionTypeSwitch) transformer:nil dependencies:nil];
}

- (void)verifyOption:(CLKOption *)option type:(CLKOptionType)type name:(NSString *)name flag:(NSString *)flag dependencies:(NSArray<NSString *> *)dependencies
{
    // switch options are always recurrent
    [self verifyOption:option type:type name:name flag:flag required:NO recurrent:(type == CLKOptionTypeSwitch) transformer:nil dependencies:dependencies];
}

- (void)verifyOption:(CLKOption *)option
                type:(CLKOptionType)type
                name:(NSString *)name
                flag:(NSString *)flag
            required:(BOOL)required
         transformer:(CLKArgumentTransformer *)transformer
{
    // switch options are always recurrent
    [self verifyOption:option type:type name:name flag:flag required:required recurrent:(type == CLKOptionTypeSwitch) transformer:transformer dependencies:nil];
}

- (void)verifyOption:(CLKOption *)option
                type:(CLKOptionType)type
                name:(NSString *)name
                flag:(NSString *)flag
            required:(BOOL)required
           recurrent:(BOOL)recurrent
         transformer:(CLKArgumentTransformer *)transformer
        dependencies:(NSArray<NSString *> *)dependencies
{
    XCTAssertNotNil(option);
    XCTAssertEqual(option.type, type);
    XCTAssertEqualObjects(option.name, name);
    XCTAssertEqualObjects(option.flag, flag);
    XCTAssertEqual(option.required, required);
    XCTAssertEqual(option.recurrent, recurrent);
    XCTAssertEqual(option.transformer, transformer); // transformers don't support equality
    XCTAssertEqualObjects(option.dependencies, dependencies);
}

#pragma mark -

- (void)testInitParameterOption
{
    CLKOption *option = [CLKOption parameterOptionWithName:@"flarn" flag:@"f"];
    [self verifyOption:option type:CLKOptionTypeParameter name:@"flarn" flag:@"f" required:NO];
    
    option = [CLKOption parameterOptionWithName:@"flarn" flag:nil];
    [self verifyOption:option type:CLKOptionTypeParameter name:@"flarn" flag:nil required:NO];
    
    option = [CLKOption parameterOptionWithName:@"flarn" flag:@"f" required:YES];
    [self verifyOption:option type:CLKOptionTypeParameter name:@"flarn" flag:@"f" required:YES];
    
    CLKArgumentTransformer *transformer = [CLKArgumentTransformer transformer];
    option = [CLKOption parameterOptionWithName:@"flarn" flag:@"f" transformer:transformer];
    [self verifyOption:option type:CLKOptionTypeParameter name:@"flarn" flag:@"f" required:NO transformer:transformer];
    
    option = [CLKOption parameterOptionWithName:@"flarn" flag:@"f" transformer:nil];
    [self verifyOption:option type:CLKOptionTypeParameter name:@"flarn" flag:@"f" required:NO];
    
    option = [CLKOption parameterOptionWithName:@"flarn" flag:@"f" required:YES recurrent:YES transformer:transformer dependencies:nil];
    [self verifyOption:option type:CLKOptionTypeParameter name:@"flarn" flag:@"f" required:YES recurrent:YES transformer:transformer dependencies:nil];
    
    XCTAssertThrows([CLKOption parameterOptionWithName:@"--flarn" flag:@"f"]);
    XCTAssertThrows([CLKOption parameterOptionWithName:@"flarn" flag:@"-f"]);
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    XCTAssertThrows([CLKOption parameterOptionWithName:nil flag:nil]);
    XCTAssertThrows([CLKOption parameterOptionWithName:nil flag:@"x"]);
    XCTAssertThrows([CLKOption parameterOptionWithName:@"" flag:@"x"]);
    XCTAssertThrows([CLKOption parameterOptionWithName:@"flarn" flag:@""]);
    XCTAssertThrows([CLKOption parameterOptionWithName:@"flarn" flag:@"xx"]);
#pragma clang diagnostic pop
}

- (void)testInitSwitchOption
{
    CLKOption *option = [CLKOption optionWithName:@"flarn" flag:@"f"];
    [self verifyOption:option type:CLKOptionTypeSwitch name:@"flarn" flag:@"f" required:NO];
    
    option = [CLKOption optionWithName:@"flarn" flag:nil];
    [self verifyOption:option type:CLKOptionTypeSwitch name:@"flarn" flag:nil required:NO];
    
    option = [CLKOption optionWithName:@"flarn" flag:@"f" dependencies:nil];
    [self verifyOption:option type:CLKOptionTypeSwitch name:@"flarn" flag:@"f" dependencies:nil];
    
    option = [CLKOption optionWithName:@"flarn" flag:@"f" dependencies:@[ @"alpha", @"bravo" ]];
    [self verifyOption:option type:CLKOptionTypeSwitch name:@"flarn" flag:@"f" dependencies:@[ @"alpha", @"bravo" ]];
    
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
    XCTAssertThrows([[[CLKOption alloc] initWithType:CLKOptionTypeSwitch name:@"flarn" flag:@"f" required:NO recurrent:NO transformer:[CLKArgumentTransformer transformer] dependencies:nil] autorelease]);
#pragma clang diagnostic pop
}

- (void)testCopying
{
    CLKOption *alphaA = [CLKOption optionWithName:@"flarn" flag:@"f"];
    CLKOption *alphaB = [[alphaA copy] autorelease];
    XCTAssertEqual(alphaA, alphaB); // CLKOption is immutable; -copy should return the receiver retained
}

- (void)testEquality_switchOptions_equal
{
    CombinationEngine *engine = [[[CombinationEngine alloc] initWithPrototype:self.standardSwitchOptionPrototype] autorelease];
    [engine enumerateCombinations:^(NSDictionary<NSString *, id> *combination) {
        CLKOption *alpha = [self switchOptionFromDictionaryRepresentation:combination];
        CLKOption *bravo = [self switchOptionFromDictionaryRepresentation:combination];
        XCTAssertEqualObjects(alpha, bravo);
        XCTAssertEqual(alpha.hash, bravo.hash);
    }];
}

- (void)testEquality_switchOptions_notEqual
{
    NSArray<CLKOption *> *options = [self generateObjectsFromPrototype:self.standardSwitchOptionPrototype block:^(NSDictionary<NSString *, id> *combination) {
        return [self switchOptionFromDictionaryRepresentation:combination];
    }];
    
    for (NSUInteger i = 0 ; i < options.count ; i++) {
        CLKOption *alpha = options[i];
        for (NSUInteger r = i + 1 ; r < options.count ; r++) {
            CLKOption *bravo = options[r];
            XCTAssertNotEqualObjects(alpha, bravo);
        }
    }
}

- (void)testEquality_parameterOptions_equal
{
    CombinationEngine *engine = [[[CombinationEngine alloc] initWithPrototype:self.standardSwitchOptionPrototype] autorelease];
    [engine enumerateCombinations:^(NSDictionary<NSString *, id> *combination) {
        CLKOption *alpha = [self parameterOptionFromDictionaryRepresentation:combination];
        CLKOption *bravo = [self parameterOptionFromDictionaryRepresentation:combination];
        XCTAssertEqualObjects(alpha, bravo);
        XCTAssertEqual(alpha.hash, bravo.hash);
    }];
}

- (void)testEquality_parameterOptions_notEqual
{
    NSArray<CLKOption *> *options = [self generateObjectsFromPrototype:self.standardParameterOptionPrototype block:^(NSDictionary<NSString *, id> *combination) {
        return [self parameterOptionFromDictionaryRepresentation:combination];
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
    CLKOption *switchOption = [CLKOption optionWithName:@"flarn" flag:@"f" dependencies:nil];
    CLKOption *parameterOption = [CLKOption parameterOptionWithName:@"flarn" flag:@"f"];
    XCTAssertNotEqualObjects(switchOption, parameterOption);
}

- (void)testEquality_misc
{
    CLKOption *option = [CLKOption optionWithName:@"flarn" flag:@"f" dependencies:nil];
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

- (void)testCollectionSupport_dictionaryKeys
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
    
    /* parameter options */
    
    quone = [CLKOption parameterOptionWithName:@"quone" flag:@"q" required:NO recurrent:YES transformer:nil dependencies:nil];
    XCTAssertEqualObjects(quone.constraints, @[]);
    
    quone = [CLKOption parameterOptionWithName:@"quone" flag:@"q" required:NO recurrent:NO transformer:nil dependencies:nil];
    expectedConstraints = @[
        [CLKArgumentManifestConstraint constraintRestrictingOccurrencesForOption:@"quone"]
    ];
    
    XCTAssertEqualObjects(quone.constraints, expectedConstraints);
    
    quone = [CLKOption parameterOptionWithName:@"quone" flag:@"q" required:YES recurrent:NO transformer:nil dependencies:nil];
    expectedConstraints = @[
        [CLKArgumentManifestConstraint constraintForRequiredOption:@"quone"],
        [CLKArgumentManifestConstraint constraintRestrictingOccurrencesForOption:@"quone"]
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
        [CLKArgumentManifestConstraint constraintRestrictingOccurrencesForOption:@"quone"]
    ];
    
    XCTAssertEqualObjects(quone.constraints, expectedConstraints);
    
    quone = [CLKOption parameterOptionWithName:@"quone" flag:@"q" required:YES recurrent:NO transformer:nil dependencies:nil];
    expectedConstraints = @[
        [CLKArgumentManifestConstraint constraintForRequiredOption:@"quone"],
        [CLKArgumentManifestConstraint constraintRestrictingOccurrencesForOption:@"quone"]
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
