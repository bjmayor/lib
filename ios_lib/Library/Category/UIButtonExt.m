//
//  UIButtonExt.m
//  Hello World
//
//  Created by  on 13-5-19.
//  Copyright (c) 2013年 __Company__. All rights reserved.
//

#import "UIButtonExt.h"
#import "UIImageExt.h"
#import <objc/runtime.h>
static char buttonBlockKey;

@implementation UIButton (Ext)
+ (UIButton*)button:(NSString*)text font:(UIFont*)font image:(UIImage*)image highLightImage:(UIImage*)highLightImage
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    //    button.adjustsImageWhenHighlighted = NO;
    CGSize size = CGSizeZero;
    if (!highLightImage)
    {
        highLightImage = [image imageByApplyingAlpha:0.8];
    }
    if (text)
    {
        NSInteger textLength = [text sizeWithFont:font].width;
        size = CGSizeMake(textLength + 20, MAX(ceil(font.lineHeight*1.4),image.size.height));
        [button.titleLabel setFont:font];
        [button setTitle:text forState:UIControlStateNormal];
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        button.titleLabel.backgroundColor = [UIColor clearColor];
		[button setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        [button setTitleShadowColor:[UIColor clearColor] forState:UIControlStateDisabled];
        button.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        if (image)
        {
            image = [image stretchableImageWithLeftCapWidth:ceil(image.size.width/2) topCapHeight:ceil(image.size.height/2)];
            [button setBackgroundImage:image forState:UIControlStateNormal];
			[button setBackgroundImage:image forState:UIControlStateDisabled];
        }
        
        if (highLightImage)
        {
            highLightImage = [highLightImage stretchableImageWithLeftCapWidth:ceil(highLightImage.size.width/2) topCapHeight:ceil(highLightImage.size.height/2)];
            [button setBackgroundImage:highLightImage forState:UIControlStateHighlighted];
            [button setBackgroundImage:highLightImage forState:UIControlStateSelected];
        }
    }
    else
    {
        size = image.size;
        if (image)
        {
            [button setImage:image forState:UIControlStateNormal];
        }
        if (highLightImage)
        {
            [button setImage:highLightImage forState:UIControlStateHighlighted];
            [button setImage:highLightImage forState:UIControlStateSelected];
        }
        if (size.width < 40)
        {
            size.width = 40;
        }
        if (size.height < 40)
        {
            size.height = 40;
        }
        
    }
    
    if (text)
    {
        if (size.width < 40)
        {
            size.width = 40;
        }
        if (size.height < 30)
        {
            size.height = 30;
        }
    }
	button.frame = CGRectMake(0, 0, size.width, size.height);
    button.adjustsImageWhenDisabled = NO;
    button.adjustsImageWhenHighlighted = NO;
    return button;
}

+ (UIButton*)buttonImage:(UIImage*)image highLightImage:(UIImage*)highLightImage
{
    return [UIButton button:nil font:nil image:image highLightImage:highLightImage];
}

+ (UIButton*)buttonImage:(UIImage*)image highLightImage:(UIImage*)highLightImage background:(UIImage*)background backgroundHighLight:(UIImage*)backgroundHighLight size:(CGSize)size
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    if (background)
    {
        background = [background stretchableImageWithLeftCapWidth:ceil(background.size.width/2) topCapHeight:ceil(background.size.height/2)];
        [button setBackgroundImage:background forState:UIControlStateNormal];
    }
    
    if (backgroundHighLight)
    {
        backgroundHighLight = [backgroundHighLight stretchableImageWithLeftCapWidth:ceil(backgroundHighLight.size.width/2) topCapHeight:ceil(backgroundHighLight.size.height/2)];
        [button setBackgroundImage:backgroundHighLight forState:UIControlStateHighlighted];
        [button setBackgroundImage:backgroundHighLight forState:UIControlStateSelected];
    }
    
    [button setImage:image forState:UIControlStateNormal];
    [button setImage:highLightImage forState:UIControlStateHighlighted];
    button.size = size;
    button.adjustsImageWhenDisabled = NO;
    button.adjustsImageWhenHighlighted = NO;
    return button;
}

+ (UIButton *)button:(NSString *)text font:(UIFont*)font textColor:(UIColor *)textColor bgColor:(UIColor *)bgColor
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = bgColor;
    [button setTitleColor:textColor forState:UIControlStateNormal];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [button setTitle:text forState:UIControlStateNormal];
    button.titleLabel.font = font;
    [button sizeToFit];
    return button;
}

- (void)setTextStyle:(TextStyle*)style
{
    if (style)
    {
        [self setTitleColor:style.color forState:UIControlStateNormal];
        [self setTitleShadowColor:style.shadowColor forState:UIControlStateNormal];
    }
}

- (void)setTextStyle:(TextStyle*)style forState:(UIControlState)state
{
    if (style)
    {
        [self setTitleColor:style.color forState:state];
        self.titleLabel.shadowOffset = style.shadowOffset;
        [self setTitleShadowColor:style.shadowColor forState:state];
    }
}

- (void)addBlock:(ButtonActionBlock)block forControlEvents:(UIControlEvents)controlEvents
{
    objc_setAssociatedObject(self, &buttonBlockKey, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self addTarget:self action:@selector(callActionBlock:) forControlEvents:controlEvents];
}

- (ButtonActionBlock)getActionBlock
{
    ButtonActionBlock block = (ButtonActionBlock)objc_getAssociatedObject(self, &buttonBlockKey);
    return block;
}

- (void)callActionBlock:(id)sender
{
    ButtonActionBlock block = [self getActionBlock];
    if (block)
    {
        block();
    }
}
@end
