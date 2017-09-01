//
//  MessageManager.h
//  DLDQ_IOS
//
//  Created by simman on 15/3/4.
//  Copyright (c) 2015年 Liwei. All rights reserved.
//

#import "ManagerBase.h"

/**
 *  扩展消息类型
 */
typedef NS_ENUM(NSInteger, extMessageType){
    /**
     *  商品
     */
    extMessageType_Goods = 1,
    /**
     *  订单
     */
    extMessageType_Order,
    
    /**
     *  @brief  订单地址改变
     */
    extMessageType_Order_Address,
    
    /**
     *  @brief  物流改变
     */
    extMessageType_Order_Logistics,
    
    /**
     *  @brief  退款成功
     */
    extMessageType_Order_Refund,
    /**
     *  @brief  图文消息
     */
    extMessageType_ImageText
};


@interface MessageManager : ManagerBase <LogicBaseModel>

+ (instancetype)shareInstance;

/**
 *  插入一条数据
 *
 *  @param itemId
 *  @param uid     接收人
 */
- (void) insertExtMessageWithItemId:(NSString *)itemId
                        messageType:(extMessageType)messageType
                         receiveUid:(NSString *)uid;


// ext_message_type

/**
 *  查询是否已经发送过消息
 *
 *  @param itemId
 *  @param replayTime  如果上次发送大于N天，则返回 false,默认为 3天
 *  @param uid     接收人的 UID
 *
 *  @return 是否
 */
- (BOOL) isSendedExtMessageWithItemId:(NSString *)itemId
                              replayTime:(NSInteger)retime
                             messageType:(extMessageType)messageType
                              receiveUid:(NSString *)uid;

/**
 *  @brief  删除一条或多条记录
 *
 *  @param ids ids
 *  @param uid 接收人ID
 */
- (void) deleteExtMessageWithMIds:(NSArray *)ids
                          receiveUid:(NSString *)uid;


/**
 *  @brief  删除消息
 *
 *  @param uid 
 */
- (void) deleteExtMessageWithReceiveUid:(NSString *)uid;


/**
 *  @brief  是否开启发送商品
 */
- (BOOL) isEnableSendGoodsWithMessage;

@end
