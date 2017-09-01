//
//  EasemobManage.m
//  DLDQ_IOS
//
//  Created by simman on 14-8-28.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import "EasemobManage.h"
//#import "ApplyViewController.h"
#import "ChatViewController.h"

// 环信
#import "MessageModelManager.h"
#import "EMMessage.h"
#import "MessageModel.h"
#import "EMChatManagerDelegate.h"

#import "UserEntity.h"

#import "AppDelegate.h"

#define API_SERVICE_HX_LIST         @{@"method": @"user.service.list"}
#define API_SWITCH_HX_SERVICE         @{@"method": @"user.service.change"}

@interface EasemobManage() <EMChatManagerDelegate>
@property (nonatomic, assign) NSInteger allUnreadCount;
@end

@implementation EasemobManage
/**
 *  单例
 *
 *  @return EasemobManage
 */
+ (instancetype)shareInstance
{
    static EasemobManage * instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype) init
{
    self = [super init];
    if (self) {

#if TARGET_IS_MINIU_BUYER
        _enableAutoLogin = NO;
#endif
        _allUnreadCount = 0;
        [NSNotificationDefaultCenter addObserver:self selector:@selector(changeWork:) name:ChangeNetWork object:nil];
    }
    return self;
}

#pragma mark - 代理方法
/**
 *  @brief  收到消息
 *
 *  @param message
 */
- (void)didReceiveMessage:(EMMessage *)message
{
    if (![[ChatViewController shareInstance] isCurrentWindow]) {
        [self showEaseMessageWith:message];
    }
    
#if !TARGET_IPHONE_SIMULATOR
    BOOL isAppActivity = [[UIApplication sharedApplication] applicationState] == UIApplicationStateActive;
    if (!isAppActivity) {
        [self showNotificationWithMessage:message];
    }
#endif
}

- (void) didUnreadMessagesCountChanged
{
    // 获取未读条数
    [self loadUnreadMessageNum];
    
    // 通知极光去更新推送数量与应用外的角标 买家版不需要执行 
    [[logicShareInstance getJpushManage] reloadBadge];
    
    // 如果是买手版,则在主线程中更新消息列表的tabbaritem角标
#if TARGET_IS_MINIU_BUYER
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[[MAIN_DELEGATE tabBarController].viewControllers objectAtIndex:0] rdv_tabBarItem] setBadgeValue:[NSString stringWithFormat:@"%d", (int)_allUnreadCount]];
    });
#endif
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(messageDidUnreadMessagesCountChanged:)]) {
        [self.delegate messageDidUnreadMessagesCountChanged:[[ChatViewController shareInstance].conversation unreadMessagesCount]];
    }
}

- (void) showEaseMessageWith:(EMMessage *)message
{
    MessageModel *model = [MessageModelManager modelWithMessage:message];
    
    NSString *title;
    
#if TARGET_IS_MINIU
    title  = @"米妞发来消息";
#elif TARGET_IS_MINIU_BUYER
    title = @"米妞买手版";
#endif
    
    NSString *des;
    switch (model.type) {
        case eMessageBodyType_Text: {
            if ([model.content length] > 30) {
                des = [model.content substringToIndex:30];
            } else {
                des = model.content ;
            }
        }
            break;
        case eMessageBodyType_Image: {
            des = @"[图片]";
        }
            break;
        case eMessageBodyType_Voice: {
            des = @"[语音]";
        }
            break;
        default:
            break;
    }
    
    [[logicShareInstance getNotificationCenterManager] showActiveNotificationWithTitle:title andAlertBody:des playSound:YES];
}

