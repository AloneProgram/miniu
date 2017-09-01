//
//  AppDelegate.m
//  miniu
//
//  Created by SimMan on 4/13/15.
//  Copyright (c) 2015 SimMan. All rights reserved.
//

#import "AppDelegate.h"

//#import "HomeViewController.h"
#import "ProfileViewController.h"
#import "REFrostedNavigationController.h"
#import "UserLoginIndexViewController.h"
#import "EaseStartView.h"
#import "ChatViewController.h"

#import "IndexTagViewController.h"


#if TARGET_IS_MINIU_BUYER
#import "ChatListViewController.h"
#import "NotificationIndexViewController.h"
#import "OrderTableViewController.h"
#import "ContactViewController.h"
#endif

#import "BaseNavigationController.h"

//#import "CreateOrderViewController.h"
//
//#import "LogisticsAddViewController.h"
//
//#import "ChooseCompanyViewController.h"
#import "IQKeyboardManager.h"
#import "RNCachingURLProtocol.h"
@interface AppDelegate ()

@end

@implementation AppDelegate

#pragma mark PUSH
- (void)registerPush
{
    //注册推送
    float sysVer = [[[UIDevice currentDevice] systemVersion] floatValue];
    if(sysVer < 8){
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
    }else{
//#if __IPHONE_OS_VERSION_MAX_ALLOWED >= _IPHONE80_
        
//        李伟的设置
//        UIMutableUserNotificationCategory *categorys = [[UIMutableUserNotificationCategory alloc] init];
//        UIUserNotificationSettings *userSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert
//                                                                                     categories:[NSSet setWithObject:categorys]];
//        [[UIApplication sharedApplication] registerUserNotificationSettings:userSettings];
//        [[UIApplication sharedApplication] registerForRemoteNotifications];
        
        //环信的推送注册方法
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerForRemoteNotifications)]) {
            [[UIApplication sharedApplication] registerForRemoteNotifications];
            UIUserNotificationType notificationTypes = UIUserNotificationTypeBadge |
            UIUserNotificationTypeSound |
            UIUserNotificationTypeAlert;
            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
            [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
            
            //可以取消
        }else{
            UIRemoteNotificationType notificationTypes = UIRemoteNotificationTypeBadge |
            UIRemoteNotificationTypeSound |
            UIRemoteNotificationTypeAlert;
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:notificationTypes];
        }
//#endif
    }
}


+ (void) initialize
{
    [super initialize];
    NSLog(@"DocumentPath : %@\n Version : %@", PATH_OF_DOCUMENT,[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]);
    
//    NSString *jsonStr = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"countryList.json" ofType:nil] encoding:NSUTF8StringEncoding error:nil];
//    
//    NSDictionary *dic = [jsonStr objectDictionary];
//    
//    NSLog(@"%@", [dic objectForKey:@"Location"]);
//    
//    
//    return;
    
    // 初始化 load 含各种第三方
    [logicShareInstance load];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    //iq keyboard setup
    [IQKeyboardManager sharedManager].enable = YES;
    _isTalking = NO;
    
    // 初始化UI设置
    //[self performSelectorInBackground:@selector(initUI) withObject:nil];
    [self initUI];
    
    self.window.backgroundColor = [UIColor blackColor];
    [self.window makeKeyAndVisible];

    WeakSelf
    //如果是通过推送消息点进来的
    NSDictionary *remoteNotification = [launchOptions objectForKey: UIApplicationLaunchOptionsRemoteNotificationKey];
    if(remoteNotification){
        
        EaseStartView *startView = [EaseStartView startView];
        
        [startView startAnimationWithCompletionBlock:^(EaseStartView *easeStartView) {
            [weakSelf_SC registerPush];
            
            
        }];
    }else{
        //加载启动图片
        EaseStartView *startView = [EaseStartView startView];
//        WeakSelf
        [startView startAnimationWithCompletionBlock:^(EaseStartView *easeStartView) {
            [weakSelf_SC registerPush]; // 注册推送相关
        }];
    }
    
    [NSURLProtocol registerClass:[RNCachingURLProtocol class]];
    

    return YES;
}

