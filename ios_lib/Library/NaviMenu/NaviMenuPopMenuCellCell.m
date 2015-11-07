//
//  NaviMenuPopMenuCellCell.m
//  YConference
//
//  Created by  on 13-1-31.
//  Copyright (c) 2013年  Ltd., Co. All rights reserved.
//

#import "NaviMenuPopMenuCellCell.h"

@implementation NaviMenuPopMenuCellCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    self.iconImageView.frame = CGRectMake(0, 0, self.iconImageView.image.size.width, self.iconImageView.image.size.height);
    self.iconImageView.top = ceil((self.height - self.iconImageView.image.size.height)/2);
    self.iconImageView.left = self.width - self.iconImageView.width - 2*KGap;
    
    [self.nameLabel sizeToFit];
    
    
    self.nameLabel.top = ceil((self.height - self.nameLabel.height)/2) - 1;
    self.nameLabel.left = self.imageView.image ? self.imageView.right + KGap/2 : KGap;
    self.nameLabel.width = self.iconImageView.left - 3*KGap;
}

- (UILabel *)nameLabel
{
    if (!_nameLabel)
    {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.font = [UIFont systemFontOfSize:16];
        [self.contentView addSubview:_nameLabel];
    }
    return _nameLabel;
}

- (UIImageView *)iconImageView
{
    if (!_iconImageView)
    {
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_iconImageView];
    }
    return _iconImageView;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self.iconImageView removeFromSuperview];
    self.iconImageView = nil;
    
    [self.nameLabel removeFromSuperview];
    self.nameLabel = nil;
}

@end
