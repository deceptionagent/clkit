//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import "CLKOption.h"
#import "CLKOption_Private.h"

#import "CLKArgumentTransformer.h"
#import "CLKAssert.h"


@implementation CLKOption
{
    NSString *_name;
    NSString *_flag;
    BOOL _expectsArgument;
    CLKArgumentTransformer *_transformer;
}

@synthesize name = _name;
@synthesize flag = _flag;
@synthesize expectsArgument = _expectsArgument;
@synthesize transformer = _transformer;

+ (instancetype)optionWithName:(NSString *)name flag:(NSString *)flag
{
    return [[[self alloc] initWithName:name flag:flag required:NO transformer:nil expectsArgument:YES] autorelease];
}

+ (instancetype)optionWithName:(NSString *)name flag:(nullable NSString *)flag required:(BOOL)required
{
    return [[[self alloc] initWithName:name flag:flag required:required transformer:nil expectsArgument:YES] autorelease];
}

+ (instancetype)optionWithName:(NSString *)name flag:(NSString *)flag transformer:(nullable CLKArgumentTransformer *)transformer
{
    return [[[self alloc] initWithName:name flag:flag required:NO transformer:transformer expectsArgument:YES] autorelease];
}

+ (instancetype)optionWithName:(NSString *)name flag:(NSString *)flag required:(BOOL)required transformer:(nullable CLKArgumentTransformer *)transformer
{
    return [[[self alloc] initWithName:name flag:flag required:required transformer:transformer expectsArgument:YES] autorelease];
}

+ (instancetype)freeOptionWithName:(NSString *)name flag:(NSString *)flag
{
    return [[[self alloc] initWithName:name flag:flag required:NO transformer:nil expectsArgument:NO] autorelease];
}

- (instancetype)initWithName:(NSString *)name flag:(NSString *)flag required:(BOOL)required transformer:(CLKArgumentTransformer *)transformer expectsArgument:(BOOL)expectsArgument
{
    CLKHardParameterAssert(![name hasPrefix:@"-"]);
    CLKHardParameterAssert(![flag hasPrefix:@"-"]);
    CLKHardParameterAssert(name.length > 0);
    CLKHardParameterAssert(flag == nil || flag.length == 1);
    
    self = [super init];
    if (self != nil) {
        _name = [name copy];
        _flag = [flag copy];
        _required = required;
        _transformer = [transformer retain];
        _expectsArgument = expectsArgument;
    }
    
    return self;
}

- (void)dealloc
{
    [_transformer release];
    [_flag release];
    [_name release];
    [super dealloc];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ { --%@ | -%@ | expects argument: %@ }", super.description, _name, _flag, (_expectsArgument ? @"YES" : @"NO")];
}

- (NSUInteger)hash
{
    return _name.hash;
}

- (BOOL)isEqual:(id)obj
{
    if (obj == self) {
        return YES;
    }
    
    if (![obj isKindOfClass:[CLKOption class]]) {
        return NO;
    }
    
    CLKOption *opt = (CLKOption *)obj;
    return [opt.name isEqualToString:_name];
}

#pragma mark -

- (NSString *)manifestKey
{
    return _name;
}

@end
