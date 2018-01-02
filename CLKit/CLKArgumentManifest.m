//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import "CLKArgumentManifest.h"
#import "CLKArgumentManifest_Private.h"

#import "CLKAssert.h"
#import "CLKOption.h"
#import "CLKOption_Private.h"


@implementation CLKArgumentManifest
{
    NSMutableDictionary<NSString *, id> *_optionManifest;
    NSMutableArray<NSString *> *_positionalArguments;
}

@synthesize optionManifest = _optionManifest;
@synthesize positionalArguments = _positionalArguments;

+ (instancetype)manifest
{
    return [[[self alloc] init] autorelease];
}

- (instancetype)init
{
    self = [super init];
    if (self != nil) {
        _optionManifest = [[NSMutableDictionary alloc] init];
        _positionalArguments = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
    [_optionManifest release];
    [_positionalArguments release];
    [super dealloc];
}

- (NSString *)debugDescription
{
    NSString *fmt = @"%@\n%@\n\npositional arguments:\n%@";
    return [NSString stringWithFormat:fmt, super.debugDescription, _optionManifest, _positionalArguments];
}

#pragma mark -

- (nullable id)objectForKeyedSubscript:(NSString *)key
{
    return _optionManifest[key];
}

- (BOOL)hasOption:(CLKOption *)option
{
    return (_optionManifest[option.name] != nil);
}

#pragma mark -
#pragma mark Building Manifests

- (void)accumulateSwitchOption:(CLKOption *)option
{
    NSParameterAssert(option.type == CLKOptionTypeSwitch);
    
    NSString *key = option.name;
    NSNumber *occurrences = _optionManifest[key];
    NSAssert2((occurrences == nil || [occurrences isKindOfClass:[NSNumber class]]), @"unexpectedly found object of class %@ for switch option key '%@'", NSStringFromClass([occurrences class]), key);
    
    _optionManifest[key] = @(occurrences.unsignedIntValue + 1);
}

- (void)accumulateArgument:(id)argument forParameterOption:(CLKOption *)option
{
    NSParameterAssert(option.type == CLKOptionTypeParameter);
    
    NSString *key = option.name;
    NSMutableArray *arguments = _optionManifest[key];
    NSAssert2((arguments == nil || [arguments isKindOfClass:[NSMutableArray class]]), @"unexpectedly found object of class %@ for parameter option key '%@'", NSStringFromClass([arguments class]), key);
    
    if (arguments == nil) {
        arguments = [NSMutableArray array];
        _optionManifest[key] = arguments;
    }
    
    [arguments addObject:argument];
}

- (void)accumulatePositionalArgument:(NSString *)argument
{
    [_positionalArguments addObject:argument];
}

@end
