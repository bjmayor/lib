//
//  MiniUITabBarController.m
//  MiniFramework
//
//  Created by  on 11-12-21.
//  Copyright (c) 2011年 Mini-Studio. All rights reserved.
//

#import "HaloUITabBarController.h"
#import <objc/message.h>

//#import "HaloUITabViewController.h"
//#import "MiniUINavigationController.h"
//#import "MiniDefine.h"
//@implementation HaloTabBarItem
//
//@synthesize controllerName = _controllerName;
//@synthesize image = _image;
//@synthesize highlightedImage = _highlightedImage;
//@synthesize title = _title;
//@synthesize titleFont = _titleFont;
//@synthesize titleNormalStyle = _titleNormalStyle;
//@synthesize titleHighlightStyle = _titleHighlightStyle;
//
//- (void)constructWithControllerClass:(Class)controllerClass image:(UIImage*)image highlightedImage:(UIImage*)highlightedImage title:(NSString*)title
//{
//    self.controllerName = [controllerClass description];
//    self.image = image;
//    self.highlightedImage = highlightedImage;
//    self.title = title;
//}
//
//- (id)initWithControllerClass:(Class)controllerClass image:(UIImage*)image highlightedImage:(UIImage*)highlightedImage title:(NSString*)title
//{
//    if ( self = [super init] )
//    {
//        [self constructWithControllerClass:controllerClass image:image highlightedImage:highlightedImage title:title];
//    }
//    return self;
//}
//- (id)initWithControllerClass:(Class)controllerClass image:(UIImage*)image highlightedImage:(UIImage*)highlightedImage title:(NSString*)title titleFont:(UIFont *)font titleNormalStyle:(TextStyle *)titleNormal titleHighlightStyle:(TextStyle *)titleHighligh
//{
//    if ( self = [super init] )
//    {
//        [self constructWithControllerClass:controllerClass image:image highlightedImage:highlightedImage title:title];
//        self.titleFont = font;
//        self.titleNormalStyle = titleNormal;
//        self.titleHighlightStyle = titleHighligh;
//    }
//    return self;
//}
//- (id)initWithControllerClass:(Class)controllerClass image:(UIImage*)image highlightedImage:(UIImage*)highlightedImage
//{
//    if ( self = [super init] )
//    {
//        [self constructWithControllerClass:controllerClass image:image highlightedImage:highlightedImage title:nil];
//    }
//    return self;
//}
//
//- (id)initWithControllerClass:(Class)controllerClass image:(UIImage*)image title:(NSString*)title
//{
//    if ( self = [super init] )
//    {
//        [self constructWithControllerClass:controllerClass image:image highlightedImage:nil title:title];
//    }
//    return self;
//}
//
//- (void)dealloc
//{
//    [_controllerName release];
//    [_image release];
//    [_highlightedImage release];
//    [_title release];
//    [_titleFont release];
//    [_titleHighlightStyle release];
//    [_titleNormalStyle release];
//    [super dealloc];
//}
//
//@end

@interface HaloUITabBarController()

@end

@interface HaloUITabBarController (Private)
- (void)hideRealTabBar;
- (void)customTabBar:(NSArray*)titles;
- (void)selectedTab:(UIButton *)button;
- (void)setViewControllers:(NSArray *)viewControllers items:(NSArray*)items;
@end

@implementation HaloUITabBarController

- (id)init
{
    self = [super init];
    if (self)
    {
        self.tabBarHeight = 50;
    }
    return self;
}

- (id)initWithItems:(NSArray*)array
{
    if (self = [self init] )
    {
        [self setItems:array];
    }
    return self;
}

- (void)setItems:(NSArray*)array
{
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:array.count];
    for ( NSInteger index = 0; index<array.count; index ++)
    {
        HaloTabBarItem *item = [array objectAtIndex:index];
        UINavigationController *nav = nil;
        if (item.controllerName.length > 0 )
        {
            UIViewController* controller = [[NSClassFromString(item.controllerName) alloc]init];
            controller.hidesBottomBarWhenPushed = NO;
            nav = [[UINavigationController alloc] initWithRootViewController:controller];
        }
        else
        {
            nav = [[UINavigationController alloc] init];
        }
        [items addObject:nav];
    }
    [self setViewControllers:items];
    self.tabBarView.tabItemsArray = [NSMutableArray arrayWithArray:array];
    self.tabBarView.selectedTabIndex = self.currentSelectedIndex;
}

- (BOOL)viewShouldRemoveFromView:(UIView *)view
{
    return YES;
}

- (HaloUITabBar *)tabBarView
{
    if ( _tabBarView == nil )
    {
        _tabBarView = [[HaloUITabBar alloc] initWithFrame:CGRectMake(0,0,self.view.width,self.tabBarHeight)];
        _tabBarView.opaque = NO;
        _tabBarView.delegate = self;
    }
    return _tabBarView;
}