#pragma mark 推送本地消息
- (void)showNotificationWithMessage:(EMMessage *)message
{
    EMPushNotificationOptions *options = [[EaseMob sharedInstance].chatManager pushNotificationOptions];
#warning 增加是否显示详细信息
    // 如果是买家版则显示简单的提示，否则显示详细提示
#if TARGET_IS_MINIU
    options.displayStyle = ePushNotificationDisplayStyle_simpleBanner;
#elif TARGET_IS_MINIU_BUYER
    options.displayStyle = ePushNotificationDisplayStyle_simpleBanner;
#endif
    
    NSString *alertBody = nil;
    NSString *messageStr = nil;
    
    if (options.displayStyle == ePushNotificationDisplayStyle_messageSummary) {
        id<IEMMessageBody> messageBody = [message.messageBodies firstObject];
        
        switch (messageBody.messageBodyType) {
            case eMessageBodyType_Text:
            {
                messageStr = ((EMTextMessageBody *)messageBody).text;
            }
                break;
            case eMessageBodyType_Image:
            {
                messageStr = @"[图片]";
            }
                break;
            case eMessageBodyType_Location:
            {
                messageStr = @"[位置]";
            }
                break;
            case eMessageBodyType_Voice:
            {
                messageStr = @"[音频]";
            }
                break;
            case eMessageBodyType_Video:{
                messageStr = @"[视频]";
            }
                break;
            default:
                break;
        }
        
        NSString *title = message.from;
        messageStr = [NSString stringWithFormat:@"%@:%@", title, messageStr];
    }
    else{
        messageStr = @"您有一条新消息";
    }
    
    alertBody = [NSString stringWithFormat:@"%@", messageStr];
    
    [[logicShareInstance getNotificationCenterManager] showLocalNotificationWithAlertBody:alertBody andUserInfo:nil playSound:YES];
}

- (NSInteger)getAllUnreadNum
{
    return _allUnreadCount;
}

#pragma mark private
- (NSInteger) loadUnreadMessageNum
{
    // 查出所有的未读条数
    NSArray *conversations = [[EaseMob sharedInstance].chatManager conversations];
    NSInteger unreadCount = 0;
    for (EMConversation *conversation in conversations) {
        unreadCount += conversation.unreadMessagesCount;
    }
    
    // 设置当前的未读数量 返回的是正确的未读数
    _allUnreadCount = unreadCount;
    
    return unreadCount;
}

#pragma 注册环信相关
- (void) easeMobapplication:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
    NSString *apnsCertName = nil;
#if DEBUG
    if (TARGET_IS_MINIU) {
        apnsCertName = @"dev";
    } else if (TARGET_IS_MINIU_BUYER) {
        apnsCertName = @"brdev0";//brdev older version
    }
#else
    if (TARGET_IS_MINIU) {
        apnsCertName = @"pro";
    } else if (TARGET_IS_MINIU_BUYER) {
        apnsCertName = @"brproduct";//brpro older version
    }
