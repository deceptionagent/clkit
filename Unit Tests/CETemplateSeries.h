//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


@class CEVariantTag;


NS_ASSUME_NONNULL_BEGIN

@interface CETemplateSeries : NSObject

+ (instancetype)seriesWithIdentifier:(NSString *)identifier values:(NSArray *)values variantTags:(NSArray<CEVariantTag *> *)variantTags;
- (instancetype)initWithIdentifier:(NSString *)identifier values:(NSArray *)values variantTags:(NSArray<CEVariantTag *> *)variantTags NS_DESIGNATED_INITIALIZER;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@property (readonly) NSString *identifier;
@property (readonly) NSArray *values;
@property (readonly) NSArray<CEVariantTag *> *variantTags;

@end

NS_ASSUME_NONNULL_END
