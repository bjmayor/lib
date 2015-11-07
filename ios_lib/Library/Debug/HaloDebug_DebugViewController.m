//
//  HaloDebug_DebugViewController.m
//  WCard
//
//  Created by Zchin Hsu on 13-4-25.
//  Copyright (c) 2013年 . All rights reserved.
//

#import "HaloDebug_DebugViewController.h"
#import "HaloDebug_DebugWindow.h"
#import "HaloDebug_ActiveViewControllerMonitor.h"
#import "HaloDebug_LogViewController.h"
#import "HaloDebug_ActiveShowViewController.h"

@interface HaloDebug_DebugViewController ()

@end

@implementation HaloDebug_DebugViewController

SYNTHESIZE_ARC_SINGLETON_FOR_CLASS(HaloDebug_DebugViewController)

- (id)init
{
    self = [super init];
    if (self)
    {
        TextStyle *style = [[TextStyle alloc] init];
        style.color = [UIColor colorWithRGBA:0xf4f4f4FF];
        
        NSMutableArray *items = [NSMutableArray array];
        
        items = [NSMutableArray arrayWithObjects:
                 [[HaloTabBarItem alloc] initWithControllerClass:[HaloDebug_LogViewController class] image:[UIImage imageNamed:@"Halo.bundle/images/debug_log"] highlightedImage:[UIImage imageNamed:@"Halo.bundle/images/debug_log"]title:@"Log" titleFont:nil titleNormalStyle:style titleHighlightStyle:style],
                 [[HaloTabBarItem alloc] initWithControllerClass:[HaloDebug_ActiveShowViewController class] image:[UIImage imageNamed:@"Halo.bundle/images/debug_active"] highlightedImage:[UIImage imageNamed:@"Halo.bundle/images/debug_active"]title:@"Active" titleFont:nil titleNormalStyle:style titleHighlightStyle:style],
                 /*[[HaloTabBarItem alloc] initWithControllerClass:[HaloDebug_ActiveShowViewController class] image:[HaloTheme imageNamed:@"Tabbar/message"] highlightedImage:[HaloTheme imageNamed:@"Tabbar/message"] title:@"Setting" titleFont:nil titleNormalStyle:style titleHighlightStyle:style],*/nil];
        self.items = items;
    }
    return self;
}

- (void)loadView
{
    self.tabBarHeight = 50;
    [super loadView];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.tabBarView.backgroundColor = [UIColor clearColor];
    self.tabBarView.bgImage = nil;
    
    UISwipeGestureRecognizer *swipeGR = [[UISwipeGestureRecognizer alloc] init];
    swipeGR.numberOfTouchesRequired = 3;
    swipeGR.direction = UISwipeGestureRecognizerDirectionRight;
    [swipeGR addTarget:self action:@selector(hideDebugView)];
    [self.view addGestureRecognizer:swipeGR];
    
    
    self.tabBarViewEdgeInsets = UIEdgeInsetsMake(0, 0, -4, 0);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    

}

- (void)hideDebugView
{
    [HaloDebug_DebugWindow sharedInstance].hidden = YES;
}



- (void)appendingLogText:(NSString *)newLogText;
{
    HaloDebug_LogViewController *vc = (HaloDebug_LogViewController *)[self viewControllerAtIndex:0];
    
    [vc appendingLogText:newLogText];
}
@end
