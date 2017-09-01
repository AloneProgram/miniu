//
//  LogManager.m
//  DLDQ_IOS
//
//  Created by simman on 14-9-23.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import "LogManager.h"
#import "LogEntity.h"
#import "LogEntity.h"

#import "TOWebViewController.h"
#import "HomeViewController.h"

#define LogTableName  @"log"

#define API_LOG_GET_NOTICE  @{@"method": @"user.notice.pageList"}

@interface LogManager()

@property (nonatomic, strong) RLMResults *allLogObj;   // 内存中的数据
@property (nonatomic, assign) int currentPage;
@property (nonatomic, assign) int pageSize;

@property (nonatomic, strong) RLMNotificationToken *notificationToken;

@property (nonatomic, strong) NSTimer *logTimer;

@end


@implementation LogManager

+ (instancetype)shareInstance
{
    static LogManager * instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        _pageSize = 100;
        _currentPage = 1;
        
        self.notificationToken = [RLMRealm.defaultRealm addNotificationBlock:^(NSString *note, RLMRealm *realm) {
            [[logicShareInstance getJpushManage] reloadBadge];
      
            [[NSNotificationCenter defaultCenter] postNotificationName:LOGMANAGER_DID_UPDATE object:self];
// 如果是买手版,则更新TabbarItem的角标
#if TARGET_IS_MINIU_BUYER
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [[[[MAIN_DELEGATE tabBarController].viewControllers objectAtIndex:1] rdv_tabBarItem] setBadgeValue:[NSString stringWithFormat:@"%d", (int)[self getAllUnreadNum]]];
//            });
#endif
        }];
        
        
        // 注册Jpush的相关通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reciveActiveMessage:) name:ReciveNotificationWithActive object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reciveInActiveNotification:) name:ReciveNotificationWithInactive object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reciveBackgroundNotification:) name:ReciveNotificationWithBackground object:nil];
    }
    return self;
}

#pragma mark 本地通知
- (void) reciveBackgroundNotification:(NSNotification *)sender
{
    
#if TARGET_IS_MINIU_BUYER
    NSInteger type = [[[sender userInfo] objectForKey:@"type"] integerValue];
    
    if (type != 314) {
        return;
    }
    [self httpRequestLogs];
#endif
}

/**
 *  非活动中收到通知的调用方法
 *
 *  @param sender 通知消息
 */
- (void) reciveInActiveNotification:(NSNotification *)sender
{
    [self openViewController:sender];
}

- (void) reciveActiveMessage:(NSNotification *)notification
{
#if TARGET_IS_MINIU_BUYER
    
    if ([[[notification userInfo] objectForKey:@"type"] intValue] != 314) {
        return;
    }
    
    [self httpRequestLogs];
    
    NSDictionary *aps = [[notification userInfo] objectForKey:@"aps"];
    
    NSString *alertBody = [NSString stringWithFormat:@"%@", [aps objectForKey:@"alert"]];
    
    [[logicShareInstance getNotificationCenterManager] showActiveNotificationWithTitle:nil andAlertBody:alertBody playSound:YES];
#endif
}

/**
 *  推送跳转页面
 *
 *  @param notification 远端推送
 */
- (void) openViewController:(NSNotification *)notification
{
    NSInteger type = [[[notification userInfo] objectForKey:@"type"] integerValue];
    
    //计数-1
    if (type == 401 || type == 402) {
        [[logicShareInstance getJpushManage] decreaseBadge:1];
    }
    
    // url
    if (type == 401) {
        
        NSString *url = [[notification userInfo] objectForKey:@"url"];
        NSURL *openUrl = [NSURL URLWithString:url];
        TOWebViewController *webViewController = [[TOWebViewController alloc] initWithURL:openUrl];
        webViewController.navigationButtonsHidden = YES;
        webViewController.hideWebViewBoundaries = YES;
        [[self getTopNavigationController] pushViewController:webViewController animated:YES];
        
    // tagName
    } else if (type == 402) {
        
        NSString *tagName = [[notification userInfo] objectForKey:@"tagName"];
        HomeViewController *homeVC = [[HomeViewController alloc] init];
        //设置商品页面请求字段的参数
        homeVC.tagName = tagName;        
        [[self getTopNavigationController] pushViewController:homeVC animated:YES];
    }
}



#pragma mark - 共有方法
#pragma mark 分页加载

/**
 *  @brief  获取内存中的所有消息
 *
 *  @return
 */
- (RLMResults *)getAllLogs
{
    return [self allLogObj];
}

/**
 *  @brief  根据 Type 返回消息
 *
 *  @param type
 *
 *  @return
 */
- (RLMResults *)getLogsWithLogType:(LogType)type
{
    RLMResults *newLogs = self.allLogObj;
    return [newLogs objectsWhere:[NSString stringWithFormat:@"logType = %d", (int)type]];
    return nil;
}

/**
 *  @brief  获取所有的消息条数
 *
 *  @return
 */
