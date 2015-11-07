//
//  HaloPageScrollViewDelegate.h
//  HaloPageScroll
//
//  Created by peiqiang li on 12-3-7.
//  Copyright (c) 2012年 . All rights reserved.
//

#import <Foundation/Foundation.h>
@class HaloPageScrollView;
@protocol HaloPageDelegate <NSObject>
@optional
- (void)pageScrollView:(HaloPageScrollView*)pageScroll  didScrollToIndex:(NSInteger)index;
- (void)pageScrollViewDidScroll:(HaloPageScrollView *)pageScroll;

@end
