//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import "CLKOption.h"

@class CLKArgumentManifestConstraint;
@class CLKArgumentTransformer;

NS_ASSUME_NONNULL_BEGIN

NSString *CLKStringForOptionType(CLKOptionType type);

@interface CLKOption ()

@property (readonly) NSArray<CLKArgumentManifestConstraint *> *constraints;

@end

NS_ASSUME_NONNULL_END
