//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import "CLKArgumentManifest.h"


@class CLKOption;


NS_ASSUME_NONNULL_BEGIN

@interface CLKArgumentManifest ()

+ (instancetype)manifest;

// secret entrance for unit tests
@property (nonnull, readonly) NSDictionary<NSString *, id> *optionManifest;

- (BOOL)hasOption:(CLKOption *)option;

- (void)accumulateSwitchOption:(CLKOption *)option;
- (void)accumulateArgument:(id)argument forParameterOption:(CLKOption *)option;
- (void)accumulatePositionalArgument:(NSString *)argument;

@end

NS_ASSUME_NONNULL_END
