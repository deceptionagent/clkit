//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


@class CEVariantTag;


NS_ASSUME_NONNULL_BEGIN

@interface CECombination : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (id)objectForKeyedSubscript:(NSString *)identifier;

@property (readonly) CEVariantTag *tag;

- (BOOL)isEqualToCombination:(CECombination *)combination;

@end

NS_ASSUME_NONNULL_END
