//
//  HaloViewController.m
//  Hello World
//
//  Created by  on 13-5-19.
//  Copyright (c) 2013年 __Company__. All rights reserved.
//

#import "HaloUIViewController.h"
#import "HaloDebug_DebugWindow.h"
#import "HaloDebug_ActiveViewControllerMonitor.h"


@interface HaloUIViewController ()<UIGestureRecognizerDelegate>
@property (nonatomic,strong) MBProgressHUD *progressHUD;
@property (nonatomic,assign) BOOL isTop;
@end

@implementation HaloUIViewController
- (id)init
{
	if((self = [super init]))
	{
        self.cancelHttpRequestWhenDisappear = YES;
        [[HaloDebug_ActiveViewControllerMonitor sharedInstance] addActiveViewController:self];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.enableSwipeRightBack)
    {
        [self addSwipeRightBackGestureRecognizer];
    }
    DDLogInfo(@"%@ is didLoad",[self description]);
    
#ifdef HaloDebugEnable
    UISwipeGestureRecognizer *swipeGR = [[UISwipeGestureRecognizer alloc] init];
    swipeGR.numberOfTouchesRequired = 3;
    swipeGR.delegate = self;
    swipeGR.direction = UISwipeGestureRecognizerDirectionLeft;
    [swipeGR addTarget:self action:@selector(showDebugView)];
    
    [self.view addGestureRecognizer:swipeGR];
#endif
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.isTop = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([self autoDeselectRow])
    {
        if (self.tableView.indexPathForSelectedRow)
        {
            [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
        }        
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.isTop = NO;
	[self dismissWaitDialog];
    if (self.cancelHttpRequestWhenDisappear)
    {
        [HaloHttpRequest cancelRequest:self];
    }
}

- (void)showDebugView
{
    DDLogInfo(@"%@", @"showDebugView");
    
    [HaloDebug_DebugWindow sharedInstance].hidden = NO;
}

- (void)addSwipeRightBackGestureRecognizer
{
    // 右滑back 手势
    UISwipeGestureRecognizer *swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRightBack:)];
    swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeGestureRecognizer];
}

- (void)handleSwipeRightBack:(UISwipeGestureRecognizer *)gestureRecognizer
{
//    if (!self.enableSwipeRightBack || ![self leftNaviButton] )
//    {
//        return;
//    }
    
    if (self.enableSwipeRightBack)
    {
        if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
        {
            [self back];
//            if (self.enableSwipeRightBack)
//            {
//            }
        }
    }
}

- (void)back
{
    [self back:YES];
}

- (void)back:(BOOL)animated
{
    if (self.navigationController.viewControllers.count>1)
    {
        [self.navigationController popViewControllerAnimated:animated];
    }
    else
    {
        [self dismissViewControllerAnimated:animated completion:nil];
    }
}

- (void)delayBack:(NSInteger)sec
{
    [NSTimer scheduledTimerWithTimeInterval:sec target:self selector:@selector(back) userInfo:nil repeats:NO];
}

- (NSArray *)backToViewController:(Class)viewControllerClass animation:(BOOL)animation
{
    NSArray *controllers = self.navigationController.viewControllers;
    UIViewController *vc = nil;
    for(int i = controllers.count - 1; i > 0; i--)
    {
        if ([controllers[i] isKindOfClass:viewControllerClass])
        {
            vc = controllers[i];
            break;
        }
    }
    return [self.navigationController popToViewController:vc animated:YES];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[HaloDebug_ActiveViewControllerMonitor sharedInstance] removeActiveViewController:self];
}

- (void)didReceiveMemoryWarning
{
    if (![self isTopViewController])
    {
        self.view = nil;
        [self didReceiveMemoryWarningWhenNotInTop];
    }
}

- (void)didReceiveMemoryWarningWhenNotInTop
{
    [self.tableView removeFromSuperview];
    self.tableView = nil;
}

- (BOOL)isTopViewController
{
    if ([self isViewLoaded])
    {
//        return self.navigationController.topViewController == self && self.view.window != nil;
        return self.isTop;
    }
    else
    {
        return NO;
    }
}

- (BOOL)autoDeselectRow
{
    return YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (void)postNotification:(NSString *)name object:(id)object
{
    dispatch_block_t block = ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:name object:object];
    };
    
    if ([NSThread isMainThread])
    {
        block();
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            block();
        });
    }
}

