//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import "CEVariantSource.h"


@implementation CEVariantSource
{
    NSString *_identifier;
    NSArray *_values;
    id<CEVariantSourceDelegate> _delegate;
    NSUInteger _currentPosition;
}

@synthesize identifier = _identifier;

- (instancetype)initWithIdentifier:(NSString *)identifier values:(NSArray *)values delegate:(id<CEVariantSourceDelegate>)delegate
{
    NSParameterAssert(identifier.length > 0);
    NSParameterAssert(values.count > 0);
    
    self = [super init];
    if (self != nil) {
        _identifier = [identifier copy];
        _values = [values copy];
        _delegate = delegate;
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
    return [NSString stringWithFormat:@"%@ { identifier: '%@' | pos: %llu | value: %@ }", super.debugDescription, _identifier, (unsigned long long)_currentPosition, self.currentValue];
}

#pragma mark -

- (id)currentValue
{
    return _values[_currentPosition];
}

- (void)advanceToNextValue
{
    _currentPosition++;
    if (_currentPosition >= _values.count) {
        _currentPosition = 0;
        [_delegate variantSourceDidAdvanceToInitialValue:self];
    }
}

@end
