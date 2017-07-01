//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import "ArgumentTransformer.h"


@implementation ArgumentTransformer

+ (instancetype)transformer
{
    return [[[self alloc] init] autorelease];
}

- (id)transformedArgument:(NSString *)argument error:(__unused NSError **)outError
{
    return argument;
}

@end


@implementation IntegerArgumentTransformer

- (id)transformedArgument:(NSString *)argument error:(NSError **)outError
{
    errno = 0;
    char *slop = NULL;
    long n = strtol(argument.UTF8String, &slop, 10);
    if ((n == 0 && errno != 0) || *slop != '\0') {
        if (outError != nil) {
            NSDictionary *info = @{
                NSLocalizedDescriptionKey : [NSString stringWithFormat:@"couldn't coerce '%@' to an integer value", argument]
            };
            
            *outError = [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:info];
        }
        
        return nil;
    }
    
    return @(n);
}

@end


@implementation FloatArgumentTransformer

- (id)transformedArgument:(NSString *)argument error:(NSError **)outError
{
    errno = 0;
    char *slop = NULL;
    float f = strtof(argument.UTF8String, &slop);
    if ((f == 0 && errno != 0) || *slop != '\0') {
        if (outError != nil) {
            NSDictionary *info = @{
                NSLocalizedDescriptionKey : [NSString stringWithFormat:@"couldn't coerce '%@' to a floating-point value", argument]
            };
            
            *outError = [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:info];
        }
        
        return nil;
    }
    
    return @(f);
}

@end
