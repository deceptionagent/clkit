//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface CEVariantTag : NSObject <NSCopying>

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)tag;

- (BOOL)isEqualToVariantTag:(CEVariantTag *)tag;
- (NSComparisonResult)compare:(CEVariantTag *)tag;

@end

NS_ASSUME_NONNULL_END