//
//  UIColorExt.h
//  
//
//  Created by lipq on 10-8-16.
//  Copyright 2010  . All rights reserved.
//

#import <Foundation/Foundation.h>
@interface UIColor (Ext)
+ (UIColor*)colorWithRGBA:(NSUInteger)color;
//string example: 0x000000FF(RGBA)
+ (UIColor *)colorWithString:(NSString *)string;
- (NSString *)hexString;
+ (UIColor *)systemBlue;
@end
