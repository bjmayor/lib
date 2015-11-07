//
//  HaloUIActionSheet.m
//  HaloSlimFramework
//
//  Created by  on 13-5-28.
//
//

#import "HaloUIActionSheet.h"
#import "UIButtonExt.h"
#import "UIImageExt.h"
#import <QuartzCore/QuartzCore.h>

#define kActionSheetBounce         5
#define kActionSheetBorder         8
#define kActionSheetButtonHeight   44
#define kActionSheetTopMargin      15

#define kAlertViewBorder         10


typedef enum
{
    EButtonTypeNormal,
    EButtonTypeCancel,
    EButtonTypeRed,
    EButtonTypeTitle,
}HaloActionSheetButtonType;

@interface HaloUIActionSheetItem : UIButton
@property(nonatomic, assign)HaloActionSheetButtonType type;
@end

@implementation HaloUIActionSheetItem

@end

@interface HaloUIActionSheet ()
//View
@property(nonatomic, strong) UIWindow *overlayWindow;
@property(nonatomic, strong) UIWindow *preWindow;
@property(nonatomic, strong) UIView *backView;

//Object
@property(nonatomic, strong) NSMutableArray *items;
@property(nonatomic, assign) CGFloat height;
@property(nonatomic, copy)void(^dimissBlock)();
@property(nonatomic, strong)HaloUIActionSheetItem *cancelButton;

//UI
@property (nonatomic, strong) NSMutableDictionary *buttonBackgroundImagesForControlStates;
@property (nonatomic, strong) NSMutableDictionary *cancelButtonBackgroundImagesForControlStates;
@property (nonatomic, strong) NSMutableDictionary *destructiveButtonBackgroundImagesForControlStates;
@end

@implementation HaloUIActionSheet

+ (void)initialize
{
	[self applySystemActionAppearance];
}

+ (void)applySystemActionAppearance {
//	// Set up default values for all UIAppearance-compatible selectors
    
    UIFont *normalFont = [UIFont iOS7SystemFontOfSize:16 attribute:UI7FontAttributeLight];
    UIFont *cancelFont = [UIFont iOS7SystemFontOfSize:16 attribute:UI7FontAttributeMedium];
    
    UIColor *redColor = [UIColor colorWithRed:1 green:69/255 blue:55/255 alpha:1];
    UIColor *normalColor = [UIColor colorWithRed:0 green:126.0/255 blue:245.0/255 alpha:1];

    [[self appearance] setTitleAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                               normalFont, UITextAttributeFont,
                                               [UIColor colorWithWhite:88/255.0 alpha:1], UITextAttributeTextColor,
                                               [UIColor clearColor], UITextAttributeTextShadowColor,
                                               CGSizeZero, UITextAttributeTextShadowOffset,
                                               nil]];
    
	[[self appearance] setButtonTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                     normalFont, UITextAttributeFont,
                                                     normalColor, UITextAttributeTextColor,
                                                    [UIColor clearColor], UITextAttributeTextShadowColor,
                                                    CGSizeZero, UITextAttributeTextShadowOffset,
                                                     nil]];
    
    [[self appearance] setRedButtonTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                normalFont, UITextAttributeFont,
                                                redColor, UITextAttributeTextColor,
                                                [UIColor clearColor], UITextAttributeTextShadowColor,
                                                CGSizeZero, UITextAttributeTextShadowOffset,
                                                nil]];
    
    [[self appearance] setCancelButtonTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                   cancelFont, UITextAttributeFont,
                                                   normalColor, UITextAttributeTextColor,
                                                   [UIColor clearColor], UITextAttributeTextShadowColor,
                                                   CGSizeZero, UITextAttributeTextShadowOffset,
                                                   nil]];
//
//	// Set basic button background images.
//	[[self appearance] setButtonBackgroundImage:[self normalButtonBackgroundImage] forState:UIControlStateNormal];
//	
//	[[self appearance] setCancelButtonBackgroundImage:[self cancelButtonBackgroundImage] forState:UIControlStateNormal];
}



