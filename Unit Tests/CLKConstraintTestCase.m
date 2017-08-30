//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import "CLKConstraintTestCase.h"

#import "CLKConstraint.h"


@implementation CLKConstraintTestCase

- (void)verifyConstraint:(CLKConstraint *)constraint
                 options:(NSArray<CLKOption *> *)options
                  groups:(NSArray<CLKOptionGroup *> *)groups
                required:(BOOL)required
                 mutexed:(BOOL)mutexed
 {
    XCTAssertNotNil(constraint);
    XCTAssertEqual(constraint.required, required);
    XCTAssertEqual(constraint.mutexed, mutexed);
    XCTAssertEqualObjects(constraint.options, options);
    XCTAssertEqualObjects(constraint.groups, groups);
}

@end
