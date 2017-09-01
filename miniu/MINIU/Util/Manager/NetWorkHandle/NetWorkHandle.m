//
//  NetWorkHandle.m
//  DLDQ_IOS
//
//  Created by simman on 14-5-14.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import "NetWorkHandle.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "URLManager.h"
#import "QiniuSDK.h"

@interface NetWorkHandle()
@property (strong, nonatomic, readwrite) NSMutableArray *tasksArr;  // 所有请求

@property (nonatomic, copy) NSString *requestURL;   // 请求地址
@property (nonatomic, copy) NSDictionary *parameters;   // 请求参数

@end

@implementation NetWorkHandle

+ (instancetype)sharedClient {
    static NetWorkHandle *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[NetWorkHandle alloc] initWithBaseURL:[NSURL URLWithString:@""]];
        _sharedClient.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        
        NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:4 * 1024 * 1024 diskCapacity:20 * 1024 * 1024 diskPath:nil];
        [NSURLCache setSharedURLCache:URLCache];
        
        [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
        
        _sharedClient.requestSerializer.timeoutInterval = 30;   // 设置超时时间
//        _sharedClient.responseSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;

        NSSet *set = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", @"text/plain", nil];
        
        _sharedClient.responseSerializer.acceptableContentTypes = set;
        
        // 启用HTTPS支持
//        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
//        [securityPolicy setAllowInvalidCertificates:YES];
//        [securityPolicy setPinnedCertificates:@[certData]];
//        [securityPolicy setSSLPinningMode:AFSSLPinningModeNone];
//        _sharedClient.securityPolicy = securityPolicy;
        
    });
    
    return _sharedClient;
}

- (void) NetWorkingSetWithURL:(NSString *)url parameters:(NSDictionary *)parameters
{
//    if (![AFNetworkReachabilityManager sharedManager].reachable) {
//        [self performSelector:@selector(netWorkTaskFinished) withObject:self afterDelay:0];
//        failureAction(nil, @"网络异常!");
//        NSURLSessionDataTask *task = [[NSURLSessionDataTask alloc] init];
//        return task;
//    }
    
    // 请求地址设置
//    NSString *newUrl;
    NSRange range = [url rangeOfString:@"http://"];
    if (range.location != NSNotFound){
        self.requestURL = url;
    }else{
        self.requestURL = [NSString stringWithFormat:@"%@?%@", [[URLManager shareInstance] getBaseURL], url];
    }
    
    NSString *timeStamp = [NSString timeStamp];
    
    NSString *verifyCode = [[NSString stringWithFormat:@"%@%@", @"org.dldq.www", timeStamp] MD5Hash];
    
    // 03、版本号，设备尺寸等信息
    NSDictionary *appDic = [[NSBundle mainBundle] infoDictionary] ;
    NSString *applicationInfo = [NSString stringWithFormat:@"%@,%@,%@,%@",
                                 [appDic objectForKey:@"CFBundleDisplayName"],
                                 [appDic objectForKey:@"CFBundleDisplayName"],
                                 [appDic objectForKey:@"CFBundleVersion"],
                                 [UIDevice currentDevice].systemVersion];
    
    NSMutableDictionary *newParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
    
    
    NSString *sendId = [CURRENT_USER_INSTANCE getCurrentUserRegistrationID];
    if (![sendId length]) {
        sendId = @"0";
    }
    
    [newParameters setObject:[NSString stringWithFormat:@"%@", sendId] forKey:@"sendId"];
    [newParameters setObject:verifyCode forKey:@"sign"];
    [newParameters setObject:@"ios" forKey:@"appKey"];
    if (![newParameters keyIsExits:@"v"]) {
        [newParameters setObject:@"1.0" forKey:@"v"];
    }
    [newParameters setObject:@"json" forKey:@"format"];
    [newParameters setObject:@"zh_CN" forKey:@"locale"];
    [newParameters setObject:timeStamp forKey:@"timeStamp"];
    
    [newParameters setObject:[CURRENT_USER_INSTANCE getSessionId] forKey:@"sessionKey"];
    
    if (![newParameters keyIsExits:@"userId"]) {
        [newParameters setObject:[NSString stringWithFormat:@"%d", (int)[CURRENT_USER_INSTANCE getCurrentUserID]] forKey:@"userId"]; //
    }
    [newParameters setObject:[applicationInfo base64String] forKey:@"application"];
    
    self.parameters = newParameters;
}

