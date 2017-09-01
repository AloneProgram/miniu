//
//  ProfileUpdateCell.m
//  miniu
//
//  Created by SimMan on 4/25/15.
//  Copyright (c) 2015 SimMan. All rights reserved.
//

#import "ProfileUpdateCell.h"

#define MARKERFELT_THIN_FONT(X) [UIFont systemFontOfSize:X]

#define MARGIN 15
#define LABLE_HEIGHT 15
#define IMAGEVIEW_H_W 45

@interface ProfileUpdateCell()

@end

@implementation ProfileUpdateCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self.contentView addSubview:self.leftLable];
        [self.contentView addSubview:self.avatarImageView];
        [self.contentView addSubview:self.rightLable];
    }
    
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _leftLable.frame = CGRectMake(MARGIN, (self.selfH - LABLE_HEIGHT)/2, self.selfW/2, LABLE_HEIGHT);

    if (![_rightLable.text isEqualToString:@""]) {
        _avatarImageView.hidden = YES;
        _rightLable.hidden = NO;
        _rightLable.frame = CGRectMake(self.selfW/2, (self.selfH - LABLE_HEIGHT)/2, self.selfW/2 - MARGIN, LABLE_HEIGHT);
    } else {
        _rightLable.hidden = YES;
        _avatarImageView.hidden = NO;
        _avatarImageView.frame = CGRectMake(self.selfW - MARGIN - IMAGEVIEW_H_W, (self.selfH - IMAGEVIEW_H_W)/2, IMAGEVIEW_H_W, IMAGEVIEW_H_W);
        [_avatarImageView doCircleFrameNoBorder];
    }
}


- (UILabel *)leftLable
{
    if (!_leftLable) {
        _leftLable = [[UILabel alloc] initWithFrame:CGRectZero];
        _leftLable.font = MARKERFELT_THIN_FONT(14);
        _leftLable.textColor = [UIColor colorWithRed:0.475 green:0.471 blue:0.475 alpha:1];
    }
    return _leftLable;
}

- (UIImageView *)avatarImageView
{
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    return _avatarImageView;
}

- (UILabel *)rightLable
{
    if (!_rightLable) {
        _rightLable = [[UILabel alloc] initWithFrame:CGRectZero];
        _rightLable.font = MARKERFELT_THIN_FONT(14);
        _rightLable.textAlignment = NSTextAlignmentRight;
        _rightLable.textColor = [UIColor colorWithRed:0.475 green:0.471 blue:0.475 alpha:1];
    }
    return _rightLable;
}

@end
