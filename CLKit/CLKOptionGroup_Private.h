//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import "CLKOptionGroup.h"


@class CLKArgumentManifestConstraint;


NS_ASSUME_NONNULL_BEGIN

@interface CLKOptionGroup ()

@property (readonly) NSArray<CLKArgumentManifestConstraint *> *constraints;

@end

NS_ASSUME_NONNULL_END
