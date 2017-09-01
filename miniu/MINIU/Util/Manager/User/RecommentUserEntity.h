//
//  RecommentUserEntity.h
//  DLDQ_IOS
//
//  Created by simman on 14-9-16.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import "BaseModel.h"

@class UserEntity;

@interface RecommentUserEntity : BaseModel

@property (nonatomic, assign) NSInteger channelId;
@property (nonatomic, strong) NSString *channelName;
@property (nonatomic, strong) NSMutableArray *userArray;

@end
