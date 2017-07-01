//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import "Option.h"

#import "ArgumentTransformer.h"


@interface Option ()

- (instancetype)_initWithLongName:(NSString *)longName shortName:(NSString *)shortName transformer:(nullable ArgumentTransformer *)transformer hasArgument:(BOOL)hasArgument NS_DESIGNATED_INITIALIZER;

@end


@implementation Option

@synthesize longName = _longName;
@synthesize shortName = _shortName;
@synthesize hasArgument = _hasArgument;
@synthesize transformer = _transformer;

+ (instancetype)optionWithLongName:(NSString *)longName shortName:(NSString *)shortName
{
    return [self optionWithLongName:longName shortName:shortName transformer:nil];
}

+ (instancetype)optionWithLongName:(NSString *)longName shortName:(NSString *)shortName transformer:(nullable ArgumentTransformer *)transformer
{
    return [[[self alloc] _initWithLongName:longName shortName:shortName transformer:transformer hasArgument:YES] autorelease];
}

+ (instancetype)freeOptionWithLongName:(NSString *)longName shortName:(NSString *)shortName
{
    return [[[self alloc] _initWithLongName:longName shortName:shortName transformer:nil hasArgument:NO] autorelease];
}

- (instancetype)_initWithLongName:(NSString *)longName shortName:(NSString *)shortName transformer:(ArgumentTransformer *)transformer hasArgument:(BOOL)hasArgument
{
    NSParameterAssert(![longName hasPrefix:@"-"]);
    NSParameterAssert(![shortName hasPrefix:@"-"]);
    NSParameterAssert(longName.length > 0);
    NSParameterAssert(shortName.length == 1);
    
    self = [super init];
    if (self != nil) {
        _longName = [longName copy];
        _shortName = [shortName copy];
        _transformer = [transformer retain];
        _hasArgument = hasArgument;
    }
    
    return self;
}

- (void)dealloc
{
    [_transformer release];
    [_shortName release];
    [_longName release];
    [super dealloc];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ { --%@ | -%@ | hasArgument: %@ }", super.description, _longName, _shortName, (_hasArgument ? @"YES" : @"NO")];
}

@end
