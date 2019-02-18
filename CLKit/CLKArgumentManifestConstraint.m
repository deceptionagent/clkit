//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import "CLKArgumentManifestConstraint.h"


static NSString *CLKStringForConstraintType(CLKConstraintType type)
{
    switch (type) {
        case CLKConstraintTypeRequired:
            return @"required";
        case CLKConstraintTypeConditionallyRequired:
            return @"conditionally required";
        case CLKConstraintTypeRepresentationRequired:
            return @"representation required";
        case CLKConstraintTypeMutuallyExclusive:
            return @"mutually exclusive";
        case CLKConstraintTypeStandalone:
            return @"standalone";
        case CLKConstraintTypeOccurrencesLimited:
            return @"occurrences limited";
    }
}

NS_ASSUME_NONNULL_BEGIN

@interface CLKArgumentManifestConstraint ()

- (instancetype)_initWithType:(CLKConstraintType)type options:(NSOrderedSet<NSString *> *)options auxOptions:(nullable NSOrderedSet<NSString *> *)auxOptions NS_DESIGNATED_INITIALIZER;

#if !NS_BLOCK_ASSERTIONS
+ (void)_validateConstraintType:(CLKConstraintType)type options:(NSOrderedSet<NSString *> *)options auxOptions:(nullable NSOrderedSet<NSString *> *)auxOptions;
#endif

@end

NS_ASSUME_NONNULL_END

@implementation CLKArgumentManifestConstraint
{
    CLKConstraintType _type;
    NSOrderedSet<NSString *> *_options;
    NSOrderedSet<NSString *> *_auxOptions;
}

@synthesize type = _type;
@synthesize options = _options;
@synthesize auxOptions = _auxOptions;

+ (instancetype)constraintForRequiredOption:(NSString *)option
{
    return [[self alloc] _initWithType:CLKConstraintTypeRequired options:[NSOrderedSet orderedSetWithObject:option] auxOptions:nil];
}

+ (instancetype)constraintForConditionallyRequiredOption:(NSString *)option causalOption:(NSString *)causalOption
{
    NSOrderedSet *options = [NSOrderedSet orderedSetWithObject:option];
    NSOrderedSet *auxOptions = [NSOrderedSet orderedSetWithObject:causalOption];
    return [[self alloc] _initWithType:CLKConstraintTypeConditionallyRequired options:options auxOptions:auxOptions];
}

+ (instancetype)constraintRequiringRepresentationForOptions:(NSArray<NSString *> *)options
{
    return [[self alloc] _initWithType:CLKConstraintTypeRepresentationRequired options:[NSOrderedSet orderedSetWithArray:options] auxOptions:nil];
}

+ (instancetype)constraintForMutuallyExclusiveOptions:(NSArray<NSString *> *)options
{
    return [[self alloc] _initWithType:CLKConstraintTypeMutuallyExclusive options:[NSOrderedSet orderedSetWithArray:options] auxOptions:nil];
}

+ (instancetype)constraintForStandaloneOption:(NSString *)option allowingOptions:(NSArray<NSString *> *)whitelistedOptions
{
    NSOrderedSet *options = [NSOrderedSet orderedSetWithObject:option];
    NSOrderedSet *auxOptions = (whitelistedOptions != nil ? [NSOrderedSet orderedSetWithArray:whitelistedOptions] : nil);
    return [[self alloc] _initWithType:CLKConstraintTypeStandalone options:options auxOptions:auxOptions];
}

+ (instancetype)constraintLimitingOccurrencesForOption:(NSString *)option
{
    return [[self alloc] _initWithType:CLKConstraintTypeOccurrencesLimited options:[NSOrderedSet orderedSetWithObject:option] auxOptions:nil];
}

- (instancetype)_initWithType:(CLKConstraintType)type options:(NSOrderedSet<NSString *> *)options auxOptions:(NSOrderedSet<NSString *> *)auxOptions
{
#if !NS_BLOCK_ASSERTIONS
    [[self class] _validateConstraintType:type options:options auxOptions:auxOptions];
#endif
    
    self = [super init];
    if (self != nil) {
        _type = type;
        _options = [options copy];
        _auxOptions = [auxOptions copy];
    }
    
    return self;
}

// since all this method does is use Foundation asserts that get compiled out in debug,
// conditionally compile the whole thing away to avoid unused parameter warnings in
// build configurations where NS_BLOCK_ASSERTIONS is enabled.
#if !NS_BLOCK_ASSERTIONS

+ (void)_validateConstraintType:(CLKConstraintType)type options:(NSOrderedSet<NSString *> *)options auxOptions:(NSOrderedSet<NSString *> *)auxOptions
{
    switch (type) {
        case CLKConstraintTypeRequired:
            NSParameterAssert(options.count == 1 && auxOptions == nil);
            break;
        case CLKConstraintTypeConditionallyRequired:
            NSParameterAssert(options.count == 1 && auxOptions.count == 1);
            break;
        case CLKConstraintTypeRepresentationRequired:
            NSParameterAssert(options.count > 0 && auxOptions == nil);
            break;
        case CLKConstraintTypeMutuallyExclusive:
            NSParameterAssert(options.count > 0 && auxOptions == nil);
            break;
        case CLKConstraintTypeStandalone:
            NSParameterAssert(options.count == 1);
            break;
        case CLKConstraintTypeOccurrencesLimited:
            NSParameterAssert(options.count == 1 && auxOptions == nil);
            break;
    }
}

#endif

- (NSString *)description
{
    NSString * const fmt = @"%@ { %@ | options: [ %@ ] | auxOptions: [ %@ ] }";
    NSString *optionsDesc = [_options.array componentsJoinedByString:@", "];
    NSString *auxOptionsDesc = [_auxOptions.array componentsJoinedByString:@", "];
    return [NSString stringWithFormat:fmt, super.description, CLKStringForConstraintType(_type), optionsDesc, auxOptionsDesc];
}

- (NSUInteger)hash
{
    return (_options.hash ^ _auxOptions.hash + _type);
}

- (BOOL)isEqual:(id)obj
{
    if (self == obj) {
        return YES;
    }
    
    if (![obj isKindOfClass:[CLKArgumentManifestConstraint class]]) {
        return NO;
    }
    
    return [self isEqualToConstraint:(CLKArgumentManifestConstraint *)obj];
}

- (BOOL)isEqualToConstraint:(CLKArgumentManifestConstraint *)constraint
{
    if (_type != constraint.type) {
        return NO;
    }
    
    if (![_options isEqualToOrderedSet:constraint.options]) {
        return NO;
    }
    
    if ((_auxOptions != nil) != (constraint.auxOptions != nil)) {
        return NO;
    }
    
    BOOL compareAuxOptions = (_auxOptions != nil && constraint.auxOptions != nil);
    if (compareAuxOptions && ![_auxOptions isEqualToOrderedSet:constraint.auxOptions]) {
        return NO;
    }
    
    return YES;
}

@end
