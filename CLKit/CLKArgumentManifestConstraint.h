//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(uint32_t, CLKConstraintType) {
    CLKConstraintTypeRequired = 0,
    CLKConstraintTypeConditionallyRequired = 1,
    CLKConstraintTypeRepresentativeRequired = 2,
    CLKConstraintTypeMutuallyExclusive = 3,
    CLKConstraintTypeStandalone = 4,
    CLKConstraintTypeOccurrencesLimited = 5,
};

NS_ASSUME_NONNULL_BEGIN

@interface CLKArgumentManifestConstraint : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)constraintForRequiredOption:(NSString *)option;
+ (instancetype)constraintForConditionallyRequiredOption:(NSString *)option associatedOption:(NSString *)associatedOption;
+ (instancetype)constraintRequiringRepresentativeForOptions:(NSArray<NSString *> *)options;
+ (instancetype)constraintForMutuallyExclusiveOptions:(NSArray<NSString *> *)options;
+ (instancetype)constraintForStandaloneOption:(NSString *)option allowingOptions:(nullable NSArray<NSString *> *)whitelistedOptions;
+ (instancetype)constraintLimitingOccurrencesForOption:(NSString *)option;

@property (readonly) CLKConstraintType type;
@property (nullable, readonly) NSString *option;
@property (nullable, readonly) NSString *associatedOption;
@property (nullable, readonly) NSArray<NSString *> *linkedOptions;

- (BOOL)isEqualToConstraint:(CLKArgumentManifestConstraint *)constraint;

@end

NS_ASSUME_NONNULL_END
