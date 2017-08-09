//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import "CLKOption.h"


@class CLKArgumentTransformer;


NS_ASSUME_NONNULL_BEGIN

@interface CLKOption ()

- (instancetype)initWithName:(NSString *)name flag:(nullable NSString *)flag transformer:(nullable CLKArgumentTransformer *)transformer expectsArgument:(BOOL)expectsArgument NS_DESIGNATED_INITIALIZER;

@property (readonly) NSString *manifestKey;
@property (readonly) BOOL expectsArgument;

@end

NS_ASSUME_NONNULL_END
