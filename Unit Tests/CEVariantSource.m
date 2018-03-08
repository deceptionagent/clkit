//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import "CEVariantSource.h"


@implementation CEVariantSource
{
    NSString *_identifier;
    NSArray *_values;
    NSUInteger _currentPosition;
    NSMutableArray<id<CEVariantSourceObserver>> *_observers;
}

@synthesize identifier = _identifier;

- (instancetype)initWithIdentifier:(NSString *)identifier values:(NSArray *)values
{
    NSParameterAssert(identifier.length > 0);
    NSParameterAssert(values.count > 0);
    
    self = [super init];
    if (self != nil) {
        _identifier = [identifier copy];
        _values = [values copy];
        _observers = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
    [_observers release];
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
        [self _notifyObservers_variantSourceDidAdvanceToInitialValue];
    }
}

#pragma mark -

- (void)addObserver:(id<CEVariantSourceObserver>)observer
{
    [_observers addObject:observer];
}

- (void)removeObserver:(id<CEVariantSourceObserver>)observer
{
    [_observers removeObject:observer];
}

- (void)_notifyObservers_variantSourceDidAdvanceToInitialValue
{
    for (id<CEVariantSourceObserver> observer in _observers) {
        [observer variantSourceDidAdvanceToInitialValue:self];
    }
}

@end
