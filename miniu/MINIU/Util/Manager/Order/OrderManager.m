//
//  OrderManager.m
//  DLDQ_IOS
//
//  Created by simman on 14-9-13.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import "OrderManager.h"
#import "AddressEntity.h"
#import "NSUserDefaults+Category.h"

#define API_ORDER_SEARCH @{@"method":  @"user.order.search"} //订单搜索

#define API_ORDER_POST   @{@"method":  @"order.save"}
#define API_ORDER_LIST   @{@"method":  @"user.order.statlist"}
#define API_ORDER_UPDATE_STATUS   @{@"method":  @"order.update"}

#define API_ORDER_INDEX @{@"method":  @"user.order.statInfo"}       // 我的订单、申请的代购统计数量

#define API_ORDER_DETAIL @{@"method":  @"order.details"}         // 订单详情
#define API_ORDER_SETPRICE  @{@"method":  @"order.cash.update"} // 设置定金和总价接口

#define API_ORDER_CLOSE   @{@"method": @"order.status.close"}   // 关闭订单

#define API_ORDER_REFUND   @{@"method": @"order.apply.refund"}   // 申请订单退款

#define API_ORDER_ALIPAY  @{@"method": @"pay.alipay.query"}   // 支付宝付款

#define API_ORDER_STATUS_TOSEND   @{@"method": @"order.status.tosend"}       // 确认发货
#define API_ORDER_STATUS_RECEIPT  @{@"method": @"order.status.receipt"}       // 确认收货

#define API_ORDER_ALIPAY_REFUND  @{@"method": @"pay.alipay.refund"}     // 支付宝退款

#define API_ORDER_REMIND  @{@"method": @"order.status.remind"}     // 提醒卖家发货

#define API_ORDER_COMPLAINT @{@"method": @"order.complaint"}         // 投诉订单

#define API_ORDER_MARKSCORE  @{@"method": @"order.markscore"}         // 评分

#define API_APPLY_MINIU_ORDER  @{@"method": @"shopping.apply"}         // 提交代购申请

#define API_CREATE_ORDER  @{@"method": @"order.hand.create"}               // 手动创建订单

#define API_ORDER_LIST_WITH_UID  @{@"method": @"user.order.pageList"}               // 查看某用户的订单

#define API_PING_PLUS_CREATE_ORDER  @{@"method": @"pingpp.charge.create"}               // PING +
#define API_LOGISTICS_COMPANYLIST  @{@"method": @"config.logistics.companylist"}               // PING +
#define API_LOGISTICS_LIST  @{@"method": @"order.logistics.list"}
#define API_LOGISTICS_SAVE  @{@"method": @"logistics.save"}

#define API_UPDATE_ORDER_ADDRESS @{@"method": @"user.order.address"}            // 哈哈哈

@implementation OrderManager

+ (instancetype)shareInstance
{
    static OrderManager * instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

//#pragma mark 申请代购
//- (NSURLSessionDataTask *)postOrderWithGoodsId:(long long)goodsId
//                                      orderNum:(NSInteger)orderNum
//                                  leaveMessage:(NSString *)leaveMessage
//                            orderAddressEntity:(AddressEntity *)orderAddressEntity
//                                       success:(void (^)(id))success
//                                       failure:(void (^)(NSString *))failure
//{
//    @try {
//        NSMutableDictionary *tmpDic = [NSMutableDictionary dictionaryWithCapacity:1];
//        [tmpDic setObject:[NSNumber numberWithLongLong:goodsId] forKey:@"goodsId"];
//        [tmpDic setObject:[NSNumber numberWithInteger:orderNum] forKey:@"orderNum"];
//        [tmpDic setObject:orderAddressEntity.realName forKey:@"consignee"];
//        [tmpDic setObject:leaveMessage forKey:@"leaveMessage"];
//
//        NSDictionary *dd = [self mergeDictionWithDicone:tmpDic AndDicTwo:[orderAddressEntity toDictionary]];
//
//        NSDictionary *parameters = [self mergeDictionWithDicone:API_ORDER_POST AndDicTwo:dd];
//        return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
//            success(responseObject);
//        } failure:^(NSURLSessionDataTask *task, NSString *error) {
//            failure(error);
//        }];
//    }
//    @catch (NSException *exception) {failure(@"请求参数错误,请检查后重试!");}
//    @finally {}
//}

- (NSURLSessionDataTask *)applyOrderWithGoodsId:(long long)goodsId success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    @try {
        NSMutableDictionary *tmpDic = [NSMutableDictionary dictionaryWithCapacity:1];
        [tmpDic setObject:[NSNumber numberWithLongLong:goodsId] forKey:@"goodsId"];
        [tmpDic setObject:@"2.0" forKey:@"v"];
        NSDictionary *parameters = [self mergeDictionWithDicone:API_APPLY_MINIU_ORDER AndDicTwo:tmpDic];
        return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            success(responseObject);
        } failure:^(NSURLSessionDataTask *task, NSString *error) {
            failure(error);
        }];
    }
    @catch (NSException *exception) {failure(@"请求参数错误,请检查后重试!");}
    @finally {}
}

