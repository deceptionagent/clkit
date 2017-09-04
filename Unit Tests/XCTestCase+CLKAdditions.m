//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import "XCTestCase+CLKAdditions.h"


@implementation XCTestCase (CLKAdditions)

- (void)verifyError:(NSError *)error domain:(NSString *)domain code:(NSInteger)code
{
    XCTAssertNotNil(error);
    XCTAssertEqualObjects(error.domain, domain);
    XCTAssertEqual(error.code, code);
}

- (void)verifyError:(NSError *)error domain:(NSString *)domain code:(NSInteger)code description:(NSString *)description
{
    XCTAssertNotNil(error);
    XCTAssertEqualObjects(error.domain, domain);
    XCTAssertEqual(error.code, code);
    XCTAssertEqualObjects(error.localizedDescription, description);
}

- (void)verifyError:(NSError *)error domain:(NSString *)domain code:(NSInteger)code userInfo:(NSDictionary *)userInfo
{
    XCTAssertNotNil(error);
    XCTAssertEqualObjects(error.domain, domain);
    XCTAssertEqual(error.code, code);
    XCTAssertEqualObjects(error.userInfo, userInfo);
}

- (void)verifyCLKError:(NSError *)error code:(CLKError)code description:(NSString *)description
{
    [self verifyError:error domain:CLKErrorDomain code:code description:description];
}

@end
