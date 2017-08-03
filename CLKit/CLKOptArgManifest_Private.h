//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import "CLKOptArgManifest.h"


NS_ASSUME_NONNULL_BEGIN

@interface CLKOptArgManifest ()

- (void)accumulateFreeOptionNamed:(NSString *)name;
- (void)accumulateArgument:(id)argument forOptionNamed:(NSString *)name;
- (void)accumulatePositionalArgument:(NSString *)argument;

@end

NS_ASSUME_NONNULL_END
