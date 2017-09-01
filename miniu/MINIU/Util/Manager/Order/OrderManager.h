//
//  OrderManager.h
//  DLDQ_IOS
//
//  Created by simman on 14-9-13.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OrderEntity.h"
#import "CreateOrderEnetity.h"
#import "LogisticsEntity.h"
#import "AddressEntity.h"

/**
 *  请求类型
 */
typedef NS_ENUM(NSInteger, queryType) {
    /**
     *  我申请的代购
     */
    queryTypeOfMyApply = 1,
    /**
     *  我收到的订单
     */
    queryTypeOfMyOrder
};

/**
 *  支付方式
 */
typedef NS_ENUM(NSInteger, payMentPattern){
    /**
     *  微信支付
     */
    payMentPatternOfWeCaht = 1,
    /**
     *  支付宝支付
     */
    payMentPatternOfAlipay,
    
    /**
     *  银行卡支付
     */
    payMentPatternOfBank
};

/**
 * 支付类型
 */
typedef NS_ENUM(NSInteger, payType) {
    
    /**
     * 支付订金
     */
    payTypeOfPayDJ = 1,
    
    /**
     * 支付余款
     */
    payTypeOfPayResidue,
    
    /**
     * 支付全款
     */
    payTypeOfPayFull,
    
    /**
     * 退订金
     */
    payTypeOfRefundDJ,
    
    /**
     * 退全款
     */
    payTypeOfRefundAll
};

///**
// *  操作类型
// */
//typedef NS_ENUM(NSInteger, orderOperateType) {
//    /**
//     *  设置定金
//     */
//    orderOperateOfSetDJ = 1,
//    
//    /**
//     *  退回定金
//     */
//    orderOperateOfRefundDJ = 2,
//    
//    /**
//     *  退回全款
//     */
//    orderOperateOfRefundAll = 3,
//    
//    /**
//     *  确认发货
//     */
//    orderOperateOfConfirmDeliver = 4,
//    
//    /**
//     *  确认收货
//     */
//    orderOperateOfConfirm = 5,
//    
//    /**
//     *  关闭订单
//     */
//    orderOperateOfClose = 6
//};

/**
 *  获取订单列表类型
 */
typedef NS_ENUM(NSInteger, orderListType) {
    
    /**
     *  等待买手确认
     */
    orderListTypeOfWaitBuyerConfirm = -2,
    /**
     *  所有订单
     */
    orderListTypeOfAll = -1,
    /**
     *  等待买家付款
     */
    orderListTypeOfWaitPayment = 0,
    /**
     *  已付定金，待付余款
     */
    orderListTypeOfisPaymentWaitBalance,
    /**
     *  已付全款，等待发货
     */
    orderListTypeOfisPaymentFull,
    /**
     *  买手已经发货
     */
    orderListTypeOfisDeliver,
    /**
     *  订单已完成
     */
    orderListTypeOfisFinish,
    /**
     *  买手已经退款
     */
    orderListTypeOfRefund,
    /**
     *  订单关闭
     */
    orderListTypeOfClose,
    
    /**
     *  退款处理中
     */
    orderListTypeOfRefunding
};

@class OrderEntity, GoodsEntity, UserEntity, AddressEntity;

@interface OrderManager : ManagerBase <LogicBaseModel>


/**
 *  对象单例
 *
 *  @return
 */
+ (instancetype)shareInstance;

//
///**
// *  申请代购
// *
// *  @param goodsId              商品ID
// *  @param orderNum             商品数量
// *  @param orderAddressEntity   地址
// *  @param success              成功回调
// *  @param failure              失败回调
// *
// *  @return 网络标识
// */
//- (NSURLSessionDataTask *)postOrderWithGoodsId:(long long)goodsId
//                                      orderNum:(NSInteger)orderNum
//                                      leaveMessage:(NSString *)leaveMessage
//                                 orderAddressEntity:(AddressEntity *)orderAddressEntity
//                                       success:(void (^)(id responseObject))success
//                                       failure:(void (^)(NSString *error))failure;
//
//
/**
 *  @brief  简版的米妞代购
 *
 *  @param goodsId
 *  @param success
 *  @param failure
 *
 *  @return
 */
