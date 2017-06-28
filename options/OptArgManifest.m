//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import "OptArgManifest.h"


@implementation OptArgManifest

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

#pragma mark -
#pragma mark Building Manifests

- (void)accumulateFreeOption:(NSString *)optionName
{
    uint32_t occurrences = [self freeOptionCount:optionName];
    _freeOptions[optionName] = @(occurrences + 1);
}

- (void)accumulateArgument:(id)argument forOption:(NSString *)optionName
{
    NSMutableArray *arguments = _optionArguments[optionName];
    if (arguments == nil) {
        arguments = [NSMutableArray array];
        _optionArguments[optionName] = arguments;
    }
    
    [arguments addObject:argument];
}

- (void)accumulateRemainderArgument:(NSString *)argument
{
    [_remainderArguments addObject:argument];
}

#pragma mark -
#pragma mark Reading Manifests

- (BOOL)freeOptionEnabled:(NSString *)optionName
{
    return ([self freeOptionCount:optionName] > 0);
}

- (uint32_t)freeOptionCount:(NSString *)optionName
{
    return _freeOptions[optionName].unsignedIntValue;
}

- (NSArray *)argumentsForOption:(NSString *)optionName
{
    return _optionArguments[optionName];
}

- (NSArray<NSString *> *)remainderArguments
{
    return (_remainderArguments.count > 0 ? _remainderArguments : nil);
}


@end
