//
//  NotificationCenterManager.m
//  miniu
//
//  Created by SimMan on 4/30/15.
//  Copyright (c) 2015 SimMan. All rights reserved.
//

#import "NotificationCenterManager.h"
#import "LNNotificationsUI_iOS7.1.h"

#import "ChatViewController.h"

#import "AppDelegate.h"

#define MINIU_CHAT_MESSAGE_IDENTIFIER @"miniu_chat_message_notification"

static const CGFloat kDefaultPlaySoundInterval = 3.0;

@interface NotificationCenterManager()

@property (strong, nonatomic)NSDate *lastPlaySoundDate;


@end

@implementation NotificationCenterManager

+ (instancetype)shareInstance
{
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
#if TARGET_IS_MINIU
        [[LNNotificationCenter defaultCenter] registerApplicationWithIdentifier:MINIU_CHAT_MESSAGE_IDENTIFIER name:@"" icon:[UIImage imageNamed:@"关于米妞-logo"] defaultSettings:LNNotificationDefaultAppSettings];
#elif TARGET_IS_MINIU_BUYER
        [[LNNotificationCenter defaultCenter] registerApplicationWithIdentifier:MINIU_CHAT_MESSAGE_IDENTIFIER name:@"" icon:[UIImage imageNamed:@"米妞买手版Icon"] defaultSettings:LNNotificationDefaultAppSettings];
#endif
    }
    return self;
}


- (void) showLocalNotificationWithAlertBody:(NSString *)alertBody andUserInfo:(NSDictionary *)userInfo playSound:(BOOL)play
{
    // 发送本地推送
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    // 触发通知的时间
    notification.fireDate = [NSDate date];
    // 显示的内容
    notification.alertBody = [NSString stringWithFormat:@"%@", alertBody];
    
    // 设置时区
    notification.timeZone = [NSTimeZone defaultTimeZone];
    
    // 设置声音
    if (play) {
        notification.soundName = UILocalNotificationDefaultSoundName;
    }

    // 设置 UserInfo
    if (userInfo) {
        notification.userInfo = userInfo;
    }
    
    // 设置角标
    UIApplication *application = [UIApplication sharedApplication];
    
    //有点多余 会导致消息数目自动多1个
    application.applicationIconBadgeNumber += 0;
    
    //发送通知
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

- (void) showActiveNotificationWithTitle:(NSString *)title andAlertBody:(NSString *)alertBody playSound:(BOOL)play
{
    return;
    
    if (!title) {
#if TARGET_IS_MINIU
        title = @"米妞";
#else
        title = @"米妞买手版";
#endif
    }
    
    if (!alertBody) {
        return;
    }
    
    // 创建通知
    LNNotification* notification = [LNNotification notificationWithTitle:title message:alertBody];
    
    // 设置声音
    if (play) {
        notification.soundName = @"notification.aiff";
    }
    
    // 设置时间
    notification.date = [NSDate date];
    
    /*
    notification.defaultAction = [LNNotificationAction actionWithTitle:@"View" handler:^(LNNotificationAction *action) {
        
    }];
     */
    
    // 发送本地通知
    [[LNNotificationCenter defaultCenter] presentNotification:notification forApplicationIdentifier:MINIU_CHAT_MESSAGE_IDENTIFIER];
}

/**
 *  @brief  播放声音与振动
 */
- (void)playSoundAndVibration
{
    //如果距离上次响铃和震动时间太短, 则跳过响铃
    NSTimeInterval timeInterval = [[NSDate date]
                                   timeIntervalSinceDate:self.lastPlaySoundDate];
    if (timeInterval < kDefaultPlaySoundInterval) {
        return;
    }
    //保存最后一次响铃时间
    self.lastPlaySoundDate = [NSDate date];
    
    // 收到消息时，播放音频
    [[EaseMob sharedInstance].deviceManager asyncPlayNewMessageSound];
    // 收到消息时，震动
    [[EaseMob sharedInstance].deviceManager asyncPlayVibration];
}


#pragma mark logic层统一管理协议方法
- (void)load{}
- (void)loadUserData{}
- (void)uiDidAppear{}
- (void)save{}
- (void)reset{}
- (void)enterBackgroundMode{}
- (void)enterForeground{}
- (void)doLoginSuccessfulLogic{}
- (void)doLogoutLogic{}
- (void)disconnectNet{}

@end
