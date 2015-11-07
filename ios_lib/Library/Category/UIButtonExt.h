//
//  UIButtonExt.h
//  Hello World
//
//  Created by  on 13-5-19.
//  Copyright (c) 2013年 __Company__. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^ButtonActionBlock)(void);

@interface UIButton (Ext)
+ (UIButton*)button:(NSString*)text font:(UIFont*)font image:(UIImage*)image highLightImage:(UIImage*)highLightImage
;
+ (UIButton*)buttonImage:(UIImage*)image highLightImage:(UIImage*)highLightImage;
+ (UIButton*)buttonImage:(UIImage*)image highLightImage:(UIImage*)highLightImage background:(UIImage*)background backgroundHighLight:(UIImage*)backgroundHighLight size:(CGSize)size;
+ (UIButton *)button:(NSString *)text font:(UIFont*)font textColor:(UIColor *)textColor bgColor:(UIColor *)bgColor;

- (void)setTextStyle:(TextStyle*)style;
- (void)setTextStyle:(TextStyle*)style forState:(UIControlState)state;

- (void)addBlock:(ButtonActionBlock)block forControlEvents:(UIControlEvents)controlEvents;
- (ButtonActionBlock)getActionBlock;
@end
