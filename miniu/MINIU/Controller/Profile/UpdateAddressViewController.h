//
//  UpdateAddressViewController.h
//  miniu
//
//  Created by SimMan on 15/6/2.
//  Copyright (c) 2015年 SimMan. All rights reserved.
//

#import "BaseViewController.h"
@class AddressEntity;
@class OrderEntity;
@interface UpdateAddressViewController : BaseViewController

@property (nonatomic, strong) AddressEntity *address;

@property (nonatomic, assign) long long createUserId; // 如果存在，则为买手创建的。

@property (nonatomic, strong) OrderEntity *orderEntity;
@end
