//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import "CLKOption.h"

#import "CLKArgumentTransformer.h"


@interface CLKOption ()

- (instancetype)_initWithName:(NSString *)name flag:(NSString *)flag transformer:(nullable CLKArgumentTransformer *)transformer expectsArgument:(BOOL)expectsArgument NS_DESIGNATED_INITIALIZER;

@end


@implementation CLKOption

@synthesize name = _name;
@synthesize flag = _flag;
@synthesize expectsArgument = _expectsArgument;
@synthesize transformer = _transformer;

+ (instancetype)optionWithName:(NSString *)name flag:(NSString *)flag
{
    return [self optionWithName:name flag:flag transformer:nil];
}

+ (instancetype)optionWithName:(NSString *)name flag:(NSString *)flag transformer:(nullable CLKArgumentTransformer *)transformer
{
    return [[[self alloc] _initWithName:name flag:flag transformer:transformer expectsArgument:YES] autorelease];
}

+ (instancetype)freeOptionWithName:(NSString *)name flag:(NSString *)flag
{
    return [[[self alloc] _initWithName:name flag:flag transformer:nil expectsArgument:NO] autorelease];
}

- (instancetype)_initWithName:(NSString *)name flag:(NSString *)flag transformer:(CLKArgumentTransformer *)transformer expectsArgument:(BOOL)expectsArgument
{
    NSParameterAssert(![name hasPrefix:@"-"]);
    NSParameterAssert(![flag hasPrefix:@"-"]);
    NSParameterAssert(name.length > 0);
    NSParameterAssert(flag.length == 1);
    
    self = [super init];
    if (self != nil) {
        _name = [name copy];
        _flag = [flag copy];
        _transformer = [transformer retain];
        _expectsArgument = expectsArgument;
    }
    
    return self;
}

- (void)dealloc
{
    [_transformer release];
    [_flag release];
    [_name release];
    [super dealloc];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ { --%@ | -%@ | expectsArgument: %@ }", super.description, _name, _flag, (_expectsArgument ? @"YES" : @"NO")];
}

- (NSUInteger)hash
{
    return _name.hash;
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
    return [opt.name isEqualToString:_name];
}

@end
