//
//  BugDetailViewController.h
//  ShackBug
//
//  Created by sub on 13-5-31.
//  Copyright (c) 2013年 Sub. All rights reserved.
//


#import <HaloUIViewController.h>
#import "HaloDebug_ShakeBugManager.h"
@interface HaloDebug_ShakeBugViewController : HaloUIViewController
@property(nonatomic, copy)FinishBlock finishBLock;
@property(nonatomic, strong)UIButton *rightNaviBtn;

- (void)setFinishBLock:(FinishBlock)finishBLock;
@end
