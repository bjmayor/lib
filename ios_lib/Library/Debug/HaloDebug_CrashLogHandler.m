//
//  HaloDebug_CrashLogHandler.m
//  YConference
//
//  Created by  on 13-5-17.
//  Copyright (c) 2013年  Ltd., Co. All rights reserved.
//

#import "HaloDebug_CrashLogHandler.h"
#include <libkern/OSAtomic.h>
#include <execinfo.h>

NSString * const UncaughtExceptionHandlerSignalExceptionName = @"UncaughtExceptionHandlerSignalExceptionName";
NSString * const UncaughtExceptionHandlerSignalKey = @"UncaughtExceptionHandlerSignalKey";
NSString * const UncaughtExceptionHandlerAddressesKey = @"UncaughtExceptionHandlerAddressesKey";

volatile int32_t UncaughtExceptionCount = 0;
const int32_t UncaughtExceptionMaximum = 10;

const NSInteger UncaughtExceptionHandlerSkipAddressCount = 4;
const NSInteger UncaughtExceptionHandlerReportAddressCount = 5;

@implementation HaloDebug_CrashLogHandler
SYNTHESIZE_ARC_SINGLETON_FOR_CLASS(HaloDebug_CrashLogHandler)
@synthesize logPath = _logPath;
+ (NSArray *)backtrace
{
    void* callstack[128];
    int frames = backtrace(callstack, 128);
    char **strs = backtrace_symbols(callstack, frames);
    
    int i;
    NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
    for (
         i = UncaughtExceptionHandlerSkipAddressCount;
         i < UncaughtExceptionHandlerSkipAddressCount +
         UncaughtExceptionHandlerReportAddressCount;
         i++)
    {
	 	[backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
    }
    free(strs);
    
    return backtrace;
}

- (void)alertView:(UIAlertView *)anAlertView clickedButtonAtIndex:(NSInteger)anIndex
{
	if (anIndex == 0)
	{
		_dismissed = YES;
	}
}

- (void)saveCrashException:(NSException *)exception
{    
    if (self.finishBlock)
    {
        self.finishBlock(exception);
    }
    
    NSArray *arr = [[exception userInfo] objectForKey:UncaughtExceptionHandlerAddressesKey];
    NSString *reason = [exception reason];
    NSString *name = [exception name];
    
    NSDate *date = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: date];
    NSDate *localeDate = [date  dateByAddingTimeInterval: interval];
    
    NSString *content = [NSString stringWithFormat:@"=============Crash Report=============\ntime:%@\nname:\n%@\nreason:\n%@\ncallStackSymbols:\n%@\n\n\n",localeDate,name,reason,[arr componentsJoinedByString:@"\n"]];
    
    // write to log file
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:self.logPath])
    {
        [fm createFileAtPath:self.logPath contents:nil attributes:NULL];
    }
    
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:self.logPath];
    if (fileHandle == nil)
    {
        DDLogError(@"%@ do not exist",self.logPath);
    }
    if (self.archiveAll)
    {
        [fileHandle seekToEndOfFile];
    }
    NSData *buffer = [content dataUsingEncoding:NSUTF8StringEncoding];
    [fileHandle writeData:buffer];
    [fileHandle closeFile];
    
}

- (NSString *)logPath
{
    if (!_logPath)
    {
        self.logPath = [[self applicationLibDirectory] stringByAppendingPathComponent:@"Logs/CrashLog.txt"];
    }
    return _logPath;
}


- (NSString *)applicationLibDirectory
{
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    return path;
    
}

