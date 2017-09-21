//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import "CLKOption.h"
#import "CLKOption_Private.h"

#import "CLKArgumentTransformer.h"
#import "CLKAssert.h"


@implementation CLKOption
{
    CLKOptionType _type;
    NSString *_name;
    NSString *_flag;
    CLKArgumentTransformer *_transformer;
}

@synthesize type = _type;
@synthesize name = _name;
@synthesize flag = _flag;
@synthesize transformer = _transformer;

+ (instancetype)optionWithName:(NSString *)name flag:(NSString *)flag
{
    return [[[self alloc] initWithType:CLKOptionTypeSwitch name:name flag:flag required:NO transformer:nil] autorelease];
}

+ (instancetype)parameterOptionWithName:(NSString *)name flag:(NSString *)flag
{
    return [[[self alloc] initWithType:CLKOptionTypeParameter name:name flag:flag required:NO transformer:nil] autorelease];
}

+ (instancetype)parameterOptionWithName:(NSString *)name flag:(nullable NSString *)flag required:(BOOL)required
{
    return [[[self alloc] initWithType:CLKOptionTypeParameter name:name flag:flag required:required transformer:nil] autorelease];
}

+ (instancetype)parameterOptionWithName:(NSString *)name flag:(NSString *)flag transformer:(nullable CLKArgumentTransformer *)transformer
{
    return [[[self alloc] initWithType:CLKOptionTypeParameter name:name flag:flag required:NO transformer:transformer] autorelease];
}

+ (instancetype)parameterOptionWithName:(NSString *)name flag:(NSString *)flag required:(BOOL)required transformer:(nullable CLKArgumentTransformer *)transformer
{
    return [[[self alloc] initWithType:CLKOptionTypeParameter name:name flag:flag required:required transformer:transformer] autorelease];
}

- (instancetype)initWithType:(CLKOptionType)type name:(NSString *)name flag:(NSString *)flag required:(BOOL)required transformer:(nullable CLKArgumentTransformer *)transformer
{
    CLKHardParameterAssert(!(type == CLKOptionTypeSwitch && (required || transformer != nil)));
    CLKHardParameterAssert(![name hasPrefix:@"-"]);
    CLKHardParameterAssert(![flag hasPrefix:@"-"]);
    CLKHardParameterAssert(name.length > 0);
    CLKHardParameterAssert(flag == nil || flag.length == 1);
    
    self = [super init];
    if (self != nil) {
        _type = type;
        _name = [name copy];
        _flag = [flag copy];
        _required = required;
        _transformer = [transformer retain];
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
    NSString * const fmt = @"%@ { --%@ | -%@ | required: %@ | type: %d }";
    return [NSString stringWithFormat:fmt, super.description, _name, _flag, (_required ? @"YES" : @"NO"), _type];
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
