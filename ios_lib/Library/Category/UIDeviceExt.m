/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

// Thanks to Emanuele Vulcano, Kevin Ballard/Eridius, Ryandjohnson, Matt Brown, etc.

#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

#import <arpa/inet.h>
#import <netdb.h>
#import <ifaddrs.h>
#import <unistd.h>
#import <dlfcn.h>

#import "UIDeviceExt.h"
#import <AdSupport/AdSupport.h>

static NSString *__udid;

#define IFT_ETHER 0x6
char *getMacAddress(char *macAddress, char *ifName);
char *getMacAddress(char *macAddress, char *ifName) {
    
    int  success;
    struct ifaddrs  *addrs;
    struct ifaddrs  *cursor;
    const struct sockaddr_dl  *dlAddr;
    const unsigned char *base;
    int i;
    
    success = getifaddrs(&addrs) == 0;
    if (success) {
        cursor = addrs;
        while (cursor != 0) {
            if ( (cursor->ifa_addr->sa_family == AF_LINK)
                && (((const struct sockaddr_dl *) cursor->ifa_addr)->sdl_type == IFT_ETHER) && strcmp(ifName,  cursor->ifa_name)==0 ) {
                dlAddr = (const struct sockaddr_dl *) cursor->ifa_addr;
                base = (const unsigned char*) &dlAddr->sdl_data[dlAddr->sdl_nlen];
                strcpy(macAddress, ""); 
                for (i = 0; i < dlAddr->sdl_alen; i++) {
                    if (i != 0) {
                        strcat(macAddress, ":");
                    }
                    char partialAddr[3];
                    sprintf(partialAddr, "%02X", base[i]);
                    strcat(macAddress, partialAddr);
                    
                }
            }
            cursor = cursor->ifa_next;
        }
        
        freeifaddrs(addrs);
    }    
    return macAddress;
}

@implementation UIDevice (Hardware)
#pragma mark sysctlbyname utils
- (NSString *)getSysInfoByName:(char *)typeSpecifier
{
	size_t size;
    sysctlbyname(typeSpecifier, NULL, &size, NULL, 0);
    char *answer = malloc(size);
	sysctlbyname(typeSpecifier, answer, &size, NULL, 0);
	NSString *results = [NSString stringWithCString:answer encoding: NSUTF8StringEncoding];
	free(answer);
	return results;
}

- (NSString *)platform
{
	return [self getSysInfoByName:"hw.machine"];
}

#pragma mark sysctl utils
- (NSUInteger)getSysInfo: (uint)typeSpecifier
{
	size_t size = sizeof(int);
	int results;
	int mib[2] = {CTL_HW, typeSpecifier};
	sysctl(mib, 2, &results, &size, NULL, 0);
	return (NSUInteger)results;
}

+ (NSInteger)iosMainVersion
{
	NSString *v = [[UIDevice currentDevice] systemVersion];
	return [[v substringToIndex:1] intValue];
}
+ (BOOL)isVersion:(NSString*)version
{
	NSString *v = [[UIDevice currentDevice] systemVersion];
    return (![v compare:version]);
}

+ (BOOL)isWifiConnected
{
#if (TARGET_IPHONE_SIMULATOR)
	return YES;
#else
	return [UIDevice localWiFiIPAddress].length > 0;
#endif
}

+ (NSString *)localWiFiIPAddress
{
	BOOL success;
	struct ifaddrs  *addrs;
	const struct ifaddrs  *cursor;
	
	success = getifaddrs(&addrs)== 0;
	if (success){
		cursor = addrs;
		while (cursor != NULL){
			// the second test keeps from picking up the loopback address
			if (cursor->ifa_addr->sa_family == AF_INET && (cursor->ifa_flags & IFF_LOOPBACK)== 0)
			{
				NSString *name = [NSString stringWithUTF8String:cursor->ifa_name];
				if ([name isEqualToString:@"en0"]) // Wi-Fi adapter
				{
					NSString *ip = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)cursor->ifa_addr)->sin_addr)];
					DDLogCInfo(@"wifi ip:%@",ip);
					freeifaddrs(addrs);
					return ip;
				}
					
			}
			cursor = cursor->ifa_next;
		}
		freeifaddrs(addrs);
	}
	return nil;
}

+ (NSString*)wifiMac
{
    char *macAddressString= (char*)malloc(18);
    NSString *macAddress= [[NSString alloc] initWithCString:getMacAddress(macAddressString,"en0")
                                                   encoding:NSMacOSRomanStringEncoding];
    free(macAddressString);
    return macAddress;
}

+ (NSString*)udid
{
    return __udid;
}

+ (NSString*)customUdid
{
    NSString *mac = [UIDevice wifiMac];
    if (mac.length > 0)
    {
        NSString *u = [NSString stringWithFormat:@"%@@",mac];
        return [u MD5String];
    }
    else
    {
        return nil;
    }
}

+ (NSComparisonResult)currentVersionCompare:(CGFloat)version
{
    NSString *v = [[UIDevice currentDevice] systemVersion];
    CGFloat currentV = [v floatValue];
    if (currentV == version)
    {
        return NSOrderedSame;
    }
    else if (currentV > version)
    {
        return NSOrderedDescending;
    }
    else
    {
        return NSOrderedAscending;
    }
}

+ (BOOL)isPad
{
    return ( [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad );
}

+ (BOOL)isJailbroken
{
    BOOL jailbroken = NO;
    NSString *cydiaPath = @"/Applications/Cydia.app";
    NSString *aptPath = @"/private/var/lib/apt/";
    if ([[NSFileManager defaultManager] fileExistsAtPath:cydiaPath])
    {
        jailbroken = YES;
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:aptPath])
    {
        jailbroken = YES;
    }
    return jailbroken;
}

+ (NSString *)deviceId
{
    if ([self iosMainVersion] < 7)
    {
        return [[self wifiMac] MD5String];
    }
    else
    {
        return [[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString];
    }
}

@end