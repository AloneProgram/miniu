//
//  CommentManager.h
//  DLDQ_IOS
//
//  Created by simman on 14-9-4.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CommentEntity,GoodsEntity;

@interface CommentManager : ManagerBase <LogicBaseModel>

/**
 *  对象单例
 *
 *  @return
 */
+ (instancetype)shareInstance;

/*
 fromUserId,toUserId,goodsId,content,status
 
 其中status:表示评论或回复标识（1：评论，2：回复）
 */

/**
 *  发布商品评论
 *
 *  @param commentEntity 评论实体
 *  @param success       成功回调
 *  @param failure       失败回调
 *
 *  @return 网络标识
 */
- (NSURLSessionDataTask *)postGoodsCommentWithcommentEntity:(CommentEntity *)commentEntity
                                                    success:(void (^)(id responseObject))success
                                                    failure:(void (^)(NSString *error))failure;

@end
