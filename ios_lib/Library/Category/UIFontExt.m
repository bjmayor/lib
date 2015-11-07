//
//  UIFont+Ext.m
//  HaloSlimFramework
//
//  Created by  on 13-7-14.
//
//

#import "UIFontExt.h"

NSString *UI7FontAttributeNone = nil;
NSString *UI7FontAttributeUltraLight = @"UltraLight";
NSString *UI7FontAttributeUltraLightItalic = @"UltraLightItalic";
NSString *UI7FontAttributeLight = @"Light";
NSString *UI7FontAttributeLightItalic = @"LightItalic";
NSString *UI7FontAttributeMedium = @"Medium";
NSString *UI7FontAttributeItalic = @"Italic";
NSString *UI7FontAttributeBold = @"Bold";
NSString *UI7FontAttributeBoldItalic = @"BoldItalic";
NSString *UI7FontAttributeCondensedBold = @"CondensedBold";
NSString *UI7FontAttributeCondensedBlack = @"CondensedBlack";

@implementation UIFont (iOS7)

+ (UIFont *)iOS7SystemFontOfSize:(CGFloat)fontSize attribute:(NSString *)attribute {
    NSString *fontName = attribute ? [@"HelveticaNeue-%@" format:attribute] : @"Helvetica Neue";
    return [UIFont fontWithName:fontName size:fontSize];
}


@end
