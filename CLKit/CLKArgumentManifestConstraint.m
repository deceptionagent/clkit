//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import "CLKArgumentManifestConstraint.h"


NSString *CLKStringForConstraintType(CLKConstraintType type)
{
    switch (type) {
        case CLKConstraintTypeRequired:
            return @"required";
        case CLKConstraintTypeConditionallyRequired:
            return @"conditionally required";
        case CLKConstraintTypeRepresentativeRequired:
            return @"representative required";
        case CLKConstraintTypeMutuallyExclusive:
            return @"mutually exclusive";
        case CLKConstraintTypeOccurrencesLimited:
            return @"occurrences limited";
    }
    
    NSCAssert(YES, @"unknown constraint type: %d", type);
    return @"unknown";
}

@interface CLKArgumentManifestConstraint ()

- (nonnull instancetype)_initWithType:(CLKConstraintType)type
                              option:(nullable NSString *)option
                    associatedOption:(nullable NSString *)associatedOption
                       linkedOptions:(nullable NSArray<NSString *> *)linkedOptions NS_DESIGNATED_INITIALIZER;

@end

@implementation CLKArgumentManifestConstraint
{
    CLKConstraintType _type;
    NSString *_option;
    NSString *_associatedOption;
    NSArray<NSString *> *_linkedOptions;
}

@synthesize type = _type;
@synthesize option = _option;
@synthesize associatedOption = _associatedOption;
@synthesize linkedOptions = _linkedOptions;

+ (instancetype)constraintForRequiredOption:(NSString *)option
{
    NSParameterAssert(option != nil);
    return [[[self alloc] _initWithType:CLKConstraintTypeRequired option:option associatedOption:nil linkedOptions:nil] autorelease];
}

+ (instancetype)constraintForConditionallyRequiredOption:(NSString *)option associatedOption:(NSString *)associatedOption
{
    NSParameterAssert(option != nil);
    NSParameterAssert(associatedOption != nil);
    return [[[self alloc] _initWithType:CLKConstraintTypeConditionallyRequired option:option associatedOption:associatedOption linkedOptions:nil] autorelease];
}

+ (instancetype)constraintRequiringRepresentativeForOptions:(NSArray<NSString *> *)options
{
    NSParameterAssert(options.count > 1);
    return [[[self alloc] _initWithType:CLKConstraintTypeRepresentativeRequired option:nil associatedOption:nil linkedOptions:options] autorelease];
}

+ (instancetype)constraintForMutuallyExclusiveOptions:(NSArray<NSString *> *)options
{
    NSParameterAssert(options.count > 1);
    return [[[self alloc] _initWithType:CLKConstraintTypeMutuallyExclusive option:nil associatedOption:nil linkedOptions:options] autorelease];
}

+ (instancetype)constraintLimitingOccurrencesForOption:(NSString *)option
{
    NSParameterAssert(option != nil);
    return [[[self alloc] _initWithType:CLKConstraintTypeOccurrencesLimited option:option associatedOption:nil linkedOptions:nil] autorelease];
}

- (instancetype)_initWithType:(CLKConstraintType)type option:(NSString *)option associatedOption:(NSString *)associatedOption linkedOptions:(NSArray<NSString *> *)linkedOptions
{
    NSParameterAssert(option != nil || linkedOptions != nil);
    
    self = [super init];
    if (self != nil) {
        _type = type;
        _option = [option copy];
        _associatedOption = [associatedOption copy];
        _linkedOptions = [linkedOptions copy];
    }
    
    return self;
}

- (void)dealloc
{
    [_linkedOptions release];
    [_associatedOption release];
    [_option release];
    [super dealloc];
}

- (NSString *)description
{
    NSString * const fmt = @"%@ { %@ | primary: %@ | associated: %@ | linked: [ %@ ] }";
    return [NSString stringWithFormat:fmt, super.description, CLKStringForConstraintType(_type), _option, _associatedOption, [_linkedOptions componentsJoinedByString:@", "]];
}

- (BOOL)isEqual:(id)obj
{
    if (self == obj) {
        return YES;
    }
    
    if (![obj isKindOfClass:[self class]]) {
        return NO;
    }
    
    return [self isEqualToConstraint:(CLKArgumentManifestConstraint *)obj];
}

- (BOOL)isEqualToConstraint:(CLKArgumentManifestConstraint *)constraint
{
    if (_type != constraint.type) {
        return NO;
    }
    
    if (_option != nil || constraint.option != nil) {
        if (![_option isEqualToString:constraint.option]) {
            return NO;
        }
    }
    
    if (_associatedOption != nil || constraint.associatedOption != nil) {
        if (![_associatedOption isEqualToString:constraint.associatedOption]) {
            return NO;
        }
    }
    
    if (_linkedOptions != nil || constraint.linkedOptions != nil) {
        if (![_linkedOptions isEqual:constraint.linkedOptions]) {
            return NO;
        }
    }
    
    return YES;
}

@end
