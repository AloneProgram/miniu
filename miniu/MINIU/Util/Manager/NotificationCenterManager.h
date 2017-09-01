//
//  NotificationCenterManager.h
//  miniu
//
//  Created by SimMan on 4/30/15.
//  Copyright (c) 2015 SimMan. All rights reserved.
//

#import "ManagerBase.h"


@interface NotificationCenterManager : ManagerBase <LogicBaseModel>

/**
 *  @brief  单例
 *
 *  @return
 */
+ (instancetype)shareInstance;

/**
 *  @brief  显示一条本地通知
 *
 *  @param alertBody 显示的内容
 *  @param userInfo  UserInfo 用于识别
 */
- (void) showLocalNotificationWithAlertBody:(NSString *)alertBody andUserInfo:(NSDictionary *)userInfo playSound:(BOOL)play;

/**
 *  @brief  在前台显示一条消息
 *
 *  @param title     标题
 *  @param alertBody 显示的内容
 */
- (void) showActiveNotificationWithTitle:(NSString *)title andAlertBody:(NSString *)alertBody playSound:(BOOL)play;

/**
 *  @brief  播放声音与振动
 */
- (void)playSoundAndVibration;

@end
