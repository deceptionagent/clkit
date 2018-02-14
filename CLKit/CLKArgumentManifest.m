//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import "CLKArgumentManifest.h"
#import "CLKArgumentManifest_Private.h"

#import "CLKAssert.h"
#import "CLKOption.h"
#import "CLKOption_Private.h"
#import "CLKOptionRegistry.h"


@implementation CLKArgumentManifest
{
    CLKOptionRegistry *_optionRegistry;
    NSMutableDictionary<NSString *, id> *_optionManifest; /* option name : NSNumber or NSArray */
    NSMutableArray<NSString *> *_positionalArguments;
}

@synthesize optionManifest = _optionManifest;
@synthesize positionalArguments = _positionalArguments;

- (instancetype)initWithOptionRegistry:(CLKOptionRegistry *)optionRegistry;
{
    NSParameterAssert(optionRegistry != nil);
    
    self = [super init];
    if (self != nil) {
        _optionRegistry = [optionRegistry retain];
        _optionManifest = [[NSMutableDictionary alloc] init];
        _positionalArguments = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
    [_optionRegistry release];
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
#pragma mark Reading Manifests

- (nullable id)objectForKeyedSubscript:(NSString *)optionName
{
    // it's reasonable to query the manifest for an unregistered option.
    // this makes it easier to write tools with varying configurations, special factoring, etc.
    CLKOption *option = [_optionRegistry optionNamed:optionName];
    if (option == nil) {
        return nil;
    }
    
    id object = _optionManifest[optionName];
    if (object == nil) {
        return nil;
    }
    
    switch (option.type) {
        case CLKOptionTypeSwitch:
            break;
        
        case CLKOptionTypeParameter:
            // for non-recurrent parameter options, return the argument directly.
            // don't assert multiple occurrences of non-recurrent options here.
            // that is a usage error and the validator will handle it in order
            // to provide a good message to the user at parsing time.
            if (!option.recurrent) {
                object = ((NSArray *)object).firstObject;
            }
            
            break;
    }
    
    return object;
}

- (BOOL)hasOptionNamed:(NSString *)optionName
{
    return (_optionManifest[optionName] != nil);
}

- (NSUInteger)occurrencesOfOptionNamed:(NSString *)optionName
{
    CLKOption *option = [_optionRegistry optionNamed:optionName];
    id value = _optionManifest[optionName];
    if (value == nil) {
        return 0;
    }
    
    NSUInteger occurrences = 0;
    switch (option.type) {
        case CLKOptionTypeSwitch:
            NSAssert2(([value isKindOfClass:[NSNumber class]]), @"unexpectedly found object of class %@ for option named: %@", NSStringFromClass([value class]), optionName);
            occurrences = ((NSNumber *)value).unsignedIntegerValue;
            break;
        
        case CLKOptionTypeParameter:
            NSAssert2(([value isKindOfClass:[NSMutableArray class]]), @"unexpectedly found object of class %@ for option named: %@", NSStringFromClass([value class]), optionName);
            occurrences = ((NSMutableArray *)value).count;
            break;
    }
    
    return occurrences;
}

#pragma mark -
#pragma mark Building Manifests

- (void)accumulateSwitchOptionNamed:(NSString *)optionName
{
    CLKParameterAssert([_optionRegistry hasOptionNamed:optionName], @"attempting to accumulate unregistered option named '%@'", optionName);
    CLKParameterAssert(([_optionRegistry optionNamed:optionName].type == CLKOptionTypeSwitch), @"attempting to accumulate switch occurrence for parameter option named '%@'", optionName);
    NSUInteger occurrences = [self occurrencesOfOptionNamed:optionName];
    _optionManifest[optionName] = @(occurrences + 1);
}

- (void)accumulateArgument:(id)argument forParameterOptionNamed:(NSString *)optionName
{
    CLKParameterAssert([_optionRegistry hasOptionNamed:optionName], @"attempting to accumulate unregistered option named '%@'", optionName);
    CLKParameterAssert(([_optionRegistry optionNamed:optionName].type == CLKOptionTypeParameter), @"attempting to accumulate argument for switch option named '%@'", optionName);
    
    NSMutableArray *arguments = _optionManifest[optionName];
    if (arguments == nil) {
        arguments = [NSMutableArray array];
        _optionManifest[optionName] = arguments;
    }
    
    // don't assert multiple occurrences of non-recurrent options here.
    // that is a usage error and the validator will handle it in order
    // to provide a good message to the user.
    
    [arguments addObject:argument];
}

- (void)accumulatePositionalArgument:(NSString *)argument
{
    [_positionalArguments addObject:argument];
}

@end
