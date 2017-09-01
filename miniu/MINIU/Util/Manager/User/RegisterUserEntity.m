//
//  RegisterUserEntity.m
//  DLDQ_IOS
//
//  Created by simman on 14-8-29.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import "RegisterUserEntity.h"

@implementation RegisterUserEntity

- (instancetype) init
{
    self = [super init];
    if (self) {
        self.countryCode = 0;
        self.phone       = @"";
        self.password    = @"";
        self.smsCode     = @"";
    }
    return self;
}

- (void)setPassword:(NSString *)password
{
    if ([_password isEqualToString:password]) {
        return;
    }
    _password = [password MD5Hash];
}

@end
