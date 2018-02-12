//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(uint32_t, CLKConstraintType) {
    CLKConstraintTypeRequired = 0,
    CLKConstraintTypeConditionallyRequired = 1,
    CLKConstraintTypeRepresentativeRequired = 2,
    CLKConstraintTypeMutuallyExclusive = 3,
    CLKConstraintTypeOccurrencesRestricted = 4
};


NS_ASSUME_NONNULL_BEGIN

@interface CLKArgumentManifestConstraint : NSObject

+ (instancetype)constraintForRequiredOption:(NSString *)option;
+ (instancetype)constraintForConditionallyRequiredOption:(NSString *)option associatedOption:(NSString *)associatedOption;
+ (instancetype)constraintRequiringRepresentativeForOptions:(NSArray<NSString *> *)options;
+ (instancetype)constraintForMutuallyExclusiveOptions:(NSArray<NSString *> *)options;
+ (instancetype)constraintRestrictingOccurrencesForOption:(NSString *)option;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@property (readonly) CLKConstraintType type;
@property (nullable, readonly) NSString *option;
@property (nullable, readonly) NSString *associatedOption;
@property (nullable, readonly) NSArray<NSString *> *linkedOptions;

- (BOOL)isEqualToConstraint:(CLKArgumentManifestConstraint *)constraint;

@end

NS_ASSUME_NONNULL_END
