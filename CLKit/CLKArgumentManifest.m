//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import "CLKArgumentManifest.h"

#import "CLKAssert.h"
#import "CLKOption.h"
#import "CLKOption_Private.h"


@implementation CLKArgumentManifest
{
    NSMutableDictionary<NSString *, NSNumber *> *_switchOptions;
    NSMutableDictionary<NSString *, NSMutableArray *> *_optionArguments;
    NSMutableArray<NSString *> *_positionalArguments;
}

@synthesize switchOptions = _switchOptions;
@synthesize optionArguments = _optionArguments;
@synthesize positionalArguments = _positionalArguments;

+ (instancetype)manifest
{
    return [[[self alloc] init] autorelease];
}

- (instancetype)init
{
    self = [super init];
    if (self != nil) {
        _switchOptions = [[NSMutableDictionary alloc] init];
        _optionArguments = [[NSMutableDictionary alloc] init];
        _positionalArguments = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
    [_switchOptions release];
    [_optionArguments release];
    [_positionalArguments release];
    [super dealloc];
}

- (NSString *)debugDescription
{
    NSString *fmt = @"%@\n\nswitch options:\n%@\n\noption arguments:\n%@\n\npositional arguments:\n%@";
    return [NSString stringWithFormat:fmt, super.debugDescription, _switchOptions, _optionArguments, _positionalArguments];
}

#pragma mark -

- (BOOL)hasOption:(CLKOption *)option
{
    return (_switchOptions[option.name] != nil || _optionArguments[option.name] != nil);
}

#pragma mark -
#pragma mark Building Manifests

- (void)accumulateSwitchOption:(CLKOption *)option
{
    NSParameterAssert(option.type == CLKOptionTypeSwitch);
    
    NSString *key = option.manifestKey;
    NSNumber *occurrences = _switchOptions[key];
    _switchOptions[key] = @(occurrences.unsignedIntValue + 1);
}

- (void)accumulateArgument:(id)argument forParameterOption:(CLKOption *)option
{
    NSParameterAssert(option.type == CLKOptionTypeParameter);

    NSString *key = option.manifestKey;
    NSMutableArray *arguments = _optionArguments[key];
    if (arguments == nil) {
        arguments = [NSMutableArray array];
        _optionArguments[key] = arguments;
    }
    
    [arguments addObject:argument];
}

- (void)accumulatePositionalArgument:(NSString *)argument
{
    [_positionalArguments addObject:argument];
}

@end
