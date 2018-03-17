//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


@class CECombination;


NS_ASSUME_NONNULL_BEGIN

@interface CEGenerator : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (void)enumerateCombinations:(void (^)(CECombination *combination))combinationBlock;

@end

NS_ASSUME_NONNULL_END
