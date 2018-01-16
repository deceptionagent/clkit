//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import "CLKArgumentManifest.h"


@class CLKOption;


NS_ASSUME_NONNULL_BEGIN

@interface CLKArgumentManifest ()

@property (nonnull, readonly) NSDictionary<CLKOption *, id> *optionManifest;
@property (nonnull, readonly) NSDictionary<NSString *, id> *optionManifestKeyedByName;

- (BOOL)hasOption:(CLKOption *)option;
- (BOOL)hasOptionNamed:(NSString *)optionName;
- (NSUInteger)occurrencesOfOption:(CLKOption *)option;
- (NSUInteger)occurrencesOfOptionNamed:(NSString *)optionName;

- (void)accumulateSwitchOption:(CLKOption *)option;
- (void)accumulateArgument:(id)argument forParameterOption:(CLKOption *)option;
- (void)accumulatePositionalArgument:(NSString *)argument;

@end

NS_ASSUME_NONNULL_END
