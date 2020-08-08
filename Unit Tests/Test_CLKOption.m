//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CLKArgumentManifestConstraint.h"
#import "CLKArgumentTransformer.h"
#import "CLKOption_Private.h"
#import "XCTestCase+CLKAdditions.h"

NS_ASSUME_NONNULL_BEGIN

@interface Test_CLKOption : XCTestCase

- (NSArray<CLKOption *> *)uniqueOptions;
- (NSArray<NSString *> *)illegalOptionNames;
- (NSArray<NSString *> *)illegalOptionFlags;

- (void)verifySwitchOption:(CLKOption *)option name:(NSString *)name flag:(nullable NSString *)flag;

- (void)verifyParameterOption:(CLKOption *)option
                         name:(NSString *)name
                         flag:(nullable NSString *)flag
                     required:(BOOL)required
                    recurrent:(BOOL)recurrent
                  transformer:(nullable CLKArgumentTransformer *)transformer;

- (void)verifyOption:(CLKOption *)option
                type:(CLKOptionType)type
                name:(NSString *)name
                flag:(nullable NSString *)flag
            required:(BOOL)required
           recurrent:(BOOL)recurrent
         transformer:(nullable CLKArgumentTransformer *)transformer;

- (void)verifyOption:(CLKOption *)option
                type:(CLKOptionType)type
                name:(NSString *)name
                flag:(nullable NSString *)flag
            required:(BOOL)required
           recurrent:(BOOL)recurrent
          standalone:(BOOL)standalone
         transformer:(nullable CLKArgumentTransformer *)transformer;

@end

NS_ASSUME_NONNULL_END

@implementation Test_CLKOption

- (NSArray<CLKOption *> *)uniqueOptions
{
    NSMutableArray<CLKOption *> *uniqueOptions = [NSMutableArray array];
    
    NSArray *names = @[ @"flarn", @"barf"];
    NSArray *flags = @[
        [NSNull null],
        @"x",
        @"y"
    ];
    
    for (NSString *name in names) {
        for (id flag_ in flags) {
            NSString *flag = (flag_ == [NSNull null] ? nil : flag_);
            [uniqueOptions addObject:[CLKOption optionWithName:name flag:flag]];
            [uniqueOptions addObject:[CLKOption standaloneOptionWithName:name flag:flag]];
            
            [uniqueOptions addObject:[CLKOption parameterOptionWithName:name flag:flag required:NO  recurrent:NO  transformer:nil]];
            [uniqueOptions addObject:[CLKOption parameterOptionWithName:name flag:flag required:YES recurrent:NO  transformer:nil]];
            [uniqueOptions addObject:[CLKOption parameterOptionWithName:name flag:flag required:NO  recurrent:YES transformer:nil]];
            [uniqueOptions addObject:[CLKOption parameterOptionWithName:name flag:flag required:YES recurrent:YES transformer:nil]];
            
            [uniqueOptions addObject:[CLKOption standaloneParameterOptionWithName:name flag:flag recurrent:NO  transformer:nil]];
            [uniqueOptions addObject:[CLKOption standaloneParameterOptionWithName:name flag:flag recurrent:YES transformer:nil]];
        };
    }
    
    return uniqueOptions;
}

- (NSArray<NSString *> *)illegalOptionNames
{
    return @[
        @"",
        @"-",
        @"--",
        @"-what",
        @"--what",
        @"w=hat",
        @"w:hat",
        @"w hat"
    ];
}

- (NSArray<NSString *> *)illegalOptionFlags
{
    return @[
        @"",
        @"-",
        @"--",
        @"-q",
        @"=",
        @":",
        @"qq"
    ];
}

#pragma mark -

- (void)verifySwitchOption:(CLKOption *)option name:(NSString *)name flag:(NSString *)flag
{
    // switch options:
    //    - are always recurrent
    //    - are never required
    //    - do not support transformers
    [self verifyOption:option type:CLKOptionTypeSwitch name:name flag:flag required:NO recurrent:YES transformer:nil];
}

- (void)verifyParameterOption:(CLKOption *)option
                         name:(NSString *)name
                         flag:(NSString *)flag
                     required:(BOOL)required
                    recurrent:(BOOL)recurrent
                  transformer:(CLKArgumentTransformer *)transformer
{
    [self verifyOption:option type:CLKOptionTypeParameter name:name flag:flag required:required recurrent:recurrent transformer:transformer];
}

- (void)verifyOption:(CLKOption *)option
                type:(CLKOptionType)type
                name:(NSString *)name
                flag:(NSString *)flag
            required:(BOOL)required
           recurrent:(BOOL)recurrent
         transformer:(CLKArgumentTransformer *)transformer
{
    [self verifyOption:option type:type name:name flag:flag required:required recurrent:recurrent standalone:NO transformer:transformer];
}