- (void)presentNaviModalViewController:(UIViewController*)viewController animated:(BOOL)animated
{
    UINavigationController  *nav = [[UINavigationController alloc] initWithRootViewController:viewController];
    if ([viewController isKindOfClass:[HaloUIViewController class]])
    {
        HaloUIViewController *vc = (HaloUIViewController *)viewController;
        UIButton *cancelBtn = [vc cancelButton];
        [cancelBtn addTarget:vc action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        [vc setLeftNaviButton:cancelBtn];
    }
    [self presentViewController:nav animated:animated completion:nil];
}
@end

@implementation HaloUIViewController(navi)
- (NSInteger)naviHeight
{
    return self.navigationController.navigationBarHidden? 0: self.navigationController.navigationBar.height;
}

- (UIButton *)leftNaviButton
{
	return (UIButton *)self.navigationItem.leftBarButtonItem.customView;
}

- (UIButton *)rightNaviButton
{
	return (UIButton *)self.navigationItem.rightBarButtonItem.customView;
}

- (void)setLeftNaviButton:(UIButton*)button
{
    [self setLeftNaviButtons:button ? @[button] : nil];
}

- (void)setRightNaviButton:(UIButton*)button
{
    [self setRightNaviButtons:button ? @[button] : nil];
}

- (void)setLeftNaviButtons:(NSArray *)buttonArray
{
    [self setNaviButtons:buttonArray isLeft:YES gap:10];
}

- (void)setRightNaviButtons:(NSArray *)buttonArray
{
    
    [self setNaviButtons:buttonArray isLeft:NO gap:10];
    
}

- (void)setLeftNaviButtons:(NSArray *)buttonArray gap:(CGFloat)gap
{
    
    [self setNaviButtons:buttonArray isLeft:YES gap:gap];
    
}

- (void)setRightNaviButtons:(NSArray *)buttonArray gap:(CGFloat)gap
{
    
    [self setNaviButtons:buttonArray isLeft:NO gap:gap];
    
}

// 设置NaviButton 的 tag, tag中包含信息有: 左 or 右 | 所处的次序 | 与外侧button 的gap
// 左侧为负值, 右侧为正值
// 举例: 左边有三个NaviButton, gap为10 其tag 分别会设置为 -(1000000 + 10), -(2000000 + 10), -(3000000 + 10)
//      右边有三个NaviButton, gap为10 其tag 分别会设置为 (1000000 + 10), (2000000 + 10), (3000000 + 10)
- (void)setNaviButtons:(NSArray *)buttonArray isLeft:(BOOL)isLeft gap:(CGFloat)gap
{
    NSMutableArray *itemArray = [NSMutableArray arrayWithCapacity:buttonArray.count];
    
//    NSInteger i = 1;
    for (UIButton *button in buttonArray)
    {
//        button.tag = (KHaloNaviBarItemTagBase * i + gap) * (isLeft? -1: 1);
//        i++;
        
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
        [itemArray addObject:item];
    }
    
    if (isLeft)
    {
        if (itemArray.count == 0)
        {
            [self.navigationItem setHidesBackButton:YES];
        }
        else
        {
            [self.navigationItem setHidesBackButton:NO];
            [self.navigationItem setLeftBarButtonItems:itemArray animated:YES];
        }
    }
    else
    {
        if (itemArray.count == 0)
        {
            [self.navigationItem setRightBarButtonItem:nil animated:NO];
        }
        else
        {
            [self.navigationItem setRightBarButtonItems:itemArray animated:YES];
        }
    }
}

- (UIButton *)cancelButton
{
    UIButton *btn = [UIButton button:NSLocalizedStringFromTableInBundle(@"cancel",@"Global",[Halo bundle], nil) font:[UIFont systemFontOfSize:14] image:nil highLightImage:nil];
    return btn;
}
@end

@implementation HaloUIViewController (TableView)

- (void)createTableView:(id)delegate
{
    [self createTableView:delegate style:UITableViewStylePlain];
}

- (void)createGroupedTableView:(id)delegate
{
    [self createTableView:delegate style:UITableViewStyleGrouped];
}

- (void)createTableView:(id)delegate style:(UITableViewStyle)style
{
    CGRect rect = self.view.bounds;
    self.tableView = [[HaloUITableView alloc] initWithFrame:rect style:style];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.dataSource = delegate;
    self.tableView.delegate = delegate;
    if (self.dataSource == nil)
    {
        self.dataSource = [NSMutableArray array];
    }
    [self.view addSubview:self.tableView];
}
@end

@implementation HaloUIViewController (Http)
- (void)dismissWait:(HaloHttpRequest *)request
{
    if ([request supportProperty:PROP_ENABLE_WAITDLG])
    {
        [self dismissWaitDialog];
    }
    else if ([request supportProperty:PROP_ENABLE_WAIT])
    {
        [self enableWaitInView:NO];
    }
}

- (void)requestStarted:(HaloHttpRequest *)request
{
    if ([request supportProperty:PROP_ENABLE_WAITDLG])
    {
        NSString *text = [request.userInfo objectForKey:HaloUserInfoKeyWaitInfo];
        [self showWaitDialog:text];
    }
    else if ([request supportProperty:PROP_ENABLE_WAIT])
    {
        [self enableWaitInView:YES];
    }
    
    if (![request supportProperty:PROP_DISABLE_BAR_STATUS])
    {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    }
    
    if ([self.tableView isKindOfClass:[HaloUITableView class]])
    {
        self.tableView.hideEmpty = YES;
    }
}

- (void)requestFailed:(HaloHttpRequest *)request error:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self dismissWait:request];
    NSString *text =  [request.userInfo objectForKey:HaloUserInfoKeyFailedInfo];
    
    if (text.length > 0)
    {
        [self showWarningView:text];
    }
    else
    {
        text =  [request.userInfo objectForKey:HaloUserInfoKeyErrInfo];
        if (text.length == 0)
        {
            if([request supportProperty:PROP_ENABLE_ERR_NOTE] && error.code != 0)
            {
                NSString *text = [request.userInfo objectForKey:HaloUserInfoKeyErrInfo];
                if (text.length > 0)
                {
                    [self showWarningView:text];
                }
                else if ([error localizedDescription].length > 0)
                {
                    [self showWarningView:[error localizedDescription]];
                }
            }
        }
        else
        {
            [self showWarningView:text];
        }
    }
    
    if ([self.tableView respondsToSelector:@selector(checkListIsEmpty)])
    {
        [self.tableView checkListIsEmpty];
    }
}

