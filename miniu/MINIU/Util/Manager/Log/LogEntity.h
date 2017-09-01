//
//  LogEntity.h
//  DLDQ_IOS
//
//  Created by simman on 14-9-23.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 *  消息类型
 */
typedef NS_ENUM(NSInteger, LogType) {
    /**
     *  粉丝
     */
    LogTypeOfFans = 101,
    /**
     *  评论
     */
    LogTypeOfComment,
    /**
     *  喜欢（原收藏）
     */
    LogTypeOfCollect,
    
    /**
     *  赞
     */
    LogTypeOfZan,
    
    /**
     *  愿望清单
     */
    LogTypeOfYWQD,
    
    /**
     *  @brief  申请代购
     */
    LogTypeOfApplyOrder = 314
};

@interface LogEntity : RLMObject

@property (nonatomic, assign) long long  noticeId;
@property (nonatomic, assign) LogType    logType;
@property (nonatomic, assign) long long  timeStamp;        // 时间
@property (nonatomic, assign) long long  fromUserId;
@property (nonatomic, strong) NSString   *hxUId;
@property (nonatomic, copy  ) NSString   *avatar;
@property (nonatomic, copy  ) NSString   *nickName;
@property (nonatomic, assign) long long  goodsId;
@property (nonatomic, copy  ) NSString   *goodsImg;
@property (nonatomic, copy  ) NSString   *content;
@property (nonatomic, assign) NSInteger  isRead;        // 默认为0

@property (nonatomic, assign) long long createUserId;

@end
