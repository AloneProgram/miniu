//
//  TagManager.h
//  DLDQ_IOS
//
//  Created by simman on 14-9-3.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ManagerBase.h"

@class TagEntity;

@interface TagManager : ManagerBase <LogicBaseModel>


/**
 *  管理对象单例
 *
 *  @return
 */
+ (instancetype)shareInstance;


/**
 *  获取兴趣标签接口
 *
 *  @param success 成功回调
 *  @param failure 失败回调
 *
 *  @return 网络标识
 */
- (NSURLSessionDataTask *)getTagList:(void (^)(id responseObject))success
                             failure:(void (^)(NSString *error))failure;

/**
 *  获取用户代购标签
 *
 *  @param success 成功回调
 *  @param failure 失败回调
 *
 *  @return 网络标识
 */
- (NSURLSessionDataTask *)getBrandList:(void (^)(id responseObject))success
                             failure:(void (^)(NSString *error))failure;

/**
 *  保存兴趣标签
 *
 *  @param entitys  兴趣标签（已,分割）
 *  @param success 成功回调
 *  @param failure 失败回调
 *
 *  @return 网络标识
 */
- (NSURLSessionDataTask *)updateTag:(NSString *)entitys
                             success:(void (^)(id responseObject))success
                             failure:(void (^)(NSString *error))failure;

/**
 *  保存代购标签
 *
 *  @param entitys  品类标签（已,分割）
 *  @param success 成功回调
 *  @param failure 失败回调
 *
 *  @return 网络标识
 */
- (NSURLSessionDataTask *)updateBrand:(NSString *)entitys
                            success:(void (^)(id responseObject))success
                            failure:(void (^)(NSString *error))failure;

/**
 *  获取商品的标签
 *
 *  @param userId      用户ID  （必填）
 *  @param goodsId     商品ID
 *  @param currentPage 当前页数
 *  @param pageSize    每页数量
 *  @param success     成功回调
 *  @param failure     失败回调
 *
 *  @return 网络标识
 */
- (NSURLSessionDataTask *)getGoodsTagsWithUserId:(long long)userId
                                         goodsId:(NSInteger)goodsId
                                     currentPage:(NSInteger)currentPage
                                        pageSize:(NSInteger)pageSize
                                         success:(void (^)(id responseObject))success
                                         failure:(void (^)(NSString *error))failure;
@end
