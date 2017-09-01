//
//  GoodsManager.h
//  DLDQ_IOS
//
//  Created by simman on 14-9-3.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GoodsEntity;

@interface GoodsManager : ManagerBase <LogicBaseModel>

/**
 *  对象单例
 *
 *  @return
 */
+ (instancetype)shareInstance;

/**
 *  发布产品
 *
 *  @param entity  产品实例
 *  @param success 成功回调
 *  @param failure 失败回调
 *
 *  @return 网络标识
 */
- (NSURLSessionDataTask *)postGoods:(GoodsEntity *)entity
                                    success:(void (^)(id responseObject))success
                                    failure:(void (^)(NSString *error))failure;

/**
 *  获取代购圈的商品列表
 *
 *  @param currentPage 当前页码
 *  @param pageSize    每页数量
 *  @param success     成功回调
 *  @param failure     失败回调
 *
 *  @return 网络标识
 */
- (NSURLSessionDataTask *)getGoodsListWithCurrentPage:(NSInteger)currentPage
                                             pageSize:(NSInteger)pageSize
                            success:(void (^)(id responseObject))success
                            failure:(void (^)(NSString *error))failure;

/**
 *  获取用户详情页面的数据
 *
 *  @param currentPage  当前页面
 *  @param pageSize     数量
 *  @param createUserId 用户ID
 *  @param success      成功回调
 *  @param failure      失败回调
 *
 *  @return 网络标识
 */
- (NSURLSessionDataTask *)getUserInfoByGoodsWithCurrentPage:(NSInteger)currentPage
                                             pageSize:(NSInteger)pageSize
                                         createUserId:(long long)createUserId
                                              success:(void (^)(id responseObject))success
                                              failure:(void (^)(NSString *error))failure;


/**
 *  添加愿望清单
 *
 *  @param goodsId 商品ID
 *  @param success 成功回调
 *  @param failure 失败回调
 *
 *  @return 网络标识
 */
- (NSURLSessionDataTask *)addCollectGoodsWithGoodsId:(long long)goodsId
                                                    success:(void (^)(id responseObject))success
                                                    failure:(void (^)(NSString *error))failure;

/**
 *  删除愿望清单
 *
 *  @param goodsId 商品ID
 *  @param success 成功回调
 *  @param failure 失败回调
 *
 *  @return 网络标识
 */
- (NSURLSessionDataTask *)delCollectGoodsWithGoodsId:(long long)goodsId
                                             success:(void (^)(id responseObject))success
                                             failure:(void (^)(NSString *error))failure;


/**
 *  添加喜欢
 *
 *  @param goodsId 商品ID
 *  @param success 成功回调
 *  @param failure 失败回调
 *
 *  @return 网络标识
 */
- (NSURLSessionDataTask *)addLikeGoodsWithGoodsId:(long long)goodsId
                                             success:(void (^)(id responseObject))success
                                             failure:(void (^)(NSString *error))failure;

/**
 *  删除喜欢
 *
 *  @param goodsId 商品ID
 *  @param success 成功回调
 *  @param failure 失败回调
 *
 *  @return 网络标识
 */
- (NSURLSessionDataTask *)delLikeGoodsWithGoodsId:(long long)goodsId
                                             success:(void (^)(id responseObject))success
                                             failure:(void (^)(NSString *error))failure;

/**
 *  删除发布的商品
 *
 *  @param goodsId 商品ID
 *  @param success 成功回调
 *  @param failure 失败回调
 *
 *  @return 网络标识
 */
- (NSURLSessionDataTask *)delGoodsWithGoodsId:(long long)goodsId
                                             success:(void (^)(id responseObject))success
                                             failure:(void (^)(NSString *error))failure;

/**
 *  投诉商品
 *
 *  @param goodsId 商品ID
 *  @param success 成功回调
 *  @param failure 失败回调
 *
 *  @return 网络标识
 */
- (NSURLSessionDataTask *)complaintWithGoodsId:(long long)goodsId
                                      success:(void (^)(id responseObject))success
                                      failure:(void (^)(NSString *error))failure;

/**
 *  商品详情
 *
 *  @param goodsId 商品ID
 *  @param success 成功回调
 *  @param failure 失败回调
 *
 *  @return 网络标识
 */
- (NSURLSessionDataTask *)goodsDetailWithGoodsId:(long long)goodsId
                                     currentPage:(NSInteger)currentPage
                                        pageSize:(NSInteger)pageSize
                                         success:(void (^)(id responseObject))success
                                         failure:(void (^)(NSString *error))failure;

/**
 *  我的发布
 *
 *  @param currentPage 当前页
 *  @param pageSize    每页数量
 *  @param success     成功回调
 *  @param failure     失败回调
 *
 *  @return 网络标识
 */
- (NSURLSessionDataTask *)myPostGoodsListWithCurrentPage:(NSInteger)currentPage
                                        pageSize:(NSInteger)pageSize
                                         success:(void (^)(id responseObject))success
                                         failure:(void (^)(NSString *error))failure;


/**
 *  所有商品
 *
 *  @param keywords    关键词
 *  @param currentPage 当前页
 *  @param pageSize    每页数量
 *  @param success     成功回调
 *  @param failure     失败回调
 *
 *  @return 网络标识
 */
- (NSURLSessionDataTask *)searchGoodsListWithKeyWords:(NSString *)keywords
                                          CurrentPage:(NSInteger)currentPage
                                             pageSize:(NSInteger)pageSize
                                              success:(void (^)(id responseObject))success
                                              failure:(void (^)(NSString *error))failure;

/**
 *  @brief  返回品牌标签
 *
 *  @param success
 *  @param failure
 *
 *  @return
 */
- (NSURLSessionDataTask *)searchBrandListSuccess:(void (^)(id responseObject))success
                                              failure:(void (^)(NSString *error))failure;



/**
 *  @brief  根据关键字与标签获取内容
 *
 *  @param keywords    关键字
 *  @param tagName     标签名称
 *  @param currentPage 当前页面
 *  @param pageSize
 *  @param success
 *  @param failure
 *
 *  @return
 */
- (NSURLSessionDataTask *)searchGoodsListWithKeyWordsAndTag:(NSString *)keywords
                                                    tagName:(NSString *)tagName
                                          CurrentPage:(NSInteger)currentPage
                                             pageSize:(NSInteger)pageSize
                                              success:(void (^)(id responseObject))success
                                              failure:(void (^)(NSString *error))failure;

/**
 *  @brief  根据标签获取商品
 *
 *  @param tagName
 *  @param currentPage
 *  @param pageSize
 *  @param success
 *  @param failure
 *
 *  @return 
 */
- (NSURLSessionDataTask *)getGoodsListWithTagName:(NSString *)tagName
                                                CurrentPage:(NSInteger)currentPage
                                                   pageSize:(NSInteger)pageSize
                                                    success:(void (^)(id responseObject))success
                                                    failure:(void (^)(NSString *error))failure;

/**
 *  随便逛逛
 *
 *  @param currentPage 当前页面
 *  @param pageSize    每页数量
 *  @param success     成功回调
 *  @param failure     失败回调
 *
 *  @return 网络标识
 */
- (NSURLSessionDataTask *)GoodsListWithCurrentPage:(NSInteger)currentPage
                                                pageSize:(NSInteger)pageSize
                                                 success:(void (^)(id responseObject))success
                                                 failure:(void (^)(NSString *error))failure;




@end
