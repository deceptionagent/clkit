//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

#import "CLKError.h"


@class CLKArgumentManifest;
@class CLKArgumentManifestValidator;
@class CLKOption;
@class CombinationEngine;


NS_ASSUME_NONNULL_BEGIN

@interface XCTestCase (CLKAdditions)

- (void)verifyError:(NSError *)error domain:(NSString *)domain code:(NSInteger)code;
- (void)verifyError:(NSError *)error domain:(NSString *)domain code:(NSInteger)code description:(NSString *)description;
- (void)verifyError:(NSError *)error domain:(NSString *)domain code:(NSInteger)code userInfo:(NSDictionary *)userInfo;
- (void)verifyCLKError:(NSError *)error code:(CLKError)code description:(NSString *)description;

- (CLKArgumentManifest *)manifestWithSwitchOptions:(nullable NSDictionary<CLKOption *, NSNumber *> *)switchOptions parameterOptions:(nullable NSDictionary<CLKOption *, NSArray *> *)parameterOptions;
- (CLKArgumentManifestValidator *)validatorWithSwitchOptions:(nullable NSDictionary<CLKOption *, NSNumber *> *)switchOptions parameterOptions:(nullable NSDictionary<CLKOption *, id> *)parameterOptions;

@end

NS_ASSUME_NONNULL_END
