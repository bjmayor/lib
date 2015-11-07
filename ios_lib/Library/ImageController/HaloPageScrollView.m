//
//  HaloPageScrollViewController.m
//  HaloPageScroll
//
//  Created by peiqiang li on 12-3-7.
//  Copyright (c) 2012年 . All rights reserved.
//

#import "HaloPageScrollView.h"
#import "HaloPageView.h"
#import "HaloRecyclerManager.h"
#define KReusedPageCount 3
@interface HaloPageScrollView ()
{
    BOOL   _modifyContentOffset;
}
- (NSInteger)pagesCount;
- (void)updateViews;
- (NSInteger)visiblePageIndex;
- (void)displayPageAtIndex:(NSInteger)pageIndex;
- (void)cleanPageAtIndex:(NSInteger)pageIndex;
- (void)updateVisibleViews;
@end

@implementation HaloPageScrollView
@synthesize scrollView = _scrollView;
@synthesize dataSource = _dataSource;
@synthesize visibleArray = _visibleArray;
@synthesize currentPageIndex = _currentPageIndex;
@synthesize delegate = _delegate;
@synthesize pageHorizontalMargin = _pageHorizontalMargin;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleHeight;
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectInset(self.bounds, -self.pageHorizontalMargin, 0)];
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        [self addSubview:_scrollView];
        
        self.visibleArray = [NSMutableArray arrayWithCapacity:3];
        
        _lastPageIndex = -1;
        _recyclerManager = [[HaloRecyclerManager alloc] init];
    }
    return self;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    _scrollView.frame = CGRectInset(self.bounds, -self.pageHorizontalMargin, 0);
    [self updateViews];
}


- (void)reloadData
{
    [self updateViews];
}



- (NSInteger)pagesCount
{
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfPages)])
    {
        return [self.dataSource numberOfPages];
    }
    return 0;
}
- (void)updateViews
{
    NSInteger  currentPage  = [self visiblePageIndex];
    if (currentPage >= [self pagesCount] || currentPage == _lastPageIndex)
    {
        return;
    }
    self.currentPageIndex = currentPage;
    [self updateVisibleViews];
}
- (NSInteger)visiblePageIndex
{
    CGFloat  pageWidth = self.width + self.pageHorizontalMargin*2;
    CGFloat  offsetX =  _scrollView.contentOffset.x;
    NSInteger  pageIndex = floor((offsetX + pageWidth/2.0)/pageWidth);
    return pageIndex;
}

- (void)setPageHorizontalMargin:(CGFloat)pageHorizontalMargin
{
    _pageHorizontalMargin = pageHorizontalMargin;
}

- (void)displayPageAtIndex:(NSInteger)pageIndex
{
    for (NSInteger i = 0; i < self.visibleArray.count; i++)
    {
        UIView<HaloPageView>* page = [self.visibleArray objectAtIndex:i];
        if (page.pageIndex == pageIndex)//exist
        {
           // page.frame = CGRectMake(self.frame.size.width*pageIndex, 0, self.frame.size.width, self.frame.size.height);
            return;
        }
    }
        UIView<HaloPageView>* page = [self.dataSource pageViewAtIndex:pageIndex];
        page.pageIndex = pageIndex;
        page.frame = CGRectMake((self.width+self.pageHorizontalMargin*2)*pageIndex + self.pageHorizontalMargin, 0, self.width, self.height);
        [_scrollView addSubview:page];
        [self.visibleArray addObject:page];
}
- (void)cleanPageAtIndex:(NSInteger)pageIndex
{
    for (NSInteger i = 0; i < self.visibleArray.count; i++)
    {
        UIView<HaloPageView>* page = [self.visibleArray objectAtIndex:i];
        if (page.pageIndex == pageIndex)//exist
        {
            [_recyclerManager recycleView:page];
            [page removeFromSuperview];
            [self.visibleArray removeObject:page];
        }
    }
}
- (void)updateVisibleViews
{
    NSInteger leftPage = MAX(self.currentPageIndex - 1, 0);
    NSInteger rightPage = MIN(self.currentPageIndex + 1, [self pagesCount]);
    for (NSInteger i = 0; i < self.visibleArray.count; i++)
    {
        UIView<HaloPageView>* page = [self.visibleArray objectAtIndex:i];
        if (page.pageIndex < leftPage || page.pageIndex > rightPage)
        {
            [self cleanPageAtIndex:page.pageIndex];
        }
    }
    [self displayPageAtIndex:self.currentPageIndex];
    if (self.currentPageIndex > 0 )//left
    {
        [self displayPageAtIndex:self.currentPageIndex - 1];
    }
    if (self.currentPageIndex < [self pagesCount] - 1)//right
    {
        [self displayPageAtIndex:self.currentPageIndex + 1];
    }
    if (_lastPageIndex != self.currentPageIndex)
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(pageScrollView:didScrollToIndex:)])
        {
            [self.delegate pageScrollView:self didScrollToIndex:self.currentPageIndex];
        }
    }
    _lastPageIndex = self.currentPageIndex;
}

- (void)setCurrentPageIndex:(NSInteger)pageIndex  animated:(BOOL)animated
{
    if (_animating)
    {
        return;
    }
    _modifyContentOffset = NO;
    [_scrollView setContentOffset:CGPointMake((self.width + self.pageHorizontalMargin*2)*pageIndex, 0) animated:animated];
    _modifyContentOffset = YES;
    if (animated)
    {
        _animating = YES;
    }
}

- (void)moveToNextPage:(BOOL)animated
{
    if (self.currentPageIndex < [self pagesCount] - 1)
    {
        [self setCurrentPageIndex:self.currentPageIndex + 1 animated:animated];
    }
}
- (void)moveToLastPage:(BOOL)animated
{
    if (self.currentPageIndex > 0)
    {
        [self setCurrentPageIndex:self.currentPageIndex - 1 animated:animated];
    }
}

- (UIView<HaloPageView>*)currentView
{
    for (NSInteger i = 0; i < self.visibleArray.count; i++)
    {
        UIView<HaloPageView>* page = [self.visibleArray objectAtIndex:i];
        if (page.pageIndex == self.currentPageIndex)//current
        {
            return page;
        }
    }
    return nil;
}

- (void)setDataSource:(id<HaloPageDataSource>)dataSource
{
    if (_dataSource != dataSource)
    {
        _dataSource = dataSource;
        
        NSInteger  pageCount = [self pagesCount];
        CGFloat    pageWidth = self.width + self.pageHorizontalMargin*2;
        [_scrollView setContentSize:CGSizeMake(pageWidth*pageCount, self.frame.size.height)]; 
    }
}
- (id)dequeueReusableViewWithIdentifier:(NSString *)identifier
{
    return [_recyclerManager dequeueReusableViewWithIdentifier:identifier];
}
#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_modifyContentOffset)
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(pageScrollViewDidScroll:)])
        {
            [self.delegate pageScrollViewDidScroll:self];
        }  
    }
    [self updateViews];
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    _animating = NO;
}







@end
