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
    CLKOption *barf = [CLKOption optionWithName:@"barf" flag:@"b"];
    return [[[self alloc] initWithName:@"flarn" options:@[ barf ] optionGroups:nil] autorelease];
}

+ (instancetype)quoneVerb
{
    CLKOption *xyzzy = [CLKOption optionWithName:@"xyzzy" flag:@"x"];
    return [[[self alloc] initWithName:@"quone" options:@[ xyzzy ] optionGroups:nil] autorelease];
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
