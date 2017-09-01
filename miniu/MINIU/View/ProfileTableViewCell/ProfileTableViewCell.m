//
//  ProfileTableViewCell.m
//  miniu
//
//  Created by SimMan on 4/21/15.
//  Copyright (c) 2015 SimMan. All rights reserved.
//

#import "ProfileTableViewCell.h"

@implementation ProfileTableViewCell

- (void)awakeFromNib {

    

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (id)shareInstanceCell
{
    return [[[NSBundle mainBundle] loadNibNamed:@"ProfileTableViewCell" owner:nil options:nil] lastObject];
}

@end
