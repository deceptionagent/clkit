//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

// a special value for use in template series value arrays. allows a combination engine to generate combinations that
// lack particular keys when CETemplateSeriesNoValue would be chosen for those keys.
#warning not great that variant view and variant source view know about this header file because of this value
extern id CETemplateSeriesNoValue;


@class CEVariantTag;


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
