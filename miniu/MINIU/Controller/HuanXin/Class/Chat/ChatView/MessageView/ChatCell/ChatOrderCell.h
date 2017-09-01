//
//  ChatOrderCell.h
//  miniu
//
//  Created by SimMan on 15/6/11.
//  Copyright (c) 2015年 SimMan. All rights reserved.
//

#import "EMChatViewBaseCell.h"

#import "MessageModel.h"

@interface ChatOrderCell : UITableViewCell


@property (nonatomic, strong) MessageModel *messageModel;

@property (nonatomic, strong) UIImageView *userAvatar;
+ (CGFloat)cellHeight;


- (void)addCallBackBlock:(void(^)(MessageModel *messageModel))Block;

@end
