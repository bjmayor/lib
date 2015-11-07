//
//  HaloUITabBarItem.m
//  
//
//  Created by  on 11-4-26.
//  Copyright 2011年  . All rights reserved.
//

#import "HaloUITabBarItem.h"
#import "HaloUIBadgeView.h"
#import "UIImageExt.h"
#import "UIViewExt.h"
#import "HaloDefine.h"
#import "HaloUIBadgeView.h"
#define KTabTitleFontHeight 10
#define KTabBadgeTag 0x200

@interface HaloTabBarItem()
{
//    UIImage *selectImage;
    UIFont *_titleFont;
    TextStyle *_titleNormalStyle;
    TextStyle *_titleHighlightStyle;
//    UIImage * _maskSelectImage;
}
@property (nonatomic,retain)UIFont *titleFont;
@property (nonatomic,retain)TextStyle *titleNormalStyle;
@property (nonatomic,retain)TextStyle *titleHighlightStyle;
@end

@implementation HaloTabBarItem
@synthesize badge = _badge;
@synthesize iconEdge = _iconEdge;
@synthesize controllerName = _controllerName;
@synthesize normalIcon = _normalIcon;
@synthesize highLightIcon = _highLightIcon;
@synthesize title = _title;
@synthesize isSelect = _isSelect;

@synthesize titleFont = _titleFont;
@synthesize titleNormalStyle = _titleNormalStyle;
@synthesize titleHighlightStyle = _titleHighlightStyle;
@synthesize titleYGap = _titleYGap;

- (id)initWithControllerClass:(Class)controllerClass image:(UIImage*)image highlightedImage:(UIImage*)highlightedImage title:(NSString*)title
{
    if ((self = [super init]))
    {
        self.badge = 0;
        self.controllerName = [controllerClass description];
        [self setImage:image highLightIcon:highlightedImage];
        self.title = title;
        self.adjustsImageWhenHighlighted = NO;
        self.frame = CGRectMake(0, 0, self.normalIcon.size.width < 40 ? 40 : self.normalIcon.size.width, self.normalIcon.size.height);
//        selectImage = [HaloTheme imageNamed:@"tab_selected_bg"];
        self.iconEdge = UIEdgeInsetsZero;
    }
    return self;
}

- (id)initWithControllerClass:(Class)controllerClass image:(UIImage*)image highlightedImage:(UIImage*)highlightedImage title:(NSString*)title titleFont:(UIFont *)font titleNormalStyle:(TextStyle *)titleNormal titleHighlightStyle:(TextStyle *)titleHighlight
{
    if (self = [self initWithControllerClass:controllerClass image:image highlightedImage:highlightedImage title:title])
    {
        self.titleFont = font;
        self.titleNormalStyle = titleNormal;
        self.titleHighlightStyle = titleHighlight;
    }
    return self;
}

- (id)initWithControllerClass:(Class)controllerClass image:(UIImage*)image highlightedImage:(UIImage*)highlightedImage
{
    if (self = [self initWithControllerClass:controllerClass image:image highlightedImage:highlightedImage title:nil])
    {
        
    }
    return self;
}

- (id)initWithControllerClass:(Class)controllerClass image:(UIImage*)image title:(NSString*)title;
{
    if (self = [self initWithControllerClass:controllerClass image:image highlightedImage:image title:title])
    {
        
    }
    return self;
}

- (void)setImage:(UIImage *)theIcon highLightIcon:(UIImage *)theHighLightIcon
{
    self.normalIcon = theIcon;
    if (theHighLightIcon)
    {
        self.highLightIcon = theHighLightIcon;
    }
    else
    {
        self.highLightIcon = self.normalIcon;
    }
}

