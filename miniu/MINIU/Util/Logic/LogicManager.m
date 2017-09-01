//
//  LogicManager.m
//  DLDQ_IOS
//
//  Created by simman on 14-7-6.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import "LogicManager.h"
#import "AFNetworkActivityLogger.h"
#import <SMS_SDK/SMS_SDK.h>
//#import <PgySDK/PgyManager.h>
#import "STDb.h"
#import "UserEntity.h"

@interface LogicManager ()

@property (nonatomic, strong) BaiduTj             *baiduTjManage;
@property (nonatomic, strong) JpushManage         *jpushManage;
@property (nonatomic, strong) WeChatManage        *weChatManage;
//@property (nonatomic, strong) IVersionManage      *iVersionManage;
@property (nonatomic, strong) ReachabilityManager *reachabilityManager;
@property (nonatomic, strong) EasemobManage       *easemobManage;
@property (nonatomic, strong) UserManager         *userManager;
@property (nonatomic, strong) AddressManager      *addressManager;
@property (nonatomic, strong) TagManager          *tagManager;
@property (nonatomic, strong) AssetManager        *assetManager;
@property (nonatomic, strong) GoodsManager        *goodsManager;
@property (nonatomic, strong) LocationManager     *locationManager;
@property (nonatomic, strong) CommentManager      *commentManager;
@property (nonatomic, strong) OrderManager        *orderManager;
@property (nonatomic, strong) LogManager          *logManager;
//@property (nonatomic, strong) UpdateManager       *updateManager;
@property (nonatomic, strong) AlipayManager       *alipayManager;
@property (nonatomic, strong) ADManager           *adManager;
@property (nonatomic, strong) MessageManager      *messageManager;
@property (nonatomic, strong) URLManager          *urlManager;
@property (nonatomic, strong) UploadManager       *uploadManager;
@property (nonatomic, strong) PingPlusManager     *pingPlusManager;
@property (nonatomic, strong) NotificationCenterManager *notificationCenter;

@end

@implementation LogicManager

+ (instancetype)shareInstance;
{
    static LogicManager* m_singleton = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        m_singleton = [[LogicManager alloc] init];
    });
    return m_singleton;
}

- (id)init
{
    if (self = [super init]) {
        self.baiduTjManage       = [BaiduTj shareInstance];
        self.jpushManage         = [JpushManage shareInstance];
        self.weChatManage        = [WeChatManage shareInstance];
//        self.iVersionManage      = [IVersionManage shareInstance];
        self.reachabilityManager = [ReachabilityManager shareInstance];
        self.easemobManage       = [EasemobManage shareInstance];
        self.userManager         = [UserManager shareInstance];
        self.addressManager      = [AddressManager shareInstance];
        self.tagManager          = [TagManager shareInstance];
        self.assetManager        = [AssetManager shareInstance];
        self.goodsManager        = [GoodsManager shareInstance];
        self.locationManager     = [LocationManager shareInstance];
        self.commentManager      = [CommentManager shareInstance];
        self.orderManager        = [OrderManager shareInstance];
        self.logManager          = [LogManager shareInstance];
//        self.updateManager       = [UpdateManager shareInstance];
        self.alipayManager       = [AlipayManager shareInstance];
        self.adManager           = [ADManager shareInstance];
        self.messageManager      = [MessageManager shareInstance];
        self.urlManager          = [URLManager shareInstance];
        self.uploadManager       = [UploadManager shareInstance];
        self.pingPlusManager     = [PingPlusManager shareInstance];
        self.notificationCenter  = [NotificationCenterManager shareInstance];
    }
    return self;
}

- (BaiduTj *)getBaiduTjManage
{
    return self.baiduTjManage;
}

- (JpushManage *)getJpushManage
{
    return self.jpushManage;
}

- (WeChatManage *)getWeChatManage
{
    return self.weChatManage;
}

//- (IVersionManage *)getIVersionManage
//{
//    return self.iVersionManage;
//}

- (ReachabilityManager *)getReachabilityManager
{
    return self.reachabilityManager;
}

- (EasemobManage *)getEasemobManage
{
    return self.easemobManage;
}

- (UserManager *)getUserManager
{
    return self.userManager;
}

- (AddressManager *)getAddressManager
{
    return self.addressManager;
}

