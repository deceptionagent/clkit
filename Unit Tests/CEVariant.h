//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


@class CEVariantSource;
@class CEVariantTag;


NS_ASSUME_NONNULL_BEGIN

@interface CEVariant : NSObject

- (instancetype)initWithTag:(CEVariantTag *)tag rootSource:(CEVariantSource *)source NS_DESIGNATED_INITIALIZER;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@property (readonly) CEVariantTag *tag;
@property (readonly) NSSet<CEVariantSource *> *sources;

- (void)addSource:(CEVariantSource *)superiorSource superiorToSource:(CEVariantSource *)inferiorSource;
- (nullable CEVariantSource *)sourceSuperiorToSource:(CEVariantSource *)source;

@end

NS_ASSUME_NONNULL_END
