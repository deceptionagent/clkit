//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>


NS_ASSUME_NONNULL_BEGIN

@interface XCTestCase (CLKAdditions)

- (void)verifyError:(NSError *)error domain:(NSString *)domain code:(NSInteger)code;
- (void)verifyError:(NSError *)error domain:(NSString *)domain code:(NSInteger)code description:(NSString *)description;
- (void)verifyError:(NSError *)error domain:(NSString *)domain code:(NSInteger)code userInfo:(NSDictionary *)userInfo;

@end

NS_ASSUME_NONNULL_END
