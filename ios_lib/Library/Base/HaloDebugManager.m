//
//  HaloDebugManager.m
//  HaloSlimFramework
//
//  Created by  on 13-5-27.
//
//

#import "HaloDebugManager.h"
#import "HaloDebug_UserTouchMap.h"
#import "DDFileLogger.h"
#import "HaloDebug_CustomFormatter.h"
#import "DDTTYLogger.h"
#import "HaloDebug_DebugViewController.h"

@implementation HaloDebugManager
SYNTHESIZE_ARC_SINGLETON_FOR_CLASS(HaloDebugManager)
- (void)enableDebugTouchMap
{
    [UIWindow swizzle];
}

- (void)enableLogToFile
{
    DDFileLogger *fileLoger = [[DDFileLogger alloc] init];
    fileLoger.rollingFrequency = 60*60*24;
    fileLoger.logFileManager.maximumNumberOfLogFiles = 7;
    [DDLog addLogger:fileLoger];
}

- (void)enableLogDebugWithCustomLogFormat
{
    HaloDebug_CustomFormatter *formaater = [[HaloDebug_CustomFormatter alloc] init];
    [[DDTTYLogger sharedInstance] setLogFormatter:formaater];
}

- (void)appendingLogText:(NSString *)string
{
    [[HaloDebug_DebugViewController sharedInstance] appendingLogText:string];
}
@end
