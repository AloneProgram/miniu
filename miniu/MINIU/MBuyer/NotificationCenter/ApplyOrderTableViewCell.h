//
//  ApplyOrderTableViewCell.h
//  miniu
//
//  Created by SimMan on 5/9/15.
//  Copyright (c) 2015 SimMan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LogEntity.h"

@protocol ApplyOrderTableViewCellDelegate <NSObject>
- (void) avatarImageViewDidTap:(LogEntity *)log;
- (void) goodsDidTap:(LogEntity *)log;
@end


@interface ApplyOrderTableViewCell : UITableViewCell

@property (nonatomic, assign) id<ApplyOrderTableViewCellDelegate> delegate;

@property (nonatomic, strong) LogEntity *log;

@end