- (void)loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor grayColor];
    self.tabBar.frame = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height-[self tabBarHeight], self.view.width, [self tabBarHeight]);
    
    DDLogVerbose(@"%@",NSStringFromCGRect(self.tabBar.frame));
    for ( UIView *view in self.tabBar.subviews )
    {
        [view removeFromSuperview];
    }
    [self.tabBar addSubview:[self tabBarView]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    for ( UIView *view in self.tabBar.subviews )
    {
        if ( ![view isKindOfClass:[HaloUITabBar class]])
        {
            //view.hidden = YES;
            [view removeFromSuperview];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)touchDownAtItemAtIndex:(NSUInteger)itemIndex
{
    if ( self.controllerDelegate )
    {
        if ( [self.controllerDelegate willSelectedAtIndex:itemIndex] )
        {
            return;
        }
    }
    
    NSInteger last = self.currentSelectedIndex;
    
    BOOL repeat = ( itemIndex == self.currentSelectedIndex )?YES:NO;
    
    if ( self.controllerDelegate )
    {
        [self.controllerDelegate willDeselectedAtIndex:last];
        UIViewController *controller = [self.viewControllers objectAtIndex:last];
        if ( [controller isKindOfClass:[UINavigationController class]] )
        {
            NSArray *controllers = [(UINavigationController*)controller viewControllers];
            if ( controllers.count > 0 )
            {
                controller = [[(UINavigationController*)controller viewControllers] objectAtIndex:0];
            }
        }
        if ( [controller respondsToSelector:@selector(didTabBarItemDeselected)])
        {
            [controller performSelector:@selector(didTabBarItemDeselected)];
        }
    }
    self.currentSelectedIndex = itemIndex;
    self.selectedIndex = itemIndex;
    if ( self.controllerDelegate )
    {
        [self.controllerDelegate didDeselectedAtIndex:last];
        [self.controllerDelegate didSelectedAtIndex:self.currentSelectedIndex];
    }
    UIViewController *controller = [self.viewControllers objectAtIndex:itemIndex];
    if ( [controller isKindOfClass:[UINavigationController class]] )
    {
        NSArray *controllers = [(UINavigationController*)controller viewControllers];
        if ( controllers.count > 0 )
        {
            controller = [[(UINavigationController*)controller viewControllers] objectAtIndex:0];
        }
    }
    if ( [controller respondsToSelector:@selector(didTabBarItemSelected:)])
    {
        //[controller performSelector:@selector(didTabBarItemSelected) w];
        objc_msgSend(controller,@selector(didTabBarItemSelected:),repeat);
    }
    else if ( [controller respondsToSelector:@selector(didTabBarItemSelected)] )
    {
        [controller performSelector:@selector(didTabBarItemSelected)];
    }
}

#pragma mark - hideTabBar, method from Ext
- (void)hideTabBar:(BOOL)yesOrNo animated:(BOOL)animated
{
    if ( yesOrNo )
    {
        CGRect frame = self.tabBar.frame;
        frame.origin.y = self.view.bottom;
        if ( animated )
        {
            [UIView animateWithDuration:.2f animations:^{
                self.tabBar.frame = frame;
                self.view.height = frame.origin.y;
            }];
        }
        else
        {
            self.tabBar.frame = frame;
            self.view.height = frame.origin.y;
        }
    }
    else
    {
        CGRect frame = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height-self.tabBarHeight, self.view.width, self.tabBarHeight);
        if ( animated )
        {
            [UIView animateWithDuration:.2f animations:^{
                self.tabBar.frame = frame;
                self.view.height = frame.origin.y;
            }];
        }
        else
        {
            self.tabBar.frame = frame;
            self.view.height = frame.origin.y;
        }
    }
}

- (void)setCurrentSelectedIndex:(NSInteger)index
{
    self.tabBarView.selectedTabIndex = index;
    _currentSelectedIndex = index;
}

- (void)setBadgeText:(NSString *)bageString atIndex:(NSInteger)index
{
    [self.tabBarView setBadgeText:bageString atIndex:index];
}

- (void)setBadge:(NSInteger)badge atIndex:(NSInteger)index
{
    [self.tabBarView setBadgeNumber:badge atIndex:index];
}

- (void)setBadgeImage:(UIImage *)badgeImage atIndex:(NSInteger)index
{
    [self.tabBarView setBadgeImage:badgeImage atIndex:index];
}

- (void)resetItem:(HaloTabBarItem *)item atIndex:(NSUInteger)index
{
    NSArray *array = self.viewControllers;
    if ( array.count > index)
    {
        UIViewController* controller = [[NSClassFromString(item.controllerName) alloc]init];
        controller.hidesBottomBarWhenPushed = NO;
        UINavigationController *nav = [array objectAtIndex:index];
        
        NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:nav.viewControllers];
        if (viewControllers.count > 0)
        {
            [viewControllers removeObjectAtIndex:0];
        }
        [viewControllers insertObject:controller atIndex:0];
        [nav setViewControllers:viewControllers];
        [self.tabBarView resetItem:item atIndex:index];
    }
}

- (void)setIcon:(UIImage *)icon highLightIcon:(UIImage *)highLightIcon atIndex:(NSUInteger)index
{
    HaloTabBarItem *item = [self.tabBarView itemAtIndex:index];
    [item setImage:icon highLightIcon:highLightIcon];
    [item setNeedsDisplay];
}

- (UIViewController *)viewControllerAtIndex:(NSInteger)index
{
    UIViewController *controller = [self.viewControllers objectAtIndex:index];
    if ( [controller isKindOfClass:[UINavigationController class]] )
    {
        NSArray *controllers = [(UINavigationController*)controller viewControllers];
        if ( controllers.count > 0 )
        {
            controller = [[(UINavigationController*)controller viewControllers] objectAtIndex:0];
        }
    }
    return controller;
}

- (void)updateItem:(HaloTabBarItem *)item atIndex:(NSUInteger)index
{
    NSArray *array = self.viewControllers;
    if ( array.count > index)
    {
        if (self.selectedIndex == index)
        {
            item.selected = YES;
        }
        [self.tabBarView resetItem:item atIndex:index];
    }
}
@end

