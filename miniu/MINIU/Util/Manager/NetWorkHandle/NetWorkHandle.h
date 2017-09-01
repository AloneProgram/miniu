//
//  NetWorkHandle.h
//  DLDQ_IOS
//
//  Created by simman on 14-5-14.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

typedef NS_ENUM(NSInteger, RequestType) {
    POST,
    GET
};

#import "AFHTTPSessionManager.h"

@interface NetWorkHandle : AFHTTPSessionManager

/**
 *  网络请求单例
 *
 *  @return 实例
 */
+ (instancetype)sharedClient;

/**
 *  网络请求基础方法
 *
 *  @param url           URL地址
 *  @param type          请求类型
 *  @param parameters    请求参数
 *  @param successAction 成功回调
 *  @param failureAction 失败回调
 *  @param timesToRetry      是否超时自动重试
 *  @param intervalInSeconds 重试次数
 *
 *  @return 网络标识
 */
- (NSURLSessionDataTask *) HttpRequestWithUrlString:(NSString *)url
                                        RequestType:(RequestType)type
                                         parameters:(NSDictionary *)parameters
                                            success:(void (^)(NSURLSessionDataTask *task, id responseObject))successAction
                                            failure:(void (^)(NSURLSessionDataTask *task, NSString *error))failureAction
                                          autoRetry:(int)timesToRetry
                                      retryInterval:(int)intervalInSeconds;

/**
 *  JAVA后端的网络请求单例
 *
 *  @param url           URL地址
 *  @param type          请求类型
 *  @param parameters    请求参数
 *  @param successAction 成功回调
 *  @param failureAction 失败回调
 *
 *  @return 标识
 */
- (NSURLSessionDataTask *) HttpRequestWithRequestType:(RequestType)type
                                           parameters:(NSDictionary *)parameters
                                              success:(void (^)(NSURLSessionDataTask *task, id responseObject))successAction
                                              failure:(void (^)(NSURLSessionDataTask *task, NSString *error))failureAction;

/**
 *  JAVA后端的网络请求单例
 *
 *  @param url           URL地址
 *  @param type          请求类型
 *  @param parameters    请求参数
 *  @param successAction 成功回调
 *  @param failureAction 失败回调
 *  @param timesToRetry      是否超时自动重试
 *  @param intervalInSeconds 重试次数
 *
 *  @return 网络标识
 */
- (NSURLSessionDataTask *) HttpRequestWithRequestType:(RequestType)type
                                           parameters:(NSDictionary *)parameters
                                              success:(void (^)(NSURLSessionDataTask *task, id responseObject))successAction
                                              failure:(void (^)(NSURLSessionDataTask *task, NSString *error))failureAction
                                            autoRetry:(int)timesToRetry
                                        retryInterval:(int)intervalInSeconds;


/**
 *  根据URL地址取消请求
 *
 *  @param path 地址
 */
- (void)cancelAllHTTPOperationsWithPath:(NSURLSessionDataTask *)taska;


/**
 *  取消所有的网络请求
 */
- (void) cancelAllHTTPOperations;



@end



