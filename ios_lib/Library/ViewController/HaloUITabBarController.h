//
//  MiniUITabBarController.h
//  MiniFramework
//
//  Created by  on 11-12-21.
//  Copyright (c) 2011年 Mini-Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HaloUITabBar.h"

//@interface HaloTabBarItem : NSObject
//{
//@private
//    NSString *_controllerName;
//    UIImage *_image;
//    UIImage *_highlightedImage;
//    NSString *_title;
//    UIFont *_titleFont;
//    TextStyle *_titleNormalStyle;
//    TextStyle *_titleHighlightStyle;
//}
//
//@property (nonatomic,retain)NSString *controllerName;
//@property (nonatomic,retain)UIImage *image;
//@property (nonatomic,retain)UIImage *highlightedImage;
//@property (nonatomic,retain)NSString *title;
//@property (nonatomic,retain)UIFont *titleFont;
//@property (nonatomic,retain)TextStyle *titleNormalStyle;
//@property (nonatomic,retain)TextStyle *titleHighlightStyle;
//- (id)initWithControllerClass:(Class)controllerClass image:(UIImage*)image highlightedImage:(UIImage*)highlightedImage title:(NSString*)title;
//- (id)initWithControllerClass:(Class)controllerClass image:(UIImage*)image highlightedImage:(UIImage*)highlightedImage title:(NSString*)title titleFont:(UIFont *)font titleNormalStyle:(TextStyle *)titleNormal titleHighlightStyle:(TextStyle *)titleHighligh;
//- (id)initWithControllerClass:(Class)controllerClass image:(UIImage*)image highlightedImage:(UIImage*)highlightedImage;
//- (id)initWithControllerClass:(Class)controllerClass image:(UIImage*)image title:(NSString*)title;
//
//@end

/*
 *===========================================================
 
 ============================================================
 */
@protocol HaloUITabBarControllerDelegate 
@required
- (BOOL)willSelectedAtIndex:(NSInteger)index;
- (void)willDeselectedAtIndex:(NSInteger)index;
- (void)didSelectedAtIndex:(NSInteger)index;
- (void)didDeselectedAtIndex:(NSInteger)index;
@end

/*
 *===========================================================
 
 ============================================================
 */
@interface HaloUITabBarController : UITabBarController <HaloUITabBarDelegate>
@property (nonatomic,retain) HaloUITabBar *tabBarView;
@property (nonatomic)NSInteger currentSelectedIndex;
@property (nonatomic) UIEdgeInsets  tabBarViewEdgeInsets;
@property (nonatomic,weak) id<HaloUITabBarControllerDelegate> controllerDelegate;
@property (nonatomic,assign) NSInteger tabBarHeight;

- (id)initWithItems:(NSArray *)array;

- (void)setItems:(NSArray *)array;

- (void)resetItem:(HaloTabBarItem *)item atIndex:(NSUInteger)index;

- (void)setBadgeText:(NSString *)bageString atIndex:(NSInteger)index;

- (void)setBadge:(NSInteger)badge atIndex:(NSInteger)index;

- (void)setBadgeImage:(UIImage *)badgeImage atIndex:(NSInteger)index;

- (void)setIcon:(UIImage *)icon highLightIcon:(UIImage *)highLightIcon atIndex:(NSUInteger)index;

- (UIViewController *)viewControllerAtIndex:(NSInteger)index;

- (void)updateItem:(HaloTabBarItem *)item atIndex:(NSUInteger)index;
@end
