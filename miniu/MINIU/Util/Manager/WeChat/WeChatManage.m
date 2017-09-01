//
//  WeChat.m
//  DLDQ_IOS
//
//  Created by simman on 14-6-19.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import "WeChatManage.h"

@implementation WechatShareEntity

- (instancetype)init
{
    self = [super init];
    if (self) {
        _title = @"";
        _des = @"";
        _openUrl = @"";
        _image = [[UIImage alloc] init];
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title
                      openURL:(NSString *)openUrl
                   shareImage:(UIImage *)image
                  description:(NSString *)des
{
    self = [super init];
    
    if (self) {
        _title = title;
        _des = des;
        _image = image;
        _openUrl = openUrl;
    }
    return self;
}

@end


@interface WeChatManage()
@property (nonatomic, copy) void (^access_code_block)(NSString *code);
@property (nonatomic, copy) void (^access_error_block)(AccessErrorCode error_code);

@property (nonatomic, copy) void (^share_message_success_block)();
@property (nonatomic, copy) void (^share_message_error_block)(NSString *error);

@property (nonatomic, copy) void (^payment_success_block)();
@property (nonatomic, copy) void (^payment_error_block)(NSString *error);


@end

@implementation WeChatManage

+ (instancetype)shareInstance
{
    static WeChatManage * instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

/**
 *  发送微信登录请求
 */
- (void)sendAuthRequest:(void (^)(NSString *))access_code_block
              errorCode:(void (^)(AccessErrorCode))access_error_block
{
    _access_code_block = access_code_block;
    _access_error_block = access_error_block;
    
    SendAuthReq *req = [[SendAuthReq alloc] init];
    req.scope = @"snsapi_userinfo";
    req.state = @"miniu.org.dldq";
    
    [WXApi sendReq:req];
}


- (void) registerApp:(NSString *)appid withDescription:(NSString *)appdesc
{
    if ([WXApi registerApp:WXAppid withDescription:@"米妞"]) {
        
    } else {
        NSLog(@"\n[WXApi registerApp:WXAppid withDescription:@\"米妞\"]注册微信失败!\n");
    }
}

/**
 *  分享到微信
 */
- (void) weChatShareForFriendListWithImage:(UIImage *)image title:(NSString *)title description:(NSString *)description openURL:(NSString *)openURL WithSuccessBlock:(void (^)())successBlock
                                errorBlock:(void (^)(NSString *))errorBlock
{
    _share_message_error_block = errorBlock;
    _share_message_success_block = successBlock;
    
    NSString *newTitle = [[NSString alloc] init];
    
    //设置默认图片 默认描述
    if (!image) {
        image = [UIImage imageNamed:@"miniuicon"];
    }

    if (![description length]) {
        description = @"米妞";
    }
    if (![title length]) {
        if ([description length] > 40) {
            newTitle = [description substringToIndex:40];
        } else {
            newTitle = @"米妞来了";
        }
    } else {
        //标题长度的控制
        if ([title length] > 40) {
            newTitle = [title substringToIndex:40];
        } else {
            newTitle = title;
        }
    }
    if (!openURL) {
        openURL = @"www.dldq.org";
    }
    @try {
        WXMediaMessage *message = [WXMediaMessage message];
        message.title = newTitle;
        message.description = description;
        
        //设置自适应大小
        UIImage *newImage = [image scaledToSize:CGSizeMake(100, 100)];
        
        [message setThumbImage:newImage];
        
        WXWebpageObject *ext = [WXWebpageObject object];
        ext.webpageUrl = openURL;
        message.mediaObject = ext;
        
        //微信消息结构体
        SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
        //指定多媒体 or 文本
        req.bText = NO;
        req.message = message;
        //发送至 聊天 or 朋友圈 or 收藏
        req.scene = WXSceneSession;
        
        if ([WXApi sendReq:req]) {
            //发送成功
        }
        
    }
    @catch (NSException *exception) {
        NSLog(@"exception= %@", exception.reason);
    }
    @finally {

    }
}

/**
 *  分享到微信朋友圈
 */
- (void) weChatShareForFriendsWithImage:(UIImage *)image title:(NSString *)title description:(NSString *)description openURL:(NSString *)openURL WithSuccessBlock:(void (^)())successBlock
                             errorBlock:(void (^)(NSString *))errorBlock
{
    
    _share_message_error_block = errorBlock;
    _share_message_success_block = successBlock;
    
    @try {
        UIImage *newImage = [[UIImage alloc] init];
        NSString *newTitle = [[NSString alloc] init];
        
        if (!image) {
            newImage = [UIImage imageNamed:@"miniuicon"];
        } else {
            newImage = [image scaledToSize:CGSizeMake(100, 100)];
        }
 
        if (![description length]) {
            description = @"米妞";
        }
        if (![title length]) {
            if ([description length] > 40) {
                newTitle = [description substringToIndex:40];
            } else {
                newTitle = @"精彩米妞";
            }
        } else {
            if ([title length] > 40) {
                newTitle = [title substringToIndex:40];
            } else {
                newTitle = title;
            }
        }
        if (!openURL) {
            openURL = @"www.dldq.org";
        }
        
        WXMediaMessage *message = [WXMediaMessage message];
        message.title = newTitle;
        message.description = description;
        //消息缩略图
        [message setThumbImage:newImage];
        //设置url内容
        WXWebpageObject *ext = [WXWebpageObject object];
        ext.webpageUrl = openURL;
        message.mediaObject = ext;
        
        SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
        req.bText = NO;
        req.message = message;
        req.scene = WXSceneTimeline;
        BOOL flag = [WXApi sendReq:req];

    }
    @catch (NSException *exception) {
        NSLog(@"exception= %@", exception.reason);
    }
    @finally {}
}


/**
 *  邀请微信好友，分享到微信
 */
- (void) addFriendWithWeChatWithSuccessBlock:(void (^)())successBlock errorBlock:(void (^)(NSString *))errorBlock
{
    
    _share_message_error_block = errorBlock;
    _share_message_success_block = successBlock;
    
    @try {
        WXMediaMessage *message = [WXMediaMessage message];
        message.title = ShareWeChatRegisterTitle;
        message.description = ShareWeChatRegisterDes;
        [message setThumbImage:[UIImage imageNamed:@"miniuicon"]];
        WXWebpageObject *ext = [WXWebpageObject object];
//        ext.webpageUrl = [NSString stringWithFormat:@"%@/%@%lld", [[URLManager shareInstance] getNoServerBaseURL], @"/share/spread.action?appKey=ios&userId=", USER_IS_LOGIN];
        ext.webpageUrl = [NSString stringWithFormat:@"http://t.dldq.org/miniu/?from=ios&userId=%lld", USER_IS_LOGIN];
        message.mediaObject = ext;
        SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
        req.bText = NO;
        req.message = message;
        req.scene = WXSceneSession;
        [WXApi sendReq:req];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    };
}

/**
 *  邀请微信好友，分享到微信朋友圈
 */
- (void) addFriendWithWeChatFriendWithSuccessBlock:(void (^)())successBlock errorBlock:(void (^)(NSString *))errorBlock
{
    
    _share_message_error_block = errorBlock;
    _share_message_success_block = successBlock;
    
    @try {
        WXMediaMessage *message = [WXMediaMessage message];
        message.title = ShareWeChatRegisterTitle;
        message.description = ShareWeChatRegisterTitle;
        [message setThumbImage:[UIImage imageNamed:@"miniuicon"]];
        WXWebpageObject *ext = [WXWebpageObject object];
//        ext.webpageUrl = [NSString stringWithFormat:@"%@/%@%lld", [[URLManager shareInstance] getNoServerBaseURL], @"/share/spread.action?appKey=ios&userId=", USER_IS_LOGIN];
        ext.webpageUrl = [NSString stringWithFormat:@"http://t.dldq.org/miniu/?from=ios&userId=%lld", USER_IS_LOGIN];
        message.mediaObject = ext;
        SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
        req.bText = NO;
        req.message = message;
        req.scene = WXSceneTimeline;
        [WXApi sendReq:req];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    };
}

- (void)sendImageToWechat:(NSString *)imageUrl
                imageData:(UIImage *)image
                    scene:(WXShareScene)scene
         WithSuccessBlock:(void (^)())successBlock
               errorBlock:(void (^)(NSString *))errorBlock
{
    
    _share_message_error_block = errorBlock;
    _share_message_success_block = successBlock;
    
    WXImageObject *imageObj = [WXImageObject object];
    
    if (image) {
        imageObj.imageData = UIImageJPEGRepresentation(image, 1);
    }
    
    if (imageUrl && [imageUrl length]) {
        imageObj.imageUrl = imageUrl;
    }
    
    WXMediaMessage *mediaMessage = [WXMediaMessage message];
    mediaMessage.mediaObject = imageObj;
    if (image) {
        [mediaMessage setThumbImage:[image scaledToSize:CGSizeMake(100, 100)]];
    }
    
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = mediaMessage;
    req.scene = scene;
    [WXApi sendReq:req];
}

#pragma mark - 微信相关
-(void) onReq:(BaseReq*)req
{
    if([req isKindOfClass:[GetMessageFromWXReq class]])
    {
        // 微信请求App提供内容， 需要app提供内容后使用sendRsp返回
        NSString *strTitle = [NSString stringWithFormat:@"微信请求App提供内容"];
        NSString *strMsg = @"微信请求App提供内容，App要调用sendResp:GetMessageFromWXResp返回给微信";
        NSLog(@"WeChat--->> %@ ___ %@", strTitle, strMsg);
    }
    else if([req isKindOfClass:[ShowMessageFromWXReq class]])
    {
//        ShowMessageFromWXReq* temp = (ShowMessageFromWXReq*)req;
//        WXMediaMessage *msg = temp.message;
        
        //显示微信传过来的内容
//        WXAppExtendObject *obj = msg.mediaObject;
        
//        NSString *strTitle = [NSString stringWithFormat:@"微信请求App显示内容"];
//        NSString *strMsg = [NSString stringWithFormat:@"标题：%@ \n内容：%@ \n附带信息：%@ \n缩略图:%u bytes\n\n", msg.title, msg.description, obj.extInfo, msg.thumbData.length];
//        NSLog(@"WeChat--->> %@ ___ %@", strTitle, strMsg);
    }
    else if([req isKindOfClass:[LaunchFromWXReq class]])
    {
        //从微信启动App
//        NSString *strTitle = [NSString stringWithFormat:@"从微信启动"];
//        NSString *strMsg = @"这是从微信启动的消息";
//        NSLog(@"WeChat--->> %@ _____ %@", strTitle, strMsg);
    }
}

-(void) onResp:(BaseResp*)resp
{
    if([resp isKindOfClass:[SendAuthResp class]])
    {
        SendAuthResp *respp = (SendAuthResp *)resp;
        if (respp.errCode == ERR_OK) {
            if (_access_code_block) {
                _access_code_block(respp.code);
            }
        } else {
            if (_access_error_block) {
                _access_error_block(respp.errCode);
            }
        }
    }
    
    if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
        
        SendMessageToWXResp *respp = (SendMessageToWXResp *)resp;
        
        if (respp.errCode == ERR_OK) {
            if (_share_message_success_block) {
                _share_message_success_block();
            }
        } else {
            if (_share_message_error_block) {
                if (respp.errStr) {
                    _share_message_error_block(respp.errStr);
                }
            }
        }
    }
    
    if([resp isKindOfClass:[PayResp class]]){
        
        switch (resp.errCode) {
            case WXSuccess:
                if (_payment_success_block) {
                    _payment_success_block(@"支付成功!");
                }
                NSLog(@"微信支付支付成功－PaySuccess，retcode = %d", resp.errCode);
                break;
                
            default:
                if (_payment_error_block) {
                    _payment_error_block(resp.errStr);
                }
                NSLog(@"微信支付错误，retcode = %d, retstr = %@", resp.errCode,resp.errStr);
                break;
        }
    }
}

#pragma mark 微信支付
- (void)weChatPaymentWithWechatPayEntity:(WXPayEntity *)wxpayment
                        WithSuccessBlock:(void (^)())successBlock
                              errorBlock:(void (^)(NSString *))errorBlock
{
    _payment_success_block = successBlock;
    _payment_error_block = errorBlock;
    if (wxpayment) {
        [WXApi safeSendReq:wxpayment];
    } else {
        errorBlock(@"请求微信失败,请重试!");
    }
}

- (void)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    [WXApi handleOpenURL:url delegate:self];
}

- (void)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    [WXApi handleOpenURL:url delegate:self];
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
