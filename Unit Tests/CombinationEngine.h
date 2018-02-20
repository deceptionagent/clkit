//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

// a special value for use in prototype arrays. allows a CombinationEngine to generate combinations that
// lack particular keys when CEPrototypeNoValue would be chosen for those keys.
extern id CEPrototypeNoValue;

@interface CombinationEngine : NSObject

- (instancetype)initWithPrototype:(NSDictionary<NSString *, NSArray *> *)prototype NS_DESIGNATED_INITIALIZER;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (void)enumerateCombinations:(void (^)(NSDictionary<NSString *, id> *))combinationBlock;

@end

NS_ASSUME_NONNULL_END
