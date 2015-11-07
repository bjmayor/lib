//
//  HaloUpdateManager.h
//  
//
//  Created by  on 10-12-3.
//  Copyright 2010  . All rights reserved.
//
#import <MessageUI/MessageUI.h>
#import "HaloUIAlertView.h"

typedef enum{
    EUpdateSoftwareNone,
    EUpdateSoftwareNormal,
    EUpdateSoftwareForce
}UpdateSoftwareType;

@interface HaloUpdateManager : NSObject
{
    BOOL                fouceUpdateAlertShown;
}
SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(HaloUpdateManager)
- (void)showUpdateAlert;
- (void)clearUpdateCache;
- (NSInteger)checkUpdateMinuteInterval:(BOOL)WifiConnected;
//set network checkupdate to block
//if fromForce is YES do not show alert
- (void)checkUpdate:(void(^)(BOOL fromForce))block;
//when checkupdate finished use this function
- (void)checkUpdateFinished;
@end
