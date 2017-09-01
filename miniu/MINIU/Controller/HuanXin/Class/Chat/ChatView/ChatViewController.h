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
#import "BaseViewController.h"

@class GoodsEntity, OrderEntity;

@interface ChatViewController : BaseViewController

// 单例
+ (instancetype)shareInstance;

@property (nonatomic, assign) BOOL isCurrentWindow;
@property (strong, nonatomic) EMConversation *conversation;//会话管理者
@property (nonatomic, strong) UIImage *willSendImage;  // 将要发送的出去的图片

@end
