//
//  CreateOrderEnetity.h
//  miniu
//
//  Created by SimMan on 15/6/2.
//  Copyright (c) 2015年 SimMan. All rights reserved.
//

#import "BaseModel.h"

@class JKAssets,ALAsset;

@interface CreateOrderEnetity : RLMObject

@property (nonatomic, assign) long long userId;         // 当前用户
@property (nonatomic, assign) long long applyUserId;    // 申请人的ID
@property (nonatomic, strong) NSString *goodsImages;    // 图片地址
@property (nonatomic, assign) double totalAmount;       // 订单总金额
@property (nonatomic, assign) double totalBailAmount;   // 定金
@property (nonatomic, strong) NSString *depictRemark;   // 描述

//@property (nonatomic, strong) NSString *remark;         //备注
@property (nonatomic, assign) int isLineTrade;


//@property (nonatomic, strong) RLMArray<NSObject> *assetsArray;
//@property (nonatomic, strong) RLMArray<NSObject> *alassetArray;

@end
