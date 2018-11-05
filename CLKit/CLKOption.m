//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import "CLKOption.h"
#import "CLKOption_Private.h"

#import "CLKArgumentManifestConstraint.h"
#import "CLKArgumentTransformer.h"
#import "CLKAssert.h"
#import "NSCharacterSet+CLKAdditions.h"
#import "NSString+CLKAdditions.h"


NSString *CLKStringForOptionType(CLKOptionType type)
{
    switch (type) {
        case CLKOptionTypeSwitch:
            return @"switch";
        case CLKOptionTypeParameter:
            return @"parameter";
    }
}

NS_ASSUME_NONNULL_BEGIN

@interface CLKOption ()

- (instancetype)_initWithType:(CLKOptionType)type
                         name:(NSString *)name
                         flag:(nullable NSString *)flag
                     required:(BOOL)required
                    recurrent:(BOOL)recurrent
                 dependencies:(nullable NSArray<NSString *> *)dependencies
                  transformer:(nullable CLKArgumentTransformer *)transformer;

- (instancetype)_initWithType:(CLKOptionType)type
                         name:(NSString *)name
                         flag:(nullable NSString *)flag
                     required:(BOOL)required
                    recurrent:(BOOL)recurrent
                   standalone:(BOOL)standalone
                 dependencies:(nullable NSArray<NSString *> *)dependencies
                  transformer:(nullable CLKArgumentTransformer *)transformer NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END

@implementation CLKOption
{
    CLKOptionType _type;
    NSString *_name;
    NSString *_flag;
    BOOL _required;
    BOOL _recurrent;
    BOOL _standalone;
    NSArray<NSString *> *_dependencies;
    CLKArgumentTransformer *_transformer;
}

@synthesize type = _type;
@synthesize name = _name;
@synthesize flag = _flag;
@synthesize required = _required;
@synthesize recurrent = _recurrent;
@synthesize standalone = _standalone;
@synthesize dependencies = _dependencies;
@synthesize transformer = _transformer;

#pragma mark -
#pragma mark Switch Options

+ (instancetype)optionWithName:(NSString *)name flag:(NSString *)flag
{
    return [[[self alloc] _initWithType:CLKOptionTypeSwitch name:name flag:flag required:NO recurrent:YES dependencies:nil transformer:nil] autorelease];
}

+ (instancetype)optionWithName:(NSString *)name flag:(NSString *)flag dependencies:(NSArray<NSString *> *)dependencies
{
    return [[[self alloc] _initWithType:CLKOptionTypeSwitch name:name flag:flag required:NO recurrent:YES dependencies:dependencies transformer:nil] autorelease];
}

+ (instancetype)standaloneOptionWithName:(NSString *)name flag:(nullable NSString *)flag
{
    return [[[self alloc] _initWithType:CLKOptionTypeSwitch name:name flag:flag required:NO recurrent:YES standalone:YES dependencies:nil transformer:nil] autorelease];
}

#pragma mark -
#pragma mark Parameter Options

+ (instancetype)parameterOptionWithName:(NSString *)name flag:(NSString *)flag
{
    return [[[self alloc] _initWithType:CLKOptionTypeParameter name:name flag:flag required:NO recurrent:NO dependencies:nil transformer:nil] autorelease];
}

+ (instancetype)requiredParameterOptionWithName:(NSString *)name flag:(NSString *)flag
{
    return [[[self alloc] _initWithType:CLKOptionTypeParameter name:name flag:flag required:YES recurrent:NO dependencies:nil transformer:nil] autorelease];
}

+ (instancetype)parameterOptionWithName:(NSString *)name
                                   flag:(nullable NSString *)flag
                               required:(BOOL)required
                              recurrent:(BOOL)recurrent
                           dependencies:(nullable NSArray<NSString *> *)dependencies
                            transformer:(nullable CLKArgumentTransformer *)transformer
{
    return [[[self alloc] _initWithType:CLKOptionTypeParameter name:name flag:flag required:required recurrent:recurrent dependencies:dependencies transformer:transformer] autorelease];
}

