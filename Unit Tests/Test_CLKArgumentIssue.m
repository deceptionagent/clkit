//
//  Copyright (c) 2020 Plastic Pulse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CLKArgumentIssue.h"
#import "NSError+CLKAdditions.h"

NS_ASSUME_NONNULL_BEGIN

@interface Test_CLKArgumentIssue : XCTestCase

- (NSError *)flarnError;
- (NSError *)barfError;
- (NSError *)quoneError;
- (NSError *)xyzzyError;

@end

NS_ASSUME_NONNULL_END

@implementation Test_CLKArgumentIssue

- (NSError *)flarnError
{
    return [NSError clk_POSIXErrorWithCode:1 description:@"flarn issue!"];
}

- (NSError *)barfError
{
    return [NSError clk_POSIXErrorWithCode:2 description:@"barf issue!"];
}

- (NSError *)quoneError
{
    return [NSError clk_CLKErrorWithCode:CLKErrorRequiredOptionNotProvided description:@"quone issue!"];
}

- (NSError *)xyzzyError
{
    return [NSError clk_CLKErrorWithCode:CLKErrorNoVerbSpecified description:@"xyzzy issue!"];
}

- (NSArray<CLKArgumentIssue *> *)uniqueIssues
{
    NSMutableArray<CLKArgumentIssue *> *issues = [NSMutableArray array];
    
    NSArray *errors = @[
        [self flarnError],
        [self barfError],
        [self quoneError],
        [self xyzzyError],
    ];
    
    NSArray *salientOptions = @[
        [NSNull null],
        @[ @"syn" ],
        @[ @"syn", @"ack" ]
    ];
    
    for (NSError *error in errors) {
        for (id options_ in salientOptions) {
            NSArray *options = (options_ == [NSNull null] ? nil : options_);
            CLKArgumentIssue *issue = [CLKArgumentIssue issueWithError:error salientOptions:options];
            [issues addObject:issue];
        };
    }
    
    return issues;
}

- (void)testInit
{
    CLKArgumentIssue *issue = [CLKArgumentIssue issueWithError:[self flarnError]];
    XCTAssertNotNil(issue);
    XCTAssertEqualObjects(issue.error, [self flarnError]);
    XCTAssertNil(issue.salientOptions);
    
    issue = [CLKArgumentIssue issueWithError:[self flarnError] salientOption:nil];
    XCTAssertNotNil(issue);
    XCTAssertEqualObjects(issue.error, [self flarnError]);
    XCTAssertNil(issue.salientOptions);
    
    issue = [CLKArgumentIssue issueWithError:[self flarnError] salientOption:@"flarn"];
    XCTAssertNotNil(issue);
    XCTAssertEqualObjects(issue.error, [self flarnError]);
    XCTAssertEqualObjects(issue.salientOptions, @[ @"flarn" ]);
    
    issue = [CLKArgumentIssue issueWithError:[self flarnError] salientOptions:nil];
    XCTAssertNotNil(issue);
    XCTAssertEqualObjects(issue.error, [self flarnError]);
    XCTAssertNil(issue.salientOptions);
    
    issue = [CLKArgumentIssue issueWithError:[self flarnError] salientOptions:@[ @"flarn" ]];
    XCTAssertNotNil(issue);
    XCTAssertEqualObjects(issue.error, [self flarnError]);
    XCTAssertEqualObjects(issue.salientOptions, @[ @"flarn" ]);
    
    issue = [CLKArgumentIssue issueWithError:[self flarnError] salientOptions:@[ @"flarn", @"barf" ]];
    XCTAssertNotNil(issue);
    XCTAssertEqualObjects(issue.error, [self flarnError]);
    XCTAssertEqualObjects(issue.salientOptions, (@[ @"flarn", @"barf" ]));
}

