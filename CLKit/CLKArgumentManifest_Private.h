//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import "CLKArgumentManifest.h"


@class CLKOptionRegistry;

NS_ASSUME_NONNULL_BEGIN

@interface CLKArgumentManifest ()

- (instancetype)initWithOptionRegistry:(CLKOptionRegistry *)optionRegistry NS_DESIGNATED_INITIALIZER;

@property (readonly) NSDictionary<NSString *, id> *dictionaryRepresentationForAccumulatedOptions;

@property (readonly) NSSet<NSString *> *accumulatedOptionNames;
- (BOOL)hasOptionNamed:(NSString *)optionName;
- (NSUInteger)occurrencesOfOptionNamed:(NSString *)optionName;

- (void)accumulateSwitchOptionNamed:(NSString *)optionName;
- (void)accumulateArgument:(id)argument forParameterOptionNamed:(NSString *)optionName;
- (void)accumulatePositionalArgument:(NSString *)argument;

@end

NS_ASSUME_NONNULL_END