#endif
    [[EaseMob sharedInstance] registerSDKWithAppKey:@"dldqsz#miniuhx" apnsCertName:apnsCertName];
    
    [[[EaseMob sharedInstance] chatManager] setIsAutoFetchBuddyList:YES];
    
    [[EaseMob sharedInstance].chatManager setIsUseIp:YES];
    
    //以下一行代码的方法里实现了自动登录，异步登录，需要监听[didLoginWithInfo: error:]
    //demo中此监听方法在MainViewController中
    [[EaseMob sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    
//#warning 注册为SDK的ChatManager的delegate (及时监听到申请和通知)
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    
//#warning 如果使用MagicalRecord, 要加上这句初始化MagicalRecord
    
    if (USER_IS_LOGIN) {
        [logicShareInstance doLoginSuccessfulLogic];
    }
    
    // 开启消息送达通知
    [[EaseMob sharedInstance].chatManager enableDeliveryNotification];
}

- (void) loginToEasemobManageWithHXID:(NSString *)hxid hxPwd:(NSString *)hxpwd
{
    // 如果已经登录环信，并且已经登录App
    if ([[EaseMob sharedInstance].chatManager isLoggedIn] && USER_IS_LOGIN) {
        NSLog(@"****请不要重复登录环信用户~~~~~~~~~~~~~");
        return;
        
    // 如果没有登录环信，并且已经登录了App
    } else if(![[EaseMob sharedInstance].chatManager isLoggedIn] && USER_IS_LOGIN){
        
//#if TARGET_IS_MINIU_BUYER
//        WeakSelf
//        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"提示" andMessage:@"为了保证正式版米妞的通讯正常,测试版将启用测试环信账号,请确认自己的版本？"];
//        alertView.backgroundStyle = SIAlertViewBackgroundStyleSolid;
//        alertView.buttonsListStyle = SIAlertViewButtonsListStyleRows;
//        [alertView addButtonWithTitle:@"正式" type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView) {
//            [weakSelf_SC loginWithHXID:hxid hxPwd:hxpwd];
//        }];
//        
//        [alertView addButtonWithTitle:@"测试" type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView) {
//            [weakSelf_SC loginWithHXID:@"mnhxuser99" hxPwd:@"dRxUTjA9CNiZMnQI"];
//        }];
//        
//        [alertView addButtonWithTitle:@"取消" type:SIAlertViewButtonTypeDestructive handler:^(SIAlertView *alertView) {
//            
//        }];
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [alertView show];
//        });
//#else
        [self loginWithHXID:hxid hxPwd:hxpwd];
//#endif

    // 如果没有登录应用
    } else if (!USER_IS_LOGIN) {
        return;
    }
}

- (void) loginWithHXID:(NSString *)hxid hxPwd:(NSString *)hxpwd
{
    /**
     *  异步登录环信帐号
     */
    [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:hxid
                                                        password:hxpwd
                                                      completion:
     ^(NSDictionary *loginInfo, EMError *error) {
         //2.1.5
         NSLog(@"EaseMob-Version= %@", [[EaseMob sharedInstance] sdkVersion]);
         
         //登录正确且不报错
         if (loginInfo && !error) {
             NSLog(@"easeMob login -- loginInfo = %@", loginInfo);
             
             //设置是否自动登录
             [[EaseMob sharedInstance].chatManager setIsAutoLoginEnabled:YES];
             
             EMError *error = [[EaseMob sharedInstance].chatManager importDataToNewDatabase];
             if (!error) {
                 error = [[EaseMob sharedInstance].chatManager loadDataFromDatabase];
             };
             
             //设置推送设置
             [[EaseMob sharedInstance].chatManager setApnsNickname:[CURRENT_USER_INSTANCE getCurrentUserName]];
             
             [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@YES];
             
             [self loadUnreadMessageNum];
         }else {
             
             NSLog(@"easeMob Login error : %lud, description: %@", error.errorCode, error.description);
             
             //             switch (error.errorCode) {
             //                 case EMErrorServerNotReachable:
             //                     TTAlertNoTitle(@"连接服务器失败!");
             //                     break;
             //                 case EMErrorServerAuthenticationFailure:
             //                     TTAlertNoTitle(@"用户名或密码错误");
             //                     break;
             //                 case EMErrorServerTimeout:
             //                     TTAlertNoTitle(@"连接服务器超时!");
             //                     break;
             //                 default:
             //                     TTAlertNoTitle(@"登录失败");
             //                     break;
             //             }
         }
     } onQueue:nil];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [[EaseMob sharedInstance] applicationWillResignActive:application];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[EaseMob sharedInstance] applicationDidEnterBackground:application];
}

#pragma mark 程序进入前台
- (void)applicationWillEnterForeground:(UIApplication *)application
{
[[EaseMob sharedInstance] applicationWillEnterForeground:application];
}

#pragma mark 程序重新激活
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [self autoLogin];
    [[EaseMob sharedInstance] applicationDidBecomeActive:application];
}

#pragma mark 程序意外暂行
- (void)applicationWillTerminate:(UIApplication *)application
{
    [[EaseMob sharedInstance] applicationWillTerminate:application];
}

#pragma mark 注册远程通知
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [[EaseMob sharedInstance] application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *) error;
{
    [[EaseMob sharedInstance] application:application didFailToRegisterForRemoteNotificationsWithError:error];
}

#pragma mark 获取APN通知
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [[EaseMob sharedInstance] application:application didReceiveRemoteNotification:userInfo];    
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    [[EaseMob sharedInstance] application:application didReceiveLocalNotification:notification];
}

/**
 *  网络改变的时候重连
 *
 *  @param notification
 */
