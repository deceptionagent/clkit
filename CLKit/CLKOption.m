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
    NSArray<CLKOption *> *_dependencies;
}

@synthesize type = _type;
@synthesize name = _name;
@synthesize flag = _flag;
@synthesize transformer = _transformer;
@synthesize dependencies = _dependencies;

#pragma mark -
#pragma mark Switch Options

+ (instancetype)optionWithName:(NSString *)name flag:(NSString *)flag
{
    return [[[self alloc] initWithType:CLKOptionTypeSwitch name:name flag:flag required:NO] autorelease];
}

+ (instancetype)optionWithName:(NSString *)name flag:(NSString *)flag dependencies:(NSArray<CLKOption *> *)dependencies
{
    return [[[self alloc] initWithType:CLKOptionTypeSwitch name:name flag:flag required:NO transformer:nil dependencies:dependencies] autorelease];
}

#pragma mark -
#pragma mark Parameter Options

+ (instancetype)parameterOptionWithName:(NSString *)name flag:(NSString *)flag
{
    return [[[self alloc] initWithType:CLKOptionTypeParameter name:name flag:flag required:NO] autorelease];
}

+ (instancetype)parameterOptionWithName:(NSString *)name flag:(NSString *)flag required:(BOOL)required
{
    return [[[self alloc] initWithType:CLKOptionTypeParameter name:name flag:flag required:required] autorelease];
}

+ (instancetype)parameterOptionWithName:(NSString *)name flag:(NSString *)flag transformer:(CLKArgumentTransformer *)transformer
{
    return [[[self alloc] initWithType:CLKOptionTypeParameter name:name flag:flag required:NO transformer:transformer dependencies:nil] autorelease];
}

+ (instancetype)parameterOptionWithName:(NSString *)name flag:(NSString *)flag required:(BOOL)required transformer:(CLKArgumentTransformer *)transformer
{
    return [[[self alloc] initWithType:CLKOptionTypeParameter name:name flag:flag required:required transformer:transformer dependencies:nil] autorelease];
}

+ (instancetype)parameterOptionWithName:(NSString *)name flag:(NSString *)flag required:(BOOL)required transformer:(CLKArgumentTransformer *)transformer dependencies:(NSArray<CLKOption *> *)dependencies;
{
    return [[[self alloc] initWithType:CLKOptionTypeParameter name:name flag:flag required:required transformer:transformer dependencies:dependencies] autorelease];
}

#pragma mark -

- (instancetype)initWithType:(CLKOptionType)type name:(NSString *)name flag:(NSString *)flag required:(BOOL)required
{
    return [self initWithType:type name:name flag:flag required:required transformer:nil dependencies:nil];
}

- (instancetype)initWithType:(CLKOptionType)type name:(NSString *)name flag:(NSString *)flag required:(BOOL)required transformer:(CLKArgumentTransformer *)transformer dependencies:(NSArray<CLKOption *> *)dependencies
{
    CLKHardParameterAssert(!(type == CLKOptionTypeSwitch && required), @"switch options cannot be required");
    CLKHardParameterAssert(!(type == CLKOptionTypeSwitch && transformer != nil), @"switch options do not support argument transformers");
    CLKHardParameterAssert(![name hasPrefix:@"-"], @"option names should not begin with -- or -");
    CLKHardParameterAssert(![flag hasPrefix:@"-"], @"option flags should not begin with -- or -");
    CLKHardParameterAssert(name.length > 0);
    CLKHardParameterAssert(flag == nil || flag.length == 1);
    
    for (CLKOption *opt in dependencies) {
        CLKHardParameterAssert((opt.type == CLKOptionTypeParameter), @"dependencies must be parameter options -- switch options cannot be required");
    }
    
    self = [super init];
    if (self != nil) {
        _type = type;
        _name = [name copy];
        _flag = [flag copy];
        _required = required;
        _transformer = [transformer retain];
        _dependencies = [dependencies copy];
    }
    
    return self;
}

- (void)dealloc
{
    [_dependencies release];
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

- (id)copyWithZone:(__unused NSZone *)zone
{
    // CLKOption is immutable
    return [self retain];
}

#pragma mark -

- (NSString *)manifestKey
{
    return _name;
}

@end
