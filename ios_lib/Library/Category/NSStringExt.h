//
//  NSStringExt.h
//  
//
//  Created by  on 10-10-27.
//  Copyright 2010  . All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    ERichTypeEmail = 1<<0,
    ERichTypePhone = 1<<1,
    ERichTypeLink = 1<<2,
    ERichTypeAll = 1<<0|1<<1|1<<2,
}RichType;

//@"(?=[\\x00-\\x7f])(((([hH][tT][tT][pP]|[fF][tT][pP]|[hH][tT][tT][pP][sS]):\\/\\/){0}[a-zA-Z-_]+)|((([hH][tT][tT][pP]|[fF][tT][pP]|[hH][tT][tT][pP][sS]):\\/\\/){1}[\\da-zA-Z-_]+))(\\.[\\w\\-_]+)+([\\w\\-\\.,@?^=%&amp;:/~\\+#]*[\\w\\-\\@?^=%&amp;/~\\+#])?(?<=[\\x00-\\x7f])"
extern const NSString *kRegexHttpLinkPattern;

//@"([+]{0,1}[0-9]{1,3}[-| ]{0,1}[0-9]{1,4}[-| ]{0,1}[0-9]{1,4}[-| ]{0,1}[0-9]{1,4})"
extern const NSString *kRegexPhoneNmuberPattern;

//@"[\\b\\w-]+(\\.[\\w-]+)*@[\\w-]+(\\.[\\w-]+)+\\b"
extern const NSString *kRegexEmailAddrPattern;

// @"tel"
extern const NSString *kStringHyperLinkTel;

//@"http"
extern const NSString *kStringHyperLinkHttp;

//@"email"
extern const NSString *kStringHyperLinkEmail ;


@interface NSString (EXT)

+ (NSString*)fileMD5:(NSString*)path;
- (NSString*)MD5String;
- (NSString*)base64Encode;
- (NSString*)base64Decode;
- (NSData*)base64DecodeData;
- (NSString*)toHex;
- (NSData*)toBinData;
- (NSString*)encryptWithKey:(NSString*)key;
- (NSString*)decryptWithKey:(NSString*)key;
+ (NSString*)stringWithLong:(long)number;
+ (NSString*)stringwithDouble:(double)number;
+ (NSString*)stringWithChar:(char)aChar;
- (NSString*)unFormatNumber;
- (NSUInteger)hexStringToInt;
- (NSString*)hideNumber;
- (NSString*)generateKey:(NSInteger)number;

- (NSString*)trimSpaceAndReturn;

- (NSString *)URLEncodedString;
- (NSString *)URLDecodedString;

- (NSString*)encodeAsURIComponent;
- (NSString*)escapeHTML;
- (NSString*)unescapeHTML;

- (NSString *)stringByTrimmingTrailingWhitespaceAndNewlineCharacters;

- (BOOL)hasEmoji;
- (BOOL)oauthIsNumeric;

- (BOOL)isPureInt;
- (BOOL)isPureFloat;
- (BOOL)isNumeric;

+ (NSString *)getSingularOrPlural:(NSInteger)count singular:(NSString*)singular plural:(NSString *)plural;
+ (NSString *)formatSingularOrPlural:(NSInteger)count singular:(NSString*)singular plural:(NSString *)plural;

- (NSString *)format:(id)first, ...;


//rich text
- (NSString *)richTextWith:(RichType)type;
- (NSString *)richTextWithSpecialColor:(UIColor *)color matchString:(NSString*)matchString subRange:(NSRange)subRange;
@end
