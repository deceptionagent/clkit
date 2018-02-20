//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol CombinationTumblerDelegate;


NS_ASSUME_NONNULL_BEGIN

@interface CombinationTumbler : NSObject

- (instancetype)initWithIdentifier:(NSString *)identifier values:(NSArray *)values delegate:(id<CombinationTumblerDelegate>)delegate NS_DESIGNATED_INITIALIZER;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@property (readonly) NSString *identifier;
@property (readonly) id currentValue;

- (void)turn;

@end

NS_ASSUME_NONNULL_END


NS_ASSUME_NONNULL_BEGIN

@protocol CombinationTumblerDelegate

@required

- (void)tumblerDidTurnOver:(CombinationTumbler *)tumbler;

@end

NS_ASSUME_NONNULL_END
