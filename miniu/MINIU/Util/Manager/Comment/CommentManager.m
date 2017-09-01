

//
//  CommentManager.m
//  DLDQ_IOS
//
//  Created by simman on 14-9-4.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import "CommentManager.h"
#import "GoodsEntity.h"
#import "CommentEntity.h"

#define API_GOODS_ADD_COMMENT   @{@"method":  @"goods.comments.add"}


@implementation CommentManager

+ (instancetype)shareInstance
{
    static CommentManager * instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

#pragma mark 添加商品评论
- (NSURLSessionDataTask *)postGoodsCommentWithcommentEntity:(CommentEntity *)commentEntity
                                                    success:(void (^)(id))success
                                                    failure:(void (^)(NSString *))failure
{
    NSDictionary *parameters = [self mergeDictionWithDicone:API_GOODS_ADD_COMMENT AndDicTwo:[commentEntity toDictionary]];
    return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSString *error) {
        failure(error);
    }];
}


#pragma mark logic层统一管理协议方法
- (void)load{}
- (void)loadUserData{}
- (void)save{}
- (void)reset{}
- (void)enterBackgroundMode{}
- (void)enterForeground{}
- (void)doLoginSuccessfulLogic{}
- (void)doLogoutLogic{}
- (void)disconnectNet{}

@end