- (NSURLSessionDataTask *)applyOrderWithGoodsId:(long long)goodsId
                                       success:(void (^)(id responseObject))success
                                       failure:(void (^)(NSString *error))failure;


/**
 *  获取订单列表
 *  @param userId 查询id
 *  @param payApplyType   支付状态(0-未支付，1-支付订金，2-支付尾款，3-支付全款
 *  @param orderListType 订单状态
 *  @param currentPage 当前页码
 *  @param pageSize    每页数量
 *  @param limitTime   时间戳（最后一条数据的发布时间）
 *
 *  @return 网络标识
 */
- (NSURLSessionDataTask *)getOrderListWithUserId:(long long)userId
                                            QueryType:(int)payApplyType
                                        orderListType:(orderListType)orderListType
                                        CurrentPage:(NSInteger)currentPage
                                           pageSize:(NSInteger)pageSize
                                          limitTime:(long long)limitTime
                                            success:(void (^)(id responseObject))success
                                            failure:(void (^)(NSString *error))failure;


/**
 *  获取订单详情信息
 *
 *  @param orderNo 订单单号
 *  @param success 成功回调
 *  @param failure 失败回调
 *
 *  @return 网络标识
 */
- (NSURLSessionDataTask *)getOrderDetailsWithOrderNo:(NSString *)orderNo
                                             success:(void (^)(id responseObject))success
                                             failure:(void (^)(NSString *error))failure;
///**
// *  修改状态
// *
// *  @param orderId     订单ID
// *  @param orderOperateTp 操作类型
// *  @param success     成功回调
// *  @param failure     失败回调
// *
// *  @return 网络标识
// */
//- (NSURLSessionDataTask *)updateOrderWithOrderID:(NSString *)orderId
//                                  orderOperateTp:(orderOperateType)orderOperateTp
//                                       success:(void (^)(id responseObject))success
//                                       failure:(void (^)(NSString *error))failure;

///**
// *  关闭订单
// *
// *  @param orderId 订单 ID
// *  @param success 成功回调
// *  @param failure 失败回调
// *
// *  @return 网络标识
// */
//- (NSURLSessionDataTask *)closeOrderWithOrderID:(NSString *)orderId
//                                         dataVN:(NSInteger)dataVN
//                                        success:(void (^)(id responseObject))success
//                                        failure:(void (^)(NSString *error))failure;
//
///**
// *  设置定金&总价格接口
// *
// *  @param orderId    订单 ID
// *  @param remark      备注信息
// *  @param bailAmount 订金
// *  @param fullAmount 总价格
// *  @param success    成功回调
// *  @param failure    失败回调
// *
// *  @return 网络标识
// */
//- (NSURLSessionDataTask *)setOrderPriceWithOrderID:(NSString *)orderId
//                                            dataVN:(NSInteger)dataVN
//                                            remark:(NSString *)remark
//                                        bailAmount:(double)bailAmount
//                                        fullAmount:(double)fullAmount
//                                           success:(void (^)(id responseObject))success
//                                           failure:(void (^)(NSString *error))failure;

///**
// *  获取用户的订单统计
// *
// *  @param queryType 请求类型
// *  @param success   成功回调
// *  @param failure   失败回调
// *
// *  @return 网络标识
// */
//- (NSURLSessionDataTask *)getUserOrderStatInfoWithOrderOperateTp:(queryType)queryType
//                                                         success:(void (^)(id responseObject))success
//                                                         failure:(void (^)(NSString *error))failure;


