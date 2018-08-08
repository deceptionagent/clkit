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
    NSArray<NSString *> *_dependencies;
    CLKArgumentTransformer *_transformer;
}

@synthesize type = _type;
@synthesize name = _name;
@synthesize flag = _flag;
@synthesize required = _required;
@synthesize recurrent = _recurrent;
@synthesize dependencies = _dependencies;
@synthesize transformer = _transformer;

#pragma mark -
#pragma mark Switch Options

+ (instancetype)optionWithName:(NSString *)name flag:(NSString *)flag
{
    return [[[self alloc] initWithType:CLKOptionTypeSwitch name:name flag:flag required:NO recurrent:YES dependencies:nil transformer:nil] autorelease];
}

+ (instancetype)optionWithName:(NSString *)name flag:(NSString *)flag dependencies:(NSArray<NSString *> *)dependencies
{
    return [[[self alloc] initWithType:CLKOptionTypeSwitch name:name flag:flag required:NO recurrent:YES dependencies:dependencies transformer:nil] autorelease];
}

#pragma mark -
#pragma mark Parameter Options

+ (instancetype)parameterOptionWithName:(NSString *)name flag:(NSString *)flag
{
    return [[[self alloc] initWithType:CLKOptionTypeParameter name:name flag:flag required:NO recurrent:NO dependencies:nil transformer:nil] autorelease];
}

+ (instancetype)parameterOptionWithName:(NSString *)name flag:(NSString *)flag required:(BOOL)required
{
    return [[[self alloc] initWithType:CLKOptionTypeParameter name:name flag:flag required:required recurrent:NO dependencies:nil transformer:nil] autorelease];
}

+ (instancetype)parameterOptionWithName:(NSString *)name flag:(NSString *)flag recurrent:(BOOL)recurrent
{
    return [[[self alloc] initWithType:CLKOptionTypeParameter name:name flag:flag required:NO recurrent:recurrent dependencies:nil transformer:nil] autorelease];
}

+ (instancetype)parameterOptionWithName:(NSString *)name flag:(nullable NSString *)flag dependencies:(nullable NSArray<NSString *> *)dependencies
{
    return [[[self alloc] initWithType:CLKOptionTypeParameter name:name flag:flag required:NO recurrent:NO dependencies:dependencies transformer:nil] autorelease];
}

+ (instancetype)parameterOptionWithName:(NSString *)name flag:(NSString *)flag transformer:(CLKArgumentTransformer *)transformer
{
    return [[[self alloc] initWithType:CLKOptionTypeParameter name:name flag:flag required:NO recurrent:NO dependencies:nil transformer:transformer] autorelease];
}

+ (instancetype)parameterOptionWithName:(NSString *)name
                                   flag:(nullable NSString *)flag
                               required:(BOOL)required
                              recurrent:(BOOL)recurrent
                           dependencies:(nullable NSArray<NSString *> *)dependencies
                            transformer:(nullable CLKArgumentTransformer *)transformer
{
    return [[[self alloc] initWithType:CLKOptionTypeParameter name:name flag:flag required:required recurrent:recurrent dependencies:dependencies transformer:transformer] autorelease];
}

#pragma mark -

- (instancetype)initWithType:(CLKOptionType)type
                        name:(NSString *)name
                        flag:(nullable NSString *)flag
                    required:(BOOL)required
                   recurrent:(BOOL)recurrent
                dependencies:(nullable NSArray<NSString *> *)dependencies
                 transformer:(nullable CLKArgumentTransformer *)transformer
{
    CLKHardParameterAssert(!(type == CLKOptionTypeSwitch && required), @"switch options cannot be required");
    CLKHardParameterAssert(!(type == CLKOptionTypeSwitch && transformer != nil), @"switch options do not support argument transformers");
    CLKHardParameterAssert(![name hasPrefix:@"-"], @"option names should not begin with -- or -");
    CLKHardParameterAssert(![flag hasPrefix:@"-"], @"option flags should not begin with -- or -");
    CLKHardParameterAssert(name.length > 0);
    CLKHardParameterAssert(flag == nil || flag.length == 1);
    
    for (NSString *dependency in dependencies) {
        CLKHardParameterAssert(![dependency isEqualToString:name], @"options cannot list themselves as dependencies");
    }
    
    NSUInteger uniqueDependencyCount = [NSSet setWithArray:dependencies].count;
    CLKHardParameterAssert(uniqueDependencyCount == dependencies.count, @"option dependency lists cannot contain duplicate references");
    
    self = [super init];
    if (self != nil) {
        _type = type;
        _name = [name copy];
        _flag = [flag copy];
        _required = required;
        _recurrent = recurrent;
        _dependencies = [dependencies copy];
        _transformer = [transformer retain];
    }
    
    return self;
}

- (void)dealloc
{
    [_transformer release];
    [_dependencies release];
    [_flag release];
    [_name release];
    [super dealloc];
}

- (id)copyWithZone:(__unused NSZone *)zone
{
    // CLKOption is immutable
    return [self retain];
}

- (NSString *)description
{
    NSMutableArray<NSString *> *attrs = [NSMutableArray array];
    [attrs addObject:CLKStringForOptionType(_type)];
    
    if (_required) {
        [attrs addObject:@"required"];
    }
    
    if (_recurrent) {
        [attrs addObject:@"recurrent"];
    }
    
    NSString *attrDesc = [attrs componentsJoinedByString:@", "];
    NSString *dependenciesDesc = [_dependencies componentsJoinedByString:@", "];
    NSString * const fmt = @"%@ { --%@ | -%@ | %@ | dependencies: %@ }";
    return [NSString stringWithFormat:fmt, super.description, _name, _flag, attrDesc, dependenciesDesc];
}

- (NSUInteger)hash
{
    return _name.hash ^ _flag.hash;
}

- (BOOL)isEqual:(id)obj
{
    if (obj == self) {
        return YES;
    }
    
    if (![obj isKindOfClass:[CLKOption class]]) {
        return NO;
    }
    
    return [self isEqualToOption:(CLKOption *)obj];
}

- (BOOL)isEqualToOption:(CLKOption *)option
{
    if (_type != option.type
        || _required != option.required
        || _recurrent != option.recurrent
        || ![_name isEqualToString:option.name]) // name can never be nil
    {
        return NO;
    }
    
    if (_flag != nil || option.flag != nil) {
        if (![_flag isEqualToString:option.flag]) {
            return NO;
        }
    }
    
    if (_dependencies != nil || option.dependencies != nil) {
        if (![_dependencies isEqualToArray:option.dependencies]) {
            return NO;
        }
    }

    return YES;
}

#pragma mark -

- (NSArray<CLKArgumentManifestConstraint *> *)constraints
{
    NSMutableArray<CLKArgumentManifestConstraint *> *constraints = [NSMutableArray array];
    
    if (_required) {
        CLKArgumentManifestConstraint *constraint = [CLKArgumentManifestConstraint constraintForRequiredOption:self.name];
        [constraints addObject:constraint];
    }
    
    if (!_recurrent) {
        CLKArgumentManifestConstraint *constraint = [CLKArgumentManifestConstraint constraintLimitingOccurrencesForOption:self.name];
        [constraints addObject:constraint];
    }
    
    for (NSString *dependency in _dependencies) {
        CLKArgumentManifestConstraint *constraint = [CLKArgumentManifestConstraint constraintForConditionallyRequiredOption:dependency associatedOption:self.name];
        [constraints addObject:constraint];
    }
    
    return constraints;
}

@end
