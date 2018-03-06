//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


@class CEVariantSource;


NS_ASSUME_NONNULL_BEGIN

#warning add tests
@interface CombinationEngineContext : NSObject

- (instancetype)initWithTumblers:(NSArray<CEVariantSource *> *)tumblers;

@property (readonly) NSArray<CEVariantSource *> *tumblers;

- (nullable CEVariantSource *)tumblerSuperiorToTumbler:(CEVariantSource *)tumbler;

@property (readonly) BOOL exhausted;
- (void)setExhausted;

@end

NS_ASSUME_NONNULL_END
