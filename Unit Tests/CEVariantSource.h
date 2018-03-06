//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol CEVariantSourceDelegate;


NS_ASSUME_NONNULL_BEGIN

@interface CEVariantSource : NSObject

- (instancetype)initWithIdentifier:(NSString *)identifier values:(NSArray *)values delegate:(id<CEVariantSourceDelegate>)delegate NS_DESIGNATED_INITIALIZER;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@property (readonly) NSString *identifier;
@property (readonly) id currentValue;

- (void)advanceToNextValue;

@end

NS_ASSUME_NONNULL_END


NS_ASSUME_NONNULL_BEGIN

@protocol CEVariantSourceDelegate

@required

- (void)variantSourceDidAdvanceToInitialValue:(CEVariantSource *)source;

@end

NS_ASSUME_NONNULL_END
