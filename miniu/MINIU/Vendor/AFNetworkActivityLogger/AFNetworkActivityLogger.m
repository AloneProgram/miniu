// AFNetworkActivityLogger.h
//
// Copyright (c) 2013 AFNetworking (http://afnetworking.com/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "AFNetworkActivityLogger.h"
#import "AFURLConnectionOperation.h"
#import "AFURLSessionManager.h"

#import <objc/runtime.h>

static NSURLRequest * AFNetworkRequestFromNotification(NSNotification *notification) {
    NSURLRequest *request = nil;
    if ([[notification object] isKindOfClass:[AFURLConnectionOperation class]]) {
        request = [(AFURLConnectionOperation *)[notification object] request];
    } else if ([[notification object] respondsToSelector:@selector(originalRequest)]) {
        request = [[notification object] originalRequest];
    }

    return request;
}

@implementation AFNetworkActivityLogger

+ (instancetype)sharedLogger {
    static AFNetworkActivityLogger *_sharedLogger = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedLogger = [[self alloc] init];
    });

    return _sharedLogger;
}

- (id)init {
    self = [super init];
    if (!self) {
        return nil;
    }

    self.level = AFLoggerLevelInfo;

    return self;
}

- (void)dealloc {
    [self stopLogging];
}

- (void)startLogging {
    [self stopLogging];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkRequestDidStart:) name:AFNetworkingOperationDidStartNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkRequestDidFinish:) name:AFNetworkingOperationDidFinishNotification object:nil];

#if (defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000) || (defined(__MAC_OS_X_VERSION_MAX_ALLOWED) && __MAC_OS_X_VERSION_MAX_ALLOWED >= 1090)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkRequestDidStart:) name:AFNetworkingTaskDidResumeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkRequestDidFinish:) name:AFNetworkingTaskDidCompleteNotification object:nil];
#endif
}

- (void)stopLogging {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - NSNotification

static void * AFNetworkRequestStartDate = &AFNetworkRequestStartDate;

- (void)networkRequestDidStart:(NSNotification *)notification {
    NSURLRequest *request = AFNetworkRequestFromNotification(notification);

    if (!request) {
        return;
    }

    if (request && self.filterPredicate && [self.filterPredicate evaluateWithObject:request]) {
        return;
    }

    objc_setAssociatedObject(notification.object, AFNetworkRequestStartDate, [NSDate date], OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    NSString *body = nil;
    if ([request HTTPBody]) {
        body = [[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding];
    }

    switch (self.level) {
        case AFLoggerLevelDebug: {
            @try {
                // 打印Log信息
                NSLog(@"##########################  开始发送请求  ###############################");
                NSString *logString = [NSString stringWithFormat:@"\n--> 请求方式：%@\n--> 请求地址：%@\n--> HTTP头 ：\n%@\n--> 请求参数：\n%@", [request HTTPMethod], [[request URL] absoluteString], [request allHTTPHeaderFields], [request HTTPBody] ? [body componentsSeparatedByString:@"&"] : @"<null>"];
                NSLog(@"%@", logString);
                NSLog(@"##########################  结束发送请求  ###############################");
            }
            @catch (NSException *exception) {}
            @finally {}
        }
            break;
        case AFLoggerLevelInfo:
            NSLog(@"%@ '%@'", [request HTTPMethod], [[request URL] absoluteString]);
            break;
        default:
            break;
    }
}

- (void)networkRequestDidFinish:(NSNotification *)notification {
    NSURLRequest *request = AFNetworkRequestFromNotification(notification);
    NSURLResponse *response = [notification.object response];
    NSError *error = [notification.object error];

    if (!request && !response) {
        return;
    }

    if (request && self.filterPredicate && [self.filterPredicate evaluateWithObject:request]) {
        return;
    }
    NSUInteger responseStatusCode = 0;
    NSDictionary *responseHeaderFields = nil;
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        responseStatusCode = (NSUInteger)[(NSHTTPURLResponse *)response statusCode];
        responseHeaderFields = [(NSHTTPURLResponse *)response allHeaderFields];
    }

    id responseObject = nil;
    if ([[notification object] respondsToSelector:@selector(responseString)]) {
        responseObject = [[notification object] responseString];
    } else if (notification.userInfo) {
        responseObject = notification.userInfo[AFNetworkingTaskDidCompleteSerializedResponseKey];
    }

    NSTimeInterval elapsedTime = [[NSDate date] timeIntervalSinceDate:objc_getAssociatedObject(notification.object, AFNetworkRequestStartDate)];

    if (error) {
        switch (self.level) {
            case AFLoggerLevelDebug:
            case AFLoggerLevelInfo:
            case AFLoggerLevelWarn:
            case AFLoggerLevelError:
                NSLog(@"[Error] %@ '%@' (%ld) [%.04f s]: %@", [request HTTPMethod], [[response URL] absoluteString], (long)responseStatusCode, elapsedTime, error);
            default:
                break;
        }
    } else {
        switch (self.level) {
            case AFLoggerLevelDebug:
                NSLog(@"##########################  请求返回结果开始  ###############################");
//                NSLog(@"\n-->HTTP状态码: %ld\n-->请求地址: '%@'\n-->所用时间: [%.04f s]\n-->头部信息:\n%@\n-->返回内容\n%@", (long)responseStatusCode, [[response URL] absoluteString], elapsedTime, responseHeaderFields, responseObject);
                NSLog(@"\n-->HTTP状态码: %ld\n-->请求地址: '%@'\n-->所用时间: [%.04f s]\n-->头部信息:\n%@\n-->返回内容\n", (long)responseStatusCode, [[response URL] absoluteString], elapsedTime, responseHeaderFields);
                [self logDic:responseObject];//输出\u的格式
                
                NSLog(@"##########################  请求返回结果结束  ###############################");
                
                
                break;
            case AFLoggerLevelInfo:
                NSLog(@"%ld '%@' [%.04f s]", (long)responseStatusCode, [[response URL] absoluteString], elapsedTime);
                break;
            default:
                break;
        }
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

#pragma mark 用户退出
- (void)userLogoutAction
{
    //提示用户退出
//    NSLog(@"提示用户重新登录");
//    UIAlertView *alt = [[UIAlertView alloc]initWithTitle:@"登录超时" message:@"请重新登录" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"好的", nil];
//    
//    return;
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //主动退出
    //WeakSelf
    if (buttonIndex != 0) {
        return;
    }
    @try {
        
        [logicShareInstance doLogoutLogic];
        
        AppDelegate *ad = [UIApplication sharedApplication].delegate;
        
        [ad changeRootViewController];
        
        [ad.window.rootViewController.navigationController popToRootViewControllerAnimated:YES];
    }
    @catch (NSException *exception) {}
    @finally {};
}
@end
