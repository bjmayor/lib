//
//  HaloDebug_DebugViewController.h
//  WCard
//
//  Created by Zchin Hsu on 13-4-25.
//  Copyright (c) 2013年 . All rights reserved.
//


#import "HaloUIViewController.h"
#import "HaloUITabBarController.h"

@interface HaloDebug_DebugViewController : HaloUITabBarController

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(HaloDebug_DebugViewController)

- (void)appendingLogText:(NSString *)newLogText;
@end
