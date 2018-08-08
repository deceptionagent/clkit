//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


@class CETemplate;
@class CEVariant;

NS_ASSUME_NONNULL_BEGIN

@interface CEVariantBuilder : NSObject

+ (NSArray<CEVariant *> *)variantsFromTemplate:(CETemplate *)template;

@end

NS_ASSUME_NONNULL_END
