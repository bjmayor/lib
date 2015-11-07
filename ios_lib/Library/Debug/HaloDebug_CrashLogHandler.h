//
//  HaloDebug_CrashLogHandler.h
//  YConference
//
//  Created by  on 13-5-31.
//  Copyright (c) 2013年  Ltd., Co. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface HaloDebug_CrashLogHandler : NSObject
SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(HaloDebug_CrashLogHandler)
@property(nonatomic, assign)BOOL dismissed;

//Default path is :Libary/Caches/Logs/CrashLog.txt
@property(nonatomic, copy)NSString *logPath;

@property(nonatomic, copy)void(^finishBlock)(NSException *exception);
@property(nonatomic, assign)BOOL  archiveAll;
@end

void InstallUncaughtExceptionHandler();