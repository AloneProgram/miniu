//
//  OrderEntity.h
//  DLDQ_IOS
//
//  Created by simman on 14-9-13.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseModel.h"

/**
 *  订单状态
 */
typedef NS_ENUM(NSInteger, orderStatusType) {
    /**
     *  等待买家付款
     */
    orderStatusOfWaitPayment = 0,
    /**
     *  已付定金，待付余款
     */
    orderStatusOfisPaymentWaitBalance,
    /**
     *  已付全款，等待发货
     */
    orderStatusOfisPaymentFull,
    
    orderStatusOfisDeliver,
    //            string = @"卖家已经发货";
    //            break;
    orderStatusOfisFinish,
    //            string = @"订单已完成";
    //            break;
    orderStatusOfRefund,
    //            string = @"退款成功";
    //            break;
    orderStatusOfClose,
    //            string = @"订单关闭";
    //            break;
    orderStatusOfRefunding,
    //            string = @"正在退款中";
    //            break;
    orderStatusOfRefundComfirm//已确认退款
    
    //
};

/**
 *  支付类型
 */
typedef NS_ENUM(NSInteger, payStatusType){
    /**
     *  订金
     */
    payStatusTypeOfNopayment = 0,
    /**
     *  定金
     */
    payStatusTypeOfBalance,
    /**
     *  全款
     */
    payStatusTypeOfFullAmout
};

@interface OrderEntity : BaseModel

@property (nonatomic, assign) NSInteger dataVN;     // 数据版本号

@property (nonatomic, strong) NSString *orderNo;    // 订单编号
@property (nonatomic, assign) long long goodsId;    // 商品ID
@property (nonatomic, strong) NSString *firstImageUrl;  // 首张图片
@property (nonatomic, strong) NSString *orderDescription;
@property (nonatomic, strong) NSString *depictRemark;
@property (nonatomic, strong) NSNumber *price;      // 价格

@property (nonatomic, assign) NSInteger orderNum;       // 商品数量

@property (nonatomic, assign) orderStatusType orderStatus;  // 订单状态

@property (nonatomic, assign) NSInteger orderType;          // 1、买家创建，2、买手创建

@property (nonatomic, assign) double totalBailAmount;       // 定金
@property (nonatomic, assign) double totalAmount;           // 全款

@property (nonatomic, assign) double totalBalanceAmount;     // 代付款余额

@property (nonatomic, assign) double totalRefundAmount;      // 退款总金额


@property (nonatomic, assign) double totalHasPaidAmount;     // 已支付金额

@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *consignee;
@property (nonatomic, strong) NSString *address;

@property (nonatomic, strong) NSString *leaveMessage;   // 留言

@property (nonatomic, assign) NSInteger applyUserId;    // 申请人ID
@property (nonatomic, assign) NSInteger buyerUserId;    // 买手ID
@property (nonatomic, assign) long long createTime;
@property (nonatomic, assign) long long updateTime;

@property (nonatomic, strong) NSString *applyUserCode;
@property (nonatomic, strong) NSString *applyNickName;
@property (nonatomic, strong) NSString *applyRoleType;
@property (nonatomic, strong) NSString *applyAvatar;
@property (nonatomic, strong) NSString *applyHxUId;

@property (nonatomic, strong) NSString *buyerUserCode;
@property (nonatomic, strong) NSString *buyerNickName;
@property (nonatomic, strong) NSString *buyerRoleType;
@property (nonatomic, strong) NSString *buyerAvatar;
@property (nonatomic, strong) NSString *buyerHxUId;

@property (nonatomic, assign) long long applyTimeStamp;         // 申请时间
@property (nonatomic, assign) long long payTimeStamp;           // 支付时间
@property (nonatomic, assign) long long shippingTimeStamp;      // 发货时间
@property (nonatomic, assign) long long confirmTimeStamp;       // 确认收货
@property (nonatomic, assign) long long refundTimeStamp;        // 退款时间

@property (nonatomic, assign) NSInteger payable;                // 是否支持收款

@property (nonatomic, strong) NSMutableArray *logArray;         // 日志


@property (nonatomic, assign) BOOL isMarkScored;                // 是否已经评分
@property (nonatomic, assign) BOOL isComplained;                // 是否已经投诉


@property (nonatomic, strong)  NSMutableArray *LogisticsArray;                   // 物流信息

@property (nonatomic, assign) int isLineTrade;

@property (nonatomic, strong) NSString *goodsImages ;//图片地址

@property (nonatomic, assign) int goodsImagesCount;//图片数量


- (instancetype) initWithOrderNo:(NSString *)orderNo;

+ (NSString *) getOrderStatusStringWith:(orderStatusType)type;

- (NSString *) getAllOrderLogString;

- (instancetype) initWithBase64String:(NSString *)base64String;

/**
 *  order实体转化成商品实体类
 *  用于展示订单详情
 *  @return goods entity
 */
- (GoodsEntity*) transferToGoodsEntity;

@end
