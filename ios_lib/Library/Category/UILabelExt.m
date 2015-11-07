//
//  UILabelExt.m
//  HaloSlimFramework
//
//  Created by  on 13-6-8.
//
//

#import "UILabelExt.h"

@implementation UILabel (Ext)
- (void)setTextStyle:(TextStyle *)textStyle
{
    self.textColor = textStyle.color;
    self.shadowColor = textStyle.shadowColor;
    self.shadowOffset = textStyle.shadowOffset;
}
@end
