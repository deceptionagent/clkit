//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import "NSError+CLKAdditions.h"


static NSString * const CLKErrorRepresentedOptionsKey = @"CLKErrorRepresentedOptions";

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

+ (instancetype)clk_POSIXErrorWithCode:(int)code representedOptions:(NSArray<NSString *> *)optionNames description:(NSString *)fmt, ...
{
    va_list ap;
    va_start(ap, fmt);
    NSString *description = [[NSString alloc] initWithFormat: fmt arguments: ap];
    va_end(ap);
    
    NSDictionary *info = @{
        NSLocalizedDescriptionKey : description,
        CLKErrorRepresentedOptionsKey : [optionNames copy]
    };
    
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

+ (instancetype)clk_CLKErrorWithCode:(CLKError)code representedOptions:(NSArray<NSString *> *)optionNames description:(NSString *)fmt, ...
{
    va_list ap;
    va_start(ap, fmt);
    NSString *description = [[NSString alloc] initWithFormat: fmt arguments: ap];
    va_end(ap);
    
    NSDictionary *info = @{
        NSLocalizedDescriptionKey : description,
        CLKErrorRepresentedOptionsKey : [optionNames copy]
    };
    
    return [self errorWithDomain:CLKErrorDomain code:code userInfo:info];
}

- (instancetype)clk_errorByAddingRepresentedOptions:(NSArray<NSString *> *)optionNames
{
    NSMutableDictionary *info = [self.userInfo mutableCopy];
    info[CLKErrorRepresentedOptionsKey] = [optionNames copy];
    return [self.class errorWithDomain:self.domain code:self.code userInfo:info];
}

- (NSArray<NSString *> *)clk_representedOptions
{
    return self.userInfo[CLKErrorRepresentedOptionsKey];
}

@end