///**
// *  支付宝 的付款接口
// *
// *  @param orderId 订单 ID
// *  @param payType 支付类型
// *  @param dataVN  数据版本号
// *  @param success 成功回调
// *  @param failure 失败回调
// *
// *  @return 网络标识
// */
//- (NSURLSessionDataTask *)paymentWithAlipayOfOrderID:(NSString *)orderId
//                                             paytype:(payType)payType
//                                              dataVN:(NSInteger)dataVN
//                                             success:(void (^)(id responseObject))success
//                                             failure:(void (^)(NSString *error))failure;

///**
// *  支付宝退款
// *
// *  @param orderId      订单 ID
// *  @param reasonType   退款原因
// *  @param refundAmount 退款金额
// *  @param remark       退款备注
// *  @param dataVN       版本号
// *  @param success      成功回调
// *  @param failure      失败回调
// *
// *  @return 网络标识
// */
//- (NSURLSessionDataTask *)refundWithAlipayOfOrderID:(NSString *)orderId
//                                         reasonType:(NSString *)reasonType
//                                       refundAmount:(double)refundAmount
//                                             remark:(NSString *)remark
//                                             dataVN:(NSInteger)dataVN
//                                            success:(void (^)(id responseObject))success
//                                            failure:(void (^)(NSString *error))failure;

///**
// *  确认发货
// *
// *  @param orderId 订单 ID
// *  @param success 成功回调
// *  @param failure 失败回调
// *
// *  @return 网络标识
// */
//- (NSURLSessionDataTask *)tosendWithOrderNo:(NSString *)orderId
//                                             success:(void (^)(id responseObject))success
//                                             failure:(void (^)(NSString *error))failure;

///**
// *  确认收货
// *
// *  @param orderId 订单 ID
// *  @param success 成功回调
// *  @param failure 失败回调
// *
// *  @return 网络标识
// */
//- (NSURLSessionDataTask *)receiptWithOrderNo:(NSString *)orderId
//                                    success:(void (^)(id responseObject))success
//                                    failure:(void (^)(NSString *error))failure;


///**
// *  提醒卖家发货
// *
// *  @param orderId 订单 ID
// *  @param success 成功回调
// *  @param failure 失败回调
// *
// *  @return 网络标识
// */
//- (NSURLSessionDataTask *)remindBuyer:(NSString *)orderId
//                                     success:(void (^)(id responseObject))success
//                                     failure:(void (^)(NSString *error))failure;

///**
// *  投诉订单
// *
// *  @param orderId 订单 ID
// *  @param content 内容
// *  @param success 成功回调
// *  @param failure 失败回调
// *
// *  @return 网络标识
// */
//- (NSURLSessionDataTask *)complaintOrder:(NSString *)orderId
//                                 content:(NSString *)content
//                              success:(void (^)(id responseObject))success
//                              failure:(void (^)(NSString *error))failure;

///**
// *  评分订单
// *
// *  @param orderId    订单 ID
// *  @param fromUserId 来自
// *  @param toUserId   到
// *  @param success    成
// *  @param failure    失败
// *
// *  @return 网络标识
// */
//- (NSURLSessionDataTask *)markscoreOrder:(NSString *)orderId
//                              fromUserId:(NSString *)fromUserId
//                                toUserId:(NSString *)toUserId
//                                   score:(NSString *)score
//                                 content:(NSString *)content
//                                 success:(void (^)(id responseObject))success
//                                 failure:(void (^)(NSString *error))failure;


/**
 *  @brief  手动创建订单
 *
 *  @param createOrder
 *  @param success    成
 *  @param failure    失败
 *
 *  @return 网络标识
 */
- (NSURLSessionDataTask *)createOrderWith:(CreateOrderEnetity *)createOrder
                                 success:(void (^)(id responseObject))success
                                 failure:(void (^)(NSString *error))failure;


/**
 *  @brief  获取用户的订单列表
 *
 *  @param userId
 *  @param currentPage
 *  @param pageSize
 *  @param limitTime
 *  @param success
 *  @param failure
 *
 *  @return
 */
