//
//  HaloFileUtil.m
//  YChat
//
//  Created by  on 11-12-9.
//  Copyright (c) 2011年 . All rights reserved.
//

#import "HaloFileUtil.h"
#import <stdio.h>
#import <MobileCoreServices/MobileCoreServices.h>

@implementation HaloFileUtil

+ (NSData *)readFromFile:(NSString *)filePath offset:(int32_t)offset length:(int32_t)length
{    
    NSFileHandle  *fh = [NSFileHandle fileHandleForReadingAtPath:filePath];
    if ( fh != nil )
    {
        long long filesize = [fh seekToEndOfFile];
        if ( offset >= filesize )
        {
            return nil;
        }
        int len = length;
        if ( len + offset > filesize )
        {
            len = filesize - offset;
        }
        [fh seekToFileOffset:offset];
        NSData  *data = [fh readDataOfLength:len];
        [fh closeFile];
        return data;
    }
    return nil;    
}

+ (NSInteger)fileSize:(NSString *) filePath
{
	NSFileManager  *fileManager = [NSFileManager defaultManager];  
	NSDictionary  *fileAttributes = [fileManager attributesOfItemAtPath:filePath error:nil];  	
	if (fileAttributes != nil) 
	{  
		return [[fileAttributes objectForKey:NSFileSize] intValue];
	}
	else 
	{
		return 0;
	}
}

+ (NSString *)parseFileNameWithPath:(NSString *)filePath
{
    if ( filePath.length == 0 ) 
    {
        return KNilString;
    }
    NSArray  *array = [filePath pathComponents];
    if ( array.count > 0 )
    {
        NSString   *last = [array lastObject];
        return last;
    }
    return  KNilString;
}

+ (NSString *)uuFileNameWith:(NSString *)ext
{
    return [NSString stringWithFormat:@"%f.%@",[[NSDate date] timeIntervalSince1970],ext];
}

+ (void)removeFileAtPath:(NSString *)path
{
    NSFileManager  *fileManager = [NSFileManager defaultManager];
    if ( [fileManager fileExistsAtPath:path] )
    {
        [fileManager removeItemAtPath:path error:nil];
    }
}

+ (BOOL)fileExist:(NSString *)filePath
{
    NSFileManager  *fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:filePath];
}

+ (NSString *)fileWithUserPath:(NSString *)filePath userKey:(NSString *)userKey
{
    NSFileManager  *NSFm= [NSFileManager defaultManager];
    BOOL usr_existed = [NSFm fileExistsAtPath:[self fileWithDocumentsPath:@"usr"]];
    if (!usr_existed)
    {
        [NSFm createDirectoryAtPath:[self fileWithDocumentsPath:@"usr"] withIntermediateDirectories:NO attributes:nil error:nil];
    }
    NSString  *path = [NSString stringWithFormat:@"usr/%@/%@",userKey,filePath];
    return [self fileWithDocumentsPath:path];
}

+ (NSString *)fileWithTempPath:(NSString *)filePath
{
    NSString  *path = [NSTemporaryDirectory()stringByAppendingString:filePath];
    DDLogInfo(@"%@",path);
	return path;
}

+ (NSString *)fileWithUploadPath:(NSString *)filePath
{
    NSFileManager *NSFm = [NSFileManager defaultManager];
    BOOL usr_existed = [NSFm fileExistsAtPath:[self fileWithDocumentsPath:@"upload"]];
    if (!usr_existed)
    {
        [NSFm createDirectoryAtPath:[self fileWithDocumentsPath:@"upload"] withIntermediateDirectories:NO attributes:nil error:nil];
    }
    return [self fileWithDocumentsPath:[NSString stringWithFormat:@"upload/%@",filePath]];
}

+ (NSString *)fileWithDocumentsPath:(NSString *)filePath
{
	NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString  *dcoumentpath = ([paths count] > 0)? [paths objectAtIndex:0] : nil;
    //assert (dcoumentpath);
	
	NSMutableString  *result = [NSMutableString stringWithCapacity:3];
	[result appendString:dcoumentpath];
    [result appendString:@"/"];
	[result appendString:filePath];
	
	NSRange range = [result rangeOfString:@"/" options:NSBackwardsSearch];
    NSString  *dirPath = [result substringToIndex:range.location];
	
	NSFileManager  *NSFm= [NSFileManager defaultManager];
    NSError  *error = nil;
	BOOL success = [NSFm createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:&error];
    if ( !success )
    {
        DDLogError(@"%@",[error description] );
    }
    return result;
}

+ (NSString*)mimeTypeForFileAtPath:(NSString *)path
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return nil;
    }
    // Borrowed from http://stackoverflow.com/questions/5996797/determine-mime-type-of-nsdata-loaded-from-a-file
    // itself, derived from  http://stackoverflow.com/questions/2439020/wheres-the-iphone-mime-type-database
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[path pathExtension], NULL);
    CFStringRef mimeType = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
    CFRelease(UTI);
    if (!mimeType)
    {
        return @"application/octet-stream";
    }
    return (__bridge NSString *)(mimeType);
}
@end