- (void)testDebugDescription
{
    CLKArgumentIssue *issue = [CLKArgumentIssue issueWithError:[self flarnError]];
    XCTAssertNotNil(issue.debugDescription);
    XCTAssertTrue([issue.debugDescription containsString:@"flarn issue!"]);
    XCTAssertTrue([issue.debugDescription containsString:@"salientOptions: [ (null) ]"]);
    
    issue = [CLKArgumentIssue issueWithError:[self flarnError] salientOptions:nil];
    XCTAssertNotNil(issue.debugDescription);
    XCTAssertTrue([issue.debugDescription containsString:@"flarn issue!"]);
    XCTAssertTrue([issue.debugDescription containsString:@"salientOptions: [ (null) ]"]);
    
    issue = [CLKArgumentIssue issueWithError:[self flarnError] salientOptions:@[ @"flarn", @"barf" ]];
    XCTAssertNotNil(issue.debugDescription);
    XCTAssertTrue([issue.debugDescription containsString:@"flarn issue!"]);
    XCTAssertTrue([issue.debugDescription containsString:@"salientOptions: [ flarn, barf ]"]);
}

- (void)testEquality
{
    NSArray<CLKArgumentIssue *> *issues = [self uniqueIssues];
    NSArray<CLKArgumentIssue *> *issueClones = [self uniqueIssues];
    [issues enumerateObjectsUsingBlock:^(CLKArgumentIssue *issue, NSUInteger idx, __unused BOOL *outStop) {
        CLKArgumentIssue *clone = issueClones[idx];
        XCTAssertEqualObjects(issue, clone);
        XCTAssertEqual(issue.hash, clone.hash);
    }];
    
    for (NSUInteger i = 0 ; i < issues.count ; i++) {
        CLKArgumentIssue *alpha = issues[i];
        for (NSUInteger c = 0 ; c < issues.count ; c++) {
            // skip the clone of alpha
            if (c == i) {
                continue;
            }
            
            CLKArgumentIssue *bravo = issues[c];
            XCTAssertFalse([alpha isEqual:bravo], @"issues unexpectedly match:\n%@ is equal to %@", alpha.debugDescription, bravo.debugDescription);
        }
    }
}

- (void)testEquality_misc
{
    CLKArgumentIssue *issue = [CLKArgumentIssue issueWithError:[self flarnError]];
    XCTAssertNotEqualObjects(issue, nil);
    XCTAssertNotEqualObjects(issue, @"not an option");
    XCTAssertTrue([issue isEqual:issue]);
}

- (void)test_isValidationIssue
{
    NSError *posixError = [NSError clk_POSIXErrorWithCode:(int)CLKErrorRequiredOptionNotProvided description:@"POSIX error with colliding code"];
    CLKArgumentIssue *posixIssue = [CLKArgumentIssue issueWithError:posixError];
    XCTAssertFalse(posixIssue.isValidationIssue);
    
    NSArray *validationErrorCodes = @[
        @(CLKErrorRequiredOptionNotProvided),
        @(CLKErrorTooManyOccurrencesOfOption),
        @(CLKErrorMutuallyExclusiveOptionsPresent)
    ];
    
    for (NSNumber *code in validationErrorCodes) {
        NSError *error = [NSError clk_CLKErrorWithCode:code.integerValue description:@"CLKErrorDomain error with validation error code"];
        CLKArgumentIssue *issue = [CLKArgumentIssue issueWithError:error];
        XCTAssertTrue(issue.isValidationIssue);
    }
    
    NSArray *otherErrorCodes = @[
        @(CLKErrorNoError),
        @(CLKErrorNoVerbSpecified),
        @(CLKErrorUnrecognizedVerb)
    ];
    
    for (NSNumber *code in otherErrorCodes) {
        NSError *error = [NSError clk_CLKErrorWithCode:code.integerValue description:@"CLKErrorDomain error with a non-validation error code"];
        CLKArgumentIssue *issue = [CLKArgumentIssue issueWithError:error];
        XCTAssertFalse(issue.isValidationIssue);
    }
}

@end
