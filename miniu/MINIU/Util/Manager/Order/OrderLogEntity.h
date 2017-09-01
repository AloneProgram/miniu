//
//  OrderLogEntity.h
//  DLDQ_IOS
//
//  Created by simman on 11/22/14.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import "BaseModel.h"

@interface OrderLogEntity : BaseModel

@property (nonatomic, strong) NSString *applyUserId;
@property (nonatomic, assign) double bailAmount;
@property (nonatomic, assign) double balanceAmount;
@property (nonatomic, strong) NSString *cashRemark;
@property (nonatomic, assign) long long createTime;
@property (nonatomic, assign) double fullAmount;
@property (nonatomic, strong) NSString *nickName;
@property (nonatomic, assign) NSInteger optType;
@property (nonatomic, strong) NSString *orderNo;
@property (nonatomic, strong) NSString *remark;
@property (nonatomic, strong) NSString *userCode;
@property (nonatomic, assign) long long userId;

@end
