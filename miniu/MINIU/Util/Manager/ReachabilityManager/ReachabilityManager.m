//
//  ReachabilityManager.m
//  DLDQ_IOS
//
//  Created by simman on 14-8-28.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import "ReachabilityManager.h"

@implementation ReachabilityManager


+ (instancetype)shareInstance
{
    static ReachabilityManager * instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void) startMonitoring
{
    // 如果要检测网络状态的变化,必须用检测管理器的单例的startMonitoring
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    // 检测网络连接的单例,网络变化时的回调方法
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        [[NSNotificationCenter defaultCenter] postNotificationName:ChangeNetWork object:self userInfo:@{@"networktype": [NSString stringWithFormat:@"%d", status]}];
    }];
}

#pragma mark
#pragma mark logic层统一管理协议方法
- (void)load{}
- (void)loadUserData{}
- (void)save{}
- (void)reset{}
- (void)enterBackgroundMode{}
- (void)enterForeground{}
- (void)doLoginSuccessfulLogic{}
- (void)doLogoutLogic{}
- (void)disconnectNet{}

@end
