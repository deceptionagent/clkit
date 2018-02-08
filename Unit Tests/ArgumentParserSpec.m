//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import "ArgumentParserSpec.h"


@implementation ArgumentParserSpec
{
    NSDictionary<NSString *, id> *_optionManifest;
    NSArray<NSString *> *_positionalArguments;
    NSArray<NSError *> *_errors;
}

@synthesize optionManifest = _optionManifest;
@synthesize positionalArguments = _positionalArguments;
@synthesize errors = _errors;

+ (instancetype)specWithOptionManifest:(NSDictionary<NSString *, id> *)optionManifest positionalArguments:(NSArray<NSString *> *)positionalArguments
{
    return [[[self alloc] initWithOptionManifest:optionManifest positionalArguments:positionalArguments errors:nil] autorelease];
}

+ (instancetype)specWithErrors:(NSArray<NSError *> *)errors
{
    return [[[self alloc] initWithOptionManifest:nil positionalArguments:nil errors:errors] autorelease];
}

- (instancetype)initWithOptionManifest:(nullable NSDictionary<NSString *, id> *)optionManifest positionalArguments:(nullable NSArray<NSString *> *)positionalArguments errors:(nullable NSArray<NSError *> *)errors
{
    self = [super init];
    if (self != nil) {
        _optionManifest = [optionManifest copy];
        _positionalArguments = [positionalArguments copy];
        _errors = [errors copy];
    }
    
    return self;
}

- (void)dealloc
{
    [_optionManifest release];
    [_positionalArguments release];
    [_errors release];
    [super dealloc];
}

#pragma mark -

- (BOOL)parserShouldSucceed
{
    return (self.errors.count == 0);
}

@end