#pragma mark 初始化UI控件
- (void) initUI
{
//    HomeViewController *homeVC = [[HomeViewController alloc] init];
    
    //索引界面的访问地址 http://server.dldq.org:7070/label/show.action?appKey=ios
    NSString *tagIndexViewURL = [NSString stringWithFormat:@"%@/label/show.action?appKey=ios", [[URLManager shareInstance] getNoServerBaseURL]];
    
    //NSString *tagIndexViewURL = @"http://hnhcc39.oicp.net/label/show.action?appKey=ios";
    
    IndexTagViewController *indexViewController = [[IndexTagViewController alloc] initWithURLString:tagIndexViewURL];
    indexViewController.urlStr = tagIndexViewURL;
    indexViewController.showActionButton = NO;
    //左边的东西
    ProfileViewController *profileVC = [[ProfileViewController alloc] init];
    
    
//    LZJWebViewController *lzjw = [[LZJWebViewController alloc]init];
//    lzjw.urlString = tagIndexViewURL;
//    BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:lzjw];
    BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:indexViewController];


#if TARGET_IS_MINIU_BUYER
    
    ChatListViewController *chatListVC = [[ChatListViewController alloc] init];
    
//    CreateOrderViewController *chatListVC = [[CreateOrderViewController alloc] init];
    
    chatListVC.title = @"消息";
    
    //通知视图控制器 换 联系人视图控制器
    //NotificationIndexViewController *vc2 = [[NotificationIndexViewController alloc] init];
    ContactViewController *vc2 = [[ContactViewController alloc]init];
    
    OrderTableViewController *vc3 = [[OrderTableViewController alloc] init];
    
    BaseNavigationController *nav2 = [[BaseNavigationController alloc] initWithRootViewController:chatListVC];
    BaseNavigationController *nav3 = [[BaseNavigationController alloc] initWithRootViewController:vc2];
    BaseNavigationController *nav4 = [[BaseNavigationController alloc] initWithRootViewController:vc3];
    
    _tabBarController = [[RDVTabBarController alloc] init];
    nav.title = @"发布";
    nav2.title = @"消息";
    nav3.title = @"客户";//通知改客户
    nav4.title = @"订单";
    [_tabBarController setViewControllers:@[nav2, nav3, nav4, nav]];
    [self customizeTabBarForController:_tabBarController];
    _frostedViewController = [[REFrostedViewController alloc] initWithContentViewController:_tabBarController menuViewController:profileVC];
#else
    _frostedViewController = [[REFrostedViewController alloc] initWithContentViewController:nav menuViewController:profileVC];
#endif
    _frostedViewController.direction = REFrostedViewControllerDirectionLeft;
    _frostedViewController.liveBlurBackgroundStyle = REFrostedViewControllerLiveBackgroundStyleDark;
    _frostedViewController.liveBlur = NO;
    _frostedViewController.panGestureEnabled = NO;
//    _frostedViewController.delegate = self;
    
    [self changeRootViewController];
    
    //设置导航条样式
    [self customizeInterface];

    // 发送UI加载完毕的通知
    [logicShareInstance uiDidAppear];
}

- (void) changeRootViewController
{
    if (USER_IS_LOGIN) {
        if (![self.window.rootViewController isKindOfClass:[REFrostedViewController class]]) {
            self.window.rootViewController = _frostedViewController;
        }
    } else {
        [self changeToLoginView];
    }
}

- (void) changeToLoginView
{
    if (![self.window.rootViewController isKindOfClass:[UserLoginIndexViewController class]]) {
 
        if (USER_IS_LOGIN) {
            [logicShareInstance doLogoutLogic];
        }
        UserLoginIndexViewController *userLoginIndexVC = [[UserLoginIndexViewController alloc] init];
        self.window.rootViewController = userLoginIndexVC;
    }
}


/**
 *  切换根界面到聊天框视图
 */
