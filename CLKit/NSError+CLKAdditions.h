//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CLKError.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSError (CLKAdditions)

+ (instancetype)clk_POSIXErrorWithCode:(int)code description:(NSString *)fmt, ... NS_FORMAT_FUNCTION(2, 3);
+ (instancetype)clk_CLKErrorWithCode:(CLKError)code description:(NSString *)fmt, ... NS_FORMAT_FUNCTION(2, 3);

@end

NS_ASSUME_NONNULL_END
