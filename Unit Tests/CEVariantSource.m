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
    return [[self alloc] initWithIdentifier:identifier values:values];
}

- (instancetype)initWithIdentifier:(NSString *)identifier values:(NSArray *)values
{
    NSParameterAssert(identifier.length > 0);
    NSParameterAssert(values.count > 0);
    NSParameterAssert(!(values.count == 1 && values[0] == CEVariantSource.noValueMarker));
    
    self = [super init];
    if (self != nil) {
        _identifier = [identifier copy];
        _values = [values copy];
    }
    
    return self;
}

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"%@ { identifier: '%@' }", super.debugDescription, _identifier];
}

#pragma mark -

+ (id)noValueMarker
{
    static id noValueMarker;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        noValueMarker = [[NSObject alloc] init];
    });
    
    return noValueMarker;
}

@end
