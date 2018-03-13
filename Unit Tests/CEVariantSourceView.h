//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


@class CEVariantSource;
@protocol CEVariantSourceViewObserver;


NS_ASSUME_NONNULL_BEGIN

@interface CEVariantSourceView : NSObject

- (instancetype)initWithVariantSource:(CEVariantSource *)variantSource;

@property (readonly) CEVariantSource *variantSource;
@property (readonly) id currentValue;
@property (readonly) BOOL elided;

- (void)advanceToNextValue;

- (void)addObserver:(id<CEVariantSourceViewObserver>)observer;
- (void)removeObserver:(id<CEVariantSourceViewObserver>)observer;

@end

NS_ASSUME_NONNULL_END


NS_ASSUME_NONNULL_BEGIN

@protocol CEVariantSourceViewObserver

@required
- (void)variantSourceViewDidAdvanceToInitialValue:(CEVariantSourceView *)sourceView;

@end

NS_ASSUME_NONNULL_END

