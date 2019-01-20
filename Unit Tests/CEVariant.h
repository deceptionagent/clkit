//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


@class CEVariantSource;

NS_ASSUME_NONNULL_BEGIN

@interface CEVariant : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)variantWithTag:(NSString *)tag sources:(NSArray<CEVariantSource *> *)sources;
- (instancetype)initWithTag:(NSString *)tag sources:(NSArray<CEVariantSource *> *)sources NS_DESIGNATED_INITIALIZER;

@property (readonly) NSString *tag;
@property (readonly) NSArray<CEVariantSource *> *sources;

@end

NS_ASSUME_NONNULL_END
