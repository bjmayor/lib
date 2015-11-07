//
//  UIColorExt.m
//  
//
//  Created by lipq on 10-8-16.
//  Copyright 2010  . All rights reserved.
//

#import "UIColorExt.h"
@implementation UIColor (Ext)

+ (UIColor*)colorWithRGBA:(NSUInteger)color
{
	return [UIColor colorWithRed:((color>>24)&0xFF)/255.0
						   green:((color>>16)&0xFF)/255.0
							blue:((color>>8)&0xFF)/255.0
						   alpha:((color)&0xFF)/255.0];
}


+ (UIColor *)colorWithString:(NSString *)string
{
    NSInteger c = 0;
    sscanf([string UTF8String], "%x", &c);
    return [UIColor colorWithRGBA:c];
}

- (NSString *)hexString
{
    const CGFloat *components = CGColorGetComponents(self.CGColor);
    int red = (int)(components[0] * 255);
    int green = (int)(components[1] * 255);
    int blue = (int)(components[2] * 255);
    int alpha = (int)(components[3] * 255);
    return [NSString stringWithFormat:@"#%0.2X%0.2X%0.2X", red, green, blue];
}


+ (UIColor *)systemBlue
{
    UIColor *btnFontColor = [UIColor colorWithRed:0 green:126.0/255 blue:245.0/255 alpha:1];
    return btnFontColor;
}
@end
