//
//  Copyright (c) 2020 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface CLKArgumentIssue : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)issueWithError:(NSError *)error;
+ (instancetype)issueWithError:(NSError *)error salientOption:(nullable NSString *)option;
+ (instancetype)issueWithError:(NSError *)error salientOptions:(nullable NSArray<NSString *> *)options;

@property (readonly) NSError *error;
@property (nullable, readonly) NSArray<NSString *> *salientOptions;
@property (readonly) BOOL isValidationIssue;

- (BOOL)isEqualToIssue:(CLKArgumentIssue *)issue;

@end

NS_ASSUME_NONNULL_END