- (void)handleException:(NSException *)exception
{
    DDLogError(@"%@",exception.description);
	[self saveCrashException:exception];
	
//	UIAlertView *alert =
//    [[UIAlertView alloc]
//      initWithTitle:NSLocalizedString(@"Unhandled exception", nil)
//      message:[NSString stringWithFormat:NSLocalizedString(
//                                                           @"You can try to continue but the application may be unstable.\n\n"
//                                                           @"Debug details follow:\n%@\n%@", nil),
//               [exception reason],
//               [[exception userInfo] objectForKey:UncaughtExceptionHandlerAddressesKey]]
//      delegate:self
//      cancelButtonTitle:NSLocalizedString(@"Quit", nil)
//      otherButtonTitles:NSLocalizedString(@"Continue", nil), nil]
//     ;
//	[alert show];
	
//	CFRunLoopRef runLoop = CFRunLoopGetCurrent();
//	CFArrayRef allModes = CFRunLoopCopyAllModes(runLoop);
//	
//	while (!_dismissed)
//	{
//		for (NSString *mode in (__bridge NSArray *)allModes)
//		{
//			CFRunLoopRunInMode((__bridge CFStringRef)mode, 0.001, false);
//		}
//	}
//	
//	CFRelease(allModes);
    
	NSSetUncaughtExceptionHandler(NULL);
	signal(SIGABRT, SIG_DFL);
	signal(SIGILL, SIG_DFL);
	signal(SIGSEGV, SIG_DFL);
	signal(SIGFPE, SIG_DFL);
	signal(SIGBUS, SIG_DFL);
	signal(SIGPIPE, SIG_DFL);
	
	if ([[exception name] isEqual:UncaughtExceptionHandlerSignalExceptionName])
	{
		kill(getpid(), [[[exception userInfo] objectForKey:UncaughtExceptionHandlerSignalKey] intValue]);
	}
	else
	{
		[exception raise];
	}
}

@end

void HandleException(NSException *exception)
{
	int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
	if (exceptionCount > UncaughtExceptionMaximum)
	{
		return;
	}
	
	NSMutableDictionary *userInfo =
    [NSMutableDictionary dictionaryWithDictionary:[exception userInfo]];
    
    //如果exception存在栈信息
    if ([exception callStackSymbols].count > 0)
    {
        [userInfo setObject:[exception callStackSymbols]forKey:UncaughtExceptionHandlerAddressesKey];
    }
    else
    {        
        NSArray *callStack = [HaloDebug_CrashLogHandler backtrace];
        [userInfo
         setObject:callStack
         forKey:UncaughtExceptionHandlerAddressesKey];
        
    }
    
	
	[[HaloDebug_CrashLogHandler sharedInstance]
     performSelectorOnMainThread:@selector(handleException:)
     withObject:
     [NSException
      exceptionWithName:[exception name]
      reason:[exception reason]
      userInfo:userInfo]
     waitUntilDone:YES];
}

void SignalHandler(int signal)
{
	int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
	if (exceptionCount > UncaughtExceptionMaximum)
	{
		return;
	}
	
	NSMutableDictionary *userInfo =
    [NSMutableDictionary
     dictionaryWithObject:[NSNumber numberWithInt:signal]
     forKey:UncaughtExceptionHandlerSignalKey];
    
	NSArray *callStack = [HaloDebug_CrashLogHandler backtrace];
	[userInfo
     setObject:callStack
     forKey:UncaughtExceptionHandlerAddressesKey];
	
	[[HaloDebug_CrashLogHandler sharedInstance]
     performSelectorOnMainThread:@selector(handleException:)
     withObject:
     [NSException
      exceptionWithName:UncaughtExceptionHandlerSignalExceptionName
      reason:
      [NSString stringWithFormat:
       NSLocalizedString(@"Signal %d was raised.", nil),
       signal]
      userInfo:
      [NSDictionary
       dictionaryWithObject:[NSNumber numberWithInt:signal]
       forKey:UncaughtExceptionHandlerSignalKey]]
     waitUntilDone:YES];
}

void InstallUncaughtExceptionHandler()
{
	NSSetUncaughtExceptionHandler(&HandleException);
	signal(SIGABRT, SignalHandler);
	signal(SIGILL, SignalHandler);
	signal(SIGSEGV, SignalHandler);
	signal(SIGFPE, SignalHandler);
	signal(SIGBUS, SignalHandler);
	signal(SIGPIPE, SignalHandler);
}

