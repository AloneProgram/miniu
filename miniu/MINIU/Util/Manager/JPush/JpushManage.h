//
//  JpushManage.h
//  DLDQ_IOS
// 100@dldq.org dldq5156
//  Created by simman on 14-7-6.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LogicBaseModel.h"
#import "APService.h"

@interface JpushManage : NSObject<LogicBaseModel>

/**
 *  获取极光推送管理的单例
 *
 *  @return
 */
+ (instancetype)shareInstance;

/**
 *  @brief  配置JPush
 *
 *  @param options 配置参数  launchOptions
 */
- (void)setUpJPushWithOptions:(NSDictionary *)options;

/**
 *  @brief  注册Token
 *
 *  @param token DeviceToken
 */
- (void)registerDeviceToken:(NSData *)token;

/**
 *  @brief  处理推送通知
 *
 *  @param userInfo 通知
 */
- (void)handleRemoteNotification:(NSDictionary *)userInfo;

/**
 * 本地推送在前台推送。默认App在前台运行时不会进行弹窗，在程序接收通知调用此接口可实现指定的推送弹窗。
 * @param notification 本地推送对象
 * @param notificationKey 需要前台显示的本地推送通知的标示符
 */
- (void) showLocalNotificationAtFront:(UILocalNotification *)notification
                        identifierKey:(NSString *)notificationKey;

/**
 *  set Badge
 *  @param value 设置JPush服务器的badge的值
 *  本地仍须调用UIApplication:setApplicationIconBadgeNumber函数设置badge
 */
-(BOOL)setBadge:(NSInteger)value;

/**
 *  reset Badge
 *  @param value 清除JPush服务器对badge值的设定.
 *  本地仍须调用UIApplication:setApplicationIconBadgeNumber函数设置badge
 */
-(void)resetBadge;


/**
 *  @brief  设置推送累加值、应用外的角标，需要在此方法内调用相关的Manager拿到未读条数
 */
- (void) reloadBadge;


/**
 *  @brief  减去N个角标
 *
 *  @param value
 */
- (void) decreaseBadge:(NSInteger)value;

@end
