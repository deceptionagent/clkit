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
}

@synthesize name = _name;
@synthesize options = _options;
@synthesize optionGroups = _optionGroups;

+ (instancetype)flarnVerb
{
    CLKOption *option = [CLKOption optionWithName:@"alpha" flag:@"a"];
    return [[self alloc] initWithName:@"flarn" options:@[ option ] optionGroups:nil];
}

+ (instancetype)barfVerb
{
    CLKOption *option = [CLKOption optionWithName:@"bravo" flag:@"b"];
    return [[self alloc] initWithName:@"flarn" options:@[ option ] optionGroups:nil];
}

+ (instancetype)quoneVerb
{
    CLKOption *option = [CLKOption optionWithName:@"charlie" flag:@"c"];
    return [[self alloc] initWithName:@"quone" options:@[ option ] optionGroups:nil];
}

+ (instancetype)xyzzyVerb
{
    CLKOption *option = [CLKOption optionWithName:@"delta" flag:@"d"];
    return [[self alloc] initWithName:@"xyzzy" options:@[ option ] optionGroups:nil];
}

+ (instancetype)synVerb
{
    CLKOption *option = [CLKOption optionWithName:@"echo" flag:@"e"];
    return [[self alloc] initWithName:@"syn" options:@[ option ] optionGroups:nil] ;
}

+ (instancetype)ackVerb
{
    CLKOption *option = [CLKOption optionWithName:@"foxtrot" flag:@"f"];
    return [[self alloc] initWithName:@"ack" options:@[ option ] optionGroups:nil];
}

+ (instancetype)verbWithName:(NSString *)name option:(CLKOption *)option
{
    return [[self alloc] initWithName:name options:@[ option ] optionGroups:nil];
}

+ (instancetype)verbWithName:(NSString *)name options:(NSArray<CLKOption *> *)options
{
    return [[self alloc] initWithName:name options:options optionGroups:nil];
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

#pragma mark -
#pragma mark <CLKVerb>

- (CLKCommandResult *)runWithManifest:(CLKArgumentManifest *)manifest
{
    NSDictionary *userInfo = @{
        @"verb" : _name,
        @"manifest" : manifest,
    };
    
    return [[CLKCommandResult alloc] initWithExitStatus:0 errors:nil userInfo:userInfo];
}

@end
