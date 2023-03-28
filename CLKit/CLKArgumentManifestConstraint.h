//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(uint32_t, CLKConstraintType) {
    // bandedOptions     : unused
    // significantOption : an option that must be present in the manifest
    CLKConstraintTypeRequired = 0,
    
    // bandedOptions     : a set of options where at least one option in the set must be present in the manifest
    // significantOption : unused
    CLKConstraintTypeAnyRequired = 1,
    
    // bandedOptions     : a set of options mutexed against each other
    // significantOption : unused
    CLKConstraintTypeMutuallyExclusive = 2,
    
    // bandedOptions     : (optional) a whitelist of options that may occur when `significantOption` is present
    // significantOption : an option that is mutually exclusive with all other options except for its whitelist
    CLKConstraintTypeStandalone = 3,
    
    // bandedOptions     : unused
    // significantOption : an option that should only have one occurrence in the manifest
    CLKConstraintTypeOccurrencesLimited = 4
};

NS_ASSUME_NONNULL_BEGIN

@interface CLKArgumentManifestConstraint : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithType:(CLKConstraintType)type
               bandedOptions:(nullable NSOrderedSet<NSString *> *)bandedOptions
           significantOption:(nullable NSString *)significantOption
           predicatingOption:(nullable NSString *)predicatingOption NS_DESIGNATED_INITIALIZER;

@property (nonatomic, readonly) CLKConstraintType type;

// type-defined
@property (nullable, nonatomic, readonly) NSOrderedSet<NSString *> *bandedOptions;
@property (nullable, nonatomic, readonly) NSString *significantOption;

// if a predicating option is set, the receiver is only active when that option is present
@property (nullable, nonatomic, readonly) NSString *predicatingOption;

- (BOOL)isEqualToConstraint:(CLKArgumentManifestConstraint *)constraint;

@end

NS_ASSUME_NONNULL_END
