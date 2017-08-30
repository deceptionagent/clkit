//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>


@class CLKConstraint;
@class CLKOption;
@class CLKOptionGroup;


@interface CLKConstraintTestCase : XCTestCase

- (void)verifyConstraint:(CLKConstraint *)constraint
                 options:(NSArray<CLKOption *> *)options
                  groups:(NSArray<CLKOptionGroup *> *)groups
                required:(BOOL)required
                 mutexed:(BOOL)mutexed;

@end