- (void)verifyOption:(CLKOption *)option
                type:(CLKOptionType)type
                name:(NSString *)name
                flag:(NSString *)flag
            required:(BOOL)required
           recurrent:(BOOL)recurrent
          standalone:(BOOL)standalone
         transformer:(CLKArgumentTransformer *)transformer
{
    XCTAssertNotNil(option);
    XCTAssertEqual(option.type, type);
    XCTAssertEqualObjects(option.name, name);
    XCTAssertEqualObjects(option.flag, flag);
    XCTAssertEqual(option.required, required);
    XCTAssertEqual(option.recurrent, recurrent);
    XCTAssertEqual(option.standalone, standalone);
    XCTAssertEqual(option.transformer, transformer); // transformers don't support equality
}

#pragma mark -

- (void)testInitSwitchOption
{
    CLKOption *option = [CLKOption optionWithName:@"flarn" flag:@"f"];
    [self verifySwitchOption:option name:@"flarn" flag:@"f"];
    
    option = [CLKOption optionWithName:@"zero" flag:@"0"];
    [self verifySwitchOption:option name:@"zero" flag:@"0"];
    
    option = [CLKOption optionWithName:@"flarn" flag:nil];
    [self verifySwitchOption:option name:@"flarn" flag:nil];
    
    option = [CLKOption standaloneOptionWithName:@"flarn" flag:@"f"];
    [self verifyOption:option type:CLKOptionTypeSwitch name:@"flarn" flag:@"f" required:NO recurrent:YES standalone:YES transformer:nil];
    
    // option names are allowed to include numeric characters and dashes
    // (leading dashes are illegal. this is covered below.)
    XCTAssertNotNil([CLKOption optionWithName:@"mode7" flag:nil]);
    XCTAssertNotNil([CLKOption optionWithName:@"pit-pat" flag:nil]);
    
    for (NSString *name in [self illegalOptionNames]) {
        XCTAssertThrows([CLKOption optionWithName:name flag:@"f"]);
    }
    
    for (NSString *flag in [self illegalOptionFlags]) {
        XCTAssertThrows([CLKOption optionWithName:@"flarn" flag:flag]);
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    XCTAssertThrows([CLKOption optionWithName:nil flag:nil]);
    XCTAssertThrows([CLKOption optionWithName:nil flag:@"x"]);
#pragma clang diagnostic pop
}

- (void)testInitParameterOption
{
    CLKOption *option = [CLKOption parameterOptionWithName:@"flarn" flag:@"f"];
    [self verifyParameterOption:option name:@"flarn" flag:@"f" required:NO recurrent:NO transformer:nil];
    
    option = [CLKOption parameterOptionWithName:@"zero" flag:@"0"];
    [self verifyParameterOption:option name:@"zero" flag:@"0" required:NO recurrent:NO transformer:nil];
    
    option = [CLKOption parameterOptionWithName:@"flarn" flag:nil];
    [self verifyParameterOption:option name:@"flarn" flag:nil required:NO recurrent:NO transformer:nil];
    
    option = [CLKOption requiredParameterOptionWithName:@"flarn" flag:@"f"];
    [self verifyParameterOption:option name:@"flarn" flag:@"f" required:YES recurrent:NO transformer:nil];
    
    option = [CLKOption parameterOptionWithName:@"flarn" flag:@"f" required:NO recurrent:NO transformer:nil];
    [self verifyParameterOption:option name:@"flarn" flag:@"f" required:NO recurrent:NO transformer:nil];
    
    option = [CLKOption parameterOptionWithName:@"flarn" flag:@"f" required:YES recurrent:YES transformer:nil];
    [self verifyParameterOption:option name:@"flarn" flag:@"f" required:YES recurrent:YES transformer:nil];
    
    CLKArgumentTransformer *transformer = [[CLKArgumentTransformer alloc] init];
    option = [CLKOption parameterOptionWithName:@"flarn" flag:@"f" required:NO recurrent:NO transformer:transformer];
    [self verifyParameterOption:option name:@"flarn" flag:@"f" required:NO recurrent:NO transformer:transformer];
    
    option = [CLKOption standaloneParameterOptionWithName:@"flarn" flag:@"f"];
    [self verifyOption:option type:CLKOptionTypeParameter name:@"flarn" flag:@"f" required:NO recurrent:NO standalone:YES transformer:nil];
    
    option = [CLKOption standaloneParameterOptionWithName:@"flarn" flag:@"f" recurrent:YES transformer:transformer];
    [self verifyOption:option type:CLKOptionTypeParameter name:@"flarn" flag:@"f" required:NO recurrent:YES standalone:YES transformer:transformer];
    
    // option names can include numeric characters and dashes
    XCTAssertNotNil([CLKOption parameterOptionWithName:@"mode7" flag:nil]);
    XCTAssertNotNil([CLKOption parameterOptionWithName:@"pit-pat" flag:nil]);
    
    for (NSString *name in [self illegalOptionNames]) {
        XCTAssertThrows([CLKOption parameterOptionWithName:name flag:@"f"]);
    }
    
    for (NSString *flag in [self illegalOptionFlags]) {
        XCTAssertThrows([CLKOption parameterOptionWithName:@"flarn" flag:flag]);
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    XCTAssertThrows([CLKOption parameterOptionWithName:nil flag:nil]);
    XCTAssertThrows([CLKOption parameterOptionWithName:nil flag:@"x"]);
#pragma clang diagnostic pop
}

- (void)testCopying
{
    CLKOption *alphaA = [CLKOption optionWithName:@"flarn" flag:@"f"];
    CLKOption *alphaB = [alphaA copy];
    XCTAssertEqual(alphaA, alphaB); // CLKOption is immutable; -copy should return the receiver retained
}

- (void)testEquality
{
    NSArray<CLKOption *> *options = [self uniqueOptions];
    NSArray<CLKOption *> *optionClones = [self uniqueOptions];
    [options enumerateObjectsUsingBlock:^(CLKOption *option, NSUInteger idx, __unused BOOL *outStop) {
        CLKOption *clone = optionClones[idx];
        XCTAssertEqualObjects(option, clone);
        XCTAssertEqual(option.hash, clone.hash);
    }];
    
    // check each option against each option that succeeds it in the list.
    // when we're done, we will have exhausted the comparison space.
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
    
    // self to self
    XCTAssertTrue([option isEqual:option]);
}

- (void)testCollectionSupport_set
{
    NSArray<CLKOption *> *options = [self uniqueOptions];
    NSArray<CLKOption *> *optionClones = [self uniqueOptions];
    
    // verify deduplication
    NSSet *expectedOptionSet = [NSSet setWithArray:options];
    NSArray<CLKOption *> *redundantOptions = [options arrayByAddingObjectsFromArray:optionClones];
    NSSet *optionSet = [NSSet setWithArray:redundantOptions];
    XCTAssertEqualObjects(optionSet, expectedOptionSet);
    
    for (NSUInteger i = 0 ; i < options.count ; i++) {
        CLKOption *option = options[i];
        CLKOption *clone = optionClones[i];
        XCTAssertTrue([optionSet containsObject:option]);
        XCTAssertTrue([optionSet containsObject:clone]);
    }
}

- (void)testCollectionSupport_dictionaryKey
{
    NSArray<CLKOption *> *options = [self uniqueOptions];
    NSArray<CLKOption *> *optionClones = [self uniqueOptions];
    
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
    CLKOption *switchC = [CLKOption standaloneOptionWithName:@"switchC" flag:@"s"];
    CLKOption *paramA = [CLKOption parameterOptionWithName:@"paramA" flag:@"p" required:NO recurrent:NO transformer:nil];
    CLKOption *paramB = [CLKOption parameterOptionWithName:@"paramB" flag:nil required:YES recurrent:YES transformer:nil];
    CLKOption *paramC = [CLKOption standaloneParameterOptionWithName:@"paramC" flag:@"p" recurrent:YES transformer:nil];
    
    XCTAssertEqualObjects(switchA.description, ([NSString stringWithFormat:@"<CLKOption: %p> { --switchA | -s | switch, recurrent }", switchA]));
    XCTAssertEqualObjects(switchB.description, ([NSString stringWithFormat:@"<CLKOption: %p> { --switchB | -(null) | switch, recurrent }", switchB]));
    XCTAssertEqualObjects(switchC.description, ([NSString stringWithFormat:@"<CLKOption: %p> { --switchC | -s | switch, recurrent, standalone }", switchC]));
    XCTAssertEqualObjects(paramA.description, ([NSString stringWithFormat:@"<CLKOption: %p> { --paramA | -p | parameter }", paramA]));
    XCTAssertEqualObjects(paramB.description, ([NSString stringWithFormat:@"<CLKOption: %p> { --paramB | -(null) | parameter, required, recurrent }", paramB]));
    XCTAssertEqualObjects(paramC.description, ([NSString stringWithFormat:@"<CLKOption: %p> { --paramC | -p | parameter, recurrent, standalone }", paramC]));
}

- (void)testConstraints_switchOptions
{
    CLKOption *option = [CLKOption optionWithName:@"quone" flag:@"q"];
    XCTAssertEqualObjects(option.constraints, @[]);
    
    option = [CLKOption standaloneOptionWithName:@"quone" flag:@"q"];
    NSArray *expectedConstraints = @[
        [CLKArgumentManifestConstraint constraintForStandaloneOption:@"quone" allowingOptions:nil]
    ];
    
    XCTAssertEqualObjects(option.constraints, expectedConstraints);
}

- (void)testConstraints_parameterOptions
{
    CLKOption *quone = [CLKOption parameterOptionWithName:@"quone" flag:@"q" required:NO recurrent:YES transformer:nil];
    XCTAssertEqualObjects(quone.constraints, @[]);
    
    quone = [CLKOption parameterOptionWithName:@"quone" flag:@"q" required:NO recurrent:NO transformer:nil];
    NSArray<CLKArgumentManifestConstraint *> *expectedConstraints = @[
        [CLKArgumentManifestConstraint constraintLimitingOccurrencesForOption:@"quone"]
    ];
    
    XCTAssertEqualObjects(quone.constraints, expectedConstraints);
    
    quone = [CLKOption parameterOptionWithName:@"quone" flag:@"q" required:YES recurrent:NO transformer:nil];
    expectedConstraints = @[
        [CLKArgumentManifestConstraint constraintForRequiredOption:@"quone"],
        [CLKArgumentManifestConstraint constraintLimitingOccurrencesForOption:@"quone"]
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
