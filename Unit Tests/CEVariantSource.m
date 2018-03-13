//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import "CEVariantSource.h"


@implementation CEVariantSource
{
    NSString *_identifier;
    NSArray *_values;
}

@synthesize identifier = _identifier;
@synthesize values = _values;

+ (instancetype)sourceWithIdentifier:(NSString *)identifier values:(NSArray *)values
{
    return [[[self alloc] initWithIdentifier:identifier values:values] autorelease];
}

- (instancetype)initWithIdentifier:(NSString *)identifier values:(NSArray *)values
{
    NSParameterAssert(identifier.length > 0);
    NSParameterAssert(values.count > 0);
    
    self = [super init];
    if (self != nil) {
        _identifier = [identifier copy];
        _values = [values copy];
    }
    
    return self;
}

- (void)dealloc
{
    [_values release];
    [_identifier release];
    [super dealloc];
}

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"%@ { identifier: '%@' }", super.debugDescription, _identifier];
}

@end
