

//
//  AlipayManager.m
//  DLDQ_IOS
//
//  Created by simman on 14/12/3.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import "AlipayManager.h"

#import <AlipaySDK/AlipaySDK.h>
#define appScheme   @"dldq"

@interface AlipayManager()
@property (nonatomic, copy) void (^payment_error_block)(NSString *error);
@property (nonatomic, copy) void (^payment_success_block)(NSString *resultDic);
@end

@implementation AlipayManager

+ (instancetype)shareInstance
{
    static AlipayManager * instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

#pragma mark 调起支付宝支付
- (void) openAlipayMentWithPayOrder:(NSString *)payOrder
                            success:(void (^)(NSString *))success
                            failure:(void (^)(NSString *))failure
{
    self.payment_success_block = success;
    self.payment_error_block   = failure;
    NSLog(@"开始检查 payOrder 数据...");
    if (!payOrder || ![payOrder length]) {
        if (self.payment_error_block) {
            self.payment_error_block(@"订单数据错误,请重试!");
        }
        return;
    }
    NSLog(@"payorder 数据正确...");
    NSLog(@"准备调起支付宝客户端...");
    NSLog(@"传给支付宝的参数：payOrder -> %@, scheme -> %@", payOrder, appScheme);
    [[AlipaySDK defaultService] payOrder:payOrder fromScheme:appScheme callback:^(NSDictionary *resultDic) {
        NSLog(@"支付宝回调方法: <%s> \n %@ ", __FUNCTION__, resultDic);
        [self resultHandelWith:resultDic];
    }];
}


#pragma mark 处理回调数据
- (void) resultHandelWith:(NSDictionary *)resultdic
{
    NSLog(@"开始处理回调数据,如果有错误信息则抛出...");
    @try {
        NSString *memo = [resultdic objectForKey:@"memo"];
        NSString *result = [resultdic objectForKey:@"result"];
        NSString *resultStatus = [resultdic objectForKey:@"resultStatus"];
        
        if ([resultStatus integerValue] != 9000) {
            NSLog(@"错误代码：%@, 错误信息：%@", resultStatus, memo);
            if (self.payment_error_block) {
                self.payment_error_block(memo);
            }
        } else {  // 如果是正确的
            NSLog(@"支付宝返回数据处理成功...");
            if (self.payment_success_block) {
                
                if (![result length]) {
                    result = @"支付失败或已被中止!";
                }
                
                self.payment_success_block(result);
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"<%s> :error %@", __FUNCTION__, exception.reason);
    }
    @finally {
        
    }
}

#pragma mark ------------
- (void)application:(UIApplication *)application
      handleOpenURL:(NSURL *)url{}
- (void)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    //跳转支付宝钱包进行支付，需要将支付宝钱包的支付结果回传给SDK
    if ([url.host isEqualToString:@"safepay"]) {
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            NSLog(@"支付宝回调方法: <%s> \n %@ ", __FUNCTION__, resultDic);
            [self resultHandelWith:resultDic];
        }];
    }
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
