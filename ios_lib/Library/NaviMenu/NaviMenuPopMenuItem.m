//
//  NaviMenuPopMenuItem.m
//  YContact
//
//  Created by 捷 邹 on 12-5-29.
//  Copyright (c) 2012年 . All rights reserved.
//

#import "NaviMenuPopMenuItem.h"

@implementation NaviMenuPopMenuItem
+ (id)itemWithTitle:(NSString*)title image:(UIImage*)image highLightImage:(UIImage *)hightLightImage block:(NaviMenuPopMenuItemBlock)block
{
    NaviMenuPopMenuItem *item = [[NaviMenuPopMenuItem alloc] init];
    item.title = title;
    item.block = block;
    item.icon = image;
    item.iconHighLight = hightLightImage;
    return item;
}
+ (id)itemWithTitle:(NSString*)title image:(UIImage*)image block:(NaviMenuPopMenuItemBlock)block
{
    NaviMenuPopMenuItem *item = [[NaviMenuPopMenuItem alloc] init];
    item.title = title;
    item.block = block;
    item.icon = image;
    return item;
}
+ (id)itemWithTitle:(NSString*)title block:(NaviMenuPopMenuItemBlock)block;
{
    NaviMenuPopMenuItem *item = [[NaviMenuPopMenuItem alloc] init];
    item.title = title;
    item.block = block;
    return item;
}
- (id)init
{
    self = [super init];
    if (self)
    {
        self.needMark = YES;
    }
    return self;
}
@end
