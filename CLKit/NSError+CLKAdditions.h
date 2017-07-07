//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface NSError (CLKAdditions)

+ (instancetype)clk_POSIXErrorWithCode:(int)code localizedDescription:(NSString *)fmt, ... NS_FORMAT_FUNCTION(2, 3);

@end

NS_ASSUME_NONNULL_END
