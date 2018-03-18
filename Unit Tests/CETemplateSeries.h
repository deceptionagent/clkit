//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN


@class CEVariantTag;


@interface CETemplateSeries : NSObject

+ (instancetype)seriesWithIdentifier:(NSString *)identifier values:(NSArray *)values variant:(CEVariantTag *)variant;
+ (instancetype)seriesWithIdentifier:(NSString *)identifier values:(NSArray *)values variants:(NSArray<CEVariantTag *> *)variants;

+ (instancetype)elidableSeriesWithIdentifier:(NSString *)identifier values:(NSArray *)values variant:(CEVariantTag *)variant;
+ (instancetype)elidableSeriesWithIdentifier:(NSString *)identifier values:(NSArray *)values variants:(NSArray<CEVariantTag *> *)variants;

- (instancetype)initWithIdentifier:(NSString *)identifier values:(NSArray *)values elidable:(BOOL)elidable variants:(NSArray<CEVariantTag *> *)variants NS_DESIGNATED_INITIALIZER;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@property (readonly) NSString *identifier;
@property (readonly) NSArray *values;
@property (readonly) NSArray<CEVariantTag *> *variants;
@property (readonly) BOOL elidable;

@end

NS_ASSUME_NONNULL_END
