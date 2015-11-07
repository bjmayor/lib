//
//  UIFont+Ext.h
//  HaloSlimFramework
//
//  Created by  on 13-7-14.
//
//

#import <UIKit/UIKit.h>
UIKIT_EXTERN NSString *UI7FontAttributeNone;
UIKIT_EXTERN NSString *UI7FontAttributeUltraLight;
UIKIT_EXTERN NSString *UI7FontAttributeUltraLightItalic;
UIKIT_EXTERN NSString *UI7FontAttributeLight;
UIKIT_EXTERN NSString *UI7FontAttributeLightItalic;
UIKIT_EXTERN NSString *UI7FontAttributeMedium;
UIKIT_EXTERN NSString *UI7FontAttributeItalic;
UIKIT_EXTERN NSString *UI7FontAttributeBold;
UIKIT_EXTERN NSString *UI7FontAttributeBoldItalic;
UIKIT_EXTERN NSString *UI7FontAttributeCondensedBold;
UIKIT_EXTERN NSString *UI7FontAttributeCondensedBlack;

#define UIFontWithHeight(height) [UIFont systemFontOfSize:height]
#define UIBoldFontWithHeight(height) [UIFont boldSystemFontOfSize:height]

@interface UIFont (iOS7)

+ (UIFont *)iOS7SystemFontOfSize:(CGFloat)fontSize attribute:(NSString *)attribute;

@end
