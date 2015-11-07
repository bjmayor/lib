//
//  HaloUITextView.m
//  YContact
//
//  Created by  on 11-10-1.
//  Copyright 2011年 . All rights reserved.
//

#import "HaloUITextView2.h"
@interface HaloUITextView2()
@property (nonatomic,retain) UILabel *placeHolderLabel;
@end

@implementation HaloUITextView2
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.font = [UIFont systemFontOfSize:17];
    }
    return self;
}

- (UILabel*)placeHolderLabel
{
    if (!_placeHolderLabel)
    {
        _placeHolderLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _placeHolderLabel.backgroundColor = [UIColor clearColor];
        _placeHolderLabel.font = self.font;
        _placeHolderLabel.textColor = [UIColor colorWithRGBA:0xb5b5b5ff];
        [self addSubview:_placeHolderLabel];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:self];
    }
    return _placeHolderLabel;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGSize size = [self.placeHolderLabel sizeThatFits:CGSizeMake(self.width - KGap*2, self.height)];
    self.placeHolderLabel.frame = CGRectMake(8, 8, size.width, size.height);
    self.placeHolderLabel.font = self.font;
}

- (void)setPlaceHolder:(NSString *)str
{
    _placeHolder = str;
    if (str.length == 0 )
    {
        self.placeHolderLabel = nil;
    }
    else
    {
        self.placeHolderLabel.text = str;
        [self setNeedsLayout];
    }
    
}

- (void)textChanged:(NSNotification *)notification
{
    if(self.placeHolder.length == 0)
    {
        return;
    }
    
    if([[self text] length] == 0)
    {
        self.placeHolderLabel.alpha = 1.0;
    }
    else
    {
        self.placeHolderLabel.alpha = 0.0;
    }
}

@end

