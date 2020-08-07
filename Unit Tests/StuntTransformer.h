//
//  Copyright (c) 2019 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CLKArgumentTransformer.h"

NS_ASSUME_NONNULL_BEGIN

@interface StuntTransformer : CLKArgumentTransformer

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)transformer NS_UNAVAILABLE;

+ (instancetype)transformerWithTransformedObject:(id)object;
+ (instancetype)erroringTransformerWithPOSIXErrorCode:(int)code description:(NSString *)description;

- (instancetype)initWithObject:(id)object NS_DESIGNATED_INITIALIZER;

@property (nullable, readonly) NSError *error;

@end

NS_ASSUME_NONNULL_END
