//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import "CLKArgumentManifest.h"


@class CLKOption;


NS_ASSUME_NONNULL_BEGIN

@interface CLKArgumentManifest ()

- (BOOL)hasOption:(CLKOption *)option;

- (void)accumulateFreeOption:(CLKOption *)option;
- (void)accumulateArgument:(id)argument forOption:(CLKOption *)option;
- (void)accumulatePositionalArgument:(NSString *)argument;

@end

NS_ASSUME_NONNULL_END
