//
//  HaloPageScrollViewController.h
//  HaloPageScroll
//
//  Created by peiqiang li on 12-3-7.
//  Copyright (c) 2012年 . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HaloPageScrollViewDataSource.h"
#import "HaloPageScrollViewDelegate.h"
#import "HaloRecyclerManager.h"

@class HaloRecyclableView;
@interface HaloPageScrollView : UIView<UIScrollViewDelegate>
{
    UIScrollView*                       _scrollView;


    NSMutableArray*                     _visibleArray;
    NSInteger                           _currentPageIndex;
    NSInteger                           _lastPageIndex;
    BOOL                                _animating;
    HaloRecyclerManager*                _recyclerManager;
    CGFloat                             _pageHorizontalMargin;
}
@property(nonatomic,strong)UIScrollView*                        scrollView;
@property(nonatomic,weak)id<HaloPageDataSource>               dataSource;
@property(nonatomic,weak)id<HaloPageDelegate>                 delegate;

@property(nonatomic,strong)NSMutableArray*                      visibleArray;
@property(nonatomic,assign)NSInteger                            currentPageIndex;
@property(nonatomic,assign)CGFloat                              pageHorizontalMargin;
- (void)reloadData;

- (id)dequeueReusableViewWithIdentifier:(NSString *)identifier;
- (void)setCurrentPageIndex:(NSInteger)pageIndex  animated:(BOOL)animated;
- (void)moveToNextPage:(BOOL)animated;
- (void)moveToLastPage:(BOOL)animated;


- (UIView<HaloPageView>*)currentView;
@end
