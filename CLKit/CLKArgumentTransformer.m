//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import "CLKArgumentTransformer.h"

#import "CLKError_Private.h"
#import "NSError+CLKAdditions.h"

@implementation CLKArgumentTransformer

- (id)transformedArgument:(NSString *)argument error:(__unused NSError **)outError
{
    return argument;
}

@end

@implementation CLKIntArgumentTransformer

- (id)transformedArgument:(NSString *)argument error:(NSError **)outError
{
    errno = 0;
    char *slop = NULL;
    long n = strtol(argument.UTF8String, &slop, 10);
    if ((n == 0 && errno != 0) || *slop != '\0') {
        CLKSetOutError(outError, ([NSError clk_POSIXErrorWithCode:errno description:@"couldn't coerce '%@' to an integer value", argument]));
        return nil;
    }
    
    return @(n);
}

@end

@implementation CLKFloatArgumentTransformer

- (id)transformedArgument:(NSString *)argument error:(NSError **)outError
{
    errno = 0;
    char *slop = NULL;
    float f = strtof(argument.UTF8String, &slop);
    if ((f == 0 && errno != 0) || *slop != '\0') {
        CLKSetOutError(outError, ([NSError clk_POSIXErrorWithCode:errno description:@"couldn't coerce '%@' to a floating-point value", argument]));
        return nil;
    }
    
    return @(f);
}

@end
