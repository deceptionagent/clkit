//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CLKArgumentManifestConstraint.h"
#import "CLKArgumentTransformer.h"
#import "CLKOption.h"
#import "CLKOption_Private.h"


NS_ASSUME_NONNULL_BEGIN

@interface Test_CLKOption : XCTestCase

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
    XCTAssertEqual(option.transformer, transformer);
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

- (void)testEquality
{
    // flags are just conveniences -- the canoical identifier of an option is its name
    CLKOption *alphaA = [CLKOption optionWithName:@"alpha" flag:@"a"];
    CLKOption *alphaB = [CLKOption optionWithName:@"alpha" flag:@"a"];
    CLKOption *alphaC = [CLKOption optionWithName:@"alpha" flag:@"A"];
    CLKOption *bravoA = [CLKOption optionWithName:@"bravo" flag:@"a"];
    CLKOption *bravoB = [CLKOption parameterOptionWithName:@"bravo" flag:@"a"];

    XCTAssertTrue([alphaA isEqual:alphaA]);
    XCTAssertTrue([alphaA isEqual:alphaB]);
    XCTAssertTrue([alphaA isEqual:alphaC]);
    XCTAssertFalse([alphaA isEqual:bravoA]);
    XCTAssertTrue([bravoA isEqual:bravoB]);
    XCTAssertFalse([alphaA isEqual:@"not even an option"]);
    XCTAssertFalse([alphaA isEqual:nil]);
    
    XCTAssertEqual(alphaA.hash, alphaB.hash);
    XCTAssertEqual(alphaA.hash, alphaC.hash);
    XCTAssertNotEqual(alphaA.hash, bravoA.hash);
    XCTAssertEqual(bravoA.hash, bravoB.hash);
}

- (void)testCollectionSupport_set
{
    // flags are just conveniences -- the identity of an option is related only to its name
    CLKOption *alphaA = [CLKOption optionWithName:@"alpha" flag:@"a"];
    CLKOption *alphaB = [CLKOption optionWithName:@"alpha" flag:@"a"];
    CLKOption *alphaC = [CLKOption optionWithName:@"alpha" flag:@"A"];
    CLKOption *bravoA = [CLKOption optionWithName:@"bravo" flag:@"a"];
    CLKOption *bravoB = [CLKOption parameterOptionWithName:@"bravo" flag:@"a"];

    NSSet *set = [NSSet setWithObjects:alphaA, alphaB, alphaC, bravoA, bravoB, nil];
    XCTAssertEqual(set.count, 2);
    XCTAssertTrue([set containsObject:alphaA]);
    XCTAssertTrue([set containsObject:alphaB]);
    XCTAssertTrue([set containsObject:alphaC]);
    XCTAssertTrue([set containsObject:bravoA]);
    XCTAssertTrue([set containsObject:bravoB]);
    
    int alphaCount = 0;
    int bravoCount = 0;
    for (CLKOption *opt in set.allObjects) {
        if ([opt.name isEqualToString:@"alpha"]) {
            alphaCount++;
        } else if ([opt.name isEqualToString:@"bravo"]) {
            bravoCount++;
        }
    }
    
    XCTAssertEqual(alphaCount, 1, @"expected only one --alpha option, found: %@", set);
    XCTAssertEqual(bravoCount, 1, @"expected only one --bravo option, found: %@", set);
}

- (void)testCollectionSupport_dictionaryKeys
{
    // flags are just conveniences -- the identity of an option is related only to its name
    CLKOption *alphaA = [CLKOption optionWithName:@"alpha" flag:@"a"];
    CLKOption *alphaA_alt = [CLKOption optionWithName:@"alpha" flag:@"a"];
    CLKOption *alphaB = [CLKOption optionWithName:@"alpha" flag:@"A"];
    CLKOption *bravo = [CLKOption optionWithName:@"bravo" flag:@"a"];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[alphaA] = @"flarn";
    XCTAssertEqualObjects(dict[alphaA], @"flarn");
    XCTAssertEqualObjects(dict[alphaA_alt], @"flarn");
    dict[alphaB] = @"barf";
    XCTAssertEqualObjects(dict[alphaA], @"barf"); // alphaA and alphaB should behave the same here
    dict[bravo] = @"what";
    XCTAssertEqualObjects(dict[bravo], @"what");
}

- (void)testDescription
{
    CLKOption *switchA = [CLKOption optionWithName:@"switchA" flag:@"a"];
    CLKOption *switchB = [CLKOption optionWithName:@"switchB" flag:nil];
    CLKOption *paramA = [CLKOption parameterOptionWithName:@"paramA" flag:@"p" required:NO recurrent:NO transformer:nil dependencies:nil];
    CLKOption *paramB = [CLKOption parameterOptionWithName:@"paramB" flag:@"P" required:YES recurrent:YES transformer:nil dependencies:nil];
    
    XCTAssertEqualObjects(switchA.description, ([NSString stringWithFormat:@"<CLKOption: %p> { --switchA | -a | switch, recurrent }", switchA]));
    XCTAssertEqualObjects(switchB.description, ([NSString stringWithFormat:@"<CLKOption: %p> { --switchB | -(null) | switch, recurrent }", switchB]));
    XCTAssertEqualObjects(paramA.description, ([NSString stringWithFormat:@"<CLKOption: %p> { --paramA | -p | parameter }", paramA]));
    XCTAssertEqualObjects(paramB.description, ([NSString stringWithFormat:@"<CLKOption: %p> { --paramB | -P | parameter, required, recurrent }", paramB]));
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
