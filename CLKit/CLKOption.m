//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import "CLKOption.h"

#import "CLKArgumentTransformer.h"


@interface CLKOption ()

- (instancetype)_initWithLongName:(NSString *)longName shortName:(NSString *)shortName transformer:(nullable CLKArgumentTransformer *)transformer expectsArgument:(BOOL)expectsArgument NS_DESIGNATED_INITIALIZER;

@end


@implementation CLKOption

@synthesize longName = _longName;
@synthesize shortName = _shortName;
@synthesize expectsArgument = _expectsArgument;
@synthesize transformer = _transformer;

+ (instancetype)optionWithLongName:(NSString *)longName shortName:(NSString *)shortName
{
    return [self optionWithLongName:longName shortName:shortName transformer:nil];
}

+ (instancetype)optionWithLongName:(NSString *)longName shortName:(NSString *)shortName transformer:(nullable CLKArgumentTransformer *)transformer
{
    return [[[self alloc] _initWithLongName:longName shortName:shortName transformer:transformer expectsArgument:YES] autorelease];
}

+ (instancetype)freeOptionWithLongName:(NSString *)longName shortName:(NSString *)shortName
{
    return [[[self alloc] _initWithLongName:longName shortName:shortName transformer:nil expectsArgument:NO] autorelease];
}

- (instancetype)_initWithLongName:(NSString *)longName shortName:(NSString *)shortName transformer:(CLKArgumentTransformer *)transformer expectsArgument:(BOOL)expectsArgument
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
        _expectsArgument = expectsArgument;
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
    return [NSString stringWithFormat:@"%@ { --%@ | -%@ | expectsArgument: %@ }", super.description, _longName, _shortName, (_expectsArgument ? @"YES" : @"NO")];
}

- (NSUInteger)hash
{
    return _longName.hash;
}

- (BOOL)isEqual:(id)obj
{
    if (obj == self) {
        return YES;
    }
    
    if (![obj isKindOfClass:[CLKOption class]]) {
        return NO;
    }
    
    CLKOption *opt = (CLKOption *)obj;
    return [opt.longName isEqualToString:_longName];
}

@end
