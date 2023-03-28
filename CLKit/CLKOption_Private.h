//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import "CLKOption.h"

#import "CLKArgumentManifestConstraint.h"
#import "CLKArgumentTransformer.h"
#import "CLKAssert.h"
#import "NSCharacterSet+CLKAdditions.h"
#import "NSString+CLKAdditions.h"

NS_ASSUME_NONNULL_BEGIN

NSString *CLKStringForOptionType(CLKOptionType type);

@interface CLKOption ()

- (instancetype)_initWithType:(CLKOptionType)type
                         name:(NSString *)name
                         flag:(nullable NSString *)flag
                     required:(BOOL)required
                    recurrent:(BOOL)recurrent
                   standalone:(BOOL)standalone
                  transformer:(nullable CLKArgumentTransformer *)transformer NS_DESIGNATED_INITIALIZER;

- (void)_initConstraints;

@property (readonly) NSArray<CLKArgumentManifestConstraint *> *constraints;

+ (void)_validateOptionName:(NSString *)name flag:(nullable NSString *)flag;

@end

NS_ASSUME_NONNULL_END
