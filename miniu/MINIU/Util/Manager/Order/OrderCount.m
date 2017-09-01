//
//  OrderCount.m
//  DLDQ_IOS
//
//  Created by simman on 14/10/30.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import "OrderCount.h"

@implementation OrderCount

- (instancetype) init
{
    self = [super init];
    if (self) {
        self.userId = 0;
        self.orderCount = 0;
        self.noPaidCount = 0;
        self.partPaidCount = 0;
        self.noSendCount = 0;
        self.hasSentCount = 0;
        self.finishedCount = 0;
        self.hasRefundCount = 0;
        self.closedCount = 0;
        self.noRefundCount = 0;
    }
    return self;
}

@end
