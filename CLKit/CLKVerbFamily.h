//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CLKVerb;

NS_ASSUME_NONNULL_BEGIN

@interface CLKVerbFamily : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)familyWithName:(NSString *)name verbs:(NSArray<id<CLKVerb>> *)verbs;

@property (readonly) NSString *name;
@property (readonly) NSArray<id<CLKVerb>> *verbs;

- (nullable id<CLKVerb>)verbNamed:(NSString *)verbName;

@end

NS_ASSUME_NONNULL_END
