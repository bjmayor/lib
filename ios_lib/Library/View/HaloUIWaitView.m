//
//  HaloUIWaitView.m
//  YContact
//
//  Created by  on 11-11-1.
//  Copyright (c) 2011年 . All rights reserved.
//

#import "HaloUIWaitView.h"

@implementation HaloUIWaitView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        self.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self addSubview:self.indicator];
        [self.indicator startAnimating];
        
        self.textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.font = [UIFont systemFontOfSize:14];
        self.textLabel.numberOfLines = 0;
        [self addSubview:self.textLabel];
        self.contentInsets = UIEdgeInsetsMake(0, KGap, 0, KGap);
    }
    return self;
}

- (void)layoutSubviews
{
    NSInteger width = self.indicator.width;
    CGSize size = CGSizeZero;
    if (self.textLabel.text.length > 0)
    {
        size = [self.textLabel.text sizeWithFont:self.textLabel.font constrainedToSize:CGSizeMake(self.width - self.contentInsets.left - self.contentInsets.right, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
        width += size.width + KGap;

    }
    if (size.height > self.textLabel.font.lineHeight)
    {
        self.textLabel.textAlignment = NSTextAlignmentLeft;
        self.indicator.frame = CGRectMake((self.width - self.indicator.width)/2, (self.height - self.indicator.height - size.height)/2+self.contentInsets.top, self.indicator.width, self.indicator.height);
        
        self.textLabel.frame = CGRectMake((self.width - size.width)/2,self.indicator.bottom + KGap/2,size.width,size.height);
    }
    else
    {
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.indicator.frame = CGRectMake((self.width - width)/2, (self.height - self.indicator.height)/2+self.contentInsets.top, self.indicator.width, self.indicator.height);
        
        NSInteger x = self.indicator.right + KGap;
        self.textLabel.frame = CGRectMake(x,self.indicator.top + (self.indicator.height - self.textLabel.font.lineHeight)/2,size.width,self.textLabel.font.lineHeight);
    }
}
@end