- (NSURLSessionDataTask *)HttpRequestWithRequestType:(RequestType)type parameters:(NSDictionary *)parameters success:(void (^)(NSURLSessionDataTask *, id))successAction failure:(void (^)(NSURLSessionDataTask *, NSString *))failureAction
{
    return [self HttpRequestWithRequestType:type parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if (successAction) {
            successAction(task, responseObject);
        }
    } failure:^(NSURLSessionDataTask *task, NSString *error) {
        if (failureAction) {
            failureAction(task, error);
        }
    } autoRetry:0 retryInterval:0];
}

- (NSURLSessionDataTask *)HttpRequestWithRequestType:(RequestType)type parameters:(NSDictionary *)parameters success:(void (^)(NSURLSessionDataTask *, id))successAction failure:(void (^)(NSURLSessionDataTask *, NSString *))failureAction autoRetry:(int)timesToRetry retryInterval:(int)intervalInSeconds
{
    return [self HttpRequestOfJavaWithUrlString:@"" RequestType:type parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        if (successAction) {
            successAction(task, responseObject);
        }
    } failure:^(NSURLSessionDataTask *task, NSString *error) {
        if (failureAction) {
            failureAction(task, error);
        }
    } autoRetry:timesToRetry retryInterval:intervalInSeconds];
}

#pragma mark 网络请求工厂方法 for Java
- (NSURLSessionDataTask *)HttpRequestOfJavaWithUrlString:(NSString *)url
                                       RequestType:(RequestType)type
                                        parameters:(NSDictionary *)parameters
                                           success:(void (^)(NSURLSessionDataTask *, id))successAction
                                           failure:(void (^)(NSURLSessionDataTask *, NSString *))failureAction
                                         autoRetry:(int)timesToRetry
                                     retryInterval:(int)intervalInSeconds
{
    return [self HttpRequestWithUrlString:url RequestType:type parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [self performSelector:@selector(netWorkTaskFinished) withObject:self afterDelay:0];
//        NSLog(@"工厂方法返回的responseObject ->%@",responseObject);
        NSLog(@"工厂方法返回的responseObject ->:");
        [self logDic:responseObject];
        
        int statusCode = [[responseObject objectForKey:@"statusCode"] intValue];
//        int errorCode = [[responseObject objectForKey:@"code"] intValue];
        int statusCode2 = [[responseObject objectForKey:@"code"] intValue];
        if (statusCode == 200) {
            successAction(task, responseObject);
            //24自动退出 登录
        } else if (statusCode == 24 || statusCode2 == 24) {
            [self showHudError:@"登录超时,请重新登录"];
            [GETMAINDELEGATE changeToLoginView];
        } else {
            failureAction(task, [responseObject objectForKey:@"message"]);
        }

    } failure:^(NSURLSessionDataTask *task, NSString *error) {
        [self performSelector:@selector(netWorkTaskFinished) withObject:self afterDelay:0];
        failureAction(task, @"网络连接失败,请重试!");
    } autoRetry:timesToRetry retryInterval:intervalInSeconds];
}

