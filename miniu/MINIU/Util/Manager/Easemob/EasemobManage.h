//
//  EasemobManage.h
//  DLDQ_IOS
//
//  Created by simman on 14-8-28.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LogicBaseModel.h"
#import "EaseMob.h"
#import "SysSetting.h"
#import "ManagerBase.h"

@protocol EasemobManageDelegate <NSObject>
- (void) messageDidUnreadMessagesCountChanged:(NSUInteger)unreadNum;
@end

@interface EasemobManage : ManagerBase<LogicBaseModel, IChatManagerDelegate>

@property (nonatomic, assign) id<EasemobManageDelegate> delegate;

+ (instancetype)shareInstance;

#if TARGET_IS_MINIU_BUYER
/**
 *  @brief  如果是买手版则可以控制是否启用用户登陆成功自动登陆环信，默认为Yes
 */
@property (nonatomic, assign) BOOL enableAutoLogin;
#endif

- (NSInteger) getAllUnreadNum;

- (void) easeMobapplication:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;

/**
 *  自动登录
 */
- (void) autoLogin;

/**
 *  登录环信
 *
 *  @param hxid  环信ID
 *  @param hxpwd 换新密码
 */
- (void) loginToEasemobManageWithHXID:(NSString *)hxid hxPwd:(NSString *)hxpwd;

- (void)applicationWillResignActive:(UIApplication *)application;

/**
 *  程序进入到后台
 *
 *  @param application 
 */
- (void)applicationDidEnterBackground:(UIApplication *)application;

/**
 *  程序进入到前台
 *
 *  @param application 
 */
- (void)applicationWillEnterForeground:(UIApplication *)application;

/**
 *  程序重新激活
 *
 *  @param application
 */
- (void)applicationDidBecomeActive:(UIApplication *)application;

/**
 *  程序意外暂行
 *
 *  @param application 
 */
- (void)applicationWillTerminate:(UIApplication *)application;

/**
 *  注册远程通知
 *
 *  @param application
 *  @param deviceToken
 */
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;

/**
 *  远程通知回调
 *
 *  @param application
 *  @param error
 */
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *) error;

/**
 *  获取APN通知
 *
 *  @param application
 *  @param userInfo
 */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo;

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification;




// --------------------------------------------  买手版本

/**
 *  @brief  切换客服接口
 *
 *  @param changeUId    需要切换的用户ID
 *  @param serviceHxUId 切换后的客服环信id
 *  @param success      成功回调
 *  @param failure      失败回调
 *
 *  @return
 */
- (NSURLSessionDataTask *)switchServiceHx:(long long)changeUId
                                     serviceHxUId:(NSString *)serviceHxUId
                                    success:(void (^)(id responseObject))success
                                    failure:(void (^)(NSString *error))failure;

/**
 *  @brief  查询客服列表接口
 *
 *  @param success 成功回调
 *  @param failure 失败回调
 *
 *  @return 
 */
- (NSURLSessionDataTask *)getServiceListSuccess:(void (^)(id responseObject))success
                                  failure:(void (^)(NSString *error))failure;



// ----------------------------------------  用户版
@property (nonatomic, strong) EMConversation *conversation;  // 当前用户和米妞的会话列表

@end