- (NSInteger)getAllLogsCount
{
    return self.allLogObj.count;
}

/**
 *  @brief  获取所有的未读条数
 *
 *  @return
 */
- (NSInteger)getAllUnreadNum
{
    RLMResults *newLogs = self.allLogObj;
    if (newLogs.count) {
        return [[newLogs objectsWhere:@"isRead = 0"] count];
    }
    return 0;
    
}

/**
 *  @brief  设置此条消息已读
 *
 *  @param log
 */
- (void)setIsReadWith:(LogEntity *)log
{
    [[RLMRealm defaultRealm] beginWriteTransaction];
    log.isRead = 1;
    [[RLMRealm defaultRealm] commitWriteTransaction];
}

/**
 *  @brief  设置所有消息已读
 */
- (void)setAllLogIsRead
{
    RLMResults *newLogs = self.allLogObj;
    
    [[RLMRealm defaultRealm] beginWriteTransaction];

    for (int i = 0; i < newLogs.count; i ++) {
        LogEntity *log = [newLogs objectAtIndex:i];
        log.isRead = 1;
    }
    [[RLMRealm defaultRealm] commitWriteTransaction];
}

/**
 *  @brief  获取所有的未读消息
 *
 *  @return
 */
- (RLMResults *) getAllUnreadLogs
{
    RLMResults *newLogs = self.allLogObj;
    return [newLogs objectsWhere:@"isRead = 0"];
}

#pragma mark - 私有方法
#pragma mark 获取所有的Log
- (RLMResults *)allLogObj
{
    if (!_allLogObj) {
        [self reloadDataToMemory];
    }
    return _allLogObj;
}

#pragma mark 重新加载所有的数据到内存中
- (void) reloadDataToMemory
{
    _allLogObj = [[LogEntity allObjects] sortedResultsUsingProperty:@"noticeId" ascending:NO];
}

#pragma mark 网络请求
- (void) httpRequestLogs
{
    @try {
        RLMRealm *realm = [RLMRealm defaultRealm];
        
        // 取出数据库中最后一条的ID ?
        LogEntity *obj = [self.allLogObj firstObject];
        
        long long lastMsgId = [obj noticeId];
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:API_LOG_GET_NOTICE];
        [params setObject:[NSString stringWithFormat:@"%lld", lastMsgId] forKey:@"lastMsgId"];
        [params setObject:[NSString stringWithFormat:@"%d", self.currentPage] forKey:@"currentPage"];
        [params setObject:[NSString stringWithFormat:@"%d", self.pageSize] forKey:@"pageSize"];
        
        [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {

            NSMutableArray *logArray = [NSMutableArray array];
            
            for (NSDictionary *dic in [responseObject objectForKey:@"data"]) {
                LogEntity *logEntity = [[LogEntity alloc] init];
                
                NSLog(@"LogEntity - >%@",dic);
                
                [logEntity setValuesForKeysWithDictionary:dic];
                [logArray addObject:logEntity];
            }
            
            if ([logArray count]) {
                [realm beginWriteTransaction];
                [realm addOrUpdateObjectsFromArray:logArray];
                [realm commitWriteTransaction];
            }

        } failure:^(NSURLSessionDataTask *task, NSString *error) {
            
        }];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    };
}

#pragma mark logic层统一管理协议方法
- (void)load
{
#if TARGET_IS_MINIU_BUYER
    // 如果用户登陆了,那么则启动定时获取通知
    if (USER_IS_LOGIN) {
        
        WeakSelf
        // 如果应用新装的,那么则20秒拉取一次数据
        if (![self.allLogObj count]) {
            _logTimer = [NSTimer bk_scheduledTimerWithTimeInterval:20 block:^(NSTimer *timer) {
                [weakSelf_SC httpRequestLogs];
            } repeats:YES];
        } else {
            // 这里初始化定时器, 5分钟主动拉取一次
            [NSTimer bk_scheduledTimerWithTimeInterval:60 block:^(NSTimer *timer) {
                [weakSelf_SC httpRequestLogs];
            } repeats:YES];
        }
    }
#endif
}

- (void)loadUserData{}
- (void)uiDidAppear
{
#if TARGET_IS_MINIU_BUYER
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [[[[MAIN_DELEGATE tabBarController].viewControllers objectAtIndex:1] rdv_tabBarItem] setBadgeValue:[NSString stringWithFormat:@"%d", (int)[self getAllUnreadNum]]];
//    });
#endif
}

- (void)save{}
- (void)reset{}
- (void)enterBackgroundMode{}
- (void)enterForeground{}
- (void)doLoginSuccessfulLogic
{
    [self httpRequestLogs];
}
- (void)doLogoutLogic
{
    // 删除所有的Log数据库
    RLMResults *allLogs = [LogEntity allObjects];
    [[RLMRealm defaultRealm] deleteObjects:allLogs];
}
- (void)disconnectNet{}

@end
