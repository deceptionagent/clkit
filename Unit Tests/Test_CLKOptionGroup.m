//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CLKArgumentManifestConstraint.h"
#import "CLKOption.h"
#import "CLKOptionGroup.h"
#import "CLKOptionGroup_Private.h"


@interface Test_CLKOptionGroup : XCTestCase

@end

@implementation Test_CLKOptionGroup

- (void)testRequired
{
    CLKOptionGroup *group = [CLKOptionGroup requiredGroupForOptionsNamed:@[ @"flarn", @"barf" ]];
    NSArray<CLKArgumentManifestConstraint *> *expectedConstraints = @[
        [CLKArgumentManifestConstraint constraintRequiringRepresentationForOptions:@[ @"flarn", @"barf" ]]
    ];
    
    XCTAssertEqualObjects(group.constraints, expectedConstraints);
    XCTAssertEqualObjects(group.allOptions, (@[ @"flarn", @"barf" ]));
    
    XCTAssertThrows([CLKOptionGroup requiredGroupForOptionsNamed:@[]]);
}

- (void)testMutexed
{
    CLKOptionGroup *group = [CLKOptionGroup mutexedGroupForOptionsNamed:@[ @"flarn", @"barf", @"quone" ]];
    NSArray<CLKArgumentManifestConstraint *> *expectedConstraints = @[
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"flarn", @"barf", @"quone" ]]
    ];
    
    XCTAssertEqualObjects(group.constraints, expectedConstraints);
    XCTAssertEqualObjects(group.allOptions, (@[ @"flarn", @"barf", @"quone" ]));
    
    XCTAssertThrows([CLKOptionGroup mutexedGroupForOptionsNamed:@[]]);
}

- (void)testStandalone
{
    CLKOptionGroup *group = [CLKOptionGroup standaloneGroupForOptionNamed:@"flarn" allowing:@[]];
    NSArray *expectedConstraints = @[
        [CLKArgumentManifestConstraint constraintForStandaloneOption:@"flarn" allowingOptions:@[]]
    ];
    
    XCTAssertEqualObjects(group.constraints, expectedConstraints);
    XCTAssertEqualObjects(group.allOptions, @[ @"flarn" ]);
    
    group = [CLKOptionGroup standaloneGroupForOptionNamed:@"flarn" allowing:@[ @"barf" ]];
    expectedConstraints = @[
        [CLKArgumentManifestConstraint constraintForStandaloneOption:@"flarn" allowingOptions:@[ @"barf" ]]
    ];
    
    XCTAssertEqualObjects(group.constraints, expectedConstraints);
    XCTAssertEqualObjects(group.allOptions, (@[ @"flarn", @"barf" ]));
    
    group = [CLKOptionGroup standaloneGroupForOptionNamed:@"flarn" allowing:@[ @"barf", @"quone" ]];
    expectedConstraints = @[
        [CLKArgumentManifestConstraint constraintForStandaloneOption:@"flarn" allowingOptions:@[ @"barf", @"quone" ]]
    ];
    
    XCTAssertEqualObjects(group.constraints, expectedConstraints);
    XCTAssertEqualObjects(group.allOptions, (@[ @"flarn", @"barf", @"quone" ]));
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    XCTAssertThrows([CLKOptionGroup standaloneGroupForOptionNamed:nil allowing:@[ @"flarn" ]]);
#pragma clang diagnostic pop
}

- (void)testDependencies
{
    XCTFail(@"unimplemented");
}

@end
