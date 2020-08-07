//
//  Copyright (c) 2019 Plastic Pulse. All rights reserved.
//

#import "StuntTransformer.h"

#import "NSError+CLKAdditions.h"

@implementation StuntTransformer
{
    id _object;
}

+ (instancetype)transformerWithTransformedObject:(id)object
{
    return [[self alloc] initWithObject:object];
}

+ (instancetype)erroringTransformerWithPOSIXErrorCode:(int)code description:(NSString *)description
{
    NSError *error = [NSError clk_POSIXErrorWithCode:code description:@"%@", description];
    return [[self alloc] initWithObject:error];
}

- (instancetype)initWithObject:(id)object
{
    self = [super init];
    if (self != nil) {
        _object = object;
    }
    
    return self;
}

- (id)transformedArgument:(NSString *)argument error:(NSError **)outError
{
    NSParameterAssert(argument != nil);
    NSParameterAssert(outError != nil);
    
    if ([_object isKindOfClass:[NSError class]]) {
        *outError = _object;
        return nil;
    }
    
    return _object;
}

- (NSError *)error
{
    return ([_object isKindOfClass:[NSError class]] ? _object : nil);
}

@end