#pragma mark 获取订单列表 API_ORDER_SEARCH
- (NSURLSessionDataTask *)getOrderListWithUserId:(long long)userId
                                       QueryType:(int)payApplyType
                                   orderListType:(orderListType)orderListType
                                     CurrentPage:(NSInteger)currentPage
                                        pageSize:(NSInteger)pageSize
                                       limitTime:(long long)limitTime
                                         success:(void (^)(id))success
                                         failure:(void (^)(NSString *))failure
{
    @try {
        NSMutableDictionary *tmpDic = [NSMutableDictionary dictionaryWithCapacity:1];
        [tmpDic setObject:[NSNumber numberWithLongLong:userId] forKey:@"userId"];
        //不需要这个字段
        //[tmpDic setObject:[NSNumber numberWithInteger:payApplyType] forKey:@"payApplyType"];
        NSInteger orderListTypeInt = (NSInteger)orderListType;
        [tmpDic setObject:[NSNumber numberWithInteger:orderListTypeInt] forKey:@"orderStatus"];
        
        [tmpDic setObject:[NSNumber numberWithInteger:currentPage] forKey:@"currentPage"];//defaultCurPage
        [tmpDic setObject:[NSNumber numberWithInteger:pageSize] forKey:@"pageSize"];
        //limitTime >=0 ? [tmpDic setObject:[NSNumber numberWithLongLong:limitTime] forKey:@"limitTime"] : nil;
        
        NSDictionary *parameters = [self mergeDictionWithDicone:API_ORDER_SEARCH AndDicTwo:tmpDic];
        return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            success(responseObject);
        } failure:^(NSURLSessionDataTask *task, NSString *error) {
            failure(error);
        }];
    }
    @catch (NSException *exception) {failure(@"请求参数错误,请检查后重试!");}
    @finally {}
}

////#pragma mark 更改订单
////- (NSURLSessionDataTask *)updateOrderWithOrderID:(NSString *)orderId
////                                  orderOperateTp:(orderOperateType)orderOperateTp
////                                         success:(void (^)(id))success
////                                         failure:(void (^)(NSString *))failure
////{
////    @try {
////        NSMutableDictionary *tmpDic = [NSMutableDictionary dictionaryWithCapacity:1];
////        orderOperateTp >= 0 ? [tmpDic setObject:[NSNumber numberWithInteger:orderOperateTp] forKey:@"operateType"] : nil;
////        [orderId length] > 0 ? [tmpDic setObject:orderId forKey:@"orderNo"] : nil;
////
////        NSDictionary *parameters = [self mergeDictionWithDicone:API_ORDER_UPDATE_STATUS AndDicTwo:tmpDic];
////        return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
////            success(responseObject);
////        } failure:^(NSURLSessionDataTask *task, NSString *error) {
////            failure(error);
////        }];
////    }
////    @catch (NSException *exception) {failure(@"请求参数错误,请检查后重试!");}
////    @finally {}
////}
//
#pragma mark 关闭订单
- (NSURLSessionDataTask *)closeOrderWithOrderID:(NSString *)orderId
                                         dataVN:(NSInteger)dataVN
                                        success:(void (^)(id))success
                                        failure:(void (^)(NSString *))failure
{
    @try {
        
        NSMutableDictionary *p = [NSMutableDictionary dictionaryWithCapacity:1];
        if (orderId) {
            [p setObject:orderId forKey:@"orderNo"];
        }
        
        [p setObject:[NSString stringWithFormat:@"%ld", (long)dataVN] forKey:@"dataVN"];
        
        NSDictionary *parameters = [self mergeDictionWithDicone:API_ORDER_CLOSE AndDicTwo:p];
        return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            success(responseObject);
        } failure:^(NSURLSessionDataTask *task, NSString *error) {
            failure(error);
        }];
    }
    @catch (NSException *exception) {failure(@"请求参数错误,请检查后重试!");}
    @finally {}
}

