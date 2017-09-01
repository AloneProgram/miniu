//
//  AlipayManager.h
//  DLDQ_IOS
//
//  Created by simman on 14/12/3.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface AlipayManager : NSObject <LogicBaseModel>

+ (instancetype)shareInstance;

/**
 *  打开支付宝支付
 *
 *  @param payOrder  订单信息
 *  @param success   成功回调
 *  @param failure   失败回调
 *
 */
- (void) openAlipayMentWithPayOrder:(NSString *)payOrder
                            success:(void (^)(NSString *resultDic))success
                            failure:(void (^)(NSString *error))failure;



- (void)application:(UIApplication *)application handleOpenURL:(NSURL *)url;
- (void)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;

@end
