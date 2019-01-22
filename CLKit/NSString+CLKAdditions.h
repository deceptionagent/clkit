//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface NSString (CLKAdditions)

- (BOOL)clk_containsString:(NSString *)string range:(NSRange)range;
- (BOOL)clk_containsCharacterFromSet:(NSCharacterSet *)characterSet;
- (BOOL)clk_containsCharacterFromSet:(NSCharacterSet *)characterSet range:(NSRange)range;

@end

NS_ASSUME_NONNULL_END
