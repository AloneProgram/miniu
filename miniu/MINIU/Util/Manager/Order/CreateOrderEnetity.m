//
//  CreateOrderEnetity.m
//  miniu
//
//  Created by SimMan on 15/6/2.
//  Copyright (c) 2015年 SimMan. All rights reserved.
//

#import "CreateOrderEnetity.h"

@implementation CreateOrderEnetity

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.userId = 0;
        self.applyUserId = 0;
        self.goodsImages = @"";
        self.totalAmount = 0.0f;
        self.totalBailAmount = 0.0f;
        self.depictRemark = @"";
        self.isLineTrade = 0;
//        
//        self.assetsArray = [NSMutableArray new];
//        self.alassetArray = [NSMutableArray new];
    }
    return self;
}

- (long long)applyUserId
{
    return _applyUserId;
}

- (long long)userId
{
    return USER_IS_LOGIN;
}

@end
