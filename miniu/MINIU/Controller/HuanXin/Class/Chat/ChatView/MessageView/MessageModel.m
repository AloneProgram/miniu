/************************************************************
  *  * EaseMob CONFIDENTIAL 
  * __________________ 
  * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved. 
  *  
  * NOTICE: All information contained herein is, and remains 
  * the property of EaseMob Technologies.
  * Dissemination of this information or reproduction of this material 
  * is strictly forbidden unless prior written permission is obtained
  * from EaseMob Technologies.
  */

#import "MessageModel.h"

@implementation MessageModel

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        self.userId = 0;
        //code
        
        self.goodsId = @"";
        self.goodsPrice = @"";
        self.goodsDescription = @"";
        self.goodsFirstImageURL = @"";
        
        self.extMessageType = 0;
        self.OrderId = @"";
    }
    
    return self;
}

- (void)setExtMessageTypeWithString:(NSString *)type
{
    NSInteger mType = [type integerValue];

    if (!mType) {
        return;
    }
    
    if (mType == 100011) {
        self.extMessageType = extMessageType_Order;
    } else if (mType == 100012) {
        self.extMessageType = extMessageType_Order_Address;
    } else if (mType == 100013) {
        self.extMessageType = extMessageType_Order_Logistics;
    } else if (mType == 100014) {
        self.extMessageType = extMessageType_Order_Refund;
    }
}

- (extMessageType)extMessageType
{
    if (_extMessageType == 0) {
        if (_message.ext && [_message.ext isKindOfClass:[NSDictionary class]]) {
            [self setExtMessageTypeWithString:_message.ext[@"mType"]];
        }
    }
    return _extMessageType;
}


- (void)setMessage:(EMMessage *)message
{
    _message = message;
 
    if (!message.ext || ![message.ext isKindOfClass:[NSDictionary class]]) {
        return;
    }
    
    if ([message.ext keyIsExits:@"mType"] && [message.ext keyIsExits:@"mBody"]) {
        
        // 订单、物流、地址
        NSInteger mType = [message.ext[@"mType"] integerValue];
        if (mType == 100011 || mType == 100012 || mType == 100013 || mType == 100014) {
            self.order = [[OrderEntity alloc] initWithBase64String:message.ext[@"mBody"]];
        }
    }
}


- (void)dealloc{
    
}

@end
