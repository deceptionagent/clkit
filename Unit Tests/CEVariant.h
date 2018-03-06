//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


@class CEVariantSeries;
@class CEVariantTag;


NS_ASSUME_NONNULL_BEGIN

@interface CEVariant : NSObject

#warning supposed to be array<series>?
- (instancetype)initWithSeries:(CEVariantSeries *)series tag:(CEVariantTag *)tag NS_DESIGNATED_INITIALIZER;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

#warning supposed to be array<series>?
@property (readonly) CEVariantSeries *series;
@property (readonly) CEVariantTag *tag;

@end

NS_ASSUME_NONNULL_END
