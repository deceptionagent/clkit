//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol CEVariantSourceObserver;


NS_ASSUME_NONNULL_BEGIN

@interface CEVariantSource : NSObject

- (instancetype)initWithIdentifier:(NSString *)identifier values:(NSArray *)values NS_DESIGNATED_INITIALIZER;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@property (readonly) NSString *identifier;
@property (readonly) id currentValue;

- (void)advanceToNextValue;

- (void)addObserver:(id<CEVariantSourceObserver>)observer;
- (void)removeObserver:(id<CEVariantSourceObserver>)observer;

@end

NS_ASSUME_NONNULL_END


NS_ASSUME_NONNULL_BEGIN

@protocol CEVariantSourceObserver

@required

- (void)variantSourceDidAdvanceToInitialValue:(CEVariantSource *)source;

@end

NS_ASSUME_NONNULL_END
