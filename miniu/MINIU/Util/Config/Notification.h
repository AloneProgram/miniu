//
//  Notification.h
//  DLDQ_IOS
//
//  Created by simman on 14-8-19.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#ifndef DLDQ_IOS_Notification_h
#define DLDQ_IOS_Notification_h

// -----------------------------  通知 -----------------------
#define NSNotificationDefaultCenter         [NSNotificationCenter defaultCenter]

/**
 *  @brief  商品发布完成
 */
#define DID_FINISH_PUSH_GOODS               @"DID_FINISH_PUSH_GOODS"

/**
 *  @brief  网络请求发送完成,用于停止下拉刷新组件
 */
#define NetWorkTaskFinish                   @"NetWorkTaskFinish"

/**
 *  @brief  网络改变的事件
 */
#define ChangeNetWork                       @"ChangeNetWork"


// --- 极光推送相关

/**
 *  @brief  收到推送,应用在前台
 */
#define ReciveNotificationWithActive        @"ReciveNotificationWithActive"

/**
 *  @brief  收到推送,点击应用的推送进入的
 */
#define ReciveNotificationWithInactive      @"ReciveNotificationWithInactive"

/**
 *  @brief  收到推送,应用在后台
 */
#define ReciveNotificationWithBackground    @"ReciveNotificationWithBackground"

/**
 *  @brief  通知处理完毕,通知视图控制器reload
 */
#define LOGMANAGER_DID_UPDATE               @"LOGMANAGER_DID_UPDATE"

#endif
