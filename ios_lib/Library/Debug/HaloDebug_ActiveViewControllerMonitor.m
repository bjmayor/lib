//
//  HaloDebug_ActiveVCManager.m
//  WCard
//
//  Created by Zchin Hsu on 13-4-24.
//  Copyright (c) 2013年 . All rights reserved.
//




#import "HaloDebug_ActiveViewControllerMonitor.h"

@interface HaloDebug_ActiveViewControllerMonitor ()

@property(nonatomic, strong, readwrite)NSMutableArray *activeViewControllerArray;

@end

@implementation HaloDebug_ActiveViewControllerMonitor

SYNTHESIZE_ARC_SINGLETON_FOR_CLASS(HaloDebug_ActiveViewControllerMonitor)

- (id)init
{
    if (self = [super init])
    {
        self.activeViewControllerArray = [NSMutableArray array];
    }
    
    return self;
}

- (void)addActiveViewController:(UIViewController *)vc
{
//    UINavigationController *nav = [HaloUIManager sharedInstance].navigationController;
    
//    NSArray *array = nav.viewControllers;
    
//    for (UIViewController *v in array)
//    {
//        LOG_DEBUG(@"--------%@", [v description]);
//    }
    
    [self.activeViewControllerArray addObject:[vc description]];
    
}

- (void)removeActiveViewController:(UIViewController *)vc
{
//    LOG_DEBUG(@"--------%@", [vc description]);
    
    [self.activeViewControllerArray removeObject:[vc description]];
    
//    LOG_DEBUG(@"--------%d", self.activeViewControllerArray.count);
}

@end