- (void) changeToChatView
{
   /* BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:[ChatViewController shareInstance]];

    [self.window.rootViewController presentViewController:nav animated:YES completion:^{
        [ChatViewController shareInstance].navigationItem.leftBarButtonItem.action= @selector(postDismissSignal);
        NSLog(@"present");
    }];
    */
    
//    if([[self getCurrentVC]isKindOfClass:[ChatViewController class]]){
//        return;
//    }
    
    REFrostedViewController* rf = (REFrostedViewController*)(self.window.rootViewController);

    [(UINavigationController*)(rf.contentViewController) pushViewController:[ChatViewController shareInstance] animated:YES];
    
//    if ([self.window.rootViewController isKindOfClass:[ChatViewController class]]) {
//        [self changeRootViewController];
//    } else {
//
//
//        BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:[ChatViewController shareInstance]];
//        
//        self.window.rootViewController = nav;
//
//    }
}

//- (instancetype )getCurrentVC
//{
//    UIViewController *result = nil;
//    
//    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
//    if (window.windowLevel != UIWindowLevelNormal)
//    {
//        NSArray *windows = [[UIApplication sharedApplication] windows];
//        for(UIWindow * tmpWin in windows)
//        {
//            if (tmpWin.windowLevel == UIWindowLevelNormal)
//            {
//                window = tmpWin;
//                break;
//            }
//        }
//    }
//    
//    UIView *frontView = [[window subviews] objectAtIndex:0];
//    id nextResponder = [frontView nextResponder];
//    
//    if ([nextResponder isKindOfClass:[ChatViewController class]])
//        return nextResponder;
//    else
//        result = window.rootViewController;
//    
//    return result;
//}
//
//- (void)postDismissSignal
//{
//    [[NSNotificationCenter defaultCenter]postNotificationName:@"ChatViewContrllerDismiss" object:nil];
//}
//- (void)dismissToFront:(UIViewController*)vc
//{
//    [vc dismissViewControllerAnimated:YES completion:nil];
//}
#pragma mark 自定义演示等
- (void)customizeInterface
{

    //设置Nav的背景色和title色
    UINavigationBar *navigationBarAppearance = [UINavigationBar appearance];
    NSDictionary *textAttributes = nil;
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        [navigationBarAppearance setTintColor:[UIColor whiteColor]];//返回按钮的箭头颜色
        [[UITextField appearance] setTintColor:[UIColor colorWithHexString:@"0x3bbc79"]];//设置UITextField的光标颜色
        [[UITextView appearance] setTintColor:[UIColor colorWithHexString:@"0x3bbc79"]];//设置UITextView的光标颜色
        [[UISearchBar appearance] setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"0xe5e5e5"]] forBarPosition:0 barMetrics:UIBarMetricsDefault];
        
        textAttributes = @{
                           NSFontAttributeName: [UIFont boldSystemFontOfSize:kNavTitleFontSize],
                           NSForegroundColorAttributeName: [UIColor whiteColor],
                           };
    } else {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
        [[UISearchBar appearance] setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"0xe5e5e5"]]];
        
        textAttributes = @{
                           UITextAttributeFont: [UIFont boldSystemFontOfSize:kNavTitleFontSize],
                           UITextAttributeTextColor: [UIColor whiteColor],
                           UITextAttributeTextShadowColor: [UIColor clearColor],
                           UITextAttributeTextShadowOffset: [NSValue valueWithUIOffset:UIOffsetZero],
                           };
