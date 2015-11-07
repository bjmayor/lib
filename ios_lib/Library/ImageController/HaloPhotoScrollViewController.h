//
//  HaloPhotoScrollViewController.h
//  YContact
//
//  Created by peiqiang li on 12-3-7.
//  Copyright (c) 2012年 . All rights reserved.
//

#import "HaloUIViewController.h"
#import "HaloPageScrollViewDelegate.h"
#import "HaloPageScrollViewDataSource.h"
#import "HaloPageScrollView.h"
#import "HaloImageView.h"
#import "ImageInfo.h"
@class HaloPhotoScrollViewController;
@protocol HaloPhotoScrollViewControllerDelegate<NSObject>
@optional
- (void)didDeleteImage:(HaloPhotoScrollViewController *)viewController;
- (UIBarButtonItem *)setPhotoNaviRightButton;
@end
typedef enum
{
    ENaviRightNone,
    ENaviRightSave,
    ENaviRightDelete,
}NaviRightButtonType;
@interface HaloPhotoScrollViewController : HaloUIViewController<HaloPageDataSource,HaloPageDelegate,HaloImageViewDelegate>
{
    BOOL                            _hiddenToolbarWhenScroll;
    NaviRightButtonType             _naviRightButtonType;
    CGFloat                         _pageHorizontalMargin;
}
@property(nonatomic,assign)NSInteger            currentPageIndex;
@property(nonatomic,assign)BOOL                 hiddenToolbarWhenScroll;
@property(nonatomic,assign)BOOL                 showPrompt;
@property(nonatomic,assign)NaviRightButtonType  naviRightButtonType;
@property(nonatomic,weak)id<HaloPhotoScrollViewControllerDelegate>   delegate;
@property(nonatomic,assign)CGFloat              pageHorizontalMargin;
@property(nonatomic,strong)UIBarButtonItem      *naviRightButton;

//@property(nonatomic,assign)BOOL                 showPageCounter;
@property(nonatomic,strong)UILabel              *pageCounterLabel;

- (id)initWithUrl:(NSString*)imageUrl;
- (id)initWithImage:(UIImage*)image;
- (id)initWithUrl:(NSString *)imageUrl placeHolderImage:(UIImage *)image;

- (void)updatePromptText:(NSInteger)page;
- (void)enableCounterLabel;
@end