- (NSURLSessionDataTask *)getOrderListWithUserId:(long long)userId
                                        CurrentPage:(NSInteger)currentPage
                                           pageSize:(NSInteger)pageSize
                                          limitTime:(long long)limitTime
                                            success:(void (^)(id responseObject))success
                                            failure:(void (^)(NSString *error))failure;


/**
 *  @brief  获取Ping+支付信息
 *
 *  @param orderNo    订单号
 *  @param payChannel 支付渠道
 *  @param success    成功回调
 *  @param failure    失败回调
 *
 *  @return 
 */
- (NSURLSessionDataTask *)pingPlusCreateOrderWith:(NSString *)orderNo
                                        payChannel:(payMentPattern)payChannel
                                         success:(void (^)(id responseObject))success
                                         failure:(void (^)(NSString *error))failure;


/**
 *  @brief  查询某订单所有物流信息
 *
 *  @param orderNo
 *  @param success
 *  @param failure
 *
 *  @return
 */
- (NSURLSessionDataTask *)getLogisticsListWithOrderNo:(NSString *)orderNo
                                          success:(void (^)(id responseObject))success
                                          failure:(void (^)(NSString *error))failure;


/**
 *  @brief  查询系统配置的所有物流公司接口
 *
 *  @param success
 *  @param failure
 *
 *  @return
 */
- (NSURLSessionDataTask *)getCompanylistSuccess:(void (^)(id responseObject))success
                                              failure:(void (^)(NSString *error))failure;

/**
 *  @brief  添加或编辑订单物流信息
 *
 *  @param orderNo
 *  @param logisticsEntity
 *  @param success
 *  @param failure
 *
 *  @return 
 */
- (NSURLSessionDataTask *)editLogisticsListWithOrderNo:(NSString *)orderNo
                                       logisticsEntity:(LogisticsEntity *)logisticsEntity
                                              success:(void (^)(id responseObject))success
                                              failure:(void (^)(NSString *error))failure;

/**
 *  @brief  添加收货地址
 *
 *  @param orderNo 订单编号
 *  @param address 
 *  @param success
 *  @param failure
 *
 *  @return 
 */
- (NSURLSessionDataTask *)addAddressWithOrderNo:(NSString *)orderNo
                                       address:(AddressEntity *)address
                                               success:(void (^)(id responseObject))success
                                               failure:(void (^)(NSString *error))failure;


/**
 *  改变订单状态
 *
 *  @param orderNo 订单号
 *  @param statues 订单状态 枚举值
 *  @param success
 *  @param failure
 *
 *  @return 请求任务
 */
- (NSURLSessionDataTask *)changeOrderStatusWithOrderNo:(NSString *)orderNo
                                        orderStates:(orderStatusType)status
                                        success:(void (^)(id responseObject))success
                                        failure:(void (^)(NSString *error))failure;
///**
// *  设置未读订单数量
// *
// *  @param num 数量
// *
// */
//- (void) setOrderUnReadNum:(NSInteger)num withOrderType:(queryType)queryType;
//
///**
// *  获取未读订单数量
// */
//- (NSInteger) orderUnReadNumWithOrderType:(queryType)queryType;

/**
 *  申请退款
 *
 *  @param orderNO 订单号
 *  @param reason  退款原因
 *  @param remark  退款描述
 *  @param success
 *  @param failure
 *
 *  @return
 */
- (NSURLSessionDataTask *)refundWithOrderNo:(NSString *)orderNO
                                     reason:(NSString *)reason
                                     remark:(NSString *)remark
                                    success:(void (^)(id responseObject))success
                                    failure:(void (^)(NSString *error))failure;

/**
 *  关闭订单
 *
 *  @param orderNo 订单号
 *  @param success success description
 *  @param failure failure description
 *
 *  @return
 */
- (NSURLSessionDataTask *)closeOrderWithWithOrderNo:(NSString *)orderNo
                                            success:(void (^)(id responseObject))success
                                            failure:(void (^)(NSString *error))failure;



@end