- (void)drawRect:(CGRect)rect
{
    UIFont *font = self.titleFont ? self.titleFont : [UIFont systemFontOfSize:KTabTitleFontHeight];
    
    BOOL fontShrinked = NO;
//    [[UIColor redColor] set];
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextStrokeRect(context,CGRectMake(rect.origin.x,rect.origin.y,rect.size.width/2,rect.size.height));
    CGPoint point;    
    if (self.title.length > 0)
    {
        TextStyle *style;
        if (self.selected) 
        {
            style = self.titleNormalStyle ? self.titleHighlightStyle : [HaloTheme textStyle:@"halo_tab_title_highlight"];
        }
        else
        {
            style = self.titleNormalStyle ? self.titleNormalStyle :[HaloTheme textStyle:@"halo_tab_title"];
        }
        [style.color set];
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetShadowWithColor(context, style.shadowOffset, 0.0, style.shadowColor.CGColor); 
        NSInteger titileTop = self.height - font.lineHeight - KGap/2;
        if ( self.autoAdjustTitleFont )
        {
            CGFloat defaultFontSize = font.pointSize;
            CGFloat minFontSize = font.pointSize - 3;
            while ([self.title sizeWithFont:font].width >= rect.size.width - 6 && font.pointSize >= minFontSize)
            {
                font = [UIFont systemFontOfSize:font.pointSize - 1];
                fontShrinked = YES;
            }
            
            if (fontShrinked && [self.title sizeWithFont:font].width >= rect.size.width - 6)
            {
                font = [UIFont systemFontOfSize:defaultFontSize];
            }
            
            [self.title drawInRect:CGRectMake(3, titileTop, rect.size.width - 6, font.lineHeight) withFont:font lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentCenter];
        }
        else
        {
             [self.title drawInRect:CGRectMake(3, titileTop + self.titleYGap, rect.size.width - 6, font.lineHeight) withFont:font lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentCenter];
        }
        
        CGContextSetShadow(context, CGSizeMake(0, 0), 0.0);
        point = CGPointMake((rect.size.width - self.normalIcon.size.width)/2 + self.iconEdge.left, titileTop - self.normalIcon.size.height - self.iconEdge.bottom );
    }
    else
    {
        point = CGPointMake((rect.size.width - self.normalIcon.size.width)/2 + self.iconEdge.left, (rect.size.height-self.normalIcon.size.height)/2);
    }
    if (self.selected)
    {
//        if ( selectImage != nil )
//        {
////            selectImage = [selectImage imageUseMask:self.highLightIcon];
////            [selectImage drawAtPoint:point];
//            if ( _maskSelectImage == nil ) 
//            {
//                _maskSelectImage = [[selectImage imageUseMask:self.highLightIcon] retain];
//            }
//            if ( _maskSelectImage )
//            {
//                [_maskSelectImage drawAtPoint:point];
//            }
//        } 
//        else
        {
            if ( self.highLightIcon != nil )
            {
                [self.highLightIcon drawAtPoint:point];
            }
            else
            {
                [self.normalIcon drawAtPoint:point];
            }
        }
    }
    else
    {
        [self.normalIcon drawAtPoint:point];
    }
}

- (CGPoint)badgeOrigin
{
    return CGPointMake(3*KGap, KGap);
}

- (void)setBadgeText:(NSString *)badgeText
{
    HaloUIBadgeView *badgeView = (HaloUIBadgeView*)[self viewWithTag:KTabBadgeTag];
    if (badgeText.length > 0 )
    {
        if (!badgeView)
        {
            CGPoint origin = [self badgeOrigin];
            badgeView = [[HaloUIBadgeView alloc] initWithFrame:CGRectMake(origin.x, origin.y, 0, 0)];
            badgeView.tag = KTabBadgeTag;
            [self addSubview:badgeView];
        }
        badgeView.badgeText = badgeText;
    }
    else
    {
        [badgeView removeFromSuperview];
    }

}

- (void)setBadgeImage:(UIImage *)image
{
    UIImageView *badgeView = (UIImageView*)[self viewWithTag:KTabBadgeTag];
    if ( image != nil )
    {
        if (!badgeView)
        {
            CGPoint origin = [self badgeOrigin];
            badgeView = [[UIImageView alloc] initWithImage:image];
            badgeView.tag = KTabBadgeTag;
            badgeView.origin = origin;
            [self addSubview:badgeView];
        }
        badgeView.image = image;
    }
    else
    {
        [badgeView removeFromSuperview];
    }
}

- (void)setBadge:(NSInteger)aBadge
{
    _badge = aBadge; 
    HaloUIBadgeView *badgeView = (HaloUIBadgeView*)[self viewWithTag:KTabBadgeTag];
    if (_badge>0)
    {
        if (!badgeView)
        {
            CGPoint origin = [self badgeOrigin];
            badgeView = [[HaloUIBadgeView alloc] initWithFrame:CGRectMake(origin.x, origin.y, 0, 0)];
            badgeView.tag = KTabBadgeTag;
            [self addSubview:badgeView];
        }
        badgeView.badge = _badge;
    }
    else
    {
        [badgeView removeFromSuperview];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}
- (void)setTitlefont:(UIFont *)font normalStyle:(TextStyle *)normalStyle highlightStyle:(TextStyle *)highlightStyle
{
    self.titleFont = font;
    self.titleNormalStyle = normalStyle;
    self.titleHighlightStyle = highlightStyle;
}
@end
