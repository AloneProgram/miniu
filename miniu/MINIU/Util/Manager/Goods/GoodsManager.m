//
//  GoodsManager.m
//  DLDQ_IOS
//
//  Created by simman on 14-9-3.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import "GoodsManager.h"
#import "GoodsEntity.h"

#define API_POST_GOODS    @{@"method":     @"goods.release"}
#define API_GOODS_LIST    @{@"method":     @"goods.myCircle.list"}
#define API_GOODS_USER_INFO @{@"method":   @"goods.userInfo"}

// 愿望清单
#define API_GOODS_ADD_COLLECT @{@"method":  @"user.collect.add"}
#define API_GOODS_DEL_COLLECT @{@"method":  @"user.collect.del"}

// 喜欢
#define API_GOODS_LIKE_ADD  @{@"method":  @"user.goodspraise.add"}
#define API_GOODS_LIKE_DEL  @{@"method":  @"user.goodspraise.cancel"}

#define API_GOODS_DEL_GOODS @{@"method":  @"goods.del"}
#define API_GOODS_COMPLAINT @{@"method":  @"goods.complaint"}

#define API_GOODS_DETAIL    @{@"method": @"goods.detail"}

#define API_GOODS_MY_POST   @{@"method": @"goods.mine.releases"}

#define API_GOODS_SEARCH_GOODS   @{@"method": @"search.goods.list"}

#define API_GOODS_STROLL_LIST        @{@"method": @"goods.list"}     // 随便逛逛

#define API_GOODS_SEARCH_BRAND   @{@"method": @"search.brand.list"}


#define API_GOODS_LIST_WITH_TAG         @{@"method": @"goods.tagCircle.list"}


#define API_GOODS_SEARCH_WITH_K_T       @{@"method": @"search.tag.goodslist"}


@implementation GoodsManager


+ (instancetype)shareInstance
{
    static GoodsManager * instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

#pragma mark 发布产品
- (NSURLSessionDataTask *)postGoods:(GoodsEntity *)entity success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    @try {
        NSMutableDictionary *entityDic = [NSMutableDictionary dictionaryWithDictionary:[entity toDictionary]];
        [entityDic removeObjectForKey:@"userId"];
        [entityDic removeObjectForKey:@"goodsUserInfo"];
        
        NSMutableDictionary *parameters = [self mergeDictionWithDicone:API_POST_GOODS AndDicTwo:entityDic];
        return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            success(responseObject);
        } failure:^(NSURLSessionDataTask *task, NSString *error) {
            failure(error);
        }];
    }
    @catch (NSException *exception) {failure(@"请求参数错误,请检查后重试!");}
    @finally {}
}

#pragma mark 获取代购圈的商品列表
- (NSURLSessionDataTask *)getGoodsListWithCurrentPage:(NSInteger)currentPage pageSize:(NSInteger)pageSize success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    @try {
        NSMutableDictionary *entityDic = [NSMutableDictionary dictionaryWithCapacity:1];
        [entityDic setObject:[NSNumber numberWithInteger:currentPage] forKey:@"currentPage"];
        [entityDic setObject:[NSNumber numberWithInteger:pageSize] forKey:@"pageSize"];
        
        NSDictionary *parameters = [self mergeDictionWithDicone:API_GOODS_LIST AndDicTwo:entityDic];
        return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            success(responseObject);
        } failure:^(NSURLSessionDataTask *task, NSString *error) {
            failure(error);
        }];
    }
    @catch (NSException *exception) {failure(@"请求参数错误,请检查后重试!");}
    @finally {}
}

#pragma mark 获取用户详情页面的数据
- (NSURLSessionDataTask *)getUserInfoByGoodsWithCurrentPage:(NSInteger)currentPage pageSize:(NSInteger)pageSize createUserId:(long long)createUserId success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    @try {
        NSMutableDictionary *entityDic = [NSMutableDictionary dictionaryWithCapacity:1];
        [entityDic setObject:[NSNumber numberWithInteger:currentPage] forKey:@"currentPage"];
        [entityDic setObject:[NSNumber numberWithInteger:pageSize] forKey:@"pageSize"];
        [entityDic setObject:[NSNumber numberWithLongLong:createUserId] forKey:@"createUserId"];
        
        NSDictionary *parameters = [self mergeDictionWithDicone:API_GOODS_USER_INFO AndDicTwo:entityDic];
        return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            success(responseObject);
        } failure:^(NSURLSessionDataTask *task, NSString *error) {
            failure(error);
        }];
    }
    @catch (NSException *exception) {failure(@"请求参数错误,请检查后重试!");}
    @finally {}
}

