//
//  SysManager.m
//  
//
//  Created by  on 10-12-3.
//  Copyright 2010  . All rights reserved.
//

#import "HaloUpdateManager.h"
#import "HaloUIAlertView.h"

@interface HaloUpdateManager()
{
    HaloUIAlertView* (^showUpdateAlterViewBlock)(NSString *title,NSString *desc, BOOL force);
}
@end

@implementation HaloUpdateManager
SYNTHESIZE_ARC_SINGLETON_FOR_CLASS(HaloUpdateManager)

- (id)init
{
    if ((self = [super init]))
    {
    }
    return self;
}

- (void)initDone
{
	[NSThread detachNewThreadSelector:@selector(checkUpdate)toTarget:self withObject:nil];	
}

- (void)didUpdate:(NSNumber *)force
{
    HaloUserDefault *u = [HaloUserDefault sharedInstance];
    if (![force boolValue]) 
    {
        [u setDate:[NSDate dateWithTimeIntervalSince1970:0] forKey:SETTING_KEY_UPDATE_ALERT_TIME];
        [u setInt:EUpdateSoftwareNone forKey:SETTING_KEY_UPDATE];        
    }
	NSString *url = [u stringForKey:SETTING_KEY_UPDATE_URL defaultValue:@""];
    [OS openSafari:url];
}

- (void)quit
{
    exit(0);
}


- (void)showUpdateAlert
{    
    if (fouceUpdateAlertShown)
    {
        return;
    }
    HaloUserDefault *u = [HaloUserDefault sharedInstance];
    
    UpdateSoftwareType show = [u intForKey:SETTING_KEY_UPDATE defaultValue:EUpdateSoftwareNone];
	NSString *v = [u stringForKey:SETTING_KEY_UPDATE_VERSION defaultValue:@""];
    NSString *desc = [u stringForKey:SETTING_KEY_UPDATE_DESC defaultValue:@""];
	if (show!=EUpdateSoftwareNone && v.length > 0)
	{
		NSString *text = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"update_alert_text",@"Global",[Halo bundle], nil),v];
        //HaloUIAlertView *alert;
        if (show == EUpdateSoftwareNormal)
        {
            HaloUIAlertView *alert = nil;
            if ( showUpdateAlterViewBlock != nil )
            {
                alert = showUpdateAlterViewBlock(text,desc,NO);
            }
            else
            {
                alert = [HaloUIAlertView alertViewWithTitle:text message:desc cancelButtonTitle:NSLocalizedStringFromTableInBundle(@"update_button_delay",@"Global",[Halo bundle],nil) otherButtonTitles:NSLocalizedStringFromTableInBundle(@"update_button_ok",@"Global",[Halo bundle],nil), nil];
            }
            [alert show:^(HaloUIAlertView *alertView, NSInteger buttonIndex) {
                if ( buttonIndex != 0 )
                {
                    [self didUpdate:[NSNumber numberWithBool:NO]];
                }
            }];
            NSDate *now = [[NSDate date] dateByAddingTimeInterval:24*60*60];
            [u setDate:now forKey:SETTING_KEY_UPDATE_ALERT_TIME];
            [u setDate:[NSDate date] forKey:SETTING_KEY_UPDATE_LAST_CHECK];
        }
        else
        {
            HaloUIAlertView *alert = nil;
            if ( showUpdateAlterViewBlock != nil )
            {
                alert = showUpdateAlterViewBlock( text, desc,YES );
            }
            else
            {
                alert = [HaloUIAlertView alertViewWithTitle:text message:desc cancelButtonTitle:NSLocalizedStringFromTableInBundle(@"quit",@"Global",[Halo bundle],nil) otherButtonTitles:NSLocalizedStringFromTableInBundle(@"update_button_ok",@"Global",[Halo bundle],nil), nil];
            }
            [alert show:^(HaloUIAlertView *alertView, NSInteger buttonIndex) {
                if ( buttonIndex != 0)
                {
                    [self didUpdate:[NSNumber numberWithBool:YES]];
                }
                else
                {
                    [self quit];
                }
            }];
            
        }
    }
}


#pragma mark -
- (NSInteger)checkUpdateMinuteInterval:(BOOL)WifiConnected
{
    return 4*60;
}

- (void)clearUpdateCache
{
    HaloUserDefault *u = [HaloUserDefault sharedInstance];
    [u setInt:EUpdateSoftwareNone forKey:SETTING_KEY_UPDATE];
    [u setDate:nil forKey:SETTING_KEY_UPDATE_LAST_CHECK];
    [u setString:nil forKey:SETTING_KEY_UPDATE_VERSION];
    [u setString:nil forKey:SETTING_KEY_UPDATE_URL];
    [u setString:nil forKey:SETTING_KEY_UPDATE_DESC];
    [u setString:nil forKey:SETTING_KEY_UPDATE_TIME];    
}

- (void)checkUpdate:(void(^)(BOOL fromForce))block
{
    if (block)
    {
        @autoreleasepool
        {
            [NSThread sleepForTimeInterval:0.1f];
            HaloUserDefault *u = [HaloUserDefault sharedInstance];
            UpdateSoftwareType needUpdate = [u intForKey:SETTING_KEY_UPDATE defaultValue:EUpdateSoftwareNone];
            NSDate *alertTime = [u dateForKey:SETTING_KEY_UPDATE_ALERT_TIME defaultValue:[NSDate dateWithTimeIntervalSince1970:0]];
            NSDate *now = [NSDate date];
            
            if (needUpdate == EUpdateSoftwareForce)
            {
                [self performSelectorOnMainThread:@selector(showUpdateAlert)withObject:nil waitUntilDone:NO];
                block(YES);
            }
            else if (needUpdate==EUpdateSoftwareNormal &&  [now compare:alertTime] == NSOrderedDescending)
            {
                [self performSelectorOnMainThread:@selector(showUpdateAlert)withObject:nil waitUntilDone:NO];
            }
            else
            {
                NSDate *lastCheck = [u dateForKey:SETTING_KEY_UPDATE_LAST_CHECK defaultValue:now];
                NSInteger intval = [now timeIntervalSinceDate:lastCheck];
                //check update after install or every 4 hours or has wifi
                
                if (intval == 0 || intval >= [self checkUpdateMinuteInterval:NO]*60 || ([UIDevice isWifiConnected] && intval>[self checkUpdateMinuteInterval:YES]*60))
                {
                    DDLogCInfo(@"checkUpdate");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        block(NO);
                    });
                    
                }
                if (lastCheck == now)
                {
                    [u setDate:lastCheck forKey:SETTING_KEY_UPDATE_LAST_CHECK];
                }
            }   
        }
    }
}

- (void)checkUpdateFinished
{
    HaloUserDefault *u = [HaloUserDefault sharedInstance];
    [u setDate:[NSDate date] forKey:SETTING_KEY_UPDATE_LAST_CHECK];
}
@end
