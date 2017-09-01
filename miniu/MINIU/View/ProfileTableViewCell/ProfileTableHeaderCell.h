//
//  ProfileTableHeaderCell.h
//  miniu
//
//  Created by SimMan on 4/24/15.
//  Copyright (c) 2015 SimMan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileTableHeaderCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNickName;

+ (id)shareInstanceCell;

@end