#pragma mark 添加愿望清单
- (NSURLSessionDataTask *)addCollectGoodsWithGoodsId:(long long)goodsId success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    @try {
        NSMutableDictionary *entityDic = [NSMutableDictionary dictionaryWithCapacity:1];
        [entityDic setObject:[NSNumber numberWithLongLong:goodsId] forKey:@"goodsId"];
        [entityDic setObject:@"1.0" forKey:@"v"];
        
        NSDictionary *parameters = [self mergeDictionWithDicone:API_GOODS_ADD_COLLECT AndDicTwo:entityDic];
        return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            success(responseObject);
        } failure:^(NSURLSessionDataTask *task, NSString *error) {
            failure(error);
        }];
    }
    @catch (NSException *exception) {failure(@"请求参数错误,请检查后重试!");}
    @finally {}
}

#pragma mark 删除愿望清单
- (NSURLSessionDataTask *)delCollectGoodsWithGoodsId:(long long)goodsId success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    @try {
        NSMutableDictionary *entityDic = [NSMutableDictionary dictionaryWithCapacity:1];
        [entityDic setObject:[NSNumber numberWithLongLong:goodsId] forKey:@"goodsId"];
        
        NSDictionary *parameters = [self mergeDictionWithDicone:API_GOODS_DEL_COLLECT AndDicTwo:entityDic];
        return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            success(responseObject);
        } failure:^(NSURLSessionDataTask *task, NSString *error) {
            failure(error);
        }];
    }
    @catch (NSException *exception) {failure(@"请求参数错误,请检查后重试!");}
    @finally {}
}

#pragma mark 删除商品
- (NSURLSessionDataTask *)delGoodsWithGoodsId:(long long)goodsId
                                      success:(void (^)(id))success
                                      failure:(void (^)(NSString *))failure
{
    @try {
        NSMutableDictionary *entityDic = [NSMutableDictionary dictionaryWithCapacity:1];
        [entityDic setObject:[NSNumber numberWithLongLong:goodsId] forKey:@"goodsId"];
        
        NSDictionary *parameters = [self mergeDictionWithDicone:API_GOODS_DEL_GOODS AndDicTwo:entityDic];
        return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            success(responseObject);
        } failure:^(NSURLSessionDataTask *task, NSString *error) {
            failure(error);
        }];
    }
    @catch (NSException *exception) {failure(@"请求参数错误,请检查后重试!");}
    @finally {}
}

#pragma mark 投诉商品
- (NSURLSessionDataTask *)complaintWithGoodsId:(long long)goodsId
                                       success:(void (^)(id))success
                                       failure:(void (^)(NSString *))failure
{
    @try {
        NSMutableDictionary *entityDic = [NSMutableDictionary dictionaryWithCapacity:1];
        [entityDic setObject:[NSNumber numberWithLongLong:goodsId] forKey:@"goodsId"];
        
        NSDictionary *parameters = [self mergeDictionWithDicone:API_GOODS_COMPLAINT AndDicTwo:entityDic];
        return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            success(responseObject);
        } failure:^(NSURLSessionDataTask *task, NSString *error) {
            failure(error);
        }];
    }
    @catch (NSException *exception) {failure(@"请求参数错误,请检查后重试!");}
    @finally {}
}

