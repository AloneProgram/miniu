//
//  BaiduTj.m
//  DLDQ_IOS
//
//  Created by simman on 14-7-6.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import "BaiduTj.h"

@implementation BaiduTj


+ (instancetype)shareInstance
{
    static BaiduTj * instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
    
    //100@dldq.org
    //haitao5156
}

- (void)baiduTjSettingLaunching
{
    BaiduMobStat* statTracker         = [BaiduMobStat defaultStat];
    statTracker.enableExceptionLog    = NO;// 是否允许截获并发送崩溃信息，请设置YES或者NO
    
    statTracker.channelId             = @"miniu_client";
#if TARGET_IS_MINIU_BUYER
    statTracker.channelId             = @"miniu_buyer";//设置您的app的发布渠道
#endif
    
    
    statTracker.logStrategy           = BaiduMobStatLogStrategyAppLaunch;//根据开发者设定的时间间隔接口发送 也可以使用启动时发送策略

    
#if DEBUG
    statTracker.channelId             = @"test_debug";//2015.10.08
//    statTracker.enableDebugOn         = YES;//打开调试模式，发布时请去除此行代码或者设置为False即可。
#else
    statTracker.enableDebugOn         = NO;//打开调试模式，发布时请去除此行代码或者设置为False即可。
#endif
    
    //    statTracker.logSendInterval = 1; //为1时表示发送日志的时间间隔为1小时,只有 statTracker.logStrategy = BaiduMobStatLogStrategyAppLaunch这时才生效。
    statTracker.logSendWifiOnly       = NO;//是否仅在WIfi情况下发送日志数据
    statTracker.sessionResumeInterval = 30;//设置应用进入后台再回到前台为同一次session的间隔时间[0~600s],超过600s则设为600s，默认为30s
    [statTracker startWithAppId:BaiduREPORT_ID];                     //设置您在mtj网站上添加的app的appkey
}



@end