//
//#pragma mark 获取用户的订单统计
//- (NSURLSessionDataTask *)getUserOrderStatInfoWithOrderOperateTp:(queryType)queryType
//                                                         success:(void (^)(id))success
//                                                         failure:(void (^)(NSString *))failure
//{
//    @try {
//        NSMutableDictionary *tmpDic = [NSMutableDictionary dictionaryWithCapacity:1];
//        [tmpDic setObject:[NSNumber numberWithInteger:queryType] forKey:@"queryType"];
//
//        NSDictionary *parameters = [self mergeDictionWithDicone:API_ORDER_INDEX AndDicTwo:tmpDic];
//        return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
//            success(responseObject);
//        } failure:^(NSURLSessionDataTask *task, NSString *error) {
//            failure(error);
//        }];
//    }
//    @catch (NSException *exception) {failure(@"请求参数错误,请检查后重试!");}
//    @finally {}
//}

#pragma mark 获取订单详情
- (NSURLSessionDataTask *)getOrderDetailsWithOrderNo:(NSString *)orderNo
                                             success:(void (^)(id))success
                                             failure:(void (^)(NSString *))failure
{
    @try {
        if (!orderNo || ![orderNo length]) {
            failure(@"请求参数错误,请检查后重试!");
        }
        NSDictionary *parameters = [self mergeDictionWithDicone:API_ORDER_DETAIL AndDicTwo:@{@"orderNo": [NSString stringWithFormat:@"%@", orderNo]}];
        return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            success(responseObject);
        } failure:^(NSURLSessionDataTask *task, NSString *error) {
            failure(error);
        }];
    }
    @catch (NSException *exception) {
        failure(@"请求参数错误,请检查后重试!");
    }
    @finally {}
}