#pragma mark 网络请求工厂方法
- (NSURLSessionDataTask *)HttpRequestWithUrlString:(NSString *)url
                                       RequestType:(RequestType)type
                                        parameters:(NSDictionary *)parameters
                                           success:(void (^)(NSURLSessionDataTask *, id))successAction
                                           failure:(void (^)(NSURLSessionDataTask *, NSString *))failureAction
                                         autoRetry:(int)timesToRetry
                                     retryInterval:(int)intervalInSeconds
{
    [self NetWorkingSetWithURL:url parameters:parameters];
    NSURLSessionDataTask *task;
    
    if (type != GET && type != POST) {
        type = GET;
    }
    
    if ( type == GET ) {
        
        task = [self GET:self.requestURL parameters:self.parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            
            if (successAction) {
                successAction(task, responseObject);
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            if (failureAction) {
                failureAction(task, @"网络连接失败,请重试!");
            }
        }];
        
        
    } else if (type == POST) {
        
        task = [self POST:self.requestURL parameters:self.parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            
            if (successAction) {
                successAction(task, responseObject);
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            if (failureAction) {
                failureAction(task, @"网络连接失败,请重试!");
            }
        }];
    }
    
    if (!self.tasksArr) {
        self.tasksArr = [NSMutableArray arrayWithCapacity:1];
    }
    
    [self.tasksArr addObject:task];
    
    return task;
}

- (void) netWorkTaskFinished
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NetWorkTaskFinish object:nil];
}


#pragma mark - 图片上传

- (void)UpLoadPhotoWithUIImage:(NSArray *)imageArr
                          type:(UploadType)tp
                       success:(void (^)(id))success
                       failure:(void (^)(NSError *))failure
                      progress:(void (^)(CGFloat))progress
{
//    UpYun *uy = [[UpYun alloc] init];
//    __block int i = 0;
//    NSInteger iCount = [imageArr count];
//    if (!iCount) return;
//    
//    NSMutableArray *dataArr = [NSMutableArray arrayWithCapacity:iCount];
//    for (int i = 0; i < iCount; i ++) {
//        [dataArr addObject:[NSString stringWithFormat:@"%d", i]];
//    }
//    
//    //    NSMutableString *pathStr = [NSMutableString stringWithCapacity:1];
//    uy.successBlocker = ^(id data)
//    {
//        i++;
//        //        NSString *str = [data objectForKey:@"url"];
//        //        [pathStr appendString:str];
//        
//        // 获取图片的Index
//        NSString *imageI = [data objectForKey:@"ext-param"];
////        [dataArr replaceObjectAtIndex:data atIndex:[imageI integerValue]];
//        [dataArr replaceObjectAtIndex:[imageI integerValue] withObject:data];
//        
//        if (i == [imageArr count]) {
////            [dataArr reverseObjectEnumerator];
//            success(dataArr);
//        }
//    };
//    uy.failBlocker = ^(NSError * error)
//    {
//        failure(error);
//    };
//    uy.progressBlocker = ^(CGFloat percent, long long requestDidSendBytes)
//    {
//        progress(percent);
//    };
//    
//    /**
//     *	@brief	根据 UIImage 上传
//     */
//    
//    NSString *saveKey = [self getSaveKeyWithType:tp];
//    
//    NSArray *photoArr = [NSArray arrayWithArray:imageArr];
//    
//    int imageIndex = 0;
//    for (UIImage *image in photoArr) {
//        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:@{@"ext-param": [NSString stringWithFormat:@"%d", imageIndex]}];
//        uy.params = dic;
//        [uy uploadFile:image saveKey:saveKey];
//        imageIndex ++;
//    }
    
    /**
     *	@brief	根据 文件路径 上传
     */
    //    NSString* resourcePath = [[NSBundle mainBundle] resourcePath];
    //    NSString* filePath = [resourcePath stringByAppendingPathComponent:@"fileTest.file"];
    //    [uy uploadFile:filePath saveKey:[self getSaveKey]];
    
    /**
     *	@brief	根据 NSDate  上传
     */
    //    NSData * fileData = [NSData dataWithContentsOfFile:filePath];
    //    [uy uploadFile:fileData saveKey:[self getSaveKey]];
}

