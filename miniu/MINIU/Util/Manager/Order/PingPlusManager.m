//
//  PingPlusManager.m
//  miniu
//
//  Created by SimMan on 15/6/8.
//  Copyright (c) 2015年 SimMan. All rights reserved.
//

#import "PingPlusManager.h"
#import "Pingpp.h"

@interface PingPlusManager()
@property (nonatomic, copy) void (^payment_error_block)(NSString *error);
@property (nonatomic, copy) void (^payment_success_block)(NSString *resultDic);
@end

@implementation PingPlusManager

+ (instancetype)shareInstance
{
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}


- (void)createPayment:(NSString *)charge
       viewController:(UIViewController *)viewController
              success:(void (^)(NSString *))success
              failure:(void (^)(NSString *))failure
{
    self.payment_success_block = success;
    self.payment_error_block = failure;
    [Pingpp createPayment:charge viewController:viewController appURLScheme:@"miniu" withCompletion:^(NSString *result, PingppError *error) {
       
        // 支付成功
        if (error == nil) {
            if (success) {
                success(result);
            }
        } else {
            if (failure) {
                
                NSString *errorStr;
                if (error.code == PingppErrCancelled) {
                    errorStr = @"已取消支付!";
                } else if (error.code == PingppErrChannelReturnFail){
                    errorStr = @"支付失败,请重试或选择其他支付方式!";
                } else if (error.code == PingppErrWxNotInstalled) {
                    errorStr = @"您没有安装微信,请选择其他支付方式!";
                } else {
                    errorStr = @"未知错误,请重试!";
                }
                
                failure(errorStr);
            }
        }
    }];
}

/*
 渠道为银联、百度钱包或者渠道为支付宝但未安装支付宝钱包时，交易结果会在调起插件时的 Completion 中返回。
 */
- (void)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    [Pingpp handleOpenURL:url withCompletion:^(NSString *result, PingppError *error) {
        // result : success, fail, cancel, invalid
        NSString *msg;
        if (error == nil) {
            if (self.payment_success_block) {
                self.payment_success_block(result);
            }
        } else {
            
            if (self.payment_error_block) {
                
                NSString *errorStr;
                if (error.code == PingppErrCancelled) {
                    errorStr = @"已取消支付!";
                } else if (error.code == PingppErrChannelReturnFail){
                    errorStr = @"支付失败,请重试或选择其他支付方式!";
                } else if (error.code == PingppErrWxNotInstalled) {
                    errorStr = @"您没有安装微信,请选择其他支付方式!";
                } else {
                    errorStr = @"未知错误,请重试!";
                }
                
                self.payment_error_block(errorStr);
            }
            
            NSLog(@"PingppError: code=%lu msg=%@", (unsigned long)error.code, [error getMsg]);
            msg = [NSString stringWithFormat:@"result=%@ PingppError: code=%lu msg=%@", result, (unsigned long)error.code, [error getMsg]];
        }
        
        NSLog(@"ping+++ result = %@", msg);
    }];
}


@end