#pragma mark 商品详情
- (NSURLSessionDataTask *)goodsDetailWithGoodsId:(long long)goodsId
                                     currentPage:(NSInteger)currentPage
                                        pageSize:(NSInteger)pageSize
                                         success:(void (^)(id))success
                                         failure:(void (^)(NSString *))failure
{
    @try {
        NSMutableDictionary *entityDic = [NSMutableDictionary dictionaryWithCapacity:1];
        [entityDic setObject:[NSNumber numberWithLongLong:goodsId] forKey:@"goodsId"];
        [entityDic setObject:[NSNumber numberWithInteger:currentPage] forKey:@"currentPage"];
        [entityDic setObject:[NSNumber numberWithInteger:pageSize] forKey:@"pageSize"];
        
        NSDictionary *parameters = [self mergeDictionWithDicone:API_GOODS_DETAIL AndDicTwo:entityDic];
        return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            success(responseObject);
        } failure:^(NSURLSessionDataTask *task, NSString *error) {
            failure(error);
        }];
    }
    @catch (NSException *exception) {failure(@"请求参数错误,请检查后重试!");}
    @finally {}
}

#pragma mark 我的发布
- (NSURLSessionDataTask *)myPostGoodsListWithCurrentPage:(NSInteger)currentPage
                                                pageSize:(NSInteger)pageSize
                                                 success:(void (^)(id))success
                                                 failure:(void (^)(NSString *))failure
{
    @try {
        NSMutableDictionary *entityDic = [NSMutableDictionary dictionaryWithCapacity:1];
        [entityDic setObject:[NSNumber numberWithInteger:currentPage] forKey:@"currentPage"];
        [entityDic setObject:[NSNumber numberWithInteger:pageSize] forKey:@"pageSize"];
        
        NSDictionary *parameters = [self mergeDictionWithDicone:API_GOODS_MY_POST AndDicTwo:entityDic];
        return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            success(responseObject);
        } failure:^(NSURLSessionDataTask *task, NSString *error) {
            failure(error);
        }];
    }
    @catch (NSException *exception) {failure(@"请求参数错误,请检查后重试!");}
    @finally {}
}

#pragma mark 搜索商品
- (NSURLSessionDataTask *)searchGoodsListWithKeyWords:(NSString *)keywords
                                          CurrentPage:(NSInteger)currentPage
                                             pageSize:(NSInteger)pageSize
                                              success:(void (^)(id))success
                                              failure:(void (^)(NSString *))failure
{
    @try {
        NSMutableDictionary *entityDic = [NSMutableDictionary dictionaryWithCapacity:1];
        [entityDic setObject:[NSString stringWithFormat:@"%@", keywords] forKey:@"keyword"];
        [entityDic setObject:[NSNumber numberWithInteger:currentPage] forKey:@"currentPage"];
        [entityDic setObject:[NSNumber numberWithInteger:pageSize] forKey:@"pageSize"];
        
        NSDictionary *parameters = [self mergeDictionWithDicone:API_GOODS_SEARCH_GOODS AndDicTwo:entityDic];
        return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            success(responseObject);
        } failure:^(NSURLSessionDataTask *task, NSString *error) {
            failure(error);
        }];
    }
    @catch (NSException *exception) {failure(@"请求参数错误,请检查后重试!");}
    @finally {}
}

#pragma mrak 随便逛逛商品列表
- (NSURLSessionDataTask *)GoodsListWithCurrentPage:(NSInteger)currentPage
                                          pageSize:(NSInteger)pageSize
                                           success:(void (^)(id))success
                                           failure:(void (^)(NSString *))failure
{
    @try {
        NSMutableDictionary *entityDic = [NSMutableDictionary dictionaryWithCapacity:1];
        [entityDic setObject:[NSNumber numberWithInteger:currentPage] forKey:@"currentPage"];
        [entityDic setObject:[NSNumber numberWithInteger:pageSize] forKey:@"pageSize"];
        
        NSDictionary *parameters = [self mergeDictionWithDicone:API_GOODS_STROLL_LIST AndDicTwo:entityDic];
        return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            success(responseObject);
        } failure:^(NSURLSessionDataTask *task, NSString *error) {
            failure(error);
        }];
    }
    @catch (NSException *exception) {failure(@"请求参数错误,请检查后重试!");}
    @finally {}
}