- (void) changeWork:(NSNotification *)notification
{
    // 如果用户登录才进行消息获取操作
    NSDictionary *userInfo = [notification userInfo];
    
    NSInteger networkstatus = [[userInfo objectForKey:@"networktype"] integerValue];
    
    if ((networkstatus == AFNetworkReachabilityStatusReachableViaWiFi || networkstatus == AFNetworkReachabilityStatusReachableViaWWAN) && ![[EaseMob sharedInstance].chatManager isLoggedIn] && USER_IS_LOGIN) {
        [self doLoginSuccessfulLogic];
    }
}

/**
 *  @brief  自动登录
 */
- (void) autoLogin
{
    [self doLoginSuccessfulLogic];
    // 如果当前换新没有登录，并且用户已经登录服务器（自己的）
}

- (void)didLoginWithInfo:(NSDictionary *)loginInfo error:(EMError *)error
{
    NSLog(@"didLoginWithInfo: %@,  error: %@", loginInfo, error.description);
}

/**
 *  @brief  其他地方上线后的操作
 *
 *  @return didLoginFromOtherDevice
 */

- (void)didLoginFromOtherDevice
{
    [WCAlertView showAlertWithTitle:@"提示" message:@"账号已在其他设备登陆,您将无法收到消息,其他功能正常!" customizationBlock:^(WCAlertView *alertView) {
        
    } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
        
        if (buttonIndex == 1) {
            [logicShareInstance doLogoutLogic];
            [MAIN_DELEGATE changeRootViewController];
        }

    } cancelButtonTitle:@"取消" otherButtonTitles:@"重新登录", nil];
}

#pragma mark -
#pragma mark - IChatManagerDelegate 好友变化
- (void)didReceiveBuddyRequest:(NSString *)username
                       message:(NSString *)message{}
#pragma mark - IChatManagerDelegate 群组变化
- (void)didReceiveGroupInvitationFrom:(NSString *)groupId
                              inviter:(NSString *)username
                              message:(NSString *)message{}
- (void)didReceiveApplyToJoinGroup:(NSString *)groupId
                         groupname:(NSString *)groupname
                     applyUsername:(NSString *)username
                            reason:(NSString *)reason
                             error:(EMError *)error{}
- (void)didReceiveRejectApplyToJoinGroupFrom:(NSString *)fromId
                                   groupname:(NSString *)groupname
                                      reason:(NSString *)reason{}
- (void)group:(EMGroup *)group didLeave:(EMGroupLeaveReason)reason error:(EMError *)error{}
- (void)didBindDeviceWithError:(EMError *)error{}




// ---------------------------------------------

- (void)didReceiveCmdMessage:(EMMessage *)cmdMessage
{
    [self handleCmdMessageParam:cmdMessage];
}

- (void)didFinishedReceiveOfflineCmdMessages:(NSArray *)offlineCmdMessages
{
    // 取最后一条消息
    EMMessage *message = (EMMessage *)[offlineCmdMessages lastObject];
    [self handleCmdMessageParam:message];
}

#pragma mark 处理透传消息
- (void) handleCmdMessageParam:(EMMessage *)cmdMessage
{
    if (!cmdMessage) {
        return;
    }
    
    // 取出最后一条 messageBody
    EMCommandMessageBody *body = (EMCommandMessageBody *)[cmdMessage.messageBodies lastObject];
    
    // 如果消息是命令消息,并且 是 ‘updateService’ 更新客服操作
    if (body.messageBodyType == eMessageBodyType_Command && [body.action isEqualToString:@"updateService"]) {
        
        @try {
            // 取出客服的hxuid
            NSString *serviceHxUID = [cmdMessage.ext objectForKey:@"toServiceHxUID"];
            
            // 取出当前用户
            UserEntity *user = [CURRENT_USER_INSTANCE getCurrentUser];
            
            // 如果拿到的HXUID为空，后者和当前的客服一致，则跳过。
            if (![serviceHxUID length] || [serviceHxUID isEqualToString:user.serviceHxUId]) {
                return;
            }
            
            // 否则更新用户的信息
            user.serviceHxUId = serviceHxUID;
            [[logicShareInstance getUserManager] updateCurrentUser:user];
            
            // 拉取环信的用户信息
            [[logicShareInstance getUserManager] getUserEntityWithHXID:serviceHxUID result:nil];
            
            // 如果当前已经有会话了,那么需要把会话的未读消息标注为已读
            if (self.conversation) {
                [self.conversation markAllMessagesAsRead:YES];
            }
            
            // 更换会话的hxuid
            [self loadUserConversation];
            
        }
        @catch (NSException *exception) {
            NSLog(@"更新客服失败!!!!>>....");
        }
        @finally {
            
        }
    }
}

