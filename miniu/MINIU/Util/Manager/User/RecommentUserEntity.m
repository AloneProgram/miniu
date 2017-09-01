//
//  RecommentUserEntity.m
//  DLDQ_IOS
//
//  Created by simman on 14-9-16.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import "RecommentUserEntity.h"
#import "UserEntity.h"

@implementation RecommentUserEntity


- (id)init
{
    self = [super init];
    if (self) {
        self.channelId = 0;
        self.channelName = @"";
        self.userArray = [NSMutableArray arrayWithCapacity:1];
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    if ([key isEqualToString:@"userList"]) {
        for (NSDictionary *dic in value) {
            UserEntity *user =[[UserEntity alloc] init];
            @try {
                [user setValuesForKeysWithDictionary:dic];
                [self.userArray addObject:user];
            }
            @catch (NSException *exception) {}
            @finally {}
        }
    }
}

@end
