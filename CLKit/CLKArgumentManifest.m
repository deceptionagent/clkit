//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import "CLKArgumentManifest.h"
#import "CLKArgumentManifest_Private.h"

#import "CLKAssert.h"
#import "CLKOption.h"
#import "CLKOption_Private.h"


NS_ASSUME_NONNULL_BEGIN

@interface CLKArgumentManifest ()

- (void)_registerOption:(CLKOption *)option;

@end

NS_ASSUME_NONNULL_END


@implementation CLKArgumentManifest
{
    NSMutableDictionary<NSString *, CLKOption *> *_optionNameRegistry;
    NSMutableDictionary<CLKOption *, id> *_optionManifest;
    NSMutableArray<NSString *> *_positionalArguments;
}

@synthesize optionManifest = _optionManifest;
@synthesize positionalArguments = _positionalArguments;

- (instancetype)init
{
    self = [super init];
    if (self != nil) {
        _optionNameRegistry = [[NSMutableDictionary alloc] init];
        _optionManifest = [[NSMutableDictionary alloc] init];
        _positionalArguments = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
    [_optionNameRegistry release];
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
    CLKOption *option = _optionNameRegistry[optionName];
    
    // option not accumulated
    if (option == nil) {
        return nil;
    }
    
    id object = _optionManifest[option];
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

- (BOOL)hasOption:(CLKOption *)option
{
    return (_optionManifest[option] != nil);
}

- (BOOL)hasOptionNamed:(NSString *)optionName
{
    return (_optionNameRegistry[optionName] != nil);
}

- (NSUInteger)occurrencesOfOption:(CLKOption *)option
{
    NSUInteger occurrences = 0;
    
    id value = _optionManifest[option];
    switch (option.type) {
        case CLKOptionTypeSwitch:
            occurrences = ((NSNumber *)value).unsignedIntegerValue;
            break;
        
        case CLKOptionTypeParameter:
            occurrences = ((NSMutableArray *)value).count;
            break;
    }
    
    return occurrences;
}

- (NSUInteger)occurrencesOfOptionNamed:(NSString *)optionName
{
    CLKOption *option = _optionNameRegistry[optionName];
    
    // option not accumulated
    if (option == nil) {
        return 0;
    }
    
    return [self occurrencesOfOption:option];
}

- (NSDictionary<NSString *, id> *)optionManifestKeyedByName
{
    NSMutableDictionary *manifestKeyedByName = [[[NSMutableDictionary alloc] initWithCapacity:_optionManifest.count] autorelease];
    
    [_optionManifest enumerateKeysAndObjectsUsingBlock:^(CLKOption *option, id arguments, __unused BOOL *outStop) {
        manifestKeyedByName[option.name] = arguments;
    }];
    
    return manifestKeyedByName;
}

#pragma mark -
#pragma mark Building Manifests

- (void)accumulateSwitchOption:(CLKOption *)option
{
    NSParameterAssert(option.type == CLKOptionTypeSwitch);
    [self _registerOption:option];
    NSUInteger occurrences = [self occurrencesOfOption:option];
    _optionManifest[option] = @(occurrences + 1);
}

- (void)accumulateArgument:(id)argument forParameterOption:(CLKOption *)option
{
    NSParameterAssert(option.type == CLKOptionTypeParameter);
    
    [self _registerOption:option];
    NSMutableArray *arguments = _optionManifest[option];
    NSAssert2((arguments == nil || [arguments isKindOfClass:[NSMutableArray class]]), @"unexpectedly found object of class %@ for option: %@", NSStringFromClass([arguments class]), option);
    if (arguments == nil) {
        arguments = [NSMutableArray array];
        _optionManifest[option] = arguments;
    }
    
    // don't assert multiple occurrences of non-recurrent options here.
    // that is a usage error and the validator will handle it in order
    // to provide a good message to the user.
    
    [arguments addObject:argument];
}

- (void)_registerOption:(CLKOption *)option
{
    if (_optionNameRegistry[option.name] == nil) {
        _optionNameRegistry[option.name] = option;
    }
}

- (void)accumulatePositionalArgument:(NSString *)argument
{
    [_positionalArguments addObject:argument];
}

@end
