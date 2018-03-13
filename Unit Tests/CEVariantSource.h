//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface CEVariantSource : NSObject

+ (instancetype)sourceWithIdentifier:(NSString *)identifier values:(NSArray *)values;
- (instancetype)initWithIdentifier:(NSString *)identifier values:(NSArray *)values NS_DESIGNATED_INITIALIZER;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@property (readonly) NSString *identifier;
@property (readonly) NSArray *values;

@end

NS_ASSUME_NONNULL_END
