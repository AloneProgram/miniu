//
//  LogEntity.m
//  DLDQ_IOS
//
//  Created by simman on 14-9-23.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import "LogEntity.h"

@implementation LogEntity


- (id)init
{
    self = [super init];
    if (self) {
        self.noticeId = 0;
        self.logType = 0;
        self.timeStamp = [[NSString timeStamp] integerValue] * 1000;//timeIntervalSince1970InMilliSecond
        self.fromUserId = 0;
        self.avatar = @"http://dldqcdn.b0.upaiyun.com/Avatar/Default/avatar.png";
        self.nickName = @"匿名用户";
        self.goodsId = 0;
        self.goodsImg = @"";
        self.content = @"0";
        self.isRead = 0;
        self.hxUId = @"";
    }
    return self;
}

#pragma mark 设置主键
+ (NSString *)primaryKey
{
    return @"noticeId";
}

+(NSArray *)indexedProperties
{
    return @[@"createUserId"];
}

- (long long)createUserId
{
    return USER_IS_LOGIN;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    if ([key isEqualToString:@"noticeType"]) {
        self.logType = [value integerValue];
    }
}

- (void) setNilValueForKey:(NSString *)key{};
- (void) setValue:(id)value forKey:(NSString *)key
{
    @try {
        [super setValue:value forKey:key];
    }
    @catch (NSException *exception) {
        NSLog(@"当前 model 发生错误，error：key = %@, value = %@", key, value);
    }
    @finally {}
}


@end