- (NSURLSessionDataTask *)getServiceListSuccess:(void (^)(id))success
                                        failure:(void (^)(NSString *))failure
{
    return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:API_SERVICE_HX_LIST success:^(NSURLSessionDataTask *task, id responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSString *error) {
        failure(error);
    }];
}

- (NSURLSessionDataTask *)switchServiceHx:(long long)changeUId
                             serviceHxUId:(NSString *)serviceHxUId
                                  success:(void (^)(id))success
                                  failure:(void (^)(NSString *))failure
{
    NSDictionary *dicData = @{
                              @"changeUId": [NSString stringWithFormat:@"%lld", changeUId],
                              @"serviceHxUId": [NSString stringWithFormat:@"%@", serviceHxUId]};
    
    NSMutableDictionary *dic = [self mergeDictionWithDicone:API_SWITCH_HX_SERVICE AndDicTwo:dicData];
    
    return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:dic success:^(NSURLSessionDataTask *task, id responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSString *error) {
        failure(error);
    }];
}


/**
 *  @brief  加载用户的会话列表和相关数据
 */
- (void)loadUserConversation
{
    // 检查用户是否已经登录
    if (!USER_IS_LOGIN) {
        return;
    }
    
    // 更新对方的信息
    [[logicShareInstance getUserManager] getUserEntityWithHXID:[CURRENT_USER_INSTANCE getCurrentUserServiceHxUId] result:nil];
    
    // 发送通知,主要用于更新viewController
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateServiceHxUid" object:nil];
    
}
- (EMConversation *)conversation
{
    return [[EaseMob sharedInstance].chatManager conversationForChatter:[CURRENT_USER_INSTANCE getCurrentUserServiceHxUId] isGroup:NO];
}

#pragma mark
#pragma mark logic层统一管理协议方法
- (void)load{
    [self loadUserConversation];
}
- (void)loadUserData{}
- (void)save{}
- (void)reset{}
- (void)enterBackgroundMode{}
- (void)enterForeground{}
- (void)doLoginSuccessfulLogic
{
    NSString *hxid = [CURRENT_USER_INSTANCE getCurrentUserHXID];
    NSString *hxpwd = [CURRENT_USER_INSTANCE getCurrentUserHXpwd];
    
//#if TARGET_IS_MINIU_BUYER
//    if (_enableAutoLogin) {
        [self loginToEasemobManageWithHXID:hxid hxPwd:hxpwd];
//    }
    
//#else
//    [self loginToEasemobManageWithHXID:hxid hxPwd:hxpwd];
//#endif
    
    
    [self loadUserConversation];
    
}
- (void)doLogoutLogic
{
    //解除device token ->no to yes
    [[EaseMob sharedInstance].chatManager asyncLogoffWithUnbindDeviceToken:YES];
}
- (void)disconnectNet{
    NSLog(@"环信断开连接! ->disconnectNet");
}

/**
 *  避免输出字典里中文\u的处理方法
 *
 *  @param dic 变量
 */
- (void)logDic:(NSDictionary *)dic
{
    //错误处理
    if(!dic)return;
    
    NSString *tempStr1 = [[dic description] stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
    if(!tempStr1)return;
    
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    if(!tempStr2)return;
    
    NSString *tempStr3 = [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString *str = [NSPropertyListSerialization propertyListFromData:tempData mutabilityOption:NSPropertyListImmutable format:NULL errorDescription:NULL];
    NSLog(@"dic:%@",str);
}
@end
