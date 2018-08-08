//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import "CLKOption.h"


@class CLKArgumentManifestConstraint;
@class CLKArgumentTransformer;

NS_ASSUME_NONNULL_BEGIN

NSString *CLKStringForOptionType(CLKOptionType type);

@interface CLKOption ()

- (instancetype)initWithType:(CLKOptionType)type
                        name:(NSString *)name
                        flag:(nullable NSString *)flag
                    required:(BOOL)required
                   recurrent:(BOOL)recurrent
                dependencies:(nullable NSArray<NSString *> *)dependencies
                 transformer:(nullable CLKArgumentTransformer *)transformer NS_DESIGNATED_INITIALIZER;

@property (readonly) NSArray<CLKArgumentManifestConstraint *> *constraints;

@end

NS_ASSUME_NONNULL_END
