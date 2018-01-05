//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import "CLKOption.h"


@class CLKArgumentTransformer;


NS_ASSUME_NONNULL_BEGIN

NSString *CLKStringForOptionType(CLKOptionType type);

@interface CLKOption ()

- (instancetype)initWithType:(CLKOptionType)type
                        name:(NSString *)name
                        flag:(nullable NSString *)flag
                    required:(BOOL)required
                    recurrent:(BOOL)recurrent
                 transformer:(nullable CLKArgumentTransformer *)transformer
                dependencies:(nullable NSArray<CLKOption *> *)dependencies NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
