//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CLKError.h"


NS_ASSUME_NONNULL_BEGIN

@interface NSError (CLKAdditions)

+ (instancetype)clk_POSIXErrorWithCode:(int)code description:(NSString *)fmt, ... NS_FORMAT_FUNCTION(2, 3);
+ (instancetype)clk_POSIXErrorWithCode:(int)code representedOptions:(NSArray<NSString *> *)optionNames description:(NSString *)fmt, ... NS_FORMAT_FUNCTION(3, 4);

+ (instancetype)clk_CLKErrorWithCode:(CLKError)code description:(NSString *)fmt, ... NS_FORMAT_FUNCTION(2, 3);
+ (instancetype)clk_CLKErrorWithCode:(CLKError)code representedOptions:(NSArray<NSString *> *)optionNames description:(NSString *)fmt, ... NS_FORMAT_FUNCTION(3, 4);

- (instancetype)clk_errorByAddingRepresentedOptions:(NSArray<NSString *> *)optionNames;

@property (nullable, readonly) NSArray<NSString *> *clk_representedOptions;
@property (readonly) BOOL clk_isValidationError;

@end

NS_ASSUME_NONNULL_END
