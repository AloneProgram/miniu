//
//  AddressEntity.h
//  DLDQ_IOS
//
//  Created by simman on 14-9-2.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import "BaseModel.h"

@interface AddressEntity : BaseModel

@property (nonatomic, assign) long long addressId;  // 地址ID
@property (nonatomic, assign) long long userId;     // 用户ID
@property (nonatomic, strong) NSString *realName;   // 姓名
@property (nonatomic, strong) NSString *phone;      // 电话
@property (nonatomic, strong) NSString *address;    // 地址
@property (nonatomic, assign) long long createTime; //创建时间
@property (nonatomic, assign) NSInteger isDefault;  // 是否为默认

@end
