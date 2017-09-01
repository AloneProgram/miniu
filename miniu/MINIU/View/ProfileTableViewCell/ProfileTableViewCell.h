//
//  ProfileTableViewCell.h
//  miniu
//
//  Created by SimMan on 4/21/15.
//  Copyright (c) 2015 SimMan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *leftImageView;
@property (weak, nonatomic) IBOutlet UILabel *title;

+ (id)shareInstanceCell;

@end