//
//  OrderLogEntity.m
//  DLDQ_IOS
//
//  Created by simman on 11/22/14.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import "OrderLogEntity.h"

@implementation OrderLogEntity


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.applyUserId = @"";
        self.cashRemark = @"";
        self.bailAmount = 0;
        self.balanceAmount = 0;
        self.createTime = 0;
        self.fullAmount = 0;
        self.nickName = @"";
        self.optType = 0;
        self.orderNo = @"";
        self.remark = @"";
        self.userCode = @"";
        self.userId = 0;
    }
    return self;
}

@end
