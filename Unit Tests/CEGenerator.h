//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


@class CECombination;
@class CEVariant;


NS_ASSUME_NONNULL_BEGIN

@interface CEGenerator : NSObject

- (instancetype)initWithVariants:(NSArray<CEVariant *> *)variants NS_DESIGNATED_INITIALIZER;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@property (readonly) NSArray<CEVariant *> *variants;

- (void)enumerateCombinations:(void (^)(CECombination *))combinationBlock;

@end

NS_ASSUME_NONNULL_END