#endif
    }
    [navigationBarAppearance setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:0.243 green:0.192 blue:0.376 alpha:1]] forBarMetrics:UIBarMetricsDefault];
    [navigationBarAppearance setTitleTextAttributes:textAttributes];
    
    navigationBarAppearance.barStyle = UIBarStyleBlackTranslucent;
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    
    [[FUIButton appearance] setCornerRadius:3.0f];
    [[FUIButton appearance].titleLabel setFont:[UIFont boldFlatFontOfSize:14]];
    [[FUIButton appearance] setButtonColor:FlatButtonColor];
    [[FUIButton appearance] setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [[FUIButton appearance] setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
}

#pragma mark 设置Tabbar
- (void)customizeTabBarForController:(RDVTabBarController *)tabBarController {
    NSArray *tabBarItemImages = @[@"0", @"1", @"2", @"3"];
    UIImage *backgroundImage = [UIImage imageNamed:@"tabbar_background"];
    
    NSInteger index = 0;
    for (RDVTabBarItem *item in [[tabBarController tabBar] items]) {
        [item setBackgroundSelectedImage:backgroundImage withUnselectedImage:backgroundImage];
        item.unselectedTitleAttributes = @{
                                           NSFontAttributeName: [UIFont systemFontOfSize:12],
                                           NSForegroundColorAttributeName: [UIColor colorWithRed:0.600 green:0.600 blue:0.600 alpha:1],
                                           };
        item.selectedTitleAttributes = @{
                                         NSFontAttributeName: [UIFont systemFontOfSize:12],
                                         NSForegroundColorAttributeName: [UIColor colorWithRed:0.400 green:0.400 blue:0.400 alpha:1],
                                         };
        UIImage *selectedimage = nil;
        UIImage *unselectedimage = nil;
        selectedimage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_focus",
                                             [tabBarItemImages objectAtIndex:index]]];
        unselectedimage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_normal",
                                               [tabBarItemImages objectAtIndex:index]]];
        [item setFinishedSelectedImage:selectedimage withFinishedUnselectedImage:unselectedimage];
        index++;
    }
}


#pragma mark URL跳转逻辑
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    //重写
    [[logicShareInstance getWeChatManage] application:application handleOpenURL:url];
    [[logicShareInstance getAlipayManager] application:application handleOpenURL:url];
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    [[logicShareInstance getWeChatManage] application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
    [[logicShareInstance getAlipayManager] application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
    [[logicShareInstance getPingPlusManager] application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
    [[logicShareInstance getURLManager] resolvingUrlAndOpenAction:url];
    return YES;
}

#pragma mark 将要挂起 （电话）
- (void)applicationWillResignActive:(UIApplication *)application
{
    [[logicShareInstance getEasemobManage] applicationWillResignActive:application];
}

#pragma mark 程序进入后台
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"applicationDidEnterBackground" object:nil];
    [[logicShareInstance getEasemobManage] applicationDidEnterBackground:application];
    [logicShareInstance enterBackgroundMode];
}

#pragma mark 程序进入前台
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [application cancelAllLocalNotifications];
    [[logicShareInstance getEasemobManage] applicationWillEnterForeground:application];
    [logicShareInstance enterForeground];
}

#pragma mark 程序重新激活
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    //[[logicShareInstance getLogManager] setAllLogIsRead];//设置全部消息已读(以后要去掉的) //会卡死崩掉
    [[logicShareInstance getEasemobManage] applicationDidBecomeActive:application];
    [logicShareInstance enterForeground];
}

#pragma mark 程序意外暂行
- (void)applicationWillTerminate:(UIApplication *)application
{
    [[logicShareInstance getEasemobManage] applicationWillTerminate:application];
}
#pragma mark 注册远程通知
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    //注册后获取device token
    //是有值的
    NSLog(@"本机的设备令牌device token :%@",[[NSString alloc]initWithData:deviceToken encoding:NSASCIIStringEncoding]);
    
    [[logicShareInstance getEasemobManage] application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
//    [APService registerDeviceToken:deviceToken];

    [[logicShareInstance getJpushManage] registerDeviceToken:deviceToken];
}
#pragma mark 远程通知回调
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *) error
{
    NSLog(@"注册推送失败!! \n错误内容: %@\n",error);
    [[logicShareInstance getEasemobManage] application:application didFailToRegisterForRemoteNotificationsWithError:error];
}

