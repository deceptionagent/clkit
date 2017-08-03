//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import "CLKOptArgManifest.h"


@implementation CLKOptArgManifest
{
    NSMutableDictionary<NSString *, NSNumber *> *_freeOptions;
    NSMutableDictionary<NSString *, NSMutableArray *> *_optionArguments;
    NSMutableArray<NSString *> *_positionalArguments;
}

@synthesize freeOptions = _freeOptions;
@synthesize optionArguments = _optionArguments;
@synthesize positionalArguments = _positionalArguments;

- (instancetype)init
{
    self = [super init];
    if (self != nil) {
        _freeOptions = [[NSMutableDictionary alloc] init];
        _optionArguments = [[NSMutableDictionary alloc] init];
        _positionalArguments = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
    [_freeOptions release];
    [_optionArguments release];
    [_positionalArguments release];
    [super dealloc];
}

- (NSString *)debugDescription
{
    NSString *fmt = @"%@\n\nfree options:\n%@\n\noption arguments:\n%@\n\npositional arguments:\n%@";
    return [NSString stringWithFormat:fmt, super.debugDescription, _freeOptions, _optionArguments, _positionalArguments];
}

#pragma mark -
#pragma mark Building Manifests

- (void)accumulateFreeOptionNamed:(NSString *)name
{
    NSNumber *occurrences = _freeOptions[name];
    _freeOptions[name] = @(occurrences.unsignedIntValue + 1);
}

- (void)accumulateArgument:(id)argument forOptionNamed:(NSString *)name
{
    NSMutableArray *arguments = _optionArguments[name];
    if (arguments == nil) {
        arguments = [NSMutableArray array];
        _optionArguments[name] = arguments;
    }
    
    [arguments addObject:argument];
}

- (void)accumulatePositionalArgument:(NSString *)argument
{
    [_positionalArguments addObject:argument];
}

@end
