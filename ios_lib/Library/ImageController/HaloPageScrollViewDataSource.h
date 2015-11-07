//
//  HaloPageScrollViewDataSource.h
//  HaloPageScroll
//
//  Created by peiqiang li on 12-3-7.
//  Copyright (c) 2012年 . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HaloPageView.h"
@protocol HaloPageDataSource <NSObject>
- (UIView< HaloPageView>*)pageViewAtIndex:(NSInteger)index;
- (NSInteger)numberOfPages;
@end