#pragma mark 添加喜欢
- (NSURLSessionDataTask *)addLikeGoodsWithGoodsId:(long long)goodsId success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    @try {
        NSMutableDictionary *entityDic = [NSMutableDictionary dictionaryWithCapacity:1];
        [entityDic setObject:[NSNumber numberWithLongLong:goodsId] forKey:@"goodsId"];
        
        NSDictionary *parameters = [self mergeDictionWithDicone:API_GOODS_LIKE_ADD AndDicTwo:entityDic];
        return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            success(responseObject);
        } failure:^(NSURLSessionDataTask *task, NSString *error) {
            failure(error);
        }];
    }
    @catch (NSException *exception) {failure(@"请求参数错误,请检查后重试!");}
    @finally {}
}
#pragma mark 删除喜欢
- (NSURLSessionDataTask *)delLikeGoodsWithGoodsId:(long long)goodsId
                                      success:(void (^)(id))success
                                      failure:(void (^)(NSString *))failure
{
    @try {
        NSMutableDictionary *entityDic = [NSMutableDictionary dictionaryWithCapacity:1];
        [entityDic setObject:[NSNumber numberWithLongLong:goodsId] forKey:@"goodsId"];
        
        NSDictionary *parameters = [self mergeDictionWithDicone:API_GOODS_LIKE_DEL AndDicTwo:entityDic];
        return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            success(responseObject);
        } failure:^(NSURLSessionDataTask *task, NSString *error) {
            failure(error);
        }];
    }
    @catch (NSException *exception) {failure(@"请求参数错误,请检查后重试!");}
    @finally {}
}
//获取分类品牌
- (NSURLSessionDataTask *)searchBrandListSuccess:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    @try {
        return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:API_GOODS_SEARCH_BRAND success:^(NSURLSessionDataTask *task, id responseObject) {
            success(responseObject);
        } failure:^(NSURLSessionDataTask *task, NSString *error) {
            failure(error);
        }];
    }
    @catch (NSException *exception) {failure(@"请求参数错误,请检查后重试!");}
    @finally {}
}

- (NSURLSessionDataTask *)searchGoodsListWithKeyWordsAndTag:(NSString *)keywords tagName:(NSString *)tagName CurrentPage:(NSInteger)currentPage pageSize:(NSInteger)pageSize success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    @try {
        NSMutableDictionary *entityDic = [NSMutableDictionary dictionaryWithCapacity:1];
        [entityDic setObject:[NSNumber numberWithInteger:currentPage] forKey:@"currentPage"];
        [entityDic setObject:[NSNumber numberWithInteger:pageSize] forKey:@"pageSize"];
        [entityDic setObject:[NSString stringWithFormat:@"%@", keywords] forKey:@"keyword"];
    
        // 如果没有的话，那么则使用之前的搜索
        if (!tagName || ![tagName length]) {
            
            [self searchGoodsListWithKeyWords:keywords CurrentPage:currentPage pageSize:pageSize success:^(id responseObject) {
               success(responseObject);
            } failure:^(NSString *error) {
                failure(error);
            }];
            return nil;
        }
        
        [entityDic setObject:[NSString stringWithFormat:@"%@", tagName] forKey:@"tagName"];
        
        NSDictionary *parameters = [self mergeDictionWithDicone:API_GOODS_SEARCH_WITH_K_T AndDicTwo:entityDic];
        return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            success(responseObject);
        } failure:^(NSURLSessionDataTask *task, NSString *error) {
            failure(error);
        }];
    }
    @catch (NSException *exception) {failure(@"请求参数错误,请检查后重试!");}
    @finally {}
}

- (NSURLSessionDataTask *)getGoodsListWithTagName:(NSString *)tagName CurrentPage:(NSInteger)currentPage pageSize:(NSInteger)pageSize success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    @try {
        NSMutableDictionary *entityDic = [NSMutableDictionary dictionaryWithCapacity:1];
        [entityDic setObject:[NSNumber numberWithInteger:currentPage] forKey:@"currentPage"];
        [entityDic setObject:[NSNumber numberWithInteger:pageSize] forKey:@"pageSize"];
        [entityDic setObject:[NSString stringWithFormat:@"%@", tagName] forKey:@"tagName"];
        
        NSDictionary *parameters = [self mergeDictionWithDicone:API_GOODS_LIST_WITH_TAG AndDicTwo:entityDic];
        return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            success(responseObject);
        } failure:^(NSURLSessionDataTask *task, NSString *error) {
            failure(error);
        }];
    }
    @catch (NSException *exception) {failure(@"请求参数错误,请检查后重试!");}
    @finally {}
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