#pragma mark 根据图片类型获取保存的路径
-(NSString * )getSaveKeyWithType:(UploadType)type {
    
    NSString *typeDir = nil;
    
    switch (type) {
        case UploadTypeOfGoods:
            typeDir = @"Goods";
            break;
        case UploadTypeOfAvatar:
            typeDir = @"Avatar";
            break;
        case UploadTypeOfLife:
            typeDir = @"Life";
            break;
        case UploadTypeOfMessage:
            typeDir = @"Message";
        case UploadTypeOfUserFile:
            typeDir = @"UserFile";
        default:
            break;
    }
    /**
     *	@brief	方式1 由开发者生成saveKey
     */
    
    //    NSDate *d = [NSDate date];
    //    return [NSString stringWithFormat:@"/%d/%d/%.0f.jpg",[self getYear:d],[self getMonth:d],[[NSDate date] timeIntervalSince1970]];
    
    /**
     *	@brief	方式2 由服务器生成saveKey
     */
    return [NSString stringWithFormat:@"/%@/{year}/{mon}/{day}/{filemd5}{hour}{min}{sec}{.suffix}", typeDir];
    
    /**
     *	@brief	更多方式 参阅 http://wiki.upyun.com/index.php?title=Policy_%E5%86%85%E5%AE%B9%E8%AF%A6%E8%A7%A3
     */
}


//- (void)UpLoadPhotoWithUIImage:(NSArray *)imageArr
//                          type:(UploadType)tp
//                       success:(void (^)(id))success
//                       failure:(void (^)(NSError *))failure
//                      progress:(void (^)(CGFloat))progress
//{
//    NSString *token = @"LSpqr4nDpRtZyOdV1Q2BJq2sVMqFEUDFupDJI-Uq:wb-EiuwqpckFseSx8eEYUj-AH_o=:eyJzY29wZSI6ImRsZHFzdGF0aWMiLCJkZWFkbGluZSI6MTc0Mzc4NzkzM30=";
//    
//    QNUploadManager *upManager = [QNUploadManager sharedInstanceWithRecorder:nil recorderKeyGenerator:nil];
//    
//    
//    int index = 0;
//    for (UIImage *image in imageArr) {
//        
//        // 首先处理图片大小并转成NSDATA
//        UIImage *reSizeImage = nil;
//        if (image.size.width > 1024) {
//            reSizeImage = [image imageCompressForWidth:1024];
//        } else {
//            reSizeImage = image;
//        }
//        
//        NSData *imageData = UIImageJPEGRepresentation(reSizeImage, 0.4);
//        
//        
//        // 添加图片的 index
//        QNUploadOption *option = [[QNUploadOption alloc] initWithMime:nil progressHandler:^(NSString *key, float percent) {
//            
//        } params:@{@"image_index": [NSString stringWithFormat:@"%d", index]} checkCrc:NO cancellationSignal:nil];
//        
//        // 上传图片
//        [upManager putData:imageData key:@"Goods/2015/05/12/2fjaosdifj209jfasldjf02jfasijdf23jfajdf.jpg" token:token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
//            
//            NSLog(@"info=%@, key=%@, resp=%@", info, key, resp);
//            
//        } option:option];
//        
//        
//        index ++;
//    }
//    
//    
//}


#pragma mark 通过task取消对应的网络请求
- (void)cancelAllHTTPOperationsWithPath:(NSURLSessionDataTask *)taska
{
    for (NSURLSessionDataTask* task in [self tasks]) {
        if (task.taskIdentifier == taska.taskIdentifier) {
            [taska cancel];
        }
    }
}

#pragma mark 取消所有网络请求
- (void)cancelAllHTTPOperations {
    for (NSURLSessionDataTask* task in [self tasks]) {
        [task cancel];
    }
}

/**
 *  避免输出字典里中文\u的处理方法
 *
 *  @param dic 变量
 */
- (void)logDic:(NSDictionary *)dic
{
    //错误处理
    if(!dic)return;
    
    NSString *tempStr1 = [[dic description] stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
    if(!tempStr1)return;
    
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    if(!tempStr2)return;
    
    NSString *tempStr3 = [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString *str = [NSPropertyListSerialization propertyListFromData:tempData mutabilityOption:NSPropertyListImmutable format:NULL errorDescription:NULL];
    NSLog(@"dic:%@",str);
}


@end
