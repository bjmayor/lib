//
//  HaloDebug_ActiveVCManager.h
//  WCard
//
//  Created by Zchin Hsu on 13-4-24.
//  Copyright (c) 2013年 . All rights reserved.
//

#import "HaloUIViewController.h"


@interface HaloDebug_ActiveViewControllerMonitor : NSObject

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(HaloDebug_ActiveViewControllerMonitor)

@property(nonatomic, strong, readonly)NSMutableArray *activeViewControllerArray;

- (void)addActiveViewController:(UIViewController *)vc;
- (void)removeActiveViewController:(UIViewController *)vc;

@end


