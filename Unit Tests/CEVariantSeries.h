//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol CEVariantSeriesDelegate;


NS_ASSUME_NONNULL_BEGIN

@interface CEVariantSeries : NSObject

- (instancetype)initWithIdentifier:(NSString *)identifier values:(NSArray *)values delegate:(id<CEVariantSeriesDelegate>)delegate NS_DESIGNATED_INITIALIZER;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@property (readonly) NSString *identifier;
@property (readonly) id currentValue;

- (void)advance;

@end

NS_ASSUME_NONNULL_END


NS_ASSUME_NONNULL_BEGIN

@protocol CEVariantSeriesDelegate

@required

- (void)variantSeriesDidAdvanceToInitialPosition:(CEVariantSeries *)series;

@end

NS_ASSUME_NONNULL_END
