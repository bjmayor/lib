//
//  NaviMenuPopView.h
//  YContact
//
//  Created by 捷 邹 on 12-5-12.
//  Copyright (c) 2012年 . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NaviMenuPopMenuItem.h"
extern NSString *NotificationPopMenuWillAppear;
extern NSString *NotificationPopMenuWillDisapper;
@interface NaviMenuPopView : UIView<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic, assign)NSInteger itemHeight;
@property(nonatomic, strong)UIImage *sectionSepratorImage UI_APPEARANCE_SELECTOR;
- (id)initWithTop:(CGFloat)top singleSection:(NSArray*)array;
- (id)initWithTop:(CGFloat)top itemsSectionArray:(NSArray *)sectionArray;
- (void)showInView:(UIView *)view;
- (void)dismissPopView;
@end
