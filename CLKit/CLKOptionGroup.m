//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import "CLKOptionGroup.h"

#import "CLKOption.h"


@interface CLKOptionGroup ()

- (nonnull instancetype)_initWithOptions:(nullable NSArray<CLKOption *> *)options
                               subgroups:(nullable NSArray<CLKOptionGroup *> *)subgroups
                                 mutexed:(BOOL)mutexed
                                required:(BOOL)required NS_DESIGNATED_INITIALIZER;

@end


@implementation CLKOptionGroup
{
    NSArray<CLKOption *> *_options;
    NSArray<CLKOptionGroup *> *_subgroups;
    BOOL _mutexed;
    BOOL _required;
}

@synthesize options = _options;
@synthesize subgroups = _subgroups;
@synthesize mutexed = _mutexed;
@synthesize required = _required;

+ (instancetype)groupWithOptions:(NSArray<CLKOption *> *)options required:(BOOL)required
{
    return [[[self alloc] _initWithOptions:options subgroups:nil mutexed:NO required:required] autorelease];
}

+ (instancetype)mutexedGroupWithOptions:(NSArray<CLKOption *> *)options required:(BOOL)required
{
    return [[[self alloc] _initWithOptions:options subgroups:nil mutexed:YES required:required] autorelease];
}

+ (instancetype)mutexedGroupWithOptions:(NSArray<CLKOption *> *)options subgroups:(NSArray<CLKOptionGroup *> *)subgroups required:(BOOL)required
{
    return [[[self alloc] _initWithOptions:options subgroups:subgroups mutexed:YES required:required] autorelease];
}

- (instancetype)_initWithOptions:(NSArray<CLKOption *> *)options subgroups:(NSArray<CLKOptionGroup *> *)subgroups mutexed:(BOOL)mutexed required:(BOOL)required
{
    self = [super init];
    if (self != nil) {
        _options = [options copy];
        _subgroups = [subgroups copy];
        _mutexed = mutexed;
        _required = required;
    }
    
    return self;
}

- (void)dealloc
{
    [_subgroups release];
    [_options release];
    [super dealloc];
}

@end
