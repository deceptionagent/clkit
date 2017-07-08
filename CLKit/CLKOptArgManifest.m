//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import "CLKOptArgManifest.h"


@implementation CLKOptArgManifest

@synthesize freeOptions = _freeOptions;
@synthesize optionArguments = _optionArguments;
@synthesize remainderArguments = _remainderArguments;

- (instancetype)init
{
    self = [super init];
    if (self != nil) {
        _freeOptions = [[NSMutableDictionary alloc] init];
        _optionArguments = [[NSMutableDictionary alloc] init];
        _remainderArguments = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
    [_freeOptions release];
    [_optionArguments release];
    [_remainderArguments release];
    [super dealloc];
}

- (NSString *)debugDescription
{
    NSString *fmt = @"%@\n\nfree options:\n%@\n\noption arguments:\n%@\n\nremainder arguments:\n%@";
    return [NSString stringWithFormat:fmt, super.debugDescription, _freeOptions, _optionArguments, _remainderArguments];
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

- (void)accumulateRemainderArgument:(NSString *)argument
{
    [_remainderArguments addObject:argument];
}

@end