- (TagManager *)getTagManager
{
    return self.tagManager;
}

- (AssetManager *)getAssetManager
{
    return self.assetManager;
}

- (GoodsManager *)getGoodsManager
{
    return self.goodsManager;
}

- (LocationManager *)getLocationManager
{
    return self.locationManager;
}

- (CommentManager *) getCommentManager
{
    return self.commentManager;
}

- (OrderManager *)getOrderManager
{
    return self.orderManager;
}

- (LogManager *)getLogManager
{
    return self.logManager;
}

//- (UpdateManager *)getUpdateManager
//{
//    return self.updateManager;
//}

- (AlipayManager *)getAlipayManager
{
    return self.alipayManager;
}

- (ADManager *)getADManager
{
    return self.adManager;
}

- (MessageManager *)getMessageManager
{
    return self.messageManager;
}

- (URLManager *)getURLManager
{
    return self.urlManager;
}

- (UploadManager *)getUploadManager
{
    return self.uploadManager;
}

- (NotificationCenterManager *)getNotificationCenterManager
{
    return self.notificationCenter;
}

- (PingPlusManager *)getPingPlusManager
{
    return self.pingPlusManager;
}

#pragma mark
#pragma mark logic层统一管理协议方法
- (void)load
{
        
    // 初始化数据库
//    [RLMRealm defaultRealm];
    
///*  此处升级 UserEntity 的数据库类 */
    @try {
//        [[STDb defaultDb] upgradeTableIfNeed:[UserEntity class]];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    
    // 拉取日志
//    [self.logManager load];
    
    // xxx 2015.09.16cancel cancel update manager and iversion manager
//    [[logicShareInstance getIVersionManage] startApplicationIversion];
    
    // 注册微信服务
    [self.weChatManage registerApp:WXAppid withDescription:nil];
    
    // 百度统计
    [self.baiduTjManage baiduTjSettingLaunching];
    
#ifdef DEBUG
    [[AFNetworkActivityLogger sharedLogger] startLogging];
    [[AFNetworkActivityLogger sharedLogger] setLevel:AFLoggerLevelDebug]; //日志级别
#endif
  
#if TARGET_IS_MINIU_BUYER
    // 蒲公英
//    [[PgyManager sharedPgyManager] startManagerWithAppId:@"7e1b64d362318ab2e85b2059b79894cf"];
#endif
    
#ifdef DEBUG
//    [[PgyManager sharedPgyManager] checkUpdate];
//    [[PgyManager sharedPgyManager] setEnableFeedback:YES];
#endif
    
//    [[PgyManager sharedPgyManager] setEnableFeedback:NO];
    
    // 设置极光推送
    [self.jpushManage setUpJPushWithOptions:nil];
    
    //网络状态检测
    [self.getReachabilityManager startMonitoring];
    
    // 环信相关
    [self.easemobManage easeMobapplication:nil didFinishLaunchingWithOptions:nil];
    
    [self.easemobManage load];
    
    // 短信
    [SMS_SDK registerApp:@"713e328a1f7e"
              withSecret:@"7df9d0a4e891f33931ded18a5e039f7d"];
    
    [self.uploadManager load];
    [self.notificationCenter load];
    [self.adManager load];
    [self.userManager load];
    [self.jpushManage load];
}
- (void)loadUserData
{
    [self.userManager loadUserData];
    [self.messageManager loadUserData];
}
- (void)uiDidAppear
{
    [self.logManager uiDidAppear];
}
- (void)save{}
- (void)reset{}
- (void)enterBackgroundMode{}
- (void)enterForeground
{
//    [self.updateManager enterForeground];
    [self.jpushManage enterForeground];
}
- (void)doLoginSuccessfulLogic
{
    [self loadUserData];
    [self.adManager doLoginSuccessfulLogic];
    [self.logManager doLoginSuccessfulLogic];
    [self.easemobManage doLoginSuccessfulLogic];
}
- (void)doLogoutLogic
{
    [self.addressManager doLogoutLogic];
    [self.userManager doLogoutLogic];
//    [self.updateManager doLogoutLogic];
    [self.orderManager doLogoutLogic];
    [self.easemobManage doLogoutLogic];
    
    [NET_WORK_HANDLE cancelAllHTTPOperations];
    
    [self reset];
}
- (void)disconnectNet{}

@end