//#pragma mark 设置定金&总价接口
//- (NSURLSessionDataTask *)setOrderPriceWithOrderID:(NSString *)orderId
//                                            dataVN:(NSInteger)dataVN
//                                            remark:(NSString *)remark
//                                        bailAmount:(double)bailAmount
//                                        fullAmount:(double)fullAmount
//                                           success:(void (^)(id))success
//                                           failure:(void (^)(NSString *))failure
//{
//    @try {
//
//        NSMutableDictionary *p = [NSMutableDictionary dictionaryWithCapacity:1];
//        [p setObject:orderId forKey:@"orderNo"];
//        if (bailAmount >= 0) {
//            [p setObject:[NSString stringWithFormat:@"%f", bailAmount] forKey:@"bailAmount"];
//        }
//
//        if (fullAmount >= 0) {
//            [p setObject:[NSString stringWithFormat:@"%f", fullAmount] forKey:@"fullAmount"];
//        }
//
//        if (remark && [remark length]) {
//            [p setObject:remark forKey:@"remark"];
//        }
//
//        [p setObject:[NSString stringWithFormat:@"%ld", (long)dataVN] forKey:@"dataVN"];
//
//        NSDictionary *parameters = [self mergeDictionWithDicone:API_ORDER_SETPRICE AndDicTwo:p];
//        return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
//            success(responseObject);
//        } failure:^(NSURLSessionDataTask *task, NSString *error) {
//            failure(error);
//        }];
//    }
//    @catch (NSException *exception) {
//        failure(@"请求参数错误,请检查后重试!");
//    }
//    @finally {}
//}
//
//#pragma mark 设置未读订单数量
//- (void) setOrderUnReadNum:(NSInteger)num withOrderType:(queryType)queryType
//{
//    // 首先获取
//    NSString *key = @"";
//    if (queryType == queryTypeOfMyApply) {
//        key = @"queryTypeOfMyApplyNum";
//    } else if (queryType == queryTypeOfMyOrder) {
//        key = @"queryTypeOfMyOrderNum";
//    }
//
//    NSInteger unReadNum = [[NSUSER_DEFAULT objForKey:key] integerValue];
//
//    if (num) {
//        [NSUSER_DEFAULT setObj:[NSString stringWithFormat:@"%d", (int)(num + unReadNum)] forKey:key];
//    } else {
//        [NSUSER_DEFAULT setObj:@"0" forKey:key];
//    }
//}
//
//#pragma mark 获取未读订单数量
//- (NSInteger) orderUnReadNumWithOrderType:(queryType)queryType
//{
//    // 首先获取
//    NSString *key = @"";
//    if (queryType == queryTypeOfMyApply) {
//        key = @"queryTypeOfMyApplyNum";
//    } else if (queryType == queryTypeOfMyOrder) {
//        key = @"queryTypeOfMyOrderNum";
//    }
//
//    NSInteger unReadNum = [[NSUSER_DEFAULT objForKey:key] integerValue];
//    NSLog(@"获取未读订单数量： %d", (int)unReadNum);
//    return unReadNum;
//}
//
//
//#pragma mark 支付宝的付款操作
//- (NSURLSessionDataTask *)paymentWithAlipayOfOrderID:(NSString *)orderId
//                                             paytype:(payType)payType
//                                              dataVN:(NSInteger)dataVN
//                                             success:(void (^)(id))success
//                                             failure:(void (^)(NSString *))failure
//{
//    @try {
//        if (!orderId || ![orderId length]) {
//            failure(@"请求参数错误,请检查后重试!");
//        }
//        NSMutableDictionary *p = [NSMutableDictionary dictionaryWithCapacity:1];
//        [p setObject:[NSString stringWithFormat:@"%d", (int)payType] forKey:@"payType"];
//        [p setObject:[NSString stringWithFormat:@"%@", orderId] forKey:@"orderNo"];
//        [p setObject:[NSString stringWithFormat:@"%lld", (long long)dataVN] forKey:@"dataVN"];
//
//        NSDictionary *parameters = [self mergeDictionWithDicone:API_ORDER_ALIPAY AndDicTwo:p];
//        return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
//            success(responseObject);
//        } failure:^(NSURLSessionDataTask *task, NSString *error) {
//            failure(error);
//        }];
//    }
//    @catch (NSException *exception) {
//        failure(@"请求参数错误,请检查后重试!");
//    }
//    @finally {}
//}
//
//#pragma mark 支付宝退款
//- (NSURLSessionDataTask *)refundWithAlipayOfOrderID:(NSString *)orderId reasonType:(NSString *)reasonType refundAmount:(double)refundAmount remark:(NSString *)remark dataVN:(NSInteger)dataVN success:(void (^)(id))success failure:(void (^)(NSString *))failure
//{
//    @try {
//        if (!orderId || ![orderId length]) {
//            failure(@"请求参数错误,请检查后重试!");
//        }
//        NSMutableDictionary *p = [NSMutableDictionary dictionaryWithCapacity:1];
//        [p setObject:[NSString stringWithFormat:@"%@", reasonType] forKey:@"refundReason"];
//        [p setObject:[NSString stringWithFormat:@"%0.2f", refundAmount] forKey:@"refundAmount"];
//        [p setObject:[NSString stringWithFormat:@"%@", remark] forKey:@"remark"];
//        [p setObject:[NSString stringWithFormat:@"%@", orderId] forKey:@"orderNo"];
//        [p setObject:[NSString stringWithFormat:@"%lld", (long long)dataVN] forKey:@"dataVN"];
//
//        NSDictionary *parameters = [self mergeDictionWithDicone:API_ORDER_ALIPAY_REFUND AndDicTwo:p];
//        return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
//            success(responseObject);
//        } failure:^(NSURLSessionDataTask *task, NSString *error) {
//            failure(error);
//        }];
//    }
//    @catch (NSException *exception) {
//        failure(@"请求参数错误,请检查后重试!");
//    }
//    @finally {}
//
//}
//
//#pragma mark 确认收货
//- (NSURLSessionDataTask *)receiptWithOrderNo:(NSString *)orderId
//                                     success:(void (^)(id))success
//                                     failure:(void (^)(NSString *))failure
//{
//    @try {
//        if (!orderId || ![orderId length]) {
//            failure(@"请求参数错误,请检查后重试!");
//        }
//        NSMutableDictionary *p = [NSMutableDictionary dictionaryWithCapacity:1];
//        [p setObject:[NSString stringWithFormat:@"%@", orderId] forKey:@"orderNo"];
//
//        NSDictionary *parameters = [self mergeDictionWithDicone:API_ORDER_STATUS_RECEIPT AndDicTwo:p];
//        return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
//            success(responseObject);
//        } failure:^(NSURLSessionDataTask *task, NSString *error) {
//            failure(error);
//        }];
//    }
//    @catch (NSException *exception) {
//        failure(@"请求参数错误,请检查后重试!");
//    }
//    @finally {}
//}
//
//#pragma mark 确认发货
//- (NSURLSessionDataTask *)tosendWithOrderNo:(NSString *)orderId
//                                    success:(void (^)(id))success
//                                    failure:(void (^)(NSString *))failure
//{
//    @try {
//        if (!orderId || ![orderId length]) {
//            failure(@"请求参数错误,请检查后重试!");
//        }
//        NSMutableDictionary *p = [NSMutableDictionary dictionaryWithCapacity:1];
//        [p setObject:[NSString stringWithFormat:@"%@", orderId] forKey:@"orderNo"];
//
//        NSDictionary *parameters = [self mergeDictionWithDicone:API_ORDER_STATUS_TOSEND AndDicTwo:p];
//        return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
//            success(responseObject);
//        } failure:^(NSURLSessionDataTask *task, NSString *error) {
//            failure(error);
//        }];
//    }
//    @catch (NSException *exception) {
//        failure(@"请求参数错误,请检查后重试!");
//    }
//    @finally {}
//}
//
//#pragma mark 提醒卖家发货
//- (NSURLSessionDataTask *)remindBuyer:(NSString *)orderId
//                              success:(void (^)(id))success
//                              failure:(void (^)(NSString *))failure
//{
//    @try {
//        if (!orderId || ![orderId length]) {
//            failure(@"请求参数错误,请检查后重试!");
//        }
//        NSMutableDictionary *p = [NSMutableDictionary dictionaryWithCapacity:1];
//        [p setObject:[NSString stringWithFormat:@"%@", orderId] forKey:@"orderNo"];
//
//        NSDictionary *parameters = [self mergeDictionWithDicone:API_ORDER_REMIND AndDicTwo:p];
//        return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
//            success(responseObject);
//        } failure:^(NSURLSessionDataTask *task, NSString *error) {
//            failure(error);
//        }];
//    }
//    @catch (NSException *exception) {
//        failure(@"请求参数错误,请检查后重试!");
//    }
//    @finally {}
//}
//
//#pragma mark 投诉订单
//- (NSURLSessionDataTask *)complaintOrder:(NSString *)orderId
//                                 content:(NSString *)content
//                                 success:(void (^)(id))success
//                                 failure:(void (^)(NSString *))failure
//{
//    @try {
//        if (!orderId || ![orderId length]) {
//            failure(@"请求参数错误,请检查后重试!");
//        }
//        NSMutableDictionary *p = [NSMutableDictionary dictionaryWithCapacity:1];
//        [p setObject:[NSString stringWithFormat:@"%@", orderId] forKey:@"orderNo"];
//        [p setObject:[NSString stringWithFormat:@"%@", content] forKey:@"content"];
//
//        NSDictionary *parameters = [self mergeDictionWithDicone:API_ORDER_COMPLAINT AndDicTwo:p];
//        return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
//            success(responseObject);
//        } failure:^(NSURLSessionDataTask *task, NSString *error) {
//            failure(error);
//        }];
//    }
//    @catch (NSException *exception) {
//        failure(@"请求参数错误,请检查后重试!");
//    }
//    @finally {}
//}
//
//
//#pragma mark 评分
//- (NSURLSessionDataTask *)markscoreOrder:(NSString *)orderId
//                              fromUserId:(NSString *)fromUserId
//                                toUserId:(NSString *)toUserId
//                                   score:(NSString *)score
//content:(NSString *)content success:(void (^)(id))success failure:(void (^)(NSString *))failure
//{
//    @try {
//        if (!orderId || ![orderId length]) {
//            failure(@"请求参数错误,请检查后重试!");
//        }
//        NSMutableDictionary *p = [NSMutableDictionary dictionaryWithCapacity:1];
//        [p setObject:[NSString stringWithFormat:@"%@", orderId] forKey:@"orderNo"];
//        [p setObject:[NSString stringWithFormat:@"%@", fromUserId] forKey:@"fromUserId"];
//        [p setObject:[NSString stringWithFormat:@"%@", toUserId] forKey:@"toUserId"];
//        [p setObject:[NSString stringWithFormat:@"%@", score] forKey:@"score"];
//        [p setObject:[NSString stringWithFormat:@"%@", content] forKey:@"content"];
//
//        NSDictionary *parameters = [self mergeDictionWithDicone:API_ORDER_MARKSCORE AndDicTwo:p];
//        return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
//            success(responseObject);
//        } failure:^(NSURLSessionDataTask *task, NSString *error) {
//            failure(error);
//        }];
//    }
//    @catch (NSException *exception) {
//        failure(@"请求参数错误,请检查后重试!");
//    }
//    @finally {}
//}

