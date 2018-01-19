//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import "CLKOption.h"
#import "CLKOption_Private.h"

#import "CLKArgumentManifestConstraint.h"
#import "CLKArgumentTransformer.h"
#import "CLKAssert.h"


NSString *CLKStringForOptionType(CLKOptionType type)
{
    switch (type) {
        case CLKOptionTypeSwitch:
            return @"switch";
        case CLKOptionTypeParameter:
            return @"parameter";
    }
    
    NSCAssert(YES, @"unknown option type: %d", type);
    return @"unknown";
}


@implementation CLKOption
{
    CLKOptionType _type;
    NSString *_name;
    NSString *_flag;
    BOOL _required;
    BOOL _recurrent;
    CLKArgumentTransformer *_transformer;
    NSArray<CLKOption *> *_dependencies;
}

@synthesize type = _type;
@synthesize name = _name;
@synthesize flag = _flag;
@synthesize required = _required;
@synthesize recurrent = _recurrent;
@synthesize transformer = _transformer;
@synthesize dependencies = _dependencies;

#pragma mark -
#pragma mark Switch Options

+ (instancetype)optionWithName:(NSString *)name flag:(NSString *)flag
{
    return [[[self alloc] initWithType:CLKOptionTypeSwitch name:name flag:flag required:NO recurrent:YES transformer:nil dependencies:nil] autorelease];
}

+ (instancetype)optionWithName:(NSString *)name flag:(NSString *)flag dependencies:(NSArray<CLKOption *> *)dependencies
{
    return [[[self alloc] initWithType:CLKOptionTypeSwitch name:name flag:flag required:NO recurrent:YES transformer:nil dependencies:dependencies] autorelease];
}

#pragma mark -
#pragma mark Parameter Options

+ (instancetype)parameterOptionWithName:(NSString *)name flag:(NSString *)flag
{
    return [[[self alloc] initWithType:CLKOptionTypeParameter name:name flag:flag required:NO recurrent:NO transformer:nil dependencies:nil] autorelease];
}

+ (instancetype)parameterOptionWithName:(NSString *)name flag:(NSString *)flag required:(BOOL)required
{
    return [[[self alloc] initWithType:CLKOptionTypeParameter name:name flag:flag required:required recurrent:NO transformer:nil dependencies:nil] autorelease];
}

+ (instancetype)parameterOptionWithName:(NSString *)name flag:(NSString *)flag transformer:(CLKArgumentTransformer *)transformer
{
    return [[[self alloc] initWithType:CLKOptionTypeParameter name:name flag:flag required:NO recurrent:NO transformer:transformer dependencies:nil] autorelease];
}

+ (instancetype)parameterOptionWithName:(NSString *)name flag:(NSString *)flag required:(BOOL)required transformer:(CLKArgumentTransformer *)transformer
{
    return [[[self alloc] initWithType:CLKOptionTypeParameter name:name flag:flag required:required recurrent:NO transformer:transformer dependencies:nil] autorelease];
}

+ (instancetype)parameterOptionWithName:(NSString *)name flag:(nullable NSString *)flag required:(BOOL)required recurrent:(BOOL)recurrent transformer:(nullable CLKArgumentTransformer *)transformer dependencies:(nullable NSArray<CLKOption *> *)dependencies
{
    return [[[self alloc] initWithType:CLKOptionTypeParameter name:name flag:flag required:required recurrent:recurrent transformer:transformer dependencies:dependencies] autorelease];
}

#pragma mark -

- (instancetype)initWithType:(CLKOptionType)type name:(NSString *)name flag:(NSString *)flag required:(BOOL)required recurrent:(BOOL)recurrent transformer:(CLKArgumentTransformer *)transformer dependencies:(NSArray<CLKOption *> *)dependencies
{
    CLKHardParameterAssert(!(type == CLKOptionTypeSwitch && required), @"switch options cannot be required");
    CLKHardParameterAssert(!(type == CLKOptionTypeSwitch && transformer != nil), @"switch options do not support argument transformers");
    CLKHardParameterAssert(![name hasPrefix:@"-"], @"option names should not begin with -- or -");
    CLKHardParameterAssert(![flag hasPrefix:@"-"], @"option flags should not begin with -- or -");
    CLKHardParameterAssert(name.length > 0);
    CLKHardParameterAssert(flag == nil || flag.length == 1);
    
    for (CLKOption *opt in dependencies) {
        CLKHardParameterAssert((opt.type == CLKOptionTypeParameter), @"dependencies must be parameter options -- switch options cannot be required (option: '--%@' -> dependency: '--%@'", name, opt.name);
    }
    
    self = [super init];
    if (self != nil) {
        _type = type;
        _name = [name copy];
        _flag = [flag copy];
        _required = required;
        _recurrent = recurrent;
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
    NSMutableArray *attrs = [NSMutableArray array];
    [attrs addObject:CLKStringForOptionType(_type)];
    
    if (_required) {
        [attrs addObject:@"required"];
    }
    
    if (_recurrent) {
        [attrs addObject:@"recurrent"];
    }
    
    NSString *attrDesc = [attrs componentsJoinedByString:@", "];
    NSString * const fmt = @"%@ { --%@ | -%@ | %@ }";
    return [NSString stringWithFormat:fmt, super.description, _name, _flag, attrDesc];
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

- (NSArray<CLKArgumentManifestConstraint *> *)constraints
{
    NSMutableArray *constraints = [NSMutableArray array];
    
    if (_required) {
        CLKArgumentManifestConstraint *constraint = [CLKArgumentManifestConstraint constraintForRequiredOption:self.name];
        [constraints addObject:constraint];
    }
    
    if (!_recurrent) {
        CLKArgumentManifestConstraint *constraint = [CLKArgumentManifestConstraint constraintRestrictingOccurrencesForOption:self.name];
        [constraints addObject:constraint];
    }
    
    for (CLKOption *dependency in _dependencies) {
        CLKArgumentManifestConstraint *constraint = [CLKArgumentManifestConstraint constraintForConditionallyRequiredOption:dependency.name associatedOption:self.name];
        [constraints addObject:constraint];
    }
    
    return constraints;
}

@end
