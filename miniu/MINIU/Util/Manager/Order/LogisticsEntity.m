//
//  LogisticsEntity.m
//  miniu
//
//  Created by SimMan on 15/6/8.
//  Copyright (c) 2015年 SimMan. All rights reserved.
//

#import "LogisticsEntity.h"

@implementation LogisticsEntity

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.company = @"";
        self.content = @"";
        self.invoiceNo = @"";
        self.orderNo = @"";
        self.code = @"";
        
        self.createTime = 0;
        self.lid = 0;
        self.userId = 0;
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    if ([key isEqualToString:@"id"]) {
        self.lid = [value longLongValue];
    }
}


@end
