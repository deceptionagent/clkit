//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import "XCTestCase+CLKAdditions.h"

#import "ArgumentParsingResultSpec.h"
#import "CLKArgumentManifest_Private.h"
#import "CLKArgumentManifestValidator.h"
#import "CLKArgumentParser.h"
#import "CLKOption.h"
#import "CLKOptionRegistry.h"

@implementation XCTestCase (CLKAdditions)

- (CLKArgumentManifest *)manifestWithSwitchOptions:(NSDictionary<CLKOption *, NSNumber *> *)switchOptions
                                  parameterOptions:(NSDictionary<CLKOption *, NSArray *> *)parameterOptions
{
    NSMutableArray *options = [NSMutableArray array];
    [options addObjectsFromArray:switchOptions.allKeys];
    [options addObjectsFromArray:parameterOptions.allKeys];
    CLKOptionRegistry *registry = [CLKOptionRegistry registryWithOptions:options];
    CLKArgumentManifest *manifest = [[CLKArgumentManifest alloc] initWithOptionRegistry:registry];
    
    [switchOptions enumerateKeysAndObjectsUsingBlock:^(CLKOption *option, NSNumber *count, __unused BOOL *outStop) {
        for (int i = 0 ; i < count.intValue ; i++) {
            [manifest accumulateSwitchOptionNamed:option.name];
        }
    }];

    [parameterOptions enumerateKeysAndObjectsUsingBlock:^(CLKOption *option, NSArray *arguments, __unused BOOL *outStop) {
        for (id argument in arguments) {
            [manifest accumulateArgument:argument forParameterOptionNamed:option.name];
        }
    }];
    
    return manifest;
}

- (CLKArgumentManifestValidator *)validatorWithSwitchOptions:(NSDictionary<CLKOption *, NSNumber *> *)switchOptions
                                            parameterOptions:(NSDictionary<CLKOption *, NSArray *> *)parameterOptions
{
    CLKArgumentManifest *manifest = [self manifestWithSwitchOptions:switchOptions parameterOptions:parameterOptions];
    return [[CLKArgumentManifestValidator alloc] initWithManifest:manifest];
}

@end

#pragma mark -

@implementation XCTestCase (CLKArgumentParserTestingAdditions)

- (void)performTestWithArgumentVector:(NSArray<NSString *> *)argv options:(NSArray<CLKOption *> *)options spec:(ArgumentParsingResultSpec *)spec
{
    [self performTestWithArgumentVector:argv options:options optionGroups:@[] spec:spec];
}

- (void)performTestWithArgumentVector:(NSArray<NSString *> *)argv
                              options:(NSArray<CLKOption *> *)options
                         optionGroups:(NSArray<CLKOptionGroup *> *)groups
                     expectedManifest:(NSDictionary<NSString *, id> *)expectedManifest
{
    ArgumentParsingResultSpec *spec = [ArgumentParsingResultSpec specWithOptionManifest:expectedManifest];
    [self performTestWithArgumentVector:argv options:options optionGroups:groups spec:spec];
}

- (void)performTestWithArgumentVector:(NSArray<NSString *> *)argv
                              options:(NSArray<CLKOption *> *)options
                         optionGroups:(NSArray<CLKOptionGroup *> *)groups
                                 spec:(ArgumentParsingResultSpec *)spec
{
    CLKArgumentParser *parser = [CLKArgumentParser parserWithArgumentVector:argv options:options optionGroups:groups];
    [self evaluateSpec:spec usingParser:parser];
}

- (void)performTestWithArgumentVector:(NSArray<NSString *> *)argv options:(NSArray<CLKOption *> *)options error:(NSError *)error
{
    ArgumentParsingResultSpec *spec = [ArgumentParsingResultSpec specWithError:error];
    CLKArgumentParser *parser = [CLKArgumentParser parserWithArgumentVector:argv options:options];
    [self evaluateSpec:spec usingParser:parser];
}

- (void)performTestWithArgumentVector:(NSArray<NSString *> *)argv
                              options:(NSArray<CLKOption *> *)options
                         optionGroups:(NSArray<CLKOptionGroup *> *)groups
                                error:(NSError *)error
{
    ArgumentParsingResultSpec *spec = [ArgumentParsingResultSpec specWithError:error];
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
        XCTAssertEqualObjects(manifest.dictionaryRepresentationForAccumulatedOptions, spec.optionManifest);
        XCTAssertEqualObjects(manifest.positionalArguments, spec.positionalArguments);
    } else {
        XCTAssertNil(manifest);
        if (manifest != nil) {
            return;
        }
        
        XCTAssertEqualObjects(parser.errors, spec.errors);
    }
}

@end
