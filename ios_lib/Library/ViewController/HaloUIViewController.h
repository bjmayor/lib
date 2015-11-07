//
//  HaloViewController.h
//  Hello World
//
//  Created by  on 13-5-19.
//  Copyright (c) 2013年 __Company__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HaloUITableView.h"
#import "HaloUIWaitView.h"
#import "HaloHttpRequestDelegate.h"
#import "HaloHttpRequest.h"
#import "HaloUITableGroupCellBackgroundView.h"

#define KProgressHUDTag 0x100
#define KWaitViewTag 0x101

@interface HaloUIViewController : UIViewController<HaloHttpRequestDelegate,UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,assign) BOOL enableSwipeRightBack;
@property (nonatomic,strong) HaloUITableView *tableView;
@property (nonatomic,strong) NSMutableArray *dataSource;
@property (nonatomic,assign) BOOL cancelHttpRequestWhenDisappear;
- (BOOL)isTopViewController;
- (void)didReceiveMemoryWarningWhenNotInTop;
- (BOOL)autoDeselectRow;
- (void)postNotification:(NSString *)name object:(id)object;

- (void)back;
- (void)back:(BOOL)animated;
- (void)delayBack:(NSInteger)sec;
- (NSArray *)backToViewController:(Class)viewControllerClass animation:(BOOL)animation;
- (void)presentNaviModalViewController:(UIViewController*)viewController animated:(BOOL)animated;
@end

@interface HaloUIViewController (Navi)

- (NSInteger)naviHeight;

- (UIButton *)leftNaviButton;
- (UIButton *)rightNaviButton;

- (void)setLeftNaviButton:(UIButton *)button;
- (void)setRightNaviButton:(UIButton *)button;

- (void)setLeftNaviButtons:(NSArray *)buttonArray;
- (void)setRightNaviButtons:(NSArray *)buttonArray;

// 默认gap 为10
- (void)setLeftNaviButtons:(NSArray *)buttonArray gap:(CGFloat)gap;
- (void)setRightNaviButtons:(NSArray *)buttonArray gap:(CGFloat)gap;

- (UIButton *)cancelButton;

@end


/*
 ===================================================
 UITableView
 ===================================================
 */

@interface HaloUIViewController (TableView)

- (void)createTableView:(id)delegate;
- (void)createGroupedTableView:(id)delegate;

@end


@interface HaloUIViewController (HUD)
- (void)showWaitDialog:(NSString*)text;
- (void)dismissWaitDialog;
- (BOOL)showInfoViewInWindow;
- (HaloUIWaitView*)enableWaitInView:(BOOL)enable;
- (MBProgressHUD*)showInfoView:(NSString*)info;
- (MBProgressHUD*)showWarningView:(NSString*)warning;
@end

@interface HaloUIViewController (CustomGroup)
- (void)customGroupCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath backgroundViewBlock:(void(^)(HaloUITableGroupCellBackgroundView *))backgroundViewBlock selectedViewBlock:(void(^)(HaloUITableGroupCellBackgroundView *))selectedViewBlock;
@end