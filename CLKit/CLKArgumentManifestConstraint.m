//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import "CLKArgumentManifestConstraint.h"


@interface CLKArgumentManifestConstraint ()

- (nonnull instancetype)initWithType:(CLKConstraintType)type
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
    return [[[self alloc] initWithType:CLKConstraintTypeRequired option:option associatedOption:nil linkedOptions:nil] autorelease];
}

+ (instancetype)constraintForConditionallyRequiredOption:(NSString *)option associatedOption:(NSString *)associatedOption
{
    NSParameterAssert(option != nil);
    NSParameterAssert(associatedOption != nil);
    return [[[self alloc] initWithType:CLKConstraintTypeConditionallyRequired option:option associatedOption:associatedOption linkedOptions:nil] autorelease];
}

+ (instancetype)constraintRequiringRepresentativeForOptions:(NSArray<NSString *> *)options
{
    NSParameterAssert(options.count > 1);
    return [[[self alloc] initWithType:CLKConstraintTypeRepresentativeRequired option:nil associatedOption:nil linkedOptions:options] autorelease];
}

+ (instancetype)constraintForMutuallyExclusiveOptions:(NSArray<NSString *> *)options
{
    NSParameterAssert(options.count > 1);
    return [[[self alloc] initWithType:CLKConstraintTypeMutuallyExclusive option:nil associatedOption:nil linkedOptions:options] autorelease];
}

+ (instancetype)constraintRestrictingOccurrencesForOption:(NSString *)option
{
    NSParameterAssert(option != nil);
    return [[[self alloc] initWithType:CLKConstraintTypeOccurrencesRestricted option:option associatedOption:nil linkedOptions:nil] autorelease];
}

- (instancetype)initWithType:(CLKConstraintType)type option:(NSString *)option associatedOption:(NSString *)associatedOption linkedOptions:(NSArray<NSString *> *)linkedOptions
{
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

#warning implement -description

- (BOOL)isEqual:(id)obj
{
    if (self == obj) {
        return YES;
    }
    
    if (![obj isKindOfClass:[self class]]) {
        return NO;
    }
    
    CLKArgumentManifestConstraint *constraint = obj;
    if (_type != constraint.type) {
        return NO;
    }
    
    if (!(_option == nil && constraint.option == nil)) {
        if (![_option isEqualToString:constraint.option]) {
            return NO;
        }
    }
    
    if (!(_associatedOption == nil && constraint.associatedOption == nil)) {
        if (![_associatedOption isEqualToString:constraint.associatedOption]) {
            return NO;
        }
    }
    
    if (!(_linkedOptions == nil && constraint.linkedOptions == nil)) {
        if (![_linkedOptions isEqual:constraint.linkedOptions]) {
            return NO;
        }
    }
    
    return YES;
}

@end
