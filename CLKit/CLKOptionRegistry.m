//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import "CLKOptionRegistry.h"

#import "CLKAssert.h"
#import "CLKOption.h"


@implementation CLKOptionRegistry
{
    NSMutableDictionary<NSString *, CLKOption *> *_optionNameMap;
    NSMutableDictionary<NSString *, CLKOption *> *_optionFlagMap;
}

+ (instancetype)registryWithOptions:(NSArray<CLKOption *> *)options
{
    // for some reason, the compiler doesn't know what -initWithOptions: we want
    return [[(CLKOptionRegistry *)[self alloc] initWithOptions:options] autorelease];
}

- (instancetype)initWithOptions:(NSArray<CLKOption *> *)options
{
    self = [super init];
    if (self != nil) {
        _optionNameMap = [[NSMutableDictionary alloc] init];
        _optionFlagMap = [[NSMutableDictionary alloc] init];
        
        // build the maps and do some sanity checks along the way
        for (CLKOption *option in options) {
            CLKHardAssert((_optionNameMap[option.name] == nil), NSInvalidArgumentException, @"encountered multiple options named '%@'", option.name);
            _optionNameMap[option.name] = option;
            
            if (option.flag != nil) {
                CLKOption *collision = _optionFlagMap[option.flag];
                CLKHardAssert((collision == nil), NSInvalidArgumentException, @"encountered colliding flag '%@' for options '%@' and '%@'", option.flag, option.name, collision.name);
                _optionFlagMap[option.flag] = option;
            }
        }
    }
    
    return self;
}

- (void)dealloc
{
    [_optionNameMap release];
    [_optionFlagMap release];
    [super dealloc];
}

#pragma mark -

- (nullable CLKOption *)optionNamed:(NSString *)name
{
    NSParameterAssert(name.length > 0);
    return _optionNameMap[name];
}

- (nullable CLKOption *)optionForFlag:(NSString *)flag
{
    NSParameterAssert(flag.length == 1);
    return _optionFlagMap[flag];
}

- (BOOL)hasOptionNamed:(NSString *)name
{
    NSParameterAssert(name.length > 0);
    return (_optionNameMap[name] != nil);
}

@end
