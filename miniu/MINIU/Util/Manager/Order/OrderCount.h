//
//  OrderCount.h
//  DLDQ_IOS
//
//  Created by simman on 14/10/30.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BaseModel.h"

@interface OrderCount : BaseModel

@property (nonatomic, assign) long long userId;             // 用户id

@property (nonatomic, assign) NSInteger noConfirmCount;    // 等待卖家确认
@property (nonatomic, assign) NSInteger orderCount;        // 所有订单数量
@property (nonatomic, assign) NSInteger noPaidCount;       // 待付款的订单数量
@property (nonatomic, assign) NSInteger partPaidCount;     // 待收余款的订单数量
@property (nonatomic, assign) NSInteger noSendCount;       // 已收全款,待发货的订单数量
@property (nonatomic, assign) NSInteger hasSentCount;      // 商家已发货的订单数量
@property (nonatomic, assign) NSInteger finishedCount;     // 买家确认收货,交易完成的订单数量
@property (nonatomic, assign) NSInteger hasRefundCount;       // 商家已退款的订单数量
@property (nonatomic, assign) NSInteger closedCount;       // 关闭的订单数量
@property (nonatomic, assign) NSInteger noRefundCount;      // 退款处理的数量

@end
