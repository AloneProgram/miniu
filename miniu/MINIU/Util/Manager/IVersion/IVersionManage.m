//
//  IVersionManage.m
//  DLDQ_IOS
//
//  Created by simman on 14-8-28.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import "IVersionManage.h"

@interface IVersionManage()

@property (nonatomic, strong) NSString *currentVersion;

@end

@implementation IVersionManage

+ (instancetype)shareInstance
{
    static IVersionManage * instance;
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
        NSDictionary *appDic = [[NSBundle mainBundle] infoDictionary] ;
        self.currentVersion =  [appDic objectForKey:@"CFBundleShortVersionString"];
    }
    return self;
}

- (void) startApplicationIversion;
{
    [iVersion sharedInstance].delegate = self;
    [iVersion sharedInstance].applicationBundleID = @"org.dldq.miniu";
    
#ifdef DEBUG
//    [self checkDebugVersion];
#endif

}


- (void)iVersionDidDetectNewVersion:(NSString *)version details:(NSString *)versionDetails
{
    [self setCurrentVersion:version];
    
    NSInteger serverVersionNum = [[version stringByReplacingOccurrencesOfString:@"." withString:@""] integerValue];
    if (!(serverVersionNum % 2)) {
//        [self showUpdateAlertView];
    }
}

- (void) showUpdateAlertView
{
    NSLog(@"此版本需要强制更新....");
    [WCAlertView showAlertWithTitle:@"提示" message:@"您目前使用的版本过旧,必须升级到最新版本才能继续使用!" customizationBlock:^(WCAlertView *alertView) {
        
    } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
        
        if (buttonIndex == 1) {
            [[iVersion sharedInstance] openAppPageInAppStore];
        }
        
    } cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
}

- (NSString *)getCurrentVersionNum
{
    return self.currentVersion;
}

- (void) checkDebugVersion
{
    [NET_WORK_HANDLE GET:@"http://fir.im/api/v2/app/53ad5ae31e977ab468000059/versions?token=uAaufwD1oBgRkpQt7ESgjlIprCjYzcemkg8tfhjj" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if ([responseObject count]) {
            
            NSDictionary *appDic = [[NSBundle mainBundle] infoDictionary] ;
            NSString *localBundleVersionStr =  [appDic objectForKey:@"CFBundleVersion"];
            
            NSDictionary *requestFirstDic = [responseObject objectAtIndex:0];
            NSString *remoteBundleVersionStr = [requestFirstDic objectForKey:@"version"];
            
            if ([localBundleVersionStr longLongValue] < [remoteBundleVersionStr longLongValue]) {
                
                NSString *changelog = [[requestFirstDic objectForKey:@"operator"] objectForKey:@"changelog"];
                
                NSString *change_log = [NSString stringWithFormat:@"\n更新日志:\n%@", changelog];
                
                NSString *message = [NSString stringWithFormat:@"(●'◡'●)(发)ﾉ♥<(▰˘◡˘▰)>(现)｡◕‿◕｡(测)(｡・`ω´･)(试) (●´ω｀●)(版)φ٩◔̯◔۶ ben>≖‿≖✧update~!o%@", change_log]; //changelog
                
                [WCAlertView showAlertWithTitle:@"😈O(∩_∩)O👿" message:message customizationBlock:^(WCAlertView *alertView) {
                    
                } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
                    
                    if (buttonIndex == 1) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://fir.im/dldq"]];
                    }
                    
                } cancelButtonTitle:@"gǔn cū" otherButtonTitles:@"kʌm ɑn", nil];
            }
            //
            //    [self.upToDate setText:[NSString stringWithFormat:@"%@", infoDict[@"CFBundleVersion"]]];
            //    [self.updateTime setText:[NSString stringWithFormat:@"20%@", infoDict[@"CFBundleVersion"]]];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {}];
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
