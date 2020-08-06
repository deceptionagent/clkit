//
//  Copyright (c) 2020 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface AssignmentFormParsingSpec : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithOptionSegment:(NSString *)optionSegment operator:(NSString *)operator argumentSegment:(NSString *)argumentSegment NS_DESIGNATED_INITIALIZER;

@property (readonly) NSString *argumentSegment;
@property (readonly) NSString *composedToken;
@property (readonly) BOOL malformed;

@end

NS_ASSUME_NONNULL_END
