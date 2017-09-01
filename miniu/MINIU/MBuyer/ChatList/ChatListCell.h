/************************************************************
  *  * EaseMob CONFIDENTIAL 
  * __________________ 
  * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved. 
  *  
  * NOTICE: All information contained herein is, and remains 
  * the property of EaseMob Technologies.
  * Dissemination of this information or reproduction of this material 
  * is strictly forbidden unless prior written permission is obtained
  * from EaseMob Technologies.
  */

#import <UIKit/UIKit.h>

@protocol ChatListCellDelegate <NSObject>
- (void)longPressAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface ChatListCell : UITableViewCell

@property (weak, nonatomic) id<ChatListCellDelegate> delegate;
@property (strong, nonatomic) NSIndexPath *indexPath;

@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, strong) UIImage *placeholderImage;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *detailMsg;
@property (nonatomic, strong) NSString *time;
@property (nonatomic) NSInteger unreadCount;

@property (nonatomic, assign) CGFloat textLableWidth;

+(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
@end
