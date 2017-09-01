//
//  PingPlusManager.h
//  miniu
//
//  Created by SimMan on 15/6/8.
//  Copyright (c) 2015年 SimMan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ManagerBase.h"

@class OrderEntity, GoodsEntity, UserEntity, AddressEntity;
@interface PingPlusManager : ManagerBase <LogicBaseModel>

+ (instancetype)shareInstance;

/**
 *  @brief  拉起支付
 *
 *  @param charge
 *  @param viewController
 *  @param success
 *  @param failure        
 */
- (void)createPayment:(NSString *)charge
       viewController:(UIViewController*)viewController
              success:(void (^)(NSString *resultDic))success
              failure:(void (^)(NSString *error))failure;

- (void)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;

@end