- (NSURLSessionDataTask *)createOrderWith:(CreateOrderEnetity *)createOrder
                                  success:(void (^)(id))success
                                  failure:(void (^)(NSString *))failure
{
    @try {
        if (!createOrder) {
            failure(@"请求参数错误,请检查后重试!");
        }
        
        NSMutableDictionary *p = [NSMutableDictionary dictionaryWithCapacity:1];
        [p setObject:[NSString stringWithFormat:@"%lld", createOrder.userId] forKey:@"userId"];
        [p setObject:[NSString stringWithFormat:@"%lld", createOrder.applyUserId] forKey:@"applyUserId"];
        [p setObject:[NSString stringWithFormat:@"%@", createOrder.goodsImages] forKey:@"goodsImages"];
        [p setObject:[NSString stringWithFormat:@"%f", createOrder.totalAmount] forKey:@"totalAmount"];
        [p setObject:[NSString stringWithFormat:@"%f", createOrder.totalBailAmount] forKey:@"totalBailAmount"];
        [p setObject:[NSString stringWithFormat:@"%@", createOrder.depictRemark] forKey:@"depictRemark"];
        [p setObject:[NSString stringWithFormat:@"%d", createOrder.isLineTrade] forKey:@"isLineTrade"];
//        [p setObject:[NSString stringWithFormat:@"%@", createOrder.remark] forKey:@"remark"];
        
        NSDictionary *parameters = [self mergeDictionWithDicone:API_CREATE_ORDER AndDicTwo:p];
        return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            success(responseObject);
        } failure:^(NSURLSessionDataTask *task, NSString *error) {
            failure(error);
        }];
    }
    @catch (NSException *exception) {
        failure(@"请求参数错误,请检查后重试!");
    }
    @finally {}
}

