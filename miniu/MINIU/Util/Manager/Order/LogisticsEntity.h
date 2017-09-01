//
//  LogisticsEntity.h
//  miniu
//
//  Created by SimMan on 15/6/8.
//  Copyright (c) 2015年 SimMan. All rights reserved.
//

#import "BaseModel.h"

@interface LogisticsEntity : BaseModel

@property (nonatomic, strong) NSString *company;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *invoiceNo;//发票号码?
@property (nonatomic, strong) NSString *orderNo;
@property (nonatomic, strong) NSString *code;

@property (nonatomic, assign) long long createTime;
@property (nonatomic, assign) long long lid;
@property (nonatomic, assign) long long userId;


@end
