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
    NSMutableDictionary<NSString *, NSNumber *> *_switchOptionOccurrences;
    NSMutableDictionary<NSString *, NSMutableArray *> *_parameterOptionArguments;
    NSMutableArray<NSString *> *_positionalArguments;
}

@synthesize positionalArguments = _positionalArguments;

- (instancetype)initWithOptionRegistry:(CLKOptionRegistry *)optionRegistry
{
    NSParameterAssert(optionRegistry != nil);
    
    self = [super init];
    if (self != nil) {
        _optionRegistry = optionRegistry;
        _switchOptionOccurrences = [[NSMutableDictionary alloc] init];
        _parameterOptionArguments = [[NSMutableDictionary alloc] init];
        _positionalArguments = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (NSString *)debugDescription
{
    NSString *fmt = @"%@\n%@\n\npositional arguments:\n%@";
    return [NSString stringWithFormat:fmt, super.debugDescription, self.dictionaryRepresentationForAccumulatedOptions, _positionalArguments];
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
    
    id object = nil;
    
    switch (option.type) {
        case CLKOptionTypeSwitch:
            object = _switchOptionOccurrences[optionName];
            break;
        
        case CLKOptionTypeParameter:
            // for non-recurrent parameter options, return the single accumulated
            // argument. multiple occurrences of non-recurrent options is a usage
            // error handled by the manifest validator.
            if (option.recurrent) {
                object = _parameterOptionArguments[optionName];
            } else {
                object = _parameterOptionArguments[optionName].firstObject;
            }
            
            break;
    }
    
    return object;
}

- (NSSet<NSString *> *)accumulatedOptionNames
{
    NSMutableSet *names = [NSMutableSet setWithArray:_switchOptionOccurrences.allKeys];
    [names addObjectsFromArray:_parameterOptionArguments.allKeys];
    return names;
}

- (BOOL)hasOptionNamed:(NSString *)optionName
{
    return (_switchOptionOccurrences[optionName] != nil || _parameterOptionArguments[optionName] != nil);
}

- (NSUInteger)occurrencesOfOptionNamed:(NSString *)optionName
{
    CLKOption *option = [_optionRegistry optionNamed:optionName];
    if (option == nil) {
        return 0;
    }
    
    NSUInteger occurrences = 0;
    switch (option.type) {
        case CLKOptionTypeSwitch:
            occurrences = _switchOptionOccurrences[optionName].unsignedIntegerValue;
            break;
        
        case CLKOptionTypeParameter:
            occurrences = _parameterOptionArguments[optionName].count;
            break;
    }
    
    return occurrences;
}

- (NSDictionary<NSString *, id> *)dictionaryRepresentationForAccumulatedOptions
{
    NSMutableDictionary *rep = [NSMutableDictionary dictionary];
    [rep addEntriesFromDictionary:_switchOptionOccurrences];
    [rep addEntriesFromDictionary:_parameterOptionArguments];
    return rep;
}

#pragma mark -
#pragma mark Building Manifests

- (void)accumulateSwitchOptionNamed:(NSString *)optionName
{
    CLKParameterAssert([_optionRegistry hasOptionNamed:optionName], @"attempting to accumulate unregistered option named '%@'", optionName);
    CLKParameterAssert(([_optionRegistry optionNamed:optionName].type == CLKOptionTypeSwitch), @"attempting to accumulate switch occurrence for parameter option named '%@'", optionName);
    NSUInteger occurrences = _switchOptionOccurrences[optionName].unsignedIntegerValue;
    _switchOptionOccurrences[optionName] = @(occurrences + 1);
}

- (void)accumulateArgument:(id)argument forParameterOptionNamed:(NSString *)optionName
{
    CLKParameterAssert([_optionRegistry hasOptionNamed:optionName], @"attempting to accumulate unregistered option named '%@'", optionName);
    CLKParameterAssert(([_optionRegistry optionNamed:optionName].type == CLKOptionTypeParameter), @"attempting to accumulate argument for switch option named '%@'", optionName);
    
    NSMutableArray *arguments = _parameterOptionArguments[optionName];
    if (arguments == nil) {
        arguments = [NSMutableArray array];
        _parameterOptionArguments[optionName] = arguments;
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