#pragma mark 获取订单列表
- (NSURLSessionDataTask *)getOrderListWithUserId:(long long)userId
                                     CurrentPage:(NSInteger)currentPage
                                        pageSize:(NSInteger)pageSize
                                       limitTime:(long long)limitTime
                                         success:(void (^)(id))success
                                         failure:(void (^)(NSString *))failure
{
    @try {
        //配置请求字典
        NSMutableDictionary *tmpDic = [NSMutableDictionary dictionaryWithCapacity:1];
        [tmpDic setObject:[NSNumber numberWithLongLong:userId] forKey:@"userId"];
        [tmpDic setObject:[NSNumber numberWithInteger:currentPage] forKey:@"currentPage"];
        [tmpDic setObject:[NSNumber numberWithInteger:pageSize] forKey:@"pageSize"];
        
        NSDictionary *parameters = [self mergeDictionWithDicone:API_ORDER_LIST_WITH_UID AndDicTwo:tmpDic];
        return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            success(responseObject);
        } failure:^(NSURLSessionDataTask *task, NSString *error) {
            failure(error);
        }];
    }
    @catch (NSException *exception) {failure(@"请求参数错误,请检查后重试!");}
    @finally {}
}


- (NSURLSessionDataTask *)pingPlusCreateOrderWith:(NSString *)orderNo
                                       payChannel:(payMentPattern)payChannel
                                          success:(void (^)(id))success
                                          failure:(void (^)(NSString *))failure
{
    @try {
        NSMutableDictionary *tmpDic = [NSMutableDictionary dictionaryWithCapacity:1];
        [tmpDic setObject:[NSString stringWithFormat:@"%@", orderNo] forKey:@"orderNo"];
        
        if (payChannel == payMentPatternOfWeCaht) {
            [tmpDic setObject:@"wx" forKey:@"payChannel"];
        } else if (payChannel == payMentPatternOfAlipay) {
            [tmpDic setObject:@"alipay" forKey:@"payChannel"];
        } else if (payChannel == payMentPatternOfBank) {
            [tmpDic setObject:@"upacp" forKey:@"payChannel"];
        } else {
            failure(@"支付渠道错误!");
            return 0;
        }
        
        NSDictionary *parameters = [self mergeDictionWithDicone:API_PING_PLUS_CREATE_ORDER AndDicTwo:tmpDic];
        return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            success(responseObject);
        } failure:^(NSURLSessionDataTask *task, NSString *error) {
            failure(error);
        }];
    }
    @catch (NSException *exception) {failure(@"请求参数错误,请检查后重试!");}
    @finally {}
}

