//
//  NSString+PNAddition.m
//  pubnub
//
//  Created by Sergey Mamontov on 2/26/13.
//
//

#import "NSString+PNAddition.h"
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonHMAC.h>
#import "NSData+PNAdditions.h"


// ARC check
#if !__has_feature(objc_arc)
#error PubNub string category must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


#pragma mark Private interface implementation

@interface NSString (PNAdditionPrivate)

- (NSString *)pn_percentEscapedStringWithEscapeString:(NSString *)stringWithCharsForEscape;
- (NSString *)pn_ASCIIStringHEXEncodedString:(BOOL)shouldUseHEXCodes;

@end


#pragma mark Public interface implementation

@implementation NSString (PNAddition)


#pragma mark - Class methods

+ (NSString *)pn_stringWithFormat:(NSString *)format argumentsArray:(NSArray *)arguments {
    
    NSUInteger argumentIndex = 0;
    NSMutableString *formattedString = [format mutableCopy];
    NSRange replacementMarkRange = [formattedString rangeOfString:@"%@"];
    while (replacementMarkRange.location != NSNotFound) {
        
        // Choose and apply argument which should be applied to corresponding token place.
        id argument = (argumentIndex < [arguments count] ? [arguments objectAtIndex:argumentIndex] : @"");
        [formattedString replaceCharactersInRange:replacementMarkRange withString:[argument description]];
        
        replacementMarkRange = [formattedString rangeOfString:@"%@"];
        argumentIndex++;
    }
    
    
    return formattedString;
}


#pragma mark - Instance methods

- (BOOL)pn_isEmpty {
    
    static NSCharacterSet *nonNewlineCharSet;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        nonNewlineCharSet = [NSCharacterSet newlineCharacterSet];
    });
    
    
    return [[[self stringByReplacingOccurrencesOfString:@" " withString:@""]
             stringByTrimmingCharactersInSet:nonNewlineCharSet] length] == 0;
}

- (NSString *)pn_percentEscapedString {

    return [self pn_percentEscapedStringWithEscapeString:@":/?#[]@!$&’()*+,;="];
}

#ifdef CRYPTO_BACKWARD_COMPATIBILITY_MODE
- (NSString *)pn_nonStringPercentEscapedString {

    return [self pn_percentEscapedStringWithEscapeString:@":/?#[]@!$&’()*+;="];
}
#endif

- (NSString *)pn_percentEscapedStringWithEscapeString:(NSString *)stringWithCharsForEscape {

    NSString *escapedString = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                (__bridge CFStringRef)self, NULL,
                                                (__bridge CFStringRef)stringWithCharsForEscape,
                                                kCFStringEncodingUTF8));
    NSString *newlineEscapedString = [escapedString stringByReplacingOccurrencesOfString:@"%0A" withString:@"%5Cn"];
    newlineEscapedString = [newlineEscapedString stringByReplacingOccurrencesOfString:@"%0D" withString:@"%5Cr"];


    return [newlineEscapedString copy];
}

- (NSString *)pn_ASCIIString {

    return [self pn_ASCIIStringHEXEncodedString:NO];
}

- (NSString *)pn_ASCIIHEXString {

    return [self pn_ASCIIStringHEXEncodedString:YES];
}

- (NSString *)pn_ASCIIStringHEXEncodedString:(BOOL)shouldUseHEXCodes {

    NSMutableString *asciiString = [[NSMutableString alloc] initWithCapacity:([self length]*2)];
    NSUInteger charIdx, charsCount = [self length];
    for (charIdx = 0; charIdx < charsCount; charIdx++) {

        unichar charCode = [self characterAtIndex:charIdx];
        [asciiString appendFormat:(shouldUseHEXCodes?@"%02X":@"%d"), charCode];
    }


    return asciiString;
}

- (NSString *)pn_truncatedString:(NSUInteger)length lineBreakMode:(NSLineBreakMode)lineBreakMode {

    NSString *truncatedString = self;
    if (length < self.length) {

        switch (lineBreakMode) {
                
            case NSLineBreakByTruncatingHead:
                {
                    NSUInteger index = (self.length - length);
                    if (index + 1 < self.length) {

                        index++;
                    }
                    truncatedString = [[NSString alloc] initWithFormat:@"…%@", [self substringFromIndex:index]];
                }
                break;
                
            case NSLineBreakByTruncatingMiddle:
                {
                    NSUInteger maximumHalfLength = (NSUInteger)ceilf(length * 0.5f);
                    if (maximumHalfLength == (self.length * 0.5f)) {

                        maximumHalfLength = MAX(maximumHalfLength - 2, MAX(maximumHalfLength - 1, (NSUInteger)0));
                    }

                    truncatedString = [[NSString alloc] initWithFormat:@"%@…%@", [self substringToIndex:maximumHalfLength],
                                       [self substringFromIndex:(self.length - maximumHalfLength)]];
                }
                break;
                
            case NSLineBreakByTruncatingTail:
                {
                    NSUInteger index = length;
                    if (index - 1 > 0) {

                        index--;
                    }
                    truncatedString = [[NSString alloc] initWithFormat:@"%@…", [self substringToIndex:index]];
                }
                break;

            default:

                if (lineBreakMode != NSLineBreakByCharWrapping && lineBreakMode != NSLineBreakByWordWrapping) {
                    
                    truncatedString = [self substringToIndex:length];
                }
                break;
        }
    }
    
    
    return truncatedString;
}


#pragma mark - Cryptography methods

- (NSData *)pn_sha256Data {

    unsigned char hashedData[CC_SHA256_DIGEST_LENGTH];
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    CC_SHA256([data bytes], (CC_LONG)[data length], hashedData);


    return [[NSData alloc] initWithBytes:hashedData length:CC_SHA256_DIGEST_LENGTH];
}

- (NSString *)pn_sha256HEXString {

    return [[[self pn_sha256Data] pn_HEXString] lowercaseString];
}

- (NSString *)pn_base64DecodedString {

    return [[NSString alloc] initWithUTF8String:[[NSData pn_dataFromBase64String:self] bytes]];
}

#ifdef CRYPTO_BACKWARD_COMPATIBILITY_MODE
- (NSData *)pn_md5Data {

    const char *src = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(src, strlen(src), result);


    return [[NSData alloc] initWithBytes:result length:CC_MD5_DIGEST_LENGTH];
}
#endif

#pragma mark -

@end
