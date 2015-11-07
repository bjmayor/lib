//
//  SeetingTableCellBackgroudView.h
//  Foodgram
//
//  Created by  on 12-9-2.
//  Copyright (c) 2012年 . All rights reserved.
//

#import <UIKit/UIKit.h>

enum {
    EFirstCell,
    EMiddleCell,
    ELastCell,
    ESingleCell
};

typedef int TableViewCellLocation;

@interface HaloUITableGroupCellBackgroundView : UIView
@property (nonatomic)TableViewCellLocation loc;
@property (nonatomic,strong)UIColor *borderColor;

@end


@interface HaloUITableGroupCellBackgroundEmptyView:UIView
@end
