//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import "XCTestCase+CLKAdditions.h"

#import "CLKArgumentManifest.h"
#import "CLKArgumentManifest_Private.h"
#import "CLKArgumentManifestValidator.h"
#import "CLKOption.h"
#import "CLKOptionRegistry.h"


@implementation XCTestCase (CLKAdditions)

- (void)verifyError:(NSError *)error domain:(NSString *)domain code:(NSInteger)code
{
    if (error == nil) {
        return;
    }
    
    XCTAssertEqualObjects(error.domain, domain);
    XCTAssertEqual(error.code, code);
}

- (void)verifyError:(NSError *)error domain:(NSString *)domain code:(NSInteger)code description:(NSString *)description
{
    XCTAssertNotNil(error, @"[description: %@]", description);
    if (error == nil) {
        return;
    }
    
    XCTAssertEqualObjects(error.domain, domain);
    XCTAssertEqual(error.code, code);
    XCTAssertEqualObjects(error.localizedDescription, description);
}

- (void)verifyError:(NSError *)error domain:(NSString *)domain code:(NSInteger)code userInfo:(NSDictionary *)userInfo
{
    XCTAssertNotNil(error, @"[userInfo: %@]", userInfo);
    if (error == nil) {
        return;
    }
    
    XCTAssertEqualObjects(error.domain, domain);
    XCTAssertEqual(error.code, code);
    XCTAssertEqualObjects(error.userInfo, userInfo);
}

- (void)verifyCLKError:(NSError *)error code:(CLKError)code description:(NSString *)description
{
    [self verifyError:error domain:CLKErrorDomain code:code description:description];
}

#pragma mark -

- (CLKArgumentManifest *)manifestWithSwitchOptions:(NSDictionary<CLKOption *, NSNumber *> *)switchOptions parameterOptions:(NSDictionary<CLKOption *, NSArray *> *)parameterOptions
{
    NSMutableArray *options = [NSMutableArray array];
    [options addObjectsFromArray:switchOptions.allKeys];
    [options addObjectsFromArray:parameterOptions.allKeys];
    CLKOptionRegistry *registry = [CLKOptionRegistry registryWithOptions:options];
    CLKArgumentManifest *manifest = [[[CLKArgumentManifest alloc] initWithOptionRegistry:registry] autorelease];
    
    [switchOptions enumerateKeysAndObjectsUsingBlock:^(CLKOption *option, NSNumber *count, __unused BOOL *outStop) {
        int i;
        for (i = 0 ; i < count.intValue ; i++) {
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

- (CLKArgumentManifestValidator *)validatorWithSwitchOptions:(NSDictionary<CLKOption *, NSNumber *> *)switchOptions parameterOptions:(NSDictionary<CLKOption *, NSArray *> *)parameterOptions
{
    CLKArgumentManifest *manifest = [self manifestWithSwitchOptions:switchOptions parameterOptions:parameterOptions];
    return [[[CLKArgumentManifestValidator alloc] initWithManifest:manifest] autorelease];
}

@end
