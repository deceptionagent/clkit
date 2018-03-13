//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


@class CEVariantSource;
@class CEVariantTag;


NS_ASSUME_NONNULL_BEGIN

@interface CEVariant : NSObject

+ (instancetype)variantWithTag:(CEVariantTag *)tag sources:(NSArray<CEVariantSource *> *)sources;
- (instancetype)initWithTag:(CEVariantTag *)tag sources:(NSArray<CEVariantSource *> *)sources NS_DESIGNATED_INITIALIZER;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@property (readonly) CEVariantTag *tag;
@property (readonly) NSArray<CEVariantSource *> *sources;

@end

NS_ASSUME_NONNULL_END
