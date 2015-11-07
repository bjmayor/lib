//
//  Halo.m
//  Hello World
//
//  Created by  on 13-5-18.
//  Copyright (c) 2013年 __Company__. All rights reserved.
//

#import "Halo.h"

@implementation Halo
+ (NSBundle *)bundle
{
    NSString *fupath = [[NSBundle mainBundle] pathForResource:@"Halo" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:fupath];
    return bundle;
}

+ (BOOL)isLocalString:(NSString*)localString
{
    return [[self currentLanguage] hasPrefix:localString];
}

+ (NSString*)currentLanguage
{
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	NSArray *languages = [defs objectForKey:@"AppleLanguages"];
	NSString *preferredLang = [languages objectAtIndex:0];
	DDLogVerbose(@"currentLanguage:%@",preferredLang);
	return preferredLang;
}

+ (NSInteger)plistVersionInteger
{
    NSString *version = [self plistVersion];
    NSArray* vers = [version componentsSeparatedByString:@"."];
    version = [vers componentsJoinedByString:KNilString];
    NSInteger code = [version intValue];
    return code;
}

+ (NSString*)plistVersion
{
	return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

+ (NSString*)plistBuild
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
}

+ (NSString*)platForm
{
    return ( [UIDevice isPad]?KPadPlatForm:KPlatForm ) ;
}

@end
