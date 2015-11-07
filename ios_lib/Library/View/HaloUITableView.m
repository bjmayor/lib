//
//  HaloUITableView.m
//  Hello World
//
//  Created by  on 13-5-19.
//  Copyright (c) 2013年 __Company__. All rights reserved.
//

#import "HaloUITableView.h"
#import "HaloUITableCell.h"
@interface HaloUITableView()
@property (nonatomic,strong) UIView *emptyView;
@end
@implementation HaloUITableView
@synthesize emptyLabel = _emptyLabel;
- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self)
    {
        self.emptyTitleInsets = UIEdgeInsetsMake(KGap/2, KGap, KGap/2, KGap);
    }
    return self;
}

- (void)setEmptyLogo:(UIImage *)emptyLogo
{
    [self.emptyView removeFromSuperview];
    self.emptyView = [[UIImageView alloc] initWithImage:emptyLogo];
    self.emptyView.size = emptyLogo.size;
    self.emptyView.hidden = YES;
    [self addSubview:self.emptyView];
}

- (UILabel*)emptyLabel
{
    if (!_emptyLabel)
    {
        _emptyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _emptyLabel.font = [UIFont systemFontOfSize:14];
        _emptyLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _emptyLabel.numberOfLines = 0;
        _emptyLabel.textColor = [UIColor colorWithRGBA:0xb3b3b3ff];
        _emptyLabel.textAlignment = NSTextAlignmentCenter;
        _emptyLabel.backgroundColor = [UIColor clearColor];
        _emptyLabel.hidden = YES;
        [self addSubview:_emptyLabel];
    }
    return _emptyLabel;
}

- (void)layoutEmptyLabel
{
    if (_emptyLabel)
    {
        NSInteger realHeight = self.height - self.tableHeaderView.height - self.tableFooterView.height;
        UIFont *font = _emptyLabel.font;
        CGSize size = [_emptyLabel.text sizeWithFont:font constrainedToSize:CGSizeMake(self.width - KGap/2, CGFLOAT_MAX) lineBreakMode:_emptyLabel.lineBreakMode];
        CGRect rect = CGRectMake(self.emptyTitleInsets.left, (realHeight - size.height)/2 + self.tableHeaderView.height + self.emptyTitleInsets.top, self.width - self.emptyTitleInsets.left - self.emptyTitleInsets.right, size.height + self.emptyTitleInsets.bottom);
        _emptyLabel.frame = rect;
    }
}

- (void)layoutEmptyView
{
    if (_emptyView)
    {
        NSInteger realHeight = self.height - self.tableHeaderView.height - self.tableFooterView.height;
        if (_emptyLabel)
        {
            CGFloat height = _emptyLabel.height + _emptyView.height;
            _emptyView.origin = CGPointMake((self.width - _emptyView.width)/2 + self.emptyViewInsets.left, (realHeight - height)/2 + self.tableHeaderView.height + self.emptyViewInsets.top);
            _emptyLabel.top = ceil(_emptyView.bottom + self.emptyTitleInsets.top + self.emptyViewInsets.bottom);
        }
        else
        {
            _emptyView.origin = CGPointMake((self.width - _emptyView.width)/2 + self.emptyViewInsets.left, (realHeight - _emptyView.height)/2 + self.tableHeaderView.height+ self.emptyViewInsets.top);
        }
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutEmptyLabel];
    [self layoutEmptyView];
}

- (void)checkListIsEmpty
{
    NSInteger count = 0;
    for (NSInteger i=0; i<self.numberOfSections;i++)
    {
        count += [self numberOfRowsInSection:i];
        if (count>0)
        {
            break;
        }
    }
    [self setHideEmpty:count > 0];
}

- (void)reloadData
{
    [super reloadData];
    [self checkListIsEmpty];
}

- (void)setHideEmpty:(BOOL)hide
{
    if (_emptyView!=nil || _emptyLabel!=nil)
    {
        _emptyView.alpha = hide ? 1.0f : 0.0f;
        _emptyLabel.alpha = hide ? 1.0f : 0.0f;
        [UIView animateWithDuration:0.2f animations:^{
            _emptyView.alpha = hide ? 0.0f : 1.0f;
            _emptyLabel.alpha = hide ? 0.0f : 1.0f;
        } completion:^(BOOL finished) {
            _emptyView.hidden = hide;
            _emptyLabel.hidden = hide;
        }];
    }
}



- (BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view
{
    if (self.cellForShowingButtons && ![view isKindOfClass:[UIButton class]])
    {
        if ([[view superview] superview] != self.cellForShowingButtons)
        {
            [self hideCellButtons];
            return NO;
        }
    }
    return [super touchesShouldBegin:touches withEvent:event inContentView:view];
}

- (void)hideCellButtons
{
    [self.cellForShowingButtons endShowRightButtons];
}
@end
