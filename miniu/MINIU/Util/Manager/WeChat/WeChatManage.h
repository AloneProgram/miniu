//
//  WeChat.h
//  DLDQ_IOS
//
//  Created by simman on 14-6-19.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LogicBaseModel.h"
#import "WXApi.h"
#import "WXPayEntity.h"
#import "BaseModel.h"
#import "WXApiObject.h"

typedef NS_ENUM(NSInteger, AccessErrorCode) {
    ERR_OK = 0,             // 用户同意
    ERR_AUTH_DENIED = -4,   // 用户拒绝
    ERR_USER_CANCEL = -2    // 用户取消
};


typedef NS_ENUM(NSUInteger, WXShareScene) {
    WXShareSceneSession  = 0,        /**< 聊天界面    */
    WXShareSceneTimeline = 1,        /**< 朋友圈      */
    WXShareSceneFavorite = 2,        /**< 收藏       */
};

@interface WechatShareEntity : BaseModel

@property (nonatomic, strong) NSString *title;      // 标题
@property (nonatomic, strong) NSString *openUrl;    // URL地址
@property (nonatomic, strong) UIImage *image;       // 图片
@property (nonatomic, strong) NSString *des;        // 描述


/**
 *  @brief  初始化方法
 *
 *  @param title   title
 *  @param openUrl url
 *  @param image   图片
 *  @param des     描述
 *
 *  @return
 */
- (instancetype) initWithTitle:(NSString *)title
                       openURL:(NSString *)openUrl
                    shareImage:(UIImage *)image
                   description:(NSString *)des;

@end


@interface WeChatManage : NSObject <LogicBaseModel, WXApiDelegate>
@property (nonatomic, strong) NSMutableDictionary *webShareDic; //分享网页字典
+ (instancetype)shareInstance;


/**
 *  登录
 */
- (void) sendAuthRequest:(void(^)(NSString *access_code))access_code_block
               errorCode:(void(^)(AccessErrorCode error_code))access_error_block;

/**
 *  添加微信好友（好友列表）
 */
- (void) addFriendWithWeChatWithSuccessBlock:(void(^)())successBlock
                                  errorBlock:(void(^)(NSString *error))errorBlock;

/**
 *  添加微信好友（朋友圈）
 */
- (void) addFriendWithWeChatFriendWithSuccessBlock:(void(^)())successBlock
                                        errorBlock:(void(^)(NSString *error))errorBlock;

/**
 *  分享到微信
 */
- (void) weChatShareForFriendListWithImage:(UIImage *)image title:(NSString *)title description:(NSString *)description openURL:(NSString *)openURL WithSuccessBlock:(void(^)())successBlock
                                errorBlock:(void(^)(NSString *error))errorBlock;;

/**
 *  分享到微信朋友圈
 */
- (void) weChatShareForFriendsWithImage:(UIImage *)image title:(NSString *)title description:(NSString *)description openURL:(NSString *)openURL WithSuccessBlock:(void(^)())successBlock
                             errorBlock:(void(^)(NSString *error))errorBlock;


/**
 *  @brief  发送图片到微信
 *
 *  @param imageUrl 图片地址
 *  @param image    图片数据
 *  @param scene    分享到？
 */
- (void) sendImageToWechat:(NSString *)imageUrl imageData:(UIImage *)image scene:(WXShareScene)scene WithSuccessBlock:(void (^)())successBlock errorBlock:(void (^)(NSString *error))errorBlock;

/**
 *  微信支付
 *
 *  @param wxpayment    支付实体
 *  @param successBlock 成功回调
 *  @param errorBlock   失败回调
 */
- (void) weChatPaymentWithWechatPayEntity:(WXPayEntity *)wxpayment
                         WithSuccessBlock:(void(^)())successBlock
                               errorBlock:(void(^)(NSString *error))errorBlock;


#pragma mark - 初始化信息
- (void) registerApp:(NSString *)appid withDescription:(NSString *)appdesc;
- (void)application:(UIApplication *)application handleOpenURL:(NSURL *)url;
- (void)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;

@end
