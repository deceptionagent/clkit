//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import "CLKConstraint.h"

#import <Foundation/Foundation.h>

#import "CLKAssert.h"


@implementation CLKConstraint
{
    BOOL _required;
    BOOL _mutexed;
    NSArray<CLKOption *> *_options;
    NSArray<CLKOptionGroup *> *_groups;
}

@synthesize required = _required;
@synthesize mutexed = _mutexed;
@synthesize options = _options;
@synthesize groups = _groups;

+ (instancetype)constraintForRequiredOption:(CLKOption *)option
{
    return [[[self alloc] initWithOptions:@[ option ] groups:nil required:YES mutexed:NO] autorelease];
}

- (instancetype)initWithOptions:(NSArray<CLKOption *> *)options groups:(NSArray<CLKOptionGroup *> *)groups required:(BOOL)required mutexed:(BOOL)mutexed
{
    CLKHardParameterAssert((options != nil && options.count > 0) || (groups != nil && groups.count > 0));
    
    self = [super init];
    if (self != nil) {
        _required = required;
        _mutexed = mutexed;
        _options = [options copy];
        _groups = [groups copy];
    }
    
    return self;
}

- (void)dealloc
{
    [_options release];
    [_groups release];
    [super dealloc];
}

@end

