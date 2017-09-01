//
//  MessageManager.m
//  DLDQ_IOS
//
//  Created by simman on 15/3/4.
//  Copyright (c) 2015年 Liwei. All rights reserved.
//

#import "MessageManager.h"

#define EXT_MESSAGE_TABLE @"ext_message"
#define REPLAY_TIME   3   // 重发天数

@implementation MessageManager

+ (instancetype)shareInstance
{
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (void)insertExtMessageWithItemId:(NSString *)itemId
                       messageType:(extMessageType)messageType
                        receiveUid:(NSString *)uid
{
    long long currentUserId = [CURRENT_USER_INSTANCE getCurrentUserID] ? [CURRENT_USER_INSTANCE getCurrentUserID] : 0;
    
    if (!currentUserId) {
        return;
    }
    
    // 封装数据
    NSMutableDictionary *dataDic = [NSMutableDictionary dictionaryWithCapacity:1];
    [dataDic setObject:[NSString stringWithFormat:@"%lld", currentUserId] forKey:@"send_uid"];
    
    if (messageType == extMessageType_Goods) {
        [dataDic setObject:[NSString stringWithFormat:@"%@", itemId] forKey:@"goods_id"];
    } else if (messageType == extMessageType_Order) {
        [dataDic setObject:[NSString stringWithFormat:@"%@", itemId] forKey:@"order_id"];
    }

    [dataDic setObject:[NSString stringWithFormat:@"%d", (int)messageType] forKey:@"ext_message_type"];
    [dataDic setObject:[NSString stringWithFormat:@"%@", uid] forKey:@"recive_uid"];
    [dataDic setObject:[NSString timeStamp] forKey:@"create_time"];
    
    if (!dataDic) return;
//    [[logicShareInstance getDataBaseManager] saveWithTable:EXT_MESSAGE_TABLE where:nil data:dataDic whereType:AND ConstraintType:REPLACE result:^(BOOL success) {}];
    NSLog(@"插入一条 ext 消息记录");
}

- (BOOL)isSendedExtMessageWithItemId:(NSString *)itemId
                          replayTime:(NSInteger)retime
                         messageType:(extMessageType)messageType
                          receiveUid:(NSString *)uid
{
    
    long long currentUserId = [CURRENT_USER_INSTANCE getCurrentUserID] ? [CURRENT_USER_INSTANCE getCurrentUserID] : 0;
    
    NSMutableDictionary *whereDic = [NSMutableDictionary dictionaryWithCapacity:1];
    [whereDic setObject:[NSString stringWithFormat:@"%lld", currentUserId] forKey:@"send_uid"];
    [whereDic setObject:[NSString stringWithFormat:@"%@", uid] forKey:@"recive_uid"];
    [whereDic setObject:[NSString stringWithFormat:@"%d", (int)messageType] forKey:@"ext_message_type"];
    
    if (messageType == extMessageType_Goods) {
        [whereDic setObject:[NSString stringWithFormat:@"%@", itemId] forKey:@"goods_id"];
    } else if (messageType == extMessageType_Order) {
        [whereDic setObject:[NSString stringWithFormat:@"%@", itemId] forKey:@"order_id"];
    }
    
    __block BOOL isSended = NO;
//    [[logicShareInstance getDataBaseManager] findAllWithTable:EXT_MESSAGE_TABLE where:whereDic whereType:AND result:^(FMResultSet *set) {
//        
//        while ([set next]) {
//            NSString *create_time = [set stringForColumn:@"create_time"];
//            NSString *current_time = [NSString timeStamp];
//            NSInteger ret = 86400000 * (retime ? retime : REPLAY_TIME);
//            if ([current_time longLongValue] - [create_time longLongValue] > ret) {
//                isSended = NO;
//            } else {
//                isSended = YES;
//            }
//        }
//    }];
    return isSended;
}

- (void)deleteExtMessageWithMIds:(NSArray *)ids
                      receiveUid:(NSString *)uid
{
    
    NSMutableDictionary *whereDic = [NSMutableDictionary dictionaryWithCapacity:1];
    
    for (NSString *mid in ids) {
        [whereDic setObject:[NSString stringWithFormat:@"%@", mid] forKey:@"hxmid"];
    }
    
//    [[logicShareInstance getDataBaseManager] deleteWithTable:EXT_MESSAGE_TABLE where:whereDic whereType:OR result:^(BOOL success) {
//        
//    }];
}

- (void) deleteExtMessageWithReceiveUid:(NSString *)uid
{
    long long currentUserId = [CURRENT_USER_INSTANCE getCurrentUserID] ? [CURRENT_USER_INSTANCE getCurrentUserID] : 0;
    
    NSMutableDictionary *whereDic = [NSMutableDictionary dictionaryWithCapacity:1];
    [whereDic setObject:[NSString stringWithFormat:@"%lld", currentUserId] forKey:@"send_uid"];
    [whereDic setObject:[NSString stringWithFormat:@"%@", uid] forKey:@"recive_uid"];
    
    NSMutableDictionary *whereDic1 = [NSMutableDictionary dictionaryWithCapacity:1];
    [whereDic1 setObject:[NSString stringWithFormat:@"%@", uid] forKey:@"send_uid"];
    [whereDic1 setObject:[NSString stringWithFormat:@"%lld", currentUserId] forKey:@"recive_uid"];
    
//    
//    [[logicShareInstance getDataBaseManager] deleteWithTable:EXT_MESSAGE_TABLE where:whereDic whereType:OR result:^(BOOL success) {
//        
//    }];
//    
//    
//    [[logicShareInstance getDataBaseManager] deleteWithTable:EXT_MESSAGE_TABLE where:whereDic1 whereType:OR result:^(BOOL success) {
//        
//    }];
}

- (BOOL)isEnableSendGoodsWithMessage
{
    BOOL isEnable = NO;
//    isEnable = [[NSUSER_DEFAULT objForKey:@"isEnableSendGoodsWithMessage"] boolValue];
    return isEnable;
}

- (void) checkIsEnableSendGoodsWithMessage
{
//    [NET_WORK_HANDLE HttpRequestWithUrlString:@"http://demo.simman.cc/dldq/openSendGoosMessage.php" RequestType:GET parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
//        
////        if ([[responseObject objectForKey:@"isOpenSendGoods"] boolValue]) {
////            [NSUSER_DEFAULT setObj:[NSNumber numberWithBool:YES] forKey:@"isEnableSendGoodsWithMessage"];
////        } else {
////            [NSUSER_DEFAULT setObj:[NSNumber numberWithBool:NO] forKey:@"isEnableSendGoodsWithMessage"];
////        }
//        
//    } failure:^(NSURLSessionDataTask *task, NSString *error) {} autoRetry:0 retryInterval:0];
}

#pragma mark logic层统一管理协议方法
- (void)load{}
- (void)loadUserData
{
    [self checkIsEnableSendGoodsWithMessage];
}
- (void)save{}
- (void)reset{}
- (void)enterBackgroundMode{}
- (void)enterForeground{}
- (void)doLoginSuccessfulLogic{}
- (void)doLogoutLogic{}
- (void)disconnectNet{}

@end
