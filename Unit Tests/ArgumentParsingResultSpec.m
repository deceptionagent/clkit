//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import "ArgumentParsingResultSpec.h"


NS_ASSUME_NONNULL_BEGIN

@interface ArgumentParsingResultSpec ()

- (instancetype)_initWithOptionManifest:(nullable NSDictionary<NSString *, id> *)optionManifest
                    positionalArguments:(nullable NSArray<NSString *> *)positionalArguments
                                 errors:(nullable NSArray<NSError *> *)errors NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END

@implementation ArgumentParsingResultSpec
{
    NSDictionary<NSString *, id> *_optionManifest;
    NSArray<NSString *> *_positionalArguments;
    NSArray<NSError *> *_errors;
}

@synthesize optionManifest = _optionManifest;
@synthesize positionalArguments = _positionalArguments;
@synthesize errors = _errors;

+ (instancetype)specWithOptionManifest:(NSDictionary<NSString *, id> *)optionManifest
{
    return [[[self alloc] _initWithOptionManifest:optionManifest positionalArguments:@[] errors:nil] autorelease];
}

+ (instancetype)specWithPositionalArguments:(NSArray<NSString *> *)positionalArguments
{
    return [[[self alloc] _initWithOptionManifest:@{} positionalArguments:positionalArguments errors:nil] autorelease];
}

+ (instancetype)specWithOptionManifest:(NSDictionary<NSString *, id> *)optionManifest positionalArguments:(NSArray<NSString *> *)positionalArguments
{
    return [[[self alloc] _initWithOptionManifest:optionManifest positionalArguments:positionalArguments errors:nil] autorelease];
}

+ (instancetype)specWithErrors:(NSArray<NSError *> *)errors
{
    return [[[self alloc] _initWithOptionManifest:nil positionalArguments:nil errors:errors] autorelease];
}

- (instancetype)_initWithOptionManifest:(NSDictionary<NSString *, id> *)optionManifest positionalArguments:(NSArray<NSString *> *)positionalArguments errors:(NSArray<NSError *> *)errors
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
