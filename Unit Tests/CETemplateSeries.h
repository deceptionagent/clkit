//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface CETemplateSeries : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)seriesWithIdentifier:(NSString *)identifier values:(NSArray *)values variant:(NSString *)variant;
+ (instancetype)seriesWithIdentifier:(NSString *)identifier values:(NSArray *)values variants:(NSArray<NSString *> *)variants;

+ (instancetype)elidableSeriesWithIdentifier:(NSString *)identifier values:(NSArray *)values variant:(NSString *)variant;
+ (instancetype)elidableSeriesWithIdentifier:(NSString *)identifier values:(NSArray *)values variants:(NSArray<NSString *> *)variants;

- (instancetype)initWithIdentifier:(NSString *)identifier values:(NSArray *)values elidable:(BOOL)elidable variants:(NSArray<NSString *> *)variants NS_DESIGNATED_INITIALIZER;

@property (readonly) NSString *identifier;
@property (readonly) NSArray *values;
@property (readonly) NSArray<NSString *> *variants;
@property (readonly) BOOL elidable;

@end

NS_ASSUME_NONNULL_END
