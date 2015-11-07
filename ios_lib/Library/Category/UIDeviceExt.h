/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
@interface UIDevice (Hardware)
- (NSString *)platform;
+ (NSInteger)iosMainVersion;
+ (BOOL)isVersion:(NSString*)version;
+ (NSComparisonResult)currentVersionCompare:(CGFloat)version;
+ (BOOL)isWifiConnected;
+ (NSString *)localWiFiIPAddress;
+ (NSString*)wifiMac;
+ (NSString*)udid;
+ (NSString*)customUdid;
+ (BOOL)isPad;
+ (BOOL)isJailbroken;
+ (NSString *)deviceId;
@end