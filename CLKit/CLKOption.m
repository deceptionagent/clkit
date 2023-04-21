//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import "CLKOption_Private.h"

NSString *CLKStringForOptionType(CLKOptionType type)
{
    switch (type) {
        case CLKOptionTypeSwitch:
            return @"switch";
        
        case CLKOptionTypeParameter:
            return @"parameter";
    }
}

@implementation CLKOption
{
    CLKOptionType _type;
    NSString *_name;
    NSString *_flag;
    BOOL _required;
    BOOL _recurrent;
    BOOL _standalone;
    CLKArgumentTransformer *_transformer;
    NSArray<CLKArgumentManifestConstraint *> *_constraints;
}

@synthesize type = _type;
@synthesize name = _name;
@synthesize flag = _flag;
@synthesize required = _required;
@synthesize recurrent = _recurrent;
@synthesize standalone = _standalone;
@synthesize transformer = _transformer;
@synthesize constraints = _constraints;

#pragma mark -
#pragma mark Switch Options

+ (instancetype)optionWithName:(NSString *)name flag:(NSString *)flag
{
    return [[self alloc] _initWithType:CLKOptionTypeSwitch name:name flag:flag required:NO recurrent:YES standalone:NO transformer:nil];
}

+ (instancetype)standaloneOptionWithName:(NSString *)name flag:(nullable NSString *)flag
{
    return [[self alloc] _initWithType:CLKOptionTypeSwitch name:name flag:flag required:NO recurrent:YES standalone:YES transformer:nil];
}

#pragma mark -
#pragma mark Parameter Options

+ (instancetype)parameterOptionWithName:(NSString *)name flag:(NSString *)flag
{
    return [[self alloc] _initWithType:CLKOptionTypeParameter name:name flag:flag required:NO recurrent:NO standalone:NO transformer:nil];
}

+ (instancetype)requiredParameterOptionWithName:(NSString *)name flag:(NSString *)flag
{
    return [[self alloc] _initWithType:CLKOptionTypeParameter name:name flag:flag required:YES recurrent:NO standalone:NO transformer:nil];
}

+ (instancetype)parameterOptionWithName:(NSString *)name flag:(NSString *)flag transformer:(CLKArgumentTransformer *)transformer
{
    return [[self alloc] _initWithType:CLKOptionTypeParameter name:name flag:flag required:NO recurrent:NO standalone:NO transformer:transformer];
}

+ (instancetype)parameterOptionWithName:(NSString *)name
                                   flag:(nullable NSString *)flag
                               required:(BOOL)required
                              recurrent:(BOOL)recurrent
                            transformer:(nullable CLKArgumentTransformer *)transformer
{
    return [[self alloc] _initWithType:CLKOptionTypeParameter name:name flag:flag required:required recurrent:recurrent standalone:NO transformer:transformer];
}

+ (instancetype)standaloneParameterOptionWithName:(NSString *)name flag:(nullable NSString *)flag
{
    return [[self alloc] _initWithType:CLKOptionTypeParameter name:name flag:flag required:NO recurrent:NO standalone:YES transformer:nil];
}

+ (instancetype)standaloneParameterOptionWithName:(NSString *)name flag:(nullable NSString *)flag recurrent:(BOOL)recurrent transformer:(nullable CLKArgumentTransformer *)transformer
{
    return [[self alloc] _initWithType:CLKOptionTypeParameter name:name flag:flag required:NO recurrent:recurrent standalone:YES transformer:transformer];
}

#pragma mark -

- (instancetype)_initWithType:(CLKOptionType)type
                         name:(NSString *)name
                         flag:(NSString *)flag
                     required:(BOOL)required
                    recurrent:(BOOL)recurrent
                   standalone:(BOOL)standalone
                  transformer:(CLKArgumentTransformer *)transformer
{
    CLKParameterAssert(!(type == CLKOptionTypeSwitch && required), @"switch options cannot be required");
    CLKParameterAssert(!(type == CLKOptionTypeSwitch && transformer != nil), @"switch options do not support argument transformers");
    CLKParameterAssert(!(standalone && required), @"standalone options cannot be required");
    
    [[self class] _validateOptionName:name flag:flag];
    
    self = [super init];
    if (self != nil) {
        _type = type;
        _name = [name copy];
        _flag = [flag copy];
        _required = required;
        _recurrent = recurrent;
        _standalone = standalone;
        _transformer = transformer;
        [self _initConstraints];
    }
    
    return self;
}

- (void)_initConstraints
{
    NSMutableArray<CLKArgumentManifestConstraint *> *constraints = [[NSMutableArray alloc] init];
    
    if (_required) {
        CLKArgumentManifestConstraint *constraint = [[CLKArgumentManifestConstraint alloc] initWithType:CLKConstraintTypeRequired
                                                                                          bandedOptions:nil
                                                                                      significantOption:self.name
                                                                                      predicatingOption:nil];
        
        [constraints addObject:constraint];
    }
    
    if (!_recurrent) {
        CLKArgumentManifestConstraint *constraint = [[CLKArgumentManifestConstraint alloc] initWithType:CLKConstraintTypeOccurrencesLimited
                                                                                          bandedOptions:nil
                                                                                      significantOption:self.name
                                                                                      predicatingOption:nil];
        
        [constraints addObject:constraint];
    }
    
    if (_standalone) {
        CLKArgumentManifestConstraint *constraint = [[CLKArgumentManifestConstraint alloc] initWithType:CLKConstraintTypeStandalone
                                                                                          bandedOptions:nil
                                                                                      significantOption:self.name
                                                                                      predicatingOption:nil];
        
        [constraints addObject:constraint];
    }
    
    _constraints = constraints;
}

- (id)copyWithZone:(__unused NSZone *)zone
{
    // CLKOption is immutable
    return self;
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
    NSString * const fmt = @"%@ { --%@ | -%@ | %@ }";
    return [NSString stringWithFormat:fmt, super.description, _name, _flag, attrDesc];
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
    
    if ((_flag != nil) != (option.flag != nil)) {
        return NO;
    }
    
    BOOL compareFlags = (_flag != nil && option.flag != nil);
    if (compareFlags && ![_flag isEqualToString:option.flag]) {
        return NO;
    }
    
    return YES;
}

#pragma mark -

+ (void)_validateOptionName:(NSString *)name flag:(NSString *)flag
{
    CLKHardParameterAssert(name.length > 0, @"options must have names");
    CLKHardParameterAssert(![name hasPrefix:@"-"], @"option names should not begin with -- or -");
    NSRange r = [name rangeOfCharacterFromSet:NSCharacterSet.clk_optionNameIllegalCharacterSet options:NSLiteralSearch];
    BOOL nameIsLegal = (r.location == NSNotFound);
    CLKHardParameterAssert(nameIsLegal, @"illegal character in option name '%@': '%C'", name, [name characterAtIndex:r.location]);
    
    CLKHardParameterAssert((flag == nil || flag.length == 1), @"option flags must be single characters");
    CLKHardParameterAssert(![NSCharacterSet.clk_optionFlagIllegalCharacterSet characterIsMember:[flag characterAtIndex:0]], @"illegal option flag: '%@'", flag);
}

@end