- (NSURLSessionDataTask *)getLogisticsListWithOrderNo:(NSString *)orderNo
                                              success:(void (^)(id))success
                                              failure:(void (^)(NSString *))failure
{
    @try {
        NSMutableDictionary *tmpDic = [NSMutableDictionary dictionaryWithCapacity:1];
        [tmpDic setObject:[NSString stringWithFormat:@"%@", orderNo] forKey:@"orderNo"];
        
        NSDictionary *parameters = [self mergeDictionWithDicone:API_LOGISTICS_LIST AndDicTwo:tmpDic];
        return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            success(responseObject);
        } failure:^(NSURLSessionDataTask *task, NSString *error) {
            failure(error);
        }];
    }
    @catch (NSException *exception) {failure(@"请求参数错误,请检查后重试!");}
    @finally {}
}

- (NSURLSessionDataTask *)getCompanylistSuccess:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    @try {
        return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:API_LOGISTICS_COMPANYLIST success:^(NSURLSessionDataTask *task, id responseObject) {
            success(responseObject);
        } failure:^(NSURLSessionDataTask *task, NSString *error) {
            failure(error);
        }];
    }
    @catch (NSException *exception) {failure(@"请求参数错误,请检查后重试!");}
    @finally {}
}

- (NSURLSessionDataTask *)editLogisticsListWithOrderNo:(NSString *)orderNo
                                       logisticsEntity:(LogisticsEntity *)logisticsEntity
                                               success:(void (^)(id))success
                                               failure:(void (^)(NSString *))failure
{
    @try {
        NSMutableDictionary *tmpDic = [NSMutableDictionary dictionaryWithCapacity:1];
        [tmpDic setObject:[NSString stringWithFormat:@"%@", orderNo] forKey:@"orderNo"];
        [tmpDic setObject:[NSString stringWithFormat:@"%@", logisticsEntity.company] forKey:@"company"];
        [tmpDic setObject:[NSString stringWithFormat:@"%@", logisticsEntity.invoiceNo] forKey:@"invoiceNo"];
        [tmpDic setObject:[NSString stringWithFormat:@"%@", logisticsEntity.content] forKey:@"content"];
        [tmpDic setObject:[NSString stringWithFormat:@"%@", logisticsEntity.code] forKey:@"code"];
        
        if (logisticsEntity.lid) {
            [tmpDic setObject:[NSString stringWithFormat:@"%lld", logisticsEntity.lid] forKey:@"logisticsId"];
        }
        
        NSDictionary *parameters = [self mergeDictionWithDicone:API_LOGISTICS_SAVE AndDicTwo:tmpDic];
        return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            success(responseObject);
        } failure:^(NSURLSessionDataTask *task, NSString *error) {
            failure(error);
        }];
    }
    @catch (NSException *exception) {failure(@"请求参数错误,请检查后重试!");}
    @finally {}
}

