//
//  HaloUIWaitView.h
//  YContact
//
//  Created by  on 11-11-1.
//  Copyright (c) 2011年 . All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HaloUIWaitView : UIView
@property (nonatomic,strong) UILabel *textLabel;
@property (nonatomic,strong) UIActivityIndicatorView *indicator;
@property (nonatomic,assign) UIEdgeInsets contentInsets;
@end
