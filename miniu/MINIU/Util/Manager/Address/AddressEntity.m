//
//  AddressEntity.m
//  DLDQ_IOS
//
//  Created by simman on 14-9-2.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import "AddressEntity.h"

@implementation AddressEntity

- (instancetype) init
{
    self = [super init];
    if (self) {
        self.addressId = 0;
        self.userId = [[logicShareInstance getUserManager] getCurrentUserID];
        //NSLog(@"userId->%lld",self.userId);
        self.realName = @"";
        self.phone = @"";
        self.address = @"";
        self.createTime = 0;
        self.isDefault = 0;
    }
    return self;
}

- (void) setValue:(id)value forUndefinedKey:(NSString *)key
{
    if ([key isEqualToString:@"id"]) {
        self.addressId = [value integerValue];
    }
}

- (void) setNilValueForKey:(NSString *)key{};


@end
