//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import "CLKOption.h"


@class CLKArgumentTransformer;


NS_ASSUME_NONNULL_BEGIN

@interface CLKOption ()

- (instancetype)initWithType:(CLKOptionType)type
                        name:(NSString *)name
                        flag:(NSString *)flag
                    required:(BOOL)required
                 transformer:(nullable CLKArgumentTransformer *)transformer NS_DESIGNATED_INITIALIZER;

@property (readonly) NSString *manifestKey;

@end

NS_ASSUME_NONNULL_END
