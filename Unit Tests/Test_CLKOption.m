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

- (void)verifyOption:(CLKOption *)option
                type:(CLKOptionType)type
                name:(NSString *)name
                flag:(NSString *)flag
            required:(BOOL)required
         transformer:(CLKArgumentTransformer *)transformer
{
    XCTAssertNotNil(option);
    XCTAssertEqual(option.type, type);
    XCTAssertEqualObjects(option.name, name);
    XCTAssertEqualObjects(option.flag, flag);
    XCTAssertEqual(option.required, required);
    XCTAssert(option.transformer == transformer);
}

- (void)testInitParameterOption
{
    CLKOption *option = [CLKOption parameterOptionWithName:@"flarn" flag:@"f"];
    [self verifyOption:option type:CLKOptionTypeParameter name:@"flarn" flag:@"f" required:NO transformer:nil];
    
    option = [CLKOption parameterOptionWithName:@"flarn" flag:nil];
    [self verifyOption:option type:CLKOptionTypeParameter name:@"flarn" flag:nil required:NO transformer:nil];
    
    option = [CLKOption parameterOptionWithName:@"flarn" flag:@"f" required:YES];
    [self verifyOption:option type:CLKOptionTypeParameter name:@"flarn" flag:@"f" required:YES transformer:nil];
    
    CLKArgumentTransformer *transformer = [CLKArgumentTransformer transformer];
    option = [CLKOption parameterOptionWithName:@"flarn" flag:@"f" transformer:transformer];
    [self verifyOption:option type:CLKOptionTypeParameter name:@"flarn" flag:@"f" required:NO transformer:transformer];
    
    option = [CLKOption parameterOptionWithName:@"flarn" flag:@"f" transformer:nil];
    [self verifyOption:option type:CLKOptionTypeParameter name:@"flarn" flag:@"f" required:NO transformer:nil];
    
    option = [CLKOption parameterOptionWithName:@"flarn" flag:@"f" required:YES transformer:transformer];
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
    [self verifyOption:option type:CLKOptionTypeSwitch name:@"flarn" flag:@"f" required:NO transformer:nil];

    option = [CLKOption optionWithName:@"flarn" flag:nil];
    [self verifyOption:option type:CLKOptionTypeSwitch name:@"flarn" flag:nil required:NO transformer:nil];
    
    XCTAssertThrows([CLKOption optionWithName:@"--flarn" flag:@"f"]);
    XCTAssertThrows([CLKOption optionWithName:@"flarn" flag:@"-f"]);
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    XCTAssertThrows([CLKOption optionWithName:nil flag:nil]);
    XCTAssertThrows([CLKOption optionWithName:nil flag:@"x"]);
    XCTAssertThrows([CLKOption optionWithName:@"" flag:@"x"]);
    XCTAssertThrows([CLKOption optionWithName:@"flarn" flag:@""]);
    XCTAssertThrows([CLKOption optionWithName:@"flarn" flag:@"xx"]);
    XCTAssertThrows([[[CLKOption alloc] initWithType:CLKOptionTypeSwitch name:@"flarn" flag:@"f" required:YES transformer:nil] autorelease]);
    XCTAssertThrows([[[CLKOption alloc] initWithType:CLKOptionTypeSwitch name:@"flarn" flag:@"f" required:NO transformer:[CLKArgumentTransformer transformer]] autorelease]);
#pragma clang diagnostic pop
}

- (void)testEquality
{
    // flags are just conveniences -- the canoical identifier of an option is its name
    CLKOption *alphaA = [CLKOption parameterOptionWithName:@"alpha" flag:@"a"];
    CLKOption *alphaB = [CLKOption parameterOptionWithName:@"alpha" flag:@"a"];
    CLKOption *alphaC = [CLKOption parameterOptionWithName:@"alpha" flag:@"A"];
    CLKOption *bravo = [CLKOption parameterOptionWithName:@"bravo" flag:@"a"];
    
    XCTAssertTrue([alphaA isEqual:alphaA]);
    XCTAssertTrue([alphaA isEqual:alphaB]);
    XCTAssertTrue([alphaA isEqual:alphaC]);
    XCTAssertFalse([alphaA isEqual:bravo]);
    XCTAssertFalse([alphaA isEqual:@"not even an option"]);
    XCTAssertFalse([alphaA isEqual:nil]);
    
    XCTAssertEqual(alphaA.hash, alphaB.hash);
    XCTAssertEqual(alphaA.hash, alphaC.hash);
}

- (void)testCollectionSupport
{
    // flags are just conveniences -- the identity of an option is related only to its name
    CLKOption *alphaA = [CLKOption parameterOptionWithName:@"alpha" flag:@"a"];
    CLKOption *alphaB = [CLKOption parameterOptionWithName:@"alpha" flag:@"a"];
    CLKOption *alphaC = [CLKOption parameterOptionWithName:@"alpha" flag:@"A"];
    CLKOption *bravo = [CLKOption parameterOptionWithName:@"bravo" flag:@"b"];
    
    NSSet *set = [NSSet setWithObjects:alphaA, alphaB, alphaC, bravo, nil];
    XCTAssertEqual(set.count, 2);
    XCTAssertTrue([set containsObject:alphaA]);
    XCTAssertTrue([set containsObject:bravo]);
    
    int alphaCount = 0;
    for (CLKOption *opt in set.allObjects) {
        if ([opt.name isEqualToString:@"alpha"]) {
            alphaCount++;
        }
    }
    
    XCTAssertEqual(alphaCount, 1, @"expected only one --alpha option, found: %@", set);
}

@end
