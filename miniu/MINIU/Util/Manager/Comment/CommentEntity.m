//
//  CommentEntity.m
//  DLDQ_IOS
//
//  Created by simman on 14-9-4.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import "CommentEntity.h"

@implementation CommentEntity

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.commentsId = 0;
        self.content = @"";
        self.goodsId = 0;
        self.createTime = [[[NSDate alloc] init] timeIntervalSince1970InMilliSecond];;
        self.status = 0;
        self.fromUserId = 0;
        self.fromUserNickName = @"";
        self.fromUserAvatar = @"";
        self.fromUserRoleType = 0;
        self.toUserId = 0;
        self.toUserNickName = @"";
        self.toUserAvatar = @"";
    }
    return self;
}

- (void) setValue:(id)value forUndefinedKey:(NSString *)key{}

@end
