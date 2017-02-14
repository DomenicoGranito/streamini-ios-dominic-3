//
//  NSDictionary+PNAdditions.m
//  pubnub
//
//  Created by Sergey Mamontov on 1/11/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "NSDictionary+PNAdditions.h"


#pragma mark Private interface declaration

@interface NSDictionary (PNAdditionsPrivate)


#pragma mark - Instance methods

/**
 Method allow to check on nested objects whether valid dictionary has been provided for state or not.

 @param isFirstLevelNesting
 If set to \c YES, then values will be checked to be simple type in other case dictionary is allowed.

 @return \c YES if provided dictionary conforms to the requirements.
*/
- (BOOL)pn_isValidState:(BOOL)isFirstLevelNesting;

#pragma mark -


@end


#pragma mark - Public interface implementation

@implementation NSDictionary (PNAdditions)


#pragma mark - Instance methods

- (BOOL)pn_isValidState {

    return [self count] && [NSJSONSerialization isValidJSONObject:self];
}

- (NSString *)logDescription {
    
    NSMutableString *logDescription = [[NSMutableString alloc] initWithString:@"<{"];
    __block NSUInteger entryIdx = 0;
    
    [self enumerateKeysAndObjectsUsingBlock:^(NSString *entryKey, id entry,
                                              __unused BOOL *entryEnumeratorStop) {
        
        // Check whether parameter can be transformed for log or not
        if ([entry respondsToSelector:@selector(logDescription)]) {
            
            entry = [entry performSelector:@selector(logDescription)];
            entry = (entry ? entry : @"");
        }
        [logDescription appendFormat:@"%@:%@%@", entryKey, entry, (entryIdx + 1 != [self count] ? @"|" : @"")];
        entryIdx++;
    }];
    [logDescription appendString:@"}>"];
    
    
    return logDescription;
}

#pragma mark -


@end
