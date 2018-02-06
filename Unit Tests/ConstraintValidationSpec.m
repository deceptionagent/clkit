//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import "ConstraintValidationSpec.h"

#import "CLKArgumentManifestConstraint.h"


@implementation ConstraintValidationSpec
{
    NSArray<CLKArgumentManifestConstraint *> *_constraints;
    NSArray<NSError *> *_errors;
}

+ (instancetype)specWithConstraints:(NSArray<CLKArgumentManifestConstraint *> *)constraints errors:(NSArray<NSError *> *)errors
{
    return [[[self alloc] initWithConstraints:constraints errors:errors] autorelease];
}

- (instancetype)initWithConstraints:(NSArray<CLKArgumentManifestConstraint *> *)constraints errors:(NSArray<NSError *> *)errors
{
    NSParameterAssert(constraints.count > 0);
    NSParameterAssert(errors == nil || errors.count > 0);
    
    self = [super init];
    if (self != nil) {
        _constraints = [constraints copy];
        _errors = [errors copy];
    }
    
    return self;
}

- (void)dealloc
{
    [_errors release];
    [_constraints release];
    [super dealloc];
}

- (BOOL)shouldPass
{
    return (self.errors.count == 0);
}

@end
