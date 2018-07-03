//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import "CECombination.h"


NS_ASSUME_NONNULL_BEGIN

@interface CECombination ()

+ (instancetype)combinationWithBacking:(NSDictionary<NSString *, id> *)backing variant:(NSString *)variant;
- (instancetype)initWithBacking:(NSDictionary<NSString *, id> *)backing variant:(NSString *)variant NS_DESIGNATED_INITIALIZER;

@property (readonly) NSDictionary<NSString *, id> *backing;

@end

NS_ASSUME_NONNULL_END