- (void)requestFinished:(HaloHttpRequest *)request error:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (![request supportProperty:PROP_DISABLE_DISMISS_WAIT_DLG])
            {
                [self dismissWait:request];
            }
            if ([self isTopViewController] || !self.cancelHttpRequestWhenDisappear )
            {                
                if([request supportProperty:PROP_ENABLE_ERR_NOTE] && error.code != 0)
                {
                    NSString *text = [request.userInfo objectForKey:HaloUserInfoKeyErrInfo];
                    [self showWarningView:text.length >0 ? text : [error localizedDescription]];
                }
                else if ([request supportProperty:PROP_ENABLE_SUCCESS_NOTE] && error.code == 0)
                {
                    NSString *text = [request.userInfo objectForKey:HaloUserInfoKeySuccessInfo];
                    [self showInfoView:text.length >0 ? text : [error localizedDescription]];
                    //hud.delegate = self;
                    if (text.length == 0 && [error localizedDescription].length == 0 && [request supportProperty:PROP_SHOW_SUCCESS_ICON])
                    {
                        [self showInfoView:@" "];
                    }
                }
            }
        });
    });
    
}
@end


@implementation HaloUIViewController (HUD)
- (CGRect)waitInWindowRect
{
    CGRect warningViewRect = self.view.frame;
    NSInteger height = self.naviHeight;
    warningViewRect.origin.y = height + 20;
    warningViewRect.size.height -= height;
    if ([HaloUIManager sharedInstance].keyboardIsShown)
    {
        warningViewRect.size.height -= CGRectGetHeight([HaloUIManager sharedInstance].keyboardRect);
    }
    return warningViewRect;
}

- (MBProgressHUD*)didShowInfoView:(NSString*)info  warning:(BOOL)warning showDelay:(int)showDelay
{
    if (info.length == 0)
    {
        return nil;
    }
//    DDLogVerbose(@"didShowInfoView:%@",info);
    
    //[[UIApplication sharedApplication] keyWindow]
    MBProgressHUD *hud = (MBProgressHUD *)[self.view viewWithTag:KProgressHUDTag];
    
    if (hud)
    {
        [hud hide:NO];
    }
    
    hud = [MBProgressHUD showInfoHUD:info view:self.view warning:warning showDelay:warning?showDelay:2 frame:[self waitInWindowRect]];
    
    hud.tag = KProgressHUDTag;
    return hud;
    
}

- (MBProgressHUD*)didShowInfoView:(NSString*)info  warning:(BOOL)warning
{
    return [self didShowInfoView:info warning:warning showDelay:5];
}

- (void)showWaitDialog:(NSString*)text
{
	if (![self isTopViewController])
		return;
    
    MBProgressHUD *hud;
    BOOL waitInWindow = [self showInfoViewInWindow];
    if (!waitInWindow)
    {
        hud = (MBProgressHUD *)[self.view viewWithTag:KProgressHUDTag];
    }
    else
    {
        hud = (MBProgressHUD *)[[[UIApplication sharedApplication] keyWindow] viewWithTag:KProgressHUDTag];
    }
    if (hud)
    {
        [hud removeFromSuperview];
    }
	DDLogVerbose(@"showWaitView:%@",text);
    if (!self.progressHUD)
    {
        if (waitInWindow)
        {
            self.progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow] animated:YES];
            self.progressHUD.frame = [self waitInWindowRect];
        }
        else
        {
            self.progressHUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        }
    }
    self.progressHUD.labelText = text;
}

