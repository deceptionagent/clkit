//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CLKArgumentTransformer.h"
#import "CLKOption.h"
#import "CLKOption_Private.h"


@interface Test_CLKOption : XCTestCase

@end


@implementation Test_CLKOption

- (void)verifyOption:(CLKOption *)option type:(CLKOptionType)type name:(NSString *)name flag:(NSString *)flag required:(BOOL)required
{
    [self verifyOption:option type:type name:name flag:flag required:required transformer:nil dependencies:nil];
}

- (void)verifyOption:(CLKOption *)option
                type:(CLKOptionType)type
                name:(NSString *)name
                flag:(NSString *)flag
            required:(BOOL)required
         transformer:(CLKArgumentTransformer *)transformer
{
    [self verifyOption:option type:type name:name flag:flag required:required transformer:transformer dependencies:nil];
}

- (void)verifyOption:(CLKOption *)option
                type:(CLKOptionType)type
                name:(NSString *)name
                flag:(NSString *)flag
            required:(BOOL)required
         transformer:(CLKArgumentTransformer *)transformer
        dependencies:(NSArray<CLKOption *> *)dependencies
{
    XCTAssertNotNil(option);
    XCTAssertEqual(option.type, type);
    XCTAssertEqualObjects(option.name, name);
    XCTAssertEqualObjects(option.flag, flag);
    XCTAssertEqual(option.required, required);
    XCTAssert(option.transformer == transformer);
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
    
    option = [CLKOption parameterOptionWithName:@"flarn" flag:@"f" required:YES transformer:transformer dependencies:nil];
    [self verifyOption:option type:CLKOptionTypeParameter name:@"flarn" flag:@"f" required:YES transformer:transformer];
    
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
    
    XCTAssertThrows([CLKOption optionWithName:@"--flarn" flag:@"f"]);
    XCTAssertThrows([CLKOption optionWithName:@"flarn" flag:@"-f"]);
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    XCTAssertThrows([CLKOption optionWithName:nil flag:nil]);
    XCTAssertThrows([CLKOption optionWithName:nil flag:@"x"]);
    XCTAssertThrows([CLKOption optionWithName:@"" flag:@"x"]);
    XCTAssertThrows([CLKOption optionWithName:@"flarn" flag:@""]);
    XCTAssertThrows([CLKOption optionWithName:@"flarn" flag:@"xx"]);
    XCTAssertThrows([[[CLKOption alloc] initWithType:CLKOptionTypeSwitch name:@"flarn" flag:@"f" required:YES] autorelease]);
    XCTAssertThrows([[[CLKOption alloc] initWithType:CLKOptionTypeSwitch name:@"flarn" flag:@"f" required:NO transformer:[CLKArgumentTransformer transformer] dependencies:nil] autorelease]);
#pragma clang diagnostic pop
}

- (void)testInitWithDependencies
{
    NSArray *dependencies = @[
        [CLKOption parameterOptionWithName:@"alpha" flag:@"a"],
        [CLKOption parameterOptionWithName:@"bravo" flag:@"b"]
    ];
    
    CLKOption *option = [CLKOption optionWithName:@"flarn" flag:@"f" dependencies:nil];
    [self verifyOption:option type:CLKOptionTypeSwitch name:@"flarn" flag:@"f" required:NO transformer:nil dependencies:nil];
    
    option = [CLKOption optionWithName:@"flarn" flag:@"f" dependencies:dependencies];
    [self verifyOption:option type:CLKOptionTypeSwitch name:@"flarn" flag:@"f" required:NO transformer:nil dependencies:dependencies];
    
    // switches can't be required
    NSArray *invalidDependencies = @[
        [CLKOption parameterOptionWithName:@"alpha" flag:@"a"], // OK
        [CLKOption optionWithName:@"bravo" flag:@"b"] // NOT OK
    ];
    
    XCTAssertThrows([CLKOption optionWithName:@"flarn" flag:@"f" dependencies:invalidDependencies]);
}

- (void)testCopying
{
    CLKOption *alphaA = [CLKOption optionWithName:@"flarn" flag:@"f"];
    CLKOption *alphaB = [alphaA copy];
    XCTAssertEqual(alphaA, alphaB); // CLKOption is immutable; -copy returns the receiver retained
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
    CLKOption *alphaB = [CLKOption optionWithName:@"alpha" flag:@"A"];
    CLKOption *bravo = [CLKOption optionWithName:@"bravo" flag:@"a"];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[alphaA] = @"flarn";
    XCTAssertEqualObjects(dict[alphaA], @"flarn");
    dict[alphaB] = @"barf";
    XCTAssertEqualObjects(dict[alphaA], @"barf"); // alphaA and alphaB should behave the same here
    dict[bravo] = @"what";
    XCTAssertEqualObjects(dict[bravo], @"what");
}

@end
