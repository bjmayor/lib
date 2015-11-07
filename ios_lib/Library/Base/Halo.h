//
//  Halo.h
//  Hello World
//
//  Created by  on 13-5-18.
//  Copyright (c) 2013年 __Company__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#define KPlatForm @"iPhone"
#define KPadPlatForm @"iPad"

@interface Halo : NSObject
+ (NSBundle *)bundle;
+ (BOOL)isLocalString:(NSString*)localString;
+ (NSString*)currentLanguage;
+ (NSInteger)plistVersionInteger;
+ (NSString*)plistVersion;
+ (NSString*)plistBuild;
@end
