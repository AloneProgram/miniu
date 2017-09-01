//
//  LogicManager.h
//  DLDQ_IOS
//
//  Created by simman on 14-7-6.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LogicBaseModel.h"
#import "BaiduTj.h"
#import "JpushManage.h"
#import "WeChatManage.h"
//#import "IVersionManage.h"
#import "ReachabilityManager.h"
#import "EasemobManage.h"

#import "UserManager.h"
#import "AddressManager.h"
#import "TagManager.h"
#import "AssetManager.h"
#import "GoodsManager.h"
#import "LocationManager.h"
#import "CommentManager.h"
#import "OrderManager.h"
#import "LogManager.h"
#import "UpdateManager.h"
#import "AlipayManager.h"
#import "ADManager.h"
#import "MessageManager.h"
#import "URLManager.h"
#import "UploadManager.h"
#import "PingPlusManager.h"
#import "NotificationCenterManager.h"

// 获取 LogicManager单例 宏定义
#define logicShareInstance   [LogicManager shareInstance]

#define CURRENT_USER_INSTANCE [logicShareInstance getUserManager]
#define USER_IS_LOGIN [[logicShareInstance getUserManager] getCurrentUserID]               // 用户是否登录

/**
 *	@brief	逻辑管理对象, 通过逻辑管理对象可以获取各个业务模块接口
 */
@interface LogicManager : NSObject <LogicBaseModel>

/**
 *	@brief	获取逻辑管理对象单例
 */
+ (instancetype)shareInstance;

/**
 *  获取百度统计实例
 *
 *  @return 
 */
- (BaiduTj *)getBaiduTjManage;

/**
 *  获取极光推送实例
 *
 *  @return
 */
- (JpushManage *)getJpushManage;

/**
 *  获取微信单例
 *
 *  @return 
 */
- (WeChatManage *)getWeChatManage;

/**
 *  获取版本检测单例
 *
 *  @return 
 */
//- (IVersionManage *)getIVersionManage;

/**
 *  获取网络检测的单例
 *
 *  @return
 */
- (ReachabilityManager *)getReachabilityManager;

/**
 *  获取环信相关的单例
 *
 *  @return 
 */
- (EasemobManage *)getEasemobManage;

/**
 *  获取用户管理单例
 *
 *  @return 
 */
- (UserManager *)getUserManager;

/**
 *  获取地址单例
 *
 *  @return
 */
- (AddressManager *)getAddressManager;

/**
 *  获取标签的单例
 *
 *  @return 
 */
- (TagManager *) getTagManager;

/**
 *  获取资源的单例
 *
 *  @return 
 */
- (AssetManager *) getAssetManager;

/**
 *  获取商品的单例
 *
 *  @return 
 */
- (GoodsManager *) getGoodsManager;

/**
 *  获取地理位置单例
 *
 *  @return 
 */
- (LocationManager *) getLocationManager;


/**
 *  获取评论的单例
 *
 *  @return
 */
- (CommentManager *) getCommentManager;

/**
 *  获取订单的单例
 *
 *  @return 
 */
- (OrderManager *) getOrderManager;

/**
 *  获取日志消息的单例
 *
 *  @return
 */
- (LogManager *) getLogManager;

/**
 *  获取 更新 的实例
 *
 *  @return 
 */
//- (UpdateManager *)getUpdateManager;

/**
 *  获取 支付宝 的实例
 *
 *  @return
 */
- (AlipayManager *) getAlipayManager;

/**
 *  获取广告管理
 *
 *  @return
 */
- (ADManager *) getADManager;

/**
 *  获取消息管理
 *
 *  @return 
 */
- (MessageManager *) getMessageManager;

/**
 *  @brief  获取URL管理单例
 *
 *  @return 
 */
- (URLManager *) getURLManager;

/**
 *  @brief  获取上传单例
 *
 *  @return 
 */
- (UploadManager *) getUploadManager;

/**
 *  @brief  ping+
 *
 *  @return 
 */
- (PingPlusManager *) getPingPlusManager;

- (NotificationCenterManager *) getNotificationCenterManager;

@end
