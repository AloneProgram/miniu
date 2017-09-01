//
//  TagManager.m
//  DLDQ_IOS
//
//  Created by simman on 14-9-3.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import "TagManager.h"
#import "TagEntity.h"

#define API_USER_TAGS_LIST    @{@"method":     @"user.xqtags.list"}
#define API_USER_BRAND_LIST    @{@"method":    @"user.brand.list"}
#define API_USER_UPDATE_TAG    @{@"method":    @"user.xqtags.save"}
#define API_USER_UPDATE_BRAND    @{@"method":    @"user.brand.save"}
#define API_GOODS_TAGS          @{@"method":    @"tags.allList"}

@implementation TagManager

+ (instancetype)shareInstance
{
    static TagManager * instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (NSURLSessionDataTask *)getTagList:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    @try {
        NSDictionary *parameters = API_USER_TAGS_LIST;
        return [NET_WORK_HANDLE HttpRequestWithRequestType:GET parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            success(responseObject);
        } failure:^(NSURLSessionDataTask *task, NSString *error) {
            failure(error);
        }];
    }
    @catch (NSException *exception) {failure(@"请求参数错误,请检查后重试!");}
    @finally {}
    
}

- (NSURLSessionDataTask *)getBrandList:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    @try {
        NSDictionary *parameters = API_USER_BRAND_LIST;
        return [NET_WORK_HANDLE HttpRequestWithRequestType:GET parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            success(responseObject);
        } failure:^(NSURLSessionDataTask *task, NSString *error) {
            failure(error);
        }];
    }
    @catch (NSException *exception) {failure(@"请求参数错误,请检查后重试!");}
    @finally {}
}

- (NSURLSessionDataTask *)updateTag:(NSString *)entitys success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    @try {
        if (!entitys) {
            failure(@"请求参数错误");
            return 0;
        }
        NSDictionary *parameters = API_USER_UPDATE_TAG;
        NSDictionary *dataDic = @{@"matchNames": entitys};
        return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:[self mergeDictionWithDicone:parameters AndDicTwo:dataDic] success:^(NSURLSessionDataTask *task, id responseObject) {
            success(responseObject);
        } failure:^(NSURLSessionDataTask *task, NSString *error) {
            failure(error);
        }];
    }
    @catch (NSException *exception) {failure(@"请求参数错误,请检查后重试!");}
    @finally {}
}

- (NSURLSessionDataTask *)updateBrand:(NSString *)entitys success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    @try {
        if (!entitys) {
            failure(@"请求参数错误");
            return 0;
        }
        NSDictionary *parameters = API_USER_UPDATE_BRAND;
        NSDictionary *dataDic = @{@"matchNames": entitys};
        return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:[self mergeDictionWithDicone:parameters AndDicTwo:dataDic] success:^(NSURLSessionDataTask *task, id responseObject) {
            success(responseObject);
        } failure:^(NSURLSessionDataTask *task, NSString *error) {
            failure(error);
        }];
    }
    @catch (NSException *exception) {failure(@"请求参数错误,请检查后重试!");}
    @finally {}
}

- (NSURLSessionDataTask *)getGoodsTagsWithUserId:(long long)userId
                                         goodsId:(NSInteger)goodsId
                                     currentPage:(NSInteger)currentPage
                                        pageSize:(NSInteger)pageSize
                                         success:(void (^)(id))success
                                         failure:(void (^)(NSString *))failure
{
    @try {
        NSDictionary *parameters = API_GOODS_TAGS;
        NSMutableDictionary *dataDic = [NSMutableDictionary dictionaryWithCapacity:1];
        if (userId) {
            [dataDic setObject:[NSNumber numberWithLongLong:userId] forKey:@"userId"];
        } else if (goodsId) {
            [dataDic setObject:[NSNumber numberWithInteger:goodsId] forKey:@"goodsId"];
        } else if (currentPage) {
            [dataDic setObject:[NSNumber numberWithInteger:currentPage] forKey:@"currentPage"];
        } else if (pageSize) {
            [dataDic setObject:[NSNumber numberWithInteger:pageSize] forKey:@"pageSize"];
        }
        
        return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:[self mergeDictionWithDicone:parameters AndDicTwo:dataDic] success:^(NSURLSessionDataTask *task, id responseObject) {
            success(responseObject);
        } failure:^(NSURLSessionDataTask *task, NSString *error) {
            failure(error);
        }];
    }
    @catch (NSException *exception) {failure(@"请求参数错误,请检查后重试!");}
    @finally {}
}

#pragma mark
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
