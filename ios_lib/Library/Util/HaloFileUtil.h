//
//  HaloFileUtil.h
//  YContact
//
//  Created by  on 11-12-20.
//  Copyright (c) 2011年 . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HaloFileUtil : NSObject
+ (NSData *)readFromFile:(NSString *)filePath offset:(int32_t)offset length:(int32_t)length;
+ (NSInteger)fileSize:(NSString *) filePath;
+ (NSString *)parseFileNameWithPath:(NSString *)filePath;
+ (NSString *)uuFileNameWith:(NSString *)ext;
+ (void)removeFileAtPath:(NSString *)path;
+ (BOOL)fileExist:(NSString *)filePath;
+ (NSString *)fileWithDocumentsPath:(NSString *)filePath;
+ (NSString *)fileWithUploadPath:(NSString *)filePath;
+ (NSString *)fileWithTempPath:(NSString *)filePath;
+ (NSString *)fileWithUserPath:(NSString *)filePath userKey:(NSString *)userKey;
+ (NSString*)mimeTypeForFileAtPath:(NSString *)path;
@end
