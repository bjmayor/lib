//
//  CaptureImageManager.m
//  ShackBug
//
//  Created by sub on 13-5-30.
//  Copyright (c) 2013年 Sub. All rights reserved.
//

#import "HaloDebug_ShakeBugManager.h"
#import<QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>
#import <objc/runtime.h>
#import "HaloDebug_ShakeBugViewController.h"
#import "HaloDebug_ShakeBugInfo.h"
#import "HaloUIManager.h"
#import "HaloUIAlertView.h"
#import "HaloUIActionSheet.h"
#import "HaloFileUtil.h"
#import "HaloUserDefault.h"
#define KImgPath @"shake_screenshot.jpg"

@interface HaloDebug_ShakeBugManager()
@end

@implementation HaloDebug_ShakeBugManager

SYNTHESIZE_ARC_SINGLETON_FOR_CLASS(HaloDebug_ShakeBugManager)

- (void)gotoShakeBugViewController
{
    HaloDebug_ShakeBugViewController *bugDetailViewController = [[HaloDebug_ShakeBugViewController alloc]init];
    [bugDetailViewController setFinishBLock:self.finishBlock];
    [[HaloUIManager sharedInstance].window.rootViewController.navigationController pushViewController:bugDetailViewController animated:YES];
}

- (void)captureImage
{
    [self screenShot];
    __weak HaloDebug_ShakeBugManager *weakSelf = self;
    if ([[HaloUserDefault sharedInstance]boolForKey:SETTING_KEY_FIRST_SHAKE defaultValue:YES])
    {
        
        [HaloUIAlertView showAlertWithTitle:NSLocalizedStringFromTable(@"feedback_help_title", @"Other", @"shake bug设置提示") message:NSLocalizedStringFromTable(@"shake_content", @"Other", @"shake bug设置提示内容") block:^(HaloUIAlertView *alertView, NSInteger buttonIndex) {
            HaloDebug_ShakeBugManager *strongSelf = weakSelf;
            
            [[HaloUserDefault sharedInstance]setBool:NO forKey:SETTING_KEY_FIRST_SHAKE];
            if (buttonIndex == 0)
            {
                [strongSelf resetManager];
            }
            else
            {
                [strongSelf gotoShakeBugViewController];
            }
        } cancelButtonTitle:NSLocalizedString(@"cancel", nil)otherButtonTitles:NSLocalizedStringFromTable(@"shake_bug_title", @"Other", @"shake bug添加详情按钮title"), nil];
    }
    else
    {

        HaloUIActionSheet *mySheet = [[HaloUIActionSheet alloc] initWithTitle:nil cancelButtonTitle:NSLocalizedString(@"cancel", nil)];
        
        [mySheet addItemWithTitle:NSLocalizedStringFromTable(@"shake_bug_title", @"Other", @"shake bug添加详情按钮title") isRed:NO block:^{
            HaloDebug_ShakeBugManager *strongSelf = weakSelf;
            [strongSelf gotoShakeBugViewController];
        }];

        [mySheet showWithDismissBlock:^{
            HaloDebug_ShakeBugManager *strongSelf = weakSelf;
            [strongSelf resetManager];
        }];
    }
}

- (void)screenShot
{
    //vibrate
    AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
    self.hasCaptureImage = YES;
    CGSize size = [UIApplication sharedApplication].keyWindow.size;
    
    UIGraphicsBeginImageContextWithOptions(size, NO,[UIScreen mainScreen].scale);
    CGContextRef ref= UIGraphicsGetCurrentContext();
    for (UIWindow *window in [[UIApplication sharedApplication] windows])
    {
        CGContextSaveGState(ref);
        [[window layer] renderInContext:ref];
        CGContextRestoreGState(ref);
    }
    Ivar test =  class_getInstanceVariable([UIApplication class], "_statusBar");
    UIView *status = object_getIvar([UIApplication sharedApplication],test);
    [status.layer renderInContext:ref];
    
    self.capturedimage= UIGraphicsGetImageFromCurrentImageContext();
    NSString *path = [HaloFileUtil fileWithDocumentsPath:KImgPath];
    self.imagePath = path;
    [UIImageJPEGRepresentation(self.capturedimage, 0.7) writeToFile:path atomically:NO];
    UIGraphicsEndImageContext();
    
}

- (void)resetManager
{
    self.capturedimage = nil;
    self.imagePath = nil;
    self.hasCaptureImage = NO;
}

- (NSString *)obtainEmailStr
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:@"reporter_email"];
}

@end
