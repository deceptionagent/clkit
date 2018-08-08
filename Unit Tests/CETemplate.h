//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


@class CETemplateSeries;

NS_ASSUME_NONNULL_BEGIN

@interface CETemplate : NSObject

+ (instancetype)templateWithSeries:(NSArray<CETemplateSeries *> *)series;
- (instancetype)initWithSeries:(NSArray<CETemplateSeries *> *)series NS_DESIGNATED_INITIALIZER;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@property (readonly) NSArray<CETemplateSeries *> *allSeries;

@end

NS_ASSUME_NONNULL_END