+ (instancetype)standaloneParameterOptionWithName:(NSString *)name flag:(nullable NSString *)flag
{
    return [[[self alloc] _initWithType:CLKOptionTypeParameter name:name flag:flag required:NO recurrent:NO standalone:YES dependencies:nil transformer:nil] autorelease];
}

+ (instancetype)standaloneParameterOptionWithName:(NSString *)name flag:(nullable NSString *)flag recurrent:(BOOL)recurrent transformer:(nullable CLKArgumentTransformer *)transformer
{
    return [[[self alloc] _initWithType:CLKOptionTypeParameter name:name flag:flag required:NO recurrent:recurrent standalone:YES dependencies:nil transformer:transformer] autorelease];
}

#pragma mark -

- (instancetype)_initWithType:(CLKOptionType)type
                         name:(NSString *)name
                         flag:(nullable NSString *)flag
                     required:(BOOL)required
                    recurrent:(BOOL)recurrent
                 dependencies:(nullable NSArray<NSString *> *)dependencies
                  transformer:(nullable CLKArgumentTransformer *)transformer
{
    return [self _initWithType:type name:name flag:flag required:required recurrent:recurrent standalone:NO dependencies:dependencies transformer:transformer];
}

- (instancetype)_initWithType:(CLKOptionType)type
                         name:(NSString *)name
                         flag:(nullable NSString *)flag
                     required:(BOOL)required
                    recurrent:(BOOL)recurrent
                   standalone:(BOOL)standalone
                 dependencies:(nullable NSArray<NSString *> *)dependencies
                  transformer:(nullable CLKArgumentTransformer *)transformer
{
    CLKHardParameterAssert(!(type == CLKOptionTypeSwitch && required), @"switch options cannot be required");
    CLKHardParameterAssert(!(type == CLKOptionTypeSwitch && transformer != nil), @"switch options do not support argument transformers");
    CLKHardParameterAssert(!(standalone && required), @"standalone options cannot be required");
    CLKHardParameterAssert(!(standalone && dependencies.count > 0), @"standalone options cannot have dependencies");
    CLKHardParameterAssert(name.length > 0, @"options must have names");
    CLKHardParameterAssert(![name hasPrefix:@"-"], @"option names should not begin with -- or -");
    CLKHardParameterAssert((flag == nil || flag.length == 1), @"option flags must be single characters");
    CLKHardParameterAssert(![flag isEqualToString:@"-"], @"'-' is not allowed as an option flag");
    CLKHardParameterAssert(![flag clk_containsCharacterFromSet:NSCharacterSet.clk_numericArgumentCharacterSet], @"'%@' is not allowed as an option flag", flag);
    CLKHardParameterAssert(![name clk_containsCharacterFromSet:NSCharacterSet.whitespaceAndNewlineCharacterSet], @"option names cannot contain whitespace characters");
    CLKHardParameterAssert(![flag clk_containsCharacterFromSet:NSCharacterSet.whitespaceAndNewlineCharacterSet], @"option flags cannot contain whitespace characters");
    
    for (NSString *dependency in dependencies) {
        CLKHardParameterAssert(![dependency isEqualToString:name], @"options cannot list themselves as dependencies");
    }
    
    NSUInteger uniqueDependencyCount = [NSSet setWithArray:dependencies].count;
    CLKHardParameterAssert((uniqueDependencyCount == dependencies.count), @"option dependency lists cannot contain duplicate references");
    
    self = [super init];
    if (self != nil) {
        _type = type;
        _name = [name copy];
        _flag = [flag copy];
        _required = required;
        _recurrent = recurrent;
        _standalone = standalone;
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
    
    if (_standalone) {
        [attrs addObject:@"standalone"];
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
        || _standalone != option.standalone
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
    
    if (_standalone) {
        CLKArgumentManifestConstraint *constraint = [CLKArgumentManifestConstraint constraintForStandaloneOption:self.name allowingOptions:nil];
        [constraints addObject:constraint];
    }
    
    for (NSString *dependency in _dependencies) {
        CLKArgumentManifestConstraint *constraint = [CLKArgumentManifestConstraint constraintForConditionallyRequiredOption:dependency associatedOption:self.name];
        [constraints addObject:constraint];
    }
    
    return constraints;
}

@end
