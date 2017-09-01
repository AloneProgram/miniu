//
//  RegisterUserEntity.h
//  DLDQ_IOS
//
//  Created by simman on 14-8-29.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseModel.h"
@interface RegisterUserEntity : BaseModel

@property (nonatomic, assign) NSInteger countryCode;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *smsCode;

@end