+ (id)actionSheetWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle
{
    return [[HaloUIActionSheet alloc] initWithTitle:title cancelButtonTitle:cancelButtonTitle];
}

- (id)initWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle
{
    if ((self = [super init]))
    {
        self.overlayWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        self.overlayWindow.windowLevel = UIWindowLevelStatusBar;
        self.overlayWindow.userInteractionEnabled = YES;
//        self.overlayWindow.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.5f];
        self.overlayWindow.hidden = YES;
        
    
        CGRect frame = self.overlayWindow.bounds;
        self.frame = frame;
        _items = [[NSMutableArray alloc] init];
        _height = kActionSheetTopMargin;
        
        [self setTitle:title];
        
        if (cancelButtonTitle.length > 0)
        {
            [self addItemWithTitle:cancelButtonTitle type:EButtonTypeCancel block:nil];
        }
    }
    
    return self;
}

- (void)setTitle:(NSString *)title
{
    if (title.length > 0)
    {

        HaloUIActionSheetItem *item = [[HaloUIActionSheetItem alloc] init];
        [item setTitle:title forState:UIControlStateNormal];
        item.titleLabel.numberOfLines = 0;
        item.type = EButtonTypeTitle;
        [self.items addObject:item];
//            UILabel *labelView = [[UILabel alloc] initWithFrame:CGRectMake(kActionSheetBorder, _height, self.width - kActionSheetBorder*2, 0)];
//            labelView.numberOfLines = 0;
//            labelView.backgroundColor = [UIColor clearColor];
//            self.titleLabel = labelView;
//            [self addSubview:labelView];
        
    }
}


#pragma mark- InnerAction

- (void)addItemWithTitle:(NSString *)title type:(HaloActionSheetButtonType)type block:(void(^)())block
{
    HaloUIActionSheetItem *item = [[HaloUIActionSheetItem alloc] init];
    [item setTitle:title forState:UIControlStateNormal];
    item.type = type;
    [item addBlock:^{
        if (block)
        {
            block();
        }
        [self dismissWithAnimated:YES];
    } forControlEvents:UIControlEventTouchUpInside];
    if (type == EButtonTypeCancel)
    {
        self.cancelButton = item;
    }
    else
    {
        [self.items addObject:item];
    }
}

- (void)addItemWithTitle:(NSString *)title isRed:(BOOL)isRed block:(void(^)())block
{
    [self addItemWithTitle:title type:isRed ? EButtonTypeRed : EButtonTypeNormal block:block];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.backgroundColor = UIColor.clearColor;
    
    for (id view in self.subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            [view removeFromSuperview]; // background image
        }
    }
    
    [self applyAppearanceAttributesToButtons];
    
    
    
}

