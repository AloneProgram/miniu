//
//  OrderEntity.m
//  DLDQ_IOS
//
//  Created by simman on 14-9-13.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import "OrderEntity.h"
#import "OrderLogEntity.h"
#import "LogisticsEntity.h"
#import "GoodsEntity.h"
@implementation OrderEntity

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.orderNo = @"";
        self.goodsId = 0;
        self.firstImageUrl = @"";
        self.orderDescription = @"";
        self.depictRemark = @"";
        self.price = @0;
        self.orderNum = 0;
        self.orderStatus = 0;
        self.totalBailAmount = 0;
        self.totalAmount = 0;
        self.phone = @"";
        self.consignee = @"";
        self.address = @"";
        self.leaveMessage = @"";
        self.applyUserId = 0;
        self.buyerUserId = 0;
        self.createTime = 0;
        self.applyUserCode = @"";
        self.applyNickName = @"";
        self.applyRoleType = @"";
        self.applyAvatar = @"";
        self.buyerUserCode = @"";
        self.buyerNickName = @"";
        self.buyerRoleType = @"";
        self.buyerAvatar = @"";
        self.applyTimeStamp = 0;
        self.payTimeStamp = 0;
        self.shippingTimeStamp = 0;
        self.confirmTimeStamp = 0;
        self.refundTimeStamp = 0;
        self.totalBalanceAmount = 0;
//        self.applyhxUId = @"";
//        self.buyerhxUId = @"";
        self.applyHxUId = @"";
        self.buyerHxUId = @"";
        self.totalRefundAmount = 0.0;
        self.totalHasPaidAmount = 0.0;
        self.payable = 0;
        self.isMarkScored = NO;
        self.isComplained = NO;
        self.dataVN     =  0;
        self.orderType = 1;
        self.LogisticsArray = [NSMutableArray new];
        self.logArray = [NSMutableArray arrayWithCapacity:1];
    }
    return self;
}

- (instancetype)initWithOrderNo:(NSString *)orderNo
{
    self = [self init];
    if (self) {
        self.orderNo = orderNo;
    }
    return self;
}

- (void) setValue:(id)value forUndefinedKey:(NSString *)key
{
//    if ( [key isEqualToString:@"description"]) {
//        self.orderDescription = value;
//    }

//    NSLog(@"orderEntity nudefinedkey %@", key);
    
    if ([key isEqualToString:@"cashLogList"]) {
        for (NSDictionary *dic in value) {
            OrderLogEntity *orderLog = [[OrderLogEntity alloc] init];
            [orderLog setValuesForKeysWithDictionary:dic];
            [self.logArray addObject:orderLog];
        }
    }
    
    if ([key isEqualToString:@"logisticsList"]) {
        
        for (NSDictionary *dic in value) {
            LogisticsEntity *logisitics = [LogisticsEntity new];
            [logisitics setValuesForKeysWithDictionary:dic];
            [self.LogisticsArray addObject:logisitics];
        }
    }
}

- (void) setNilValueForKey:(NSString *)key{};


- (NSString *) getAllOrderLogString
{
    NSMutableString *string = [NSMutableString stringWithString:@""];
    int i = 0;
    for (OrderLogEntity *log in self.logArray) {
        if (i == 0) {
            [string appendString:@"修改记录：\n"];
        }
        [string appendFormat:@"%@\n", log.cashRemark];
        
        i ++;
    }
    
    return string;
}


+ (NSString *) getOrderStatusStringWith:(orderStatusType)type
{
    NSString *string = nil;
    switch (type) {
        case orderStatusOfWaitPayment:
            string = @"等待买家付款";
            break;
        case orderStatusOfisPaymentWaitBalance:
            string = @"已付订金,待付尾款";
            break;
        case orderStatusOfisPaymentFull:
            string = @"已付全款,等待发货";
            break;
#warning 注销提示 订单右下角
        case orderStatusOfisDeliver:
            string = @"卖家已经发货";
            break;
        case orderStatusOfisFinish:
            string = @"订单已完成";
            break;
        case orderStatusOfRefund:
            string = @"退款成功";
            break;
        case orderStatusOfClose:
            string = @"订单关闭";
            break;
        case orderStatusOfRefunding:
            string = @"正在退款中";
            break;
        case orderStatusOfRefundComfirm:
            string = @"正在退款中";
            break;
        case 9:
            string = @"正在退款中";
            break;
        default:
            string = @"";
            break;
    }
    return string;
}

- (instancetype)initWithBase64String:(NSString *)base64String
{
    // Base64 解码
    NSString *jsonStr = [NSString stringFromBase64String:base64String];
    
    // 转NSData
    NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];

    NSError *dicError = nil;
    
    // 如果为垃圾数据
    if (!jsonData) {
        return [super init];
    }
    
    // 转字典
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&dicError];
    
    if (!dic || dicError) {
        return [super init];
    }
    
    NSLog(@"dic = %@", dic);

    self = [super init];    
    [self setValuesForKeysWithDictionary:dic[@"OrderInfo"]];
    return self;
}

- (GoodsEntity *)transferToGoodsEntity
{
    GoodsEntity *ge = [[GoodsEntity alloc]initWithGoodsId:nil];
    ge.position = @"";
    ge.goodsImagesCount = self.goodsImagesCount;
    ge.goodsDescription = self.orderDescription;
    ge.depictRemark = self.depictRemark;
//    NSLog(@"%@",)
    return ge;
}

@end
