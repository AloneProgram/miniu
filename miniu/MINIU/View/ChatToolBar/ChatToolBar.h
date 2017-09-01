//
//  ChatToolBar.h
//  miniu
//
//  Created by SimMan on 15/5/26.
//  Copyright (c) 2015年 SimMan. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ChatViewController.h"
#import "EMConversation.h"

@interface ChatToolBar : UIView <EasemobManageDelegate>

+ (instancetype)shareInstance;

- (void)updateBadge;//更新标志

- (void) show;
- (void) hidden;

@end