- (void)show
{
    self.preWindow = [[UIApplication sharedApplication] keyWindow];
    [self.overlayWindow addSubview:self];
    [self.overlayWindow makeKeyAndVisible];
    
    [self layoutIfNeeded];
    
//    UIImageView *modalBackground = [[UIImageView alloc] initWithFrame:self.bounds];
//    modalBackground.image = [self.backgroundImage stretchableImageWithLeftCapWidth:self.backgroundImage.size.width/2 topCapHeight:self
//                             .backgroundImage.size.width/2];
//    modalBackground.contentMode = UIViewContentModeScaleToFill;
//    [self insertSubview:modalBackground atIndex:0];
    
    
    CGSize cornerSize = CGSizeMake(4, 4);
    UIColor *defaultColor = [UIColor colorWithWhite:248.0/255 alpha:1];
    UIBezierPath *path;
    
    for (NSInteger i=0; i<self.items.count+1;i++)
    {
        HaloUIActionSheetItem *item = self.items[i];
        if (i == self.items.count)
        {
            item = self.cancelButton;
            _height += KGap;
        }
        
        item.titleLabel.textAlignment = NSTextAlignmentCenter;
        item.backgroundColor = [UIColor clearColor];
        
        if (item.type != EButtonTypeTitle)
        {            
            item.frame = CGRectMake(kActionSheetBorder, _height, self.bounds.size.width-kActionSheetBorder*2, kActionSheetButtonHeight-0.5);
            item.titleLabel.adjustsFontSizeToFitWidth = YES;
            _height += kActionSheetButtonHeight;
        }
        else
        {
            CGSize size = [item sizeThatFits:CGSizeMake(self.bounds.size.width-kActionSheetBorder*2, MAXFLOAT)];
            if (size.height + KGap*2 < 44)
            {
                size.height = 44;
            }
            else
            {
                size.height += 2*KGap;
            }
            
            item.frame = CGRectMake(kActionSheetBorder, _height, self.bounds.size.width-kActionSheetBorder*2, size.height-0.5);
            _height += size.height;
        }
//Sep Line
        if (i < self.items.count - 1)
        {
            CGRect buttonFrame = CGRectMake(item.left, item.bottom,
											item.width, 0.5);
            UIView *strokeView = [[UIView alloc] initWithFrame:buttonFrame];
            strokeView.backgroundColor = [[UIColor alloc] initWithWhite:(182.0/255.0) alpha:1];
            [self addSubview:strokeView];
        }
        
//Layout Items
        if (i == 0)
        {
            if(self.items.count == 1)
            {
                path = [UIBezierPath bezierPathWithRoundedRect:item.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:cornerSize];
            }
            else
            {
                path = [UIBezierPath bezierPathWithRoundedRect:item.bounds byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight cornerRadii:cornerSize];
            }
        }
        else if (i == self.items.count)
        {
            path = [UIBezierPath bezierPathWithRoundedRect:item.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:cornerSize];
        }
        else if (i == self.items.count - 1)
        {
            path = [UIBezierPath bezierPathWithRoundedRect:item.bounds byRoundingCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight cornerRadii:cornerSize];
        }
        else
        {
            path = [UIBezierPath bezierPathWithRoundedRect:item.bounds cornerRadius:.0f];
        }
        
        UIImage *img = [UIImage imageWithBezierPath:path color:nil backgroundColor:defaultColor];
        UIImage *imgHigh = [UIImage imageWithBezierPath:path color:nil backgroundColor:[UIColor colorWithRGBA:0xb0b0b0ff]];
        [item setBackgroundImage:img forState:UIControlStateNormal];
        if (item.type != EButtonTypeTitle)
        {
            [item setBackgroundImage:imgHigh forState:UIControlStateHighlighted];
        }
        else
        {
             [item setBackgroundImage:img forState:UIControlStateHighlighted];
        }
        
        [self addSubview:item];
        
    }
    
    CGRect frame = self.overlayWindow.bounds;
    frame.origin.y = self.overlayWindow.bounds.size.height;
    frame.size.height = _height + kActionSheetBounce*3;
    self.frame = frame;
    
    self.backView = [[UIView alloc] initWithFrame:self.overlayWindow.bounds];
    self.backView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.5f];
    self.backView.alpha = 0;
    [self.overlayWindow insertSubview:self.backView atIndex:0];
    
    __block CGPoint center = self.center;
    center.y -= _height + kActionSheetBounce;

    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.backView.alpha = 0.5f;
                         self.center = center;
                     } completion:^(BOOL finished) {
                     }];
}

- (void)showWithDismissBlock:(void (^)())block
{
    self.dimissBlock = block;
    [self show];
}

