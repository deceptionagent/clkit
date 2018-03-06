//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import "CECombination.h"


@class CEVariantTag;


NS_ASSUME_NONNULL_BEGIN

@interface CECombination ()

- (instancetype)initWithCombinationDictionary:(NSDictionary<NSString *, id> *)dictionary tag:(CEVariantTag *)tag NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
