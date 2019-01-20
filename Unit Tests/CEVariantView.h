//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


@class CEVariant;
@class CECombination;

NS_ASSUME_NONNULL_BEGIN

@interface CEVariantView : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithVariant:(CEVariant *)variant NS_DESIGNATED_INITIALIZER;

@property (readonly) CEVariant *variant;
@property (readonly) BOOL exhausted;
@property (readonly) CECombination *combination;

- (void)advance;

@end

NS_ASSUME_NONNULL_END
