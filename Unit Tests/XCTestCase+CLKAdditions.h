//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

#import "CLKError.h"


@class ArgumentParsingResultSpec;
@class CLKArgumentManifest;
@class CLKArgumentManifestValidator;
@class CLKArgumentParser;
@class CLKOption;
@class CLKOptionGroup;
@class CombinationEngine;

NS_ASSUME_NONNULL_BEGIN

@interface XCTestCase (CLKAdditions)

- (CLKArgumentManifest *)manifestWithSwitchOptions:(nullable NSDictionary<CLKOption *, NSNumber *> *)switchOptions parameterOptions:(nullable NSDictionary<CLKOption *, NSArray *> *)parameterOptions;
- (CLKArgumentManifestValidator *)validatorWithSwitchOptions:(nullable NSDictionary<CLKOption *, NSNumber *> *)switchOptions parameterOptions:(nullable NSDictionary<CLKOption *, id> *)parameterOptions;

@end

@interface XCTestCase (CLKArgumentParserTestingAdditions)

- (void)performTestWithArgumentVector:(NSArray<NSString *> *)argv options:(NSArray<CLKOption *> *)options spec:(ArgumentParsingResultSpec *)spec;
- (void)performTestWithArgumentVector:(NSArray<NSString *> *)argv
                              options:(NSArray<CLKOption *> *)options
                         optionGroups:(NSArray<CLKOptionGroup *> *)groups
                                 spec:(ArgumentParsingResultSpec *)spec;

- (void)evaluateSpec:(ArgumentParsingResultSpec *)spec usingParser:(CLKArgumentParser *)parser;

@end

NS_ASSUME_NONNULL_END
