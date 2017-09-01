
//
//  JpushManage.m
//  DLDQ_IOS
//
//  Created by simman on 14-7-6.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import "JpushManage.h"
#import "UserEntity.h"
@implementation JpushManage

+ (instancetype)shareInstance
{
    static JpushManage * instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (id)init
{
    if (self = [super init]) {
        NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
        
        [defaultCenter addObserver:self selector:@selector(networkDidSetup:) name:kJPFNetworkDidSetupNotification object:nil];
        [defaultCenter addObserver:self selector:@selector(networkDidClose:) name:kJPFNetworkDidCloseNotification object:nil];
        [defaultCenter addObserver:self selector:@selector(networkDidRegister:) name:kJPFNetworkDidRegisterNotification object:nil];
        [defaultCenter addObserver:self selector:@selector(networkDidLogin:) name:kJPFNetworkDidLoginNotification object:nil];
        [defaultCenter addObserver:self selector:@selector(networkDidReceiveMessage:) name:kJPFNetworkDidReceiveMessageNotification object:nil];
    }
    return self;
}

- (void)setUpJPushWithOptions:(NSDictionary *)options
{
    
#if DEBUG
    [APService setDebugMode];
#else
    [APService setLogOFF];
#endif
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        //可以添加自定义categories
        [APService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                       UIUserNotificationTypeSound |
                                                       UIUserNotificationTypeAlert)
                                           categories:nil];
    } else {
        //categories 必须为nil
        [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                       UIRemoteNotificationTypeSound |
                                                       UIRemoteNotificationTypeAlert)
                                           categories:nil];
    }
#else
    //categories 必须为nil
    [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                   UIRemoteNotificationTypeSound |
                                                   UIRemoteNotificationTypeAlert)
                                       categories:nil];
#endif
    
    UserEntity *userE = [[logicShareInstance getUserManager]getCurrentUser];
    
    //设置群组
    [APService setTags:[NSSet setWithObjects:@"tag4",@"tag5",@"tag6",nil] alias:userE.nickName callbackSelector:@selector(tagsAliasCallback:tags:alias:) target:self];
    
    // apn 内容获取：如果应用没有运行
//    NSDictionary *remoteNotification = [options objectForKey: UIApplicationLaunchOptionsRemoteNotificationKey];
    NSLog(@"registrionID: %@", [APService registrationID]);
}

- (void)registerDeviceToken:(NSData *)token
{
    [APService registerDeviceToken:token];
}

#pragma mark -
- (void)networkDidSetup:(NSNotification *)notification
{
//    NSLog(@"已连接");
}

- (void)networkDidClose:(NSNotification *)notification
{
//    NSLog(@"未连接。。。");
}

- (void)networkDidRegister:(NSNotification *)notification
{
    
//    NSLog(@"已注册");
}

- (void)networkDidLogin:(NSNotification *)notification
{
//    NSLog(@"已登录");
    
    NSString *sendId = [NSString stringWithFormat:@"%@", [APService registrationID]];
    
    if (sendId && [sendId length]) {
        // 写入本地
        [NSUSER_DEFAULT setObj:sendId forKey:JPUSH_SENDID];
        
        // 如果已经登录了。
        if (USER_IS_LOGIN) {
            // 已经注册成功了,那么则向服务器更新当前用户的SendId
            [[logicShareInstance getUserManager] updateSendId:sendId Success:^(id responseObject) {
                DebugLog(@"");
            } failure:^(NSString *error) {
                DebugLog(@"");
            }];
        }
    }
}


#pragma mark 标签与别名
- (void)tagsAliasCallback:(int)iResCode tags:(NSSet*)tags alias:(NSString*)alias {
    //    NSLog(@"rescode: %d, \ntags: %@, \nalias: %@\n", iResCode, tags , alias);
}

#pragma mark 当应用在前台收到的消息
- (void)handleRemoteNotification:(NSDictionary *)userInfo
{
    //发送本地通知
    [self sendLocationNotification:userInfo];
    [APService handleRemoteNotification:userInfo];
}

#pragma mark 本地推送在前台
- (void) showLocalNotificationAtFront:(UILocalNotification *)notification
                        identifierKey:(NSString *)notificationKey
{
    NSLog(@"jpush _ showLocalNotificationAtFront  %@",notification);
//    [APService showLocalNotificationAtFront:notification identifierKey:notificationKey];
//    [self sendLocationNotification:notification];
}

#pragma mark 收到应用内消息
- (void)networkDidReceiveMessage:(NSNotification *)notification {
    NSDictionary * userInfo = [notification userInfo];
    [self sendLocationNotification:userInfo];
}

#pragma mark - 本地的监听者
- (void) sendLocationNotification:(NSDictionary *)notificationDic
{    
    // 前台
    if ([[notificationDic objectForKey:@"UIApplicationState"] integerValue] == UIApplicationStateActive) {
        [[NSNotificationCenter defaultCenter] postNotificationName:ReciveNotificationWithActive object:self userInfo:notificationDic];
    // 点击应用
    } else if ([[notificationDic objectForKey:@"UIApplicationState"] integerValue] == UIApplicationStateInactive) {
        [[NSNotificationCenter defaultCenter] postNotificationName:ReciveNotificationWithInactive object:self userInfo:notificationDic];
    // 后台
    } else if ([[notificationDic objectForKey:@"UIApplicationState"] integerValue] == UIApplicationStateBackground) {
        [[NSNotificationCenter defaultCenter] postNotificationName:ReciveNotificationWithBackground object:self userInfo:notificationDic];
    }
}

- (BOOL) setBadge:(NSInteger)value
{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:value];
    NSLog(@"setBadge(%d)",value);

    return [APService setBadge:value];
}

- (void) decreaseBadge:(NSInteger)value
{
    NSInteger badge = [[UIApplication sharedApplication] applicationIconBadgeNumber];
    NSInteger newBadge = badge - value;
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:newBadge];
    NSLog(@"decreaseBadge(%d)",value);
    [APService setBadge:newBadge];
}

- (void) resetBadge
{
//[[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [APService resetBadge];
}

- (void) reloadBadge
{
    NSInteger unCount = 0;
    // 消息
    unCount += [[logicShareInstance getEasemobManage] getAllUnreadNum];
    
#if TARGET_IS_MINIU_BUYER
    // 通知 关闭了通知显示
    //unCount += [[logicShareInstance getLogManager] getAllUnreadNum];
//#elif TARGET_IS_MINIU_BUYER
    

#endif
    
    [self setBadge:unCount];
}

#pragma mark
#pragma mark logic层统一管理协议方法
- (void)load
{
    [self reloadBadge];
}

- (void)loadUserData{}
- (void)save{}
- (void)reset{}
- (void)enterBackgroundMode{}
- (void)enterForeground{
    [self reloadBadge];
}
- (void)doLoginSuccessfulLogic{}
- (void)doLogoutLogic{}
- (void)disconnectNet{}
@end