//
//  NaviMenuPopMenuItem.h
//  YContact
//
//  Created by 捷 邹 on 12-5-29.
//  Copyright (c) 2012年 . All rights reserved.
//

typedef void (^NaviMenuPopMenuItemBlock)();
@interface NaviMenuPopMenuItem : NSObject
{
    NSString *_title;
    UIImage *_icon;
    NaviMenuPopMenuItemBlock  _block;
}
@property(nonatomic, strong)UIImage     *icon;
@property(nonatomic, strong)NSString    *title;
@property(nonatomic, strong)UIImage     *iconHighLight;
@property(nonatomic, copy)NaviMenuPopMenuItemBlock block;
@property(nonatomic, assign)BOOL needMark;

+ (id)itemWithTitle:(NSString*)title image:(UIImage*)image block:(NaviMenuPopMenuItemBlock)block;

+ (id)itemWithTitle:(NSString*)title block:(NaviMenuPopMenuItemBlock)block;

+ (id)itemWithTitle:(NSString*)title image:(UIImage*)image highLightImage:(UIImage *)hightLightImage block:(NaviMenuPopMenuItemBlock)block;
@end
