//
//  UpdateManager.m
//  DLDQ_IOS
//
//  Created by simman on 14-10-14.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import "UpdateManager.h"
#import "NSUserDefaults+Category.h"

#define LAST_UPDATE_TIME_NAME   @"DLDQ_LAST_UPDATE_TIME"
#define SERVER_VERSION          @"SERVER_VERSION"

@implementation UpdateManager

+ (instancetype)shareInstance
{
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return nil;
    return _sharedInstance;
}

//- (instancetype)init
//{
//    self = [super init];
//    if (self) {
//        // 检测空值
//        @try {
//            
//            NSString *lastUpdateTimeName = [NSUSER_DEFAULT objForKey:LAST_UPDATE_TIME_NAME];
//            if (!lastUpdateTimeName) {
//                NSLog(@"DEBUG: 最后一次检查更新时间没有值, 设置默认值为0");
//                [NSUSER_DEFAULT setObject:@"1" forKey:LAST_UPDATE_TIME_NAME];
//            }
//
//            NSString *serverVersion = [NSUSER_DEFAULT objectForKey:SERVER_VERSION];
//            if (!serverVersion) {
//                NSLog(@"DEBUG: 服务器版本号没有值, 设置默认值为0");
//                [NSUSER_DEFAULT setObject:@"1" forKey:SERVER_VERSION];
//            }
//        }
//        @catch (NSException *exception) {
//            NSLog(@"%@", exception.reason);
//        }
//        @finally {
//            
//        }
//    }
//    return self;
//}

/**
 *  检查更新
 */
- (void) checkUpdate
{
    return;
    @try {
        NSLog(@"开始检测版本更新....");
        // 首先拿出最后的更新时间
        long long time = [[NSUSER_DEFAULT objForKey:LAST_UPDATE_TIME_NAME] longLongValue];
        NSDate *date = [[NSDate alloc] init];
        long long currentTime = [date timeIntervalSince1970InMilliSecond];
        
        // 服务器的版本号
        NSInteger serverVersionNum = [[NSUSER_DEFAULT objectForKey:SERVER_VERSION] integerValue];
        NSInteger localVersionNum = [self getLocalCurrentVersionNum];
        
        // 如果大于1天,则请求服务器
        if (currentTime - time > 86400) {
            [self requestAppStoreIsNeedUpdate:^(BOOL isNeedUpdate) {
                [NSUSER_DEFAULT setObject:[NSNumber numberWithLongLong:currentTime] forKey:LAST_UPDATE_TIME_NAME];
                if (isNeedUpdate) {
                    [self showUpdateAlertView];
                } else {
                    NSLog(@"网络请求 Appstore 数据，发现版本号是最新或者非强制更新版本...");
                }
            }];
        } else {
            
            // 能被整除的为0 取反则为 YES
            
            if (serverVersionNum > localVersionNum && !(serverVersionNum % 2)) {
                [self showUpdateAlertView];
            } else {
                NSLog(@"本地数据存储的结果是不需要更新!");
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%s --->> %@", __FUNCTION__ ,exception.reason);
    }
    @finally {
        
    }
}

- (void) showUpdateAlertView
{
    NSLog(@"此版本需要更新....");
    [WCAlertView showAlertWithTitle:@"提示" message:@"您目前使用的版本过旧,必须升级到最新版本才能继续使用!" customizationBlock:^(WCAlertView *alertView) {
        
    } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
        
        if (buttonIndex == 1) {
//            [[iVersion sharedInstance] openAppPageInAppStore];
        }
     
    } cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
}

#pragma mark 向服务器请求最新的版本号
- (void) requestAppStoreIsNeedUpdate:(void(^)(BOOL isNeedUpdate))isNeedUpdate
{
    NSInteger currentVersionNum = [self getLocalCurrentVersionNum];
    
    [NET_WORK_HANDLE HttpRequestWithUrlString:@"http://itunes.apple.com/lookup?id=843676946" RequestType:GET parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if ([[responseObject objectForKey:@"resultCount"] integerValue]) {
            
            @try {
                NSString *serverVersionStr = [[[responseObject objectForKey:@"results"] firstObject] objectForKey:@"version"];
                NSInteger serverVersionNum = [[serverVersionStr stringByReplacingOccurrencesOfString:@"." withString:@""] integerValue];
                [NSUSER_DEFAULT setObj:[NSNumber numberWithInteger:serverVersionNum] forKey:SERVER_VERSION];
                if (serverVersionNum > currentVersionNum && !(serverVersionNum % 2)) {
                    isNeedUpdate(YES);
                } else {
                    isNeedUpdate(NO);
                }
            }
            @catch (NSException *exception) {}
            @finally {}
        }
    } failure:^(NSURLSessionDataTask *task, NSString *error) {} autoRetry:0 retryInterval:0];
}

- (NSInteger) getLocalCurrentVersionNum
{
    NSDictionary* infoDict =[[NSBundle mainBundle] infoDictionary];
    NSString* versionNumString =[infoDict objectForKey:@"CFBundleShortVersionString"];
    NSInteger currentVersionNum = [[versionNumString stringByReplacingOccurrencesOfString:@"." withString:@""] integerValue];
    return currentVersionNum;
}


- (void) clearData
{
    [NSUSER_DEFAULT removeObjForKey:LAST_UPDATE_TIME_NAME];
}

#pragma mark
#pragma mark logic层统一管理协议方法
- (void)load{}
- (void)loadUserData{}
- (void)save{}
- (void)reset{}
- (void)enterBackgroundMode{}
- (void)enterForeground
{
    return;
//    [self checkUpdate];
}
- (void)doLoginSuccessfulLogic{}
- (void)doLogoutLogic
{
//    [self clearData];
}
- (void)disconnectNet{}

@end
