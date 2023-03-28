//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import "CLKArgumentManifestConstraint.h"

NS_ASSUME_NONNULL_BEGIN

static NSString *CLKStringForConstraintType(CLKConstraintType type);

NS_ASSUME_NONNULL_END

static NSString *CLKStringForConstraintType(CLKConstraintType type)
{
    switch (type) {
        case CLKConstraintTypeRequired:
            return @"required";
        
        case CLKConstraintTypeAnyRequired:
            return @"any-required";
        
        case CLKConstraintTypeMutuallyExclusive:
            return @"mutex";
        
        case CLKConstraintTypeStandalone:
            return @"standalone";
        
        case CLKConstraintTypeOccurrencesLimited:
            return @"limit";
    }
}

@implementation CLKArgumentManifestConstraint
{
    CLKConstraintType _type;
    NSOrderedSet<NSString *> *_bandedOptions;
    NSString *_significantOption;
    NSString *_predicatingOption;
}

@synthesize type = _type;
@synthesize bandedOptions = _bandedOptions;
@synthesize significantOption = _significantOption;
@synthesize predicatingOption = _predicatingOption;

- (instancetype)initWithType:(CLKConstraintType)type
               bandedOptions:(NSOrderedSet<NSString *> *)bandedOptions
           significantOption:(NSString *)significantOption
           predicatingOption:(NSString *)predicatingOption
{
    self = [super init];
    if (self != nil) {
        _type = type;
        _bandedOptions = [bandedOptions copy];
        _significantOption = [significantOption copy];
        _predicatingOption = [predicatingOption copy];
    }
    
    return self;
}

- (NSString *)description
{
    NSString *fmt = @"%@ { %@ | banded: %@ | significant: %@ | predicating: %@ }";
    NSString *bandDesc = (_bandedOptions != nil ? [_bandedOptions.array componentsJoinedByString:@", "] : @"(nil)");
    NSString *signiDesc = (_significantOption != nil ? _significantOption : @"(nil)");
    NSString *predDesc = (_predicatingOption != nil ? _predicatingOption : @"(nil)");
    return [NSString stringWithFormat:fmt, super.description, CLKStringForConstraintType(_type), bandDesc, signiDesc, predDesc];
}

- (NSUInteger)hash
{
    return (_bandedOptions.hash ^ _significantOption.hash ^ _predicatingOption.hash + _type);
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
    
    NSOrderedSet *bandedOptions = constraint.bandedOptions;
    NSString *significantOption = constraint.significantOption;
    NSString *predicatingOption = constraint.predicatingOption;
    
    if ((_bandedOptions != nil) != (bandedOptions != nil)) {
        return NO;
    }
    
    if ((_significantOption != nil) != (significantOption != nil)) {
        return NO;
    }
    
    if ((_predicatingOption != nil) != (predicatingOption != nil)) {
        return NO;
    }
    
    BOOL compareBandedOptions = (_bandedOptions != nil && bandedOptions != nil);
    BOOL compareSignificantOption = (_significantOption != nil && predicatingOption != nil);
    BOOL comparePredicatingOption = (_predicatingOption != nil && predicatingOption != nil);
    
    if (compareBandedOptions && ![_bandedOptions isEqualToOrderedSet:bandedOptions]) {
        return NO;
    }
    
    if (compareSignificantOption && ![_significantOption isEqualToString:significantOption]) {
        return NO;
    }
    
    if (comparePredicatingOption && ![_predicatingOption isEqualToString:predicatingOption]) {
        return NO;
    }
    
    return YES;
}

@end
