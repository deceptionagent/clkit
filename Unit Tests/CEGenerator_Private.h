//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import "CEGenerator.h"


@class CEVariant;

NS_ASSUME_NONNULL_BEGIN

@interface CEGenerator ()

- (instancetype)initWithVariants:(NSArray<CEVariant *> *)variants NS_DESIGNATED_INITIALIZER;

@property (readonly) NSArray<CEVariant *> *variants;

@end

NS_ASSUME_NONNULL_END
