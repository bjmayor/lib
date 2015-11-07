//
//  HaloUITabBarItem.h
//  
//
//  Created by  on 11-4-26.
//  Copyright 2011年  . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HaloTheme.h"
@interface HaloTabBarItem : UIButton {
    NSInteger       _badge;
    UIImage         *_normalIcon;
    UIImage         *_highLightIcon;
    NSString        *_title;
    BOOL            _isSelect;
    UIEdgeInsets _iconEdge;
    NSString *_controllerName;
    NSInteger       _titleYGap;
}
@property(nonatomic,assign)NSInteger        badge;
@property(nonatomic,retain)UIImage         *normalIcon;
@property(nonatomic,retain)UIImage         *highLightIcon;
@property(nonatomic,retain)NSString        *title;
@property(nonatomic,assign)BOOL            isSelect;
@property(nonatomic,assign)UIEdgeInsets    iconEdge;
@property(nonatomic,retain)NSString        *controllerName;
@property(nonatomic)BOOL                    autoAdjustTitleFont;
@property(nonatomic,assign)NSInteger        titleYGap;
- (id)initWithControllerClass:(Class)controllerClass image:(UIImage*)image highlightedImage:(UIImage*)highlightedImage title:(NSString*)title;
- (id)initWithControllerClass:(Class)controllerClass image:(UIImage*)image highlightedImage:(UIImage*)highlightedImage title:(NSString*)title titleFont:(UIFont *)font titleNormalStyle:(TextStyle *)titleNormal titleHighlightStyle:(TextStyle *)titleHighligh;
- (id)initWithControllerClass:(Class)controllerClass image:(UIImage*)image highlightedImage:(UIImage*)highlightedImage;
- (id)initWithControllerClass:(Class)controllerClass image:(UIImage*)image title:(NSString*)title;

- (void)setTitlefont:(UIFont *)font normalStyle:(TextStyle *)normalStyle highlightStyle:(TextStyle *)highlightStyle;
- (void)setImage:(UIImage *)icon highLightIcon:(UIImage *)highLightIcon;
- (void)setBadgeText:(NSString *)badgeText;
- (void)setBadgeImage:(UIImage *)image;
- (CGPoint)badgeOrigin;
@end
