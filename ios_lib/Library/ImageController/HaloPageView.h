//
//  HaloPageView.h
//  HaloPageScroll
//
//  Created by peiqiang li on 12-3-7.
//  Copyright (c) 2012年 . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HaloRecyclableView.h"
@protocol HaloPageView <HaloRecyclableView>
@property(nonatomic,assign)NSInteger                pageIndex;
@end