#pragma mark 获取APN通知
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    
//    if (application.applicationState == UIApplicationStateActive) {
////        UILocalNotification *note = [APService setLocalNotification:[NSDate dateWithTimeIntervalSinceNow:10] alertBody:@"hi" badge:0 alertAction:@"OK" identifierKey:nil userInfo:userInfo soundName:nil];
////                                     
//        
//        NSDictionary *aps = [userInfo valueForKey:@"aps"];
//        NSString *content = [aps valueForKey:@"alert"]; //推送显示的内容
//        NSInteger badge = [[aps valueForKey:@"badge"] integerValue]; //badge数量
//        NSString *sound = [aps valueForKey:@"sound"]; //播放的声音
//        
//        // 取得自定义字段内容
//        NSString *customizeField1 = [userInfo valueForKey:@"customizeField1"]; //自定义参数，key是自己定义的
//        NSLog(@"content =[%@], badge=[%d], sound=[%@], customize field =[%@]",content,badge,sound,customizeField1);
//        
//        // Required
//        [APService handleRemoteNotification:userInfo];
////        [APService showLocalNotificationAtFront:note    identifierKey:nil];
////        UIAlertView*alt =[[UIAlertView alloc]initWithTitle:@"test" message:content delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
////        [alt show];
//        return;
//    }
    
    //[self logDic:userInfo];
    
    //极光推送 maybe without this code app could not load the ads
    [[logicShareInstance getJpushManage] handleRemoteNotification:userInfo];
    //环信推送
    [[logicShareInstance getEasemobManage] application:application didReceiveRemoteNotification:userInfo];
    
    if (TARGET_IS_MINIU) {
        [self changeToChatView];
    }
    
    
}

#pragma mark 收到本地通知
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    //全部消息都显示
//    if (notification.userInfo) {
//        [APService showLocalNotificationAtFront:notification identifierKey:nil];
//    }
    //可以获取探框
//    UIAlertView*alt =[[UIAlertView alloc]initWithTitle:@"test" message:@"获取了一个前台数据" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
//    [alt show];
//    return;
    
    [[logicShareInstance getEasemobManage] application:application didReceiveLocalNotification:notification];
    [[logicShareInstance getJpushManage] showLocalNotificationAtFront:notification identifierKey:nil];
    
    NSLog(@"_isTalking = %d",_isTalking);
    
    if (TARGET_IS_MINIU && !_isTalking) {
        [self changeToChatView];
    }
}

#pragma mark 获取APN通知  ios7
#ifdef __IPHONE_7_0
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    // 此处加上逻辑处理（是否前台或者后台）
    // UIApplicationStateInactive 点击推送
    // UIApplicationStateBackground  后台运行
    // UIApplicationStateActive 前台运行
    
    NSMutableDictionary *userInfoDic = [NSMutableDictionary dictionaryWithDictionary:userInfo];
    [userInfoDic setObject:[NSString stringWithFormat:@"%ld", (long)application.applicationState] forKey:@"UIApplicationState"];
    
    [[logicShareInstance getJpushManage] handleRemoteNotification:userInfoDic];
    completionHandler(UIBackgroundFetchResultNoData);
}


#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_8_0
- (void)application:(UIApplication *)application
didRegisterUserNotificationSettings:
(UIUserNotificationSettings *)notificationSettings {
    [application registerForRemoteNotifications];
}

// Called when your app has been activated by the user selecting an action from
// a local notification.
// A nil action identifier indicates the default action.
// You should call the completion handler as soon as you've finished handling
// the action.
- (void)application:(UIApplication *)application
handleActionWithIdentifier:(NSString *)identifier
forLocalNotification:(UILocalNotification *)notification
  completionHandler:(void (^)())completionHandler {
    
}

// Called when your app has been activated by the user selecting an action from
// a remote notification.
// A nil action identifier indicates the default action.
// You should call the completion handler as soon as you've finished handling
// the action.
- (void)application:(UIApplication *)application
handleActionWithIdentifier:(NSString *)identifier
forRemoteNotification:(NSDictionary *)userInfo
  completionHandler:(void (^)())completionHandler {
    
}
#endif

#endif
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
