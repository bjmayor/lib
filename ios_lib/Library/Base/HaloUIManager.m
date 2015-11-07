//
//  HaloUIManager.m
//  Hello World
//
//  Created by  on 13-5-19.
//  Copyright (c) 2013年 __Company__. All rights reserved.
//

#import "HaloUIManager.h"

@implementation HaloUIManager
SYNTHESIZE_ARC_SINGLETON_FOR_CLASS(HaloUIManager)

- (id)init
{
    if (self = [super init])
    {
        _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        [self.window makeKeyAndVisible];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShowNotification:) name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideNotification) name:UIKeyboardWillHideNotification object:nil];
    }
    
    return self;
}

- (void)startFromViewController:(UIViewController *)viewController
{
    UIViewController *vc = viewController;
    
    if ([vc isKindOfClass:[UITabBarController class]])
    {
        self.window.rootViewController = vc;
    }
    else
    {
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        self.window.rootViewController = nav;
    }
}

- (UIViewController *)topViewController
{
    if ([self.window.rootViewController isKindOfClass:[UITabBarController class]])
    {
        UITabBarController *tabVc = (UITabBarController *)self.window.rootViewController;
        return tabVc.selectedViewController;
    }
    else
    {
        return self.window.rootViewController.navigationController.topViewController;
    }
}

- (void)keyboardDidShowNotification:(NSNotification *)notification
{
    NSDictionary *dict = notification.userInfo;
    self.keyboardIsShown = YES;
    self.keyboardRect = [[dict objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
}

- (void)keyboardWillHideNotification
{
    self.keyboardIsShown = NO;
}
@end
