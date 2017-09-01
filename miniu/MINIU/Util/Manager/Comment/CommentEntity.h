//
//  CommentEntity.h
//  DLDQ_IOS
//
//  Created by simman on 14-9-4.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseModel.h"
@interface CommentEntity : BaseModel

@property (nonatomic, assign) long long commentsId;
@property (nonatomic, strong) NSString  *content;
@property (nonatomic, assign) long long goodsId;
@property (nonatomic, assign) long long createTime;
@property (nonatomic, assign) NSInteger status;// 1：评论  2：回复


@property (nonatomic, assign) long long fromUserId;
@property (nonatomic, strong) NSString  *fromUserAvatar;
@property (nonatomic, strong) NSString  *fromUserNickName;
@property (nonatomic, assign) NSInteger fromUserRoleType;

@property (nonatomic, assign) long long toUserId;
@property (nonatomic, strong) NSString  *toUserAvatar;
@property (nonatomic, strong) NSString  *toUserNickName;

@end
