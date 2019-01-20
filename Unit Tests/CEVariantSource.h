//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface CEVariantSource : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)sourceWithIdentifier:(NSString *)identifier values:(NSArray *)values;
- (instancetype)initWithIdentifier:(NSString *)identifier values:(NSArray *)values NS_DESIGNATED_INITIALIZER;

@property (readonly) NSString *identifier;
@property (readonly) NSArray *values;

// a special value to allow a combination engine to generate a combination that
// lacks a value for a source when CEVariantSourceNoValue would be chosen.
@property (class, readonly) id noValueMarker;

@end

NS_ASSUME_NONNULL_END