- (NSURLSessionDataTask *)addAddressWithOrderNo:(NSString *)orderNo address:(AddressEntity *)address success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    @try {
        NSMutableDictionary *tmpDic = [NSMutableDictionary dictionaryWithCapacity:1];
        [tmpDic setObject:[NSString stringWithFormat:@"%@", orderNo] forKey:@"orderNo"];
        [tmpDic setObject:[NSString stringWithFormat:@"%@", address.realName] forKey:@"realName"];
        [tmpDic setObject:[NSString stringWithFormat:@"%@", address.phone] forKey:@"phone"];
        [tmpDic setObject:[NSString stringWithFormat:@"%@", address.address] forKey:@"address"];
        
        NSDictionary *parameters = [self mergeDictionWithDicone:API_UPDATE_ORDER_ADDRESS AndDicTwo:tmpDic];
        return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            success(responseObject);
        } failure:^(NSURLSessionDataTask *task, NSString *error) {
            failure(error);
        }];
    }
    @catch (NSException *exception) {failure(@"请求参数错误,请检查后重试!");}
    @finally {}
}

- (NSURLSessionDataTask *)changeOrderStatusWithOrderNo:(NSString *)orderNo orderStates:(orderStatusType)status success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    
    @try {
        NSMutableDictionary *tmpDic = [NSMutableDictionary dictionaryWithCapacity:1];
        [tmpDic setObject:[NSString stringWithFormat:@"%@", orderNo] forKey:@"orderNo"];
        [tmpDic setObject:[NSNumber numberWithInt:status] forKey:@"orderStatus"];
        NSDictionary *parameters;
        //处理一下请求方法
        
        //退款
        if(status == orderStatusOfisPaymentFull ){
            //设置已付全款
            
        }else if (status == orderStatusOfClose){ //关闭订单
            parameters = [self mergeDictionWithDicone:API_ORDER_CLOSE AndDicTwo:tmpDic];
        }
        
        return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            success(responseObject);
        } failure:^(NSURLSessionDataTask *task, NSString *error) {
            failure(error);
        }];
    }
    @catch (NSException *exception) {
        failure(@"请求参数错误,请检查后重试!");
    }
    @finally {
        
    }
    
}

- (NSURLSessionDataTask *)closeOrderWithWithOrderNo:(NSString *)orderNo success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    return [self changeOrderStatusWithOrderNo:orderNo orderStates:(orderStatusOfClose) success:^(id responseObject) {
        
        success(responseObject);
        
    } failure:^(NSString *error) {
        failure(error);
    }];
}

- (NSURLSessionDataTask *)refundWithOrderNo:(NSString *)orderNO reason:(NSString *)reason remark:(NSString *)remark success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    @try {
        NSMutableDictionary *tmpDic = [NSMutableDictionary dictionaryWithCapacity:1];
        [tmpDic setObject:orderNO forKey:@"orderNo"];
        [tmpDic setObject:[NSNumber numberWithInt:orderStatusOfRefunding] forKey:@"orderStatus"];
        if (!reason) {
            reason = @"没有原因-iOS";
        }
        if (!remark){
            remark = @"没有描述-iOS";
        }
        [tmpDic setObject:reason forKey:@"reason"];
        [tmpDic setObject:remark forKey:@"remark"];
        NSDictionary *parameters;
        //退款
            parameters = [self mergeDictionWithDicone:API_ORDER_REFUND AndDicTwo:tmpDic];

        
        return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            success(responseObject);
        } failure:^(NSURLSessionDataTask *task, NSString *error) {
            failure(error);
        }];
    }
    @catch (NSException *exception) {
        failure(@"请求参数错误,请检查后重试!");
    }
    @finally {
        
    }
}

#pragma mark logic层统一管理协议方法
- (void)load{}
- (void)loadUserData{}
- (void)save{}
- (void)reset{}
- (void)enterBackgroundMode{}
- (void)enterForeground{}
- (void)doLoginSuccessfulLogic{}
- (void)doLogoutLogic
{
    [NSUSER_DEFAULT setObj:@"0" forKey:@"orderUnReadNum"];
}
- (void)disconnectNet{}


@end
