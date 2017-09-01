//
//  ProfileTableHeaderCell.m
//  miniu
//
//  Created by SimMan on 4/24/15.
//  Copyright (c) 2015 SimMan. All rights reserved.
//

#import "ProfileTableHeaderCell.h"

@implementation ProfileTableHeaderCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.avatarImageView setImageWithUrl:[CURRENT_USER_INSTANCE getCurrentUserAvatar] withSize:ImageSizeOfAuto];
    
    [self.avatarImageView doCircleFrame];
    
    [self.userNickName setText:[CURRENT_USER_INSTANCE getCurrentUserName]];
}

+ (id)shareInstanceCell
{
    return [[[NSBundle mainBundle] loadNibNamed:@"ProfileTableHeaderCell" owner:nil options:nil] lastObject];
}

@end
