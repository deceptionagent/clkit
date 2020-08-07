//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import "NSError+CLKAdditions.h"

@implementation NSError (CLKAdditions)

+ (instancetype)clk_POSIXErrorWithCode:(int)code description:(NSString *)fmt, ...
{
    va_list ap;
    va_start(ap, fmt);
    NSString *description = [[NSString alloc] initWithFormat: fmt arguments: ap];
    va_end(ap);
    
    NSDictionary *info = @{ NSLocalizedDescriptionKey : description };
    return [self errorWithDomain:NSPOSIXErrorDomain code:code userInfo:info];
}

+ (instancetype)clk_CLKErrorWithCode:(CLKError)code description:(NSString *)fmt, ...
{
    va_list ap;
    va_start(ap, fmt);
    NSString *description = [[NSString alloc] initWithFormat: fmt arguments: ap];
    va_end(ap);
    
    NSDictionary *info = @{ NSLocalizedDescriptionKey : description };
    return [self errorWithDomain:CLKErrorDomain code:code userInfo:info];
}

@end