- (HaloUIWaitView*)enableWaitInView:(BOOL)enable
{
    if (enable && (![self isTopViewController] || self.dataSource.count > 0))
		return nil;
    HaloUIWaitView *v = (HaloUIWaitView*)[self.view viewWithTag:KWaitViewTag];
    NSString *text = NSLocalizedStringFromTableInBundle(@"waiting",@"Global",[Halo bundle], nil);
    if (enable)
    {
        self.tableView.hidden = YES;
        if (v)
        {
            v.textLabel.text = text;
            [v setNeedsLayout];
        }
        else
        {
            v = [[HaloUIWaitView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height - self.naviHeight)];
            v.tag = KWaitViewTag;
            [self.view addSubview:v];
            v.textLabel.text = text;
            [v setNeedsLayout];
        }
        return v;
    }
    else
    {
        self.tableView.hidden = NO;
        self.tableView.alpha = 0.0f;
        [UIView animateWithDuration:0.2f animations:^{
            self.tableView.alpha = 1.0f;
            v.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [v removeFromSuperview];
        }];
        return nil;
    }
}

- (void)updateWaitViewText:(NSString*)text
{
	if (self.progressHUD)
	{
		self.progressHUD.labelText = text;
	}
    HaloUIWaitView *v = (HaloUIWaitView*)[self.view viewWithTag:KWaitViewTag];
    if (v)
    {
        v.textLabel.text = text;
        [v setNeedsLayout];
    }
}

- (void)dismissWaitDialog
{
	if (self.progressHUD)
	{
		[self.progressHUD hide:YES];
        self.progressHUD = nil;
	}
}

- (BOOL)showInfoViewInWindow
{
    return NO;
}

- (MBProgressHUD*)showInfoView:(NSString*)info
{
	return [self didShowInfoView:info warning:NO];
}

- (MBProgressHUD*)showWarningView:(NSString*)warning
{
	return [self didShowInfoView:warning warning:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.tableView.cellForShowingButtons)
    {
        [self.tableView hideCellButtons];
        self.tableView.alwaysBounceVertical = NO;
        double delayInSeconds = 0.3;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            self.tableView.alwaysBounceVertical = YES;
        });
    }
}
@end

@implementation HaloUIViewController (CustomGroup)
- (void)customGroupCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath backgroundViewBlock:(void(^)(HaloUITableGroupCellBackgroundView *))backgroundViewBlock selectedViewBlock:(void(^)(HaloUITableGroupCellBackgroundView *))selectedViewBlock

{
    cell.textLabel.highlightedTextColor = cell.textLabel.textColor;
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.highlightedTextColor = cell.detailTextLabel.textColor;
    NSInteger count = [self.tableView numberOfRowsInSection:indexPath.section];
    TableViewCellLocation loc = ESingleCell;
    if (count > 1)
    {
        if (indexPath.row == 0)
        {
            loc = EFirstCell;
        }
        else if(indexPath.row == count-1)
        {
            loc = ELastCell;
        }
        else
        {
            loc = EMiddleCell;
        }
    }
    
    
    BOOL useView = (![cell.backgroundView isKindOfClass:[HaloUITableGroupCellBackgroundView class]] && ![cell.backgroundView isKindOfClass:[HaloUITableGroupCellBackgroundEmptyView class]]) || cell.backgroundView == nil;
    HaloUITableGroupCellBackgroundView *view = nil;
    
    if (useView)
    {
        view = [[HaloUITableGroupCellBackgroundView alloc] initWithFrame:CGRectZero];
        backgroundViewBlock(view);
        cell.backgroundView = view;
    }
    else if([cell.backgroundView isKindOfClass:[HaloUITableGroupCellBackgroundView class]])
    {
        view = (HaloUITableGroupCellBackgroundView *)cell.backgroundView;
    }
    
    if ( view != nil )
    {
        view.loc = loc;
        view = nil;
    }
    
    if (cell.selectionStyle != UITableViewCellSelectionStyleNone)
    {
        useView = (![cell.selectedBackgroundView isKindOfClass:[HaloUITableGroupCellBackgroundView class]] && ![cell.selectedBackgroundView isKindOfClass:[HaloUITableGroupCellBackgroundEmptyView class]]) || cell.selectedBackgroundView == nil;
        
        if ( useView )
        {
            view = [[HaloUITableGroupCellBackgroundView alloc] initWithFrame:cell.bounds];
            selectedViewBlock(view);
            cell.selectedBackgroundView = view;
        }
        else if([cell.selectedBackgroundView isKindOfClass:[HaloUITableGroupCellBackgroundView class]])
        {
            view = (HaloUITableGroupCellBackgroundView *)cell.selectedBackgroundView;
        }
        
        if ( view != nil )
        {
            view.loc = loc;
            view = nil;
        }
    }
}
@end

