//
//  HaloDebug_CustomFormatter.m
//  YConference
//
//  Created by  on 13-5-17.
//  Copyright (c) 2013年  Ltd., Co. All rights reserved.
//

#import "HaloDebug_CustomFormatter.h"
#import "HaloDebug_DebugViewController.h"
@implementation HaloDebug_CustomFormatter

- (id)init
{
    self = [super init];
    if (self)
    {
        dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    }
    return self;
}

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage
{
    NSString *logLevel;
    switch (logMessage->logFlag)
    {
        case LOG_FLAG_ERROR : logLevel = @"E"; break;
        case LOG_FLAG_WARN  : logLevel = @"W"; break;
        case LOG_FLAG_INFO  : logLevel = @"I"; break;
        default             : logLevel = @"V"; break;
    }
    NSString *logStr = [NSString stringWithFormat:@"[%@] [%@] [%s %d] [%s]: %@\n \n", logLevel, [dateFormatter stringFromDate:logMessage->timestamp], logMessage->function, logMessage->lineNumber,logMessage->queueLabel , logMessage->logMsg ];
    [[HaloDebug_DebugViewController sharedInstance] appendingLogText:logStr];
    return logStr;
}

@end
