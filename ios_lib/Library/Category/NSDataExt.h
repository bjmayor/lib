
    //
//  NSDataExt.h
//  
//
//  Created by  on 10-11-6.
//  Copyright 2010  . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Ext)
- (NSString *) base64Encode;
- (NSData *)gzipInflate;
- (NSData *)gzipDeflate;
- (NSString*)MD5String;
- (int8_t)readInt8:(NSNumber**)offset;
- (int16_t)readInt16:(NSNumber**)offset;
- (int32_t)readInt32:(NSNumber**)offset;
- (int64_t)readInt64:(NSNumber**)offset;
- (NSString*)readCharacter:(NSNumber**)offset;
- (NSData*)readData:(NSNumber**)offset;
- (NSData*)encryptWithKey:(NSString*)key;
- (NSData*)decryptWithKey:(NSString*)key;
@end

@interface NSMutableData (YMS)
- (void)writeValue8:(int8_t)value code:(int16_t)code;
- (void)writeValue16:(int16_t)value code:(int16_t)code;
- (void)writeValue32:(int32_t)value code:(int16_t)code;
- (void)writeValue64:(int64_t)value code:(int16_t)code;
- (void)writeCharacter:(NSString*)value code:(int16_t)code;
- (void)writeData:(NSData*)data code:(int16_t)code;
@end