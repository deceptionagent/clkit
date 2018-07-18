//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import "StuntVerb.h"

#import "CLKCommandResult.h"
#import "CLKOption.h"
#import "CLKOptionGroup.h"


@implementation StuntVerb
{
    NSString *_name;
    NSString *_help;
    BOOL _public;
    NSArray<CLKOption *> *_options;
    NSArray<CLKOptionGroup *> *_optionGroups;
    CLKCommandResult *(^_runWithManifest_impl)(CLKArgumentManifest *);
}

@synthesize name = _name;
@synthesize help = _help;
@synthesize public = _public;
@synthesize options = _options;
@synthesize optionGroups = _optionGroups;
@synthesize runWithManifest_impl = _runWithManifest_impl;

+ (instancetype)flarnVerb
{
    CLKOption *barf = [CLKOption optionWithName:@"barf" flag:@"b"];
    return [[[self alloc] initWithName:@"flarn" help:@"flarn the barf" pubilc:YES options:@[ barf ] optionGroups:nil] autorelease];
}

+ (instancetype)quoneVerb
{
    CLKOption *xyzzy = [CLKOption optionWithName:@"xyzzy" flag:@"x"];
    return [[[self alloc] initWithName:@"quone" help:@"quone the xyzzy" pubilc:YES options:@[ xyzzy ] optionGroups:nil] autorelease];
}

- (instancetype)initWithName:(NSString *)name
                        help:(NSString *)help
                      pubilc:(BOOL)public
                     options:(NSArray<CLKOption *> *)options
                optionGroups:(NSArray<CLKOptionGroup *> *)optionGroups
{
    self = [super init];
    if (self != nil) {
        _name = [name copy];
        _help = [help copy];
        _public = public;
        _options = [options copy];
        _optionGroups = [optionGroups copy];
    }
    
    return self;
}

- (void)dealloc
{
    [_name release];
    [_help release];
    [_options release];
    [_optionGroups release];
    [super dealloc];
}

#pragma mark -
#pragma mark <CLKVerb>

- (CLKCommandResult *)runWithManifest:(CLKArgumentManifest *)manifest
{
    if (_runWithManifest_impl == nil) {
        return [CLKCommandResult resultWithExitStatus:0];
    }
    
    return _runWithManifest_impl(manifest);
}

@end
