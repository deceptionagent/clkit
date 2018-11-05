//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import "CLKOptionGroup.h"


@class CLKArgumentManifestConstraint;

NS_ASSUME_NONNULL_BEGIN

@interface CLKOptionGroup ()

@property (nullable, readonly) NSArray<NSString *> *options;
@property (nullable, readonly) NSArray<CLKOptionGroup *> *subgroups;
@property (readonly) BOOL mutexed;
@property (readonly) BOOL required; // at least one member of this group is required

@property (readonly) NSArray<NSString *> *allOptions; // includes subgroups
@property (readonly) NSArray<CLKArgumentManifestConstraint *> *constraints;

@end

NS_ASSUME_NONNULL_END
