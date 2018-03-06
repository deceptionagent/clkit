//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


@class CEVariantSeries;


NS_ASSUME_NONNULL_BEGIN

#warning add tests
@interface CombinationEngineContext : NSObject

- (instancetype)initWithTumblers:(NSArray<CEVariantSeries *> *)tumblers;

@property (readonly) NSArray<CEVariantSeries *> *tumblers;

- (nullable CEVariantSeries *)tumblerSuperiorToTumbler:(CEVariantSeries *)tumbler;

@property (readonly) BOOL exhausted;
- (void)setExhausted;

@end

NS_ASSUME_NONNULL_END
