//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import "ConstraintValidationSpec.h"

#import "CLKArgumentManifestConstraint.h"


@implementation ConstraintValidationSpec
{
    NSArray<CLKArgumentManifestConstraint *> *_constraints;
    NSArray<CLKArgumentIssue *> *_issues;
}

@synthesize constraints = _constraints;
@synthesize issues = _issues;

+ (instancetype)specWithConstraints:(NSArray<CLKArgumentManifestConstraint *> *)constraints issues:(NSArray<CLKArgumentIssue *> *)issues
{
    return [[self alloc] initWithConstraints:constraints issues:issues];
}

- (instancetype)initWithConstraints:(NSArray<CLKArgumentManifestConstraint *> *)constraints issues:(NSArray<CLKArgumentIssue *> *)issues
{
    NSParameterAssert(constraints.count > 0);
    NSParameterAssert(issues == nil || issues.count > 0);
    
    self = [super init];
    if (self != nil) {
        _constraints = [constraints copy];
        _issues = [issues copy];
    }
    
    return self;
}

- (BOOL)shouldPass
{
    return (self.issues.count == 0);
}

@end