- (void)dismissWithAnimated:(BOOL)animated
{
    dispatch_block_t completeBlock = ^(void){
        [self.backView removeFromSuperview];
        self.backView = nil;
        [self.overlayWindow removeFromSuperview];
        self.overlayWindow = nil;
        [self.preWindow makeKeyWindow];
        self.preWindow = nil;
        [self removeFromSuperview];
    };
    if (animated)
    {
        CGPoint center = self.center;
        center.y += _height + kActionSheetBounce;
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.center = center;
                             self.backView.alpha = 0;
                             self.overlayWindow.userInteractionEnabled = NO;
                             
                         } completion:^(BOOL finished) {
                             
                             completeBlock();
                         }];
    }
    else
    {
        completeBlock();
    }
}

#pragma mark- UIApperence


- (void)applyTextAttributes:(NSDictionary *)attributes toLabel:(UILabel *)label
{
	label.font = [attributes objectForKey:UITextAttributeFont];
	label.textColor = [attributes objectForKey:UITextAttributeTextColor];
	label.shadowColor = [attributes objectForKey:UITextAttributeTextShadowColor];
	label.shadowOffset = [[attributes objectForKey:UITextAttributeTextShadowOffset] CGSizeValue];
}

- (void)applyTextAttributes:(NSDictionary *)attributes toButton:(UIButton *)button
{
	button.titleLabel.font = [attributes objectForKey:UITextAttributeFont];
	[button setTitleColor:[attributes objectForKey:UITextAttributeTextColor] forState:UIControlStateNormal];
	[button setTitleShadowColor:[attributes objectForKey:UITextAttributeTextShadowColor] forState:UIControlStateNormal];
	button.titleLabel.shadowOffset = [[attributes objectForKey:UITextAttributeTextShadowOffset] CGSizeValue];
}

- (void)applyAppearanceAttributesToButtons
{
    for (NSInteger i=0; i<self.items.count+1;i++)
    {
        HaloUIActionSheetItem *item = self.items[i];
        if (i == self.items.count)
        {
            item = self.cancelButton;
        }
        switch (item.type)
        {
            case EButtonTypeCancel:
            {
                [self applyTextAttributes:self.cancelButtonTextAttributes toButton:item];
                break;
            }
            case EButtonTypeRed:
            {
                [self applyTextAttributes:self.redButtonTextAttributes toButton:item];
                break;
            }
            case EButtonTypeNormal:
            {
                [self applyTextAttributes:self.buttonTextAttributes toButton:item];

                break;
            }
            case EButtonTypeTitle:
            {
                [self applyTextAttributes:self.titleAttributes toButton:item];
            }
            default:
                break;
        }
    }
}

- (void)setTitleFont:(UIFont *)font textStyle:(TextStyle *)style
{
    [self setTitleAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                  font, UITextAttributeFont,
                                  style.color, UITextAttributeTextColor,
                                  style.shadowColor, UITextAttributeTextShadowColor,
                                  style.shadowOffset, UITextAttributeTextShadowOffset,
                                  nil]];
}

- (void)setButtonTextFont:(UIFont *)font textStyle:(TextStyle *)style
{
    [self setButtonTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                        font, UITextAttributeFont,
                                        style.color, UITextAttributeTextColor,
                                        style.shadowColor, UITextAttributeTextShadowColor,
                                        style.shadowOffset, UITextAttributeTextShadowOffset,
                                        nil]];
}

- (void)setCancelButtonTextFont:(UIFont *)font textStyle:(TextStyle *)style
{
    [self setCancelButtonTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                   font, UITextAttributeFont,
                                   style.color, UITextAttributeTextColor,
                                   style.shadowColor, UITextAttributeTextShadowColor,
                                   style.shadowOffset, UITextAttributeTextShadowOffset,
                                   nil]];
}

- (void)setRedButtonTextFont:(UIFont *)font textStyle:(TextStyle *)style
{
    [self setRedButtonTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                   font, UITextAttributeFont,
                                   style.color, UITextAttributeTextColor,
                                   style.shadowColor, UITextAttributeTextShadowColor,
                                   style.shadowOffset, UITextAttributeTextShadowOffset,
                                   nil]];
}
@end
