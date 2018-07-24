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
@synthesize options = _options;
@synthesize optionGroups = _optionGroups;
@synthesize runWithManifest_impl = _runWithManifest_impl;

+ (instancetype)flarnVerb
{
    CLKOption *option = [CLKOption optionWithName:@"alpha" flag:@"a"];
    return [[[self alloc] initWithName:@"flarn" options:@[ option ] optionGroups:nil] autorelease];
}

+ (instancetype)barfVerb
{
    CLKOption *option = [CLKOption optionWithName:@"bravo" flag:@"b"];
    return [[[self alloc] initWithName:@"flarn" options:@[ option ] optionGroups:nil] autorelease];
}

+ (instancetype)quoneVerb
{
    CLKOption *option = [CLKOption optionWithName:@"charlie" flag:@"c"];
    return [[[self alloc] initWithName:@"quone" options:@[ option ] optionGroups:nil] autorelease];
}

+ (instancetype)xyzzyVerb
{
    CLKOption *option = [CLKOption optionWithName:@"delta" flag:@"d"];
    return [[[self alloc] initWithName:@"xyzzy" options:@[ option ] optionGroups:nil] autorelease];
}

+ (instancetype)synVerb
{
    CLKOption *option = [CLKOption optionWithName:@"echo" flag:@"e"];
    return [[[self alloc] initWithName:@"syn" options:@[ option ] optionGroups:nil] autorelease];
}

+ (instancetype)ackVerb
{
    CLKOption *option = [CLKOption optionWithName:@"foxtrot" flag:@"f"];
    return [[[self alloc] initWithName:@"ack" options:@[ option ] optionGroups:nil] autorelease];
}

+ (instancetype)verbWithName:(NSString *)name option:(CLKOption *)option
{
    return [[[self alloc] initWithName:name options:@[ option ] optionGroups:nil] autorelease];
}

+ (instancetype)verbWithName:(NSString *)name options:(NSArray<CLKOption *> *)options
{
    return [[[self alloc] initWithName:name options:options optionGroups:nil] autorelease];
}

- (instancetype)initWithName:(NSString *)name
                     options:(NSArray<CLKOption *> *)options
                optionGroups:(NSArray<CLKOptionGroup *> *)optionGroups
{
    self = [super init];
    if (self != nil) {
        _name = [name copy];
        _options = [options copy];
        _optionGroups = [optionGroups copy];
    }
    
    return self;
}

- (void)dealloc
{
    [_name release];
    [_options release];
    [_optionGroups release];
    [_runWithManifest_impl release];
    [super dealloc];
}

#pragma mark -
#pragma mark <CLKVerb>

- (CLKCommandResult *)runWithManifest:(CLKArgumentManifest *)manifest
{
    if (_runWithManifest_impl == nil) {
        NSDictionary *userInfo = @{
            @"verb" : _name,
            @"manifest" : manifest,
        };
        
        return [[[CLKCommandResult alloc] initWithExitStatus:0 errors:nil userInfo:userInfo] autorelease];
    }
    
    return _runWithManifest_impl(manifest);
}

@end
