//
//  HaloUITableView.h
//  Hello World
//
//  Created by  on 13-5-19.
//  Copyright (c) 2013年 __Company__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HaloUITableCell;
@interface HaloUITableView : UITableView
@property (nonatomic,assign) UIEdgeInsets emptyViewInsets;
@property (nonatomic,assign) UIEdgeInsets emptyTitleInsets;
@property (nonatomic,strong) UIImage *emptyLogo;
@property (nonatomic,strong,readonly) UILabel *emptyLabel;
@property (nonatomic,assign) HaloUITableCell *cellForShowingButtons;

- (void)checkListIsEmpty;
- (void)setHideEmpty:(BOOL)hide;
- (void)hideCellButtons;
@end
