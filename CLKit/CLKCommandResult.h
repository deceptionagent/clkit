//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CLKCommandResult : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)resultWithExitStatus:(int)exitStatus;
+ (instancetype)resultWithExitStatus:(int)exitStatus errors:(nullable NSArray<NSError *> *)errors;
+ (instancetype)resultWithExitStatus:(int)exitStatus userInfo:(nullable NSDictionary *)userInfo;

- (instancetype)initWithExitStatus:(int)exitStatus errors:(nullable NSArray<NSError *> *)errors userInfo:(nullable NSDictionary *)userInfo NS_DESIGNATED_INITIALIZER;

@property (readonly) int exitStatus;
@property (nullable, readonly) NSArray<NSError *> *errors;
@property (nullable, readonly) NSString *errorDescription;
@property (nullable, readonly) NSDictionary *userInfo;

@end
