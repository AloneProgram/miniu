//
//  UserManager.h
//  DLDQ_IOS
//
//  Created by simman on 14-8-29.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ManagerBase.h"
@class RegisterUserEntity, UserEntity;


/**
 *  上传的认证信息类型
 */
typedef NS_ENUM(NSInteger, VerifyBuyerUploadFlag) {
    /**
     *  身份证
     */
    VerifyBuyerUploadFlagOfIdCardPhoto = 1,
    /**
     *  学业证明
     */
    VerifyBuyerUploadFlagOfPractitioners,
    /**
     *  当地地址图片
     */
    VerifyBuyerUploadFlagOfLocationAddress,
    /**
     *  三个月购物凭证
     */
    VerifyBuyerUploadFlagOfShoppingCertificate,
    /**
     *  物流凭证
     */
    VerifyBuyerUploadFlagOfLogisticsCertificate,
    /**
     *  当地背景的个人图片
     */
    VerifyBuyerUploadFlagOfLocBackGroundProfile
};

@interface UserManager : ManagerBase <LogicBaseModel>

/**
 *  用户管理对象单例
 *
 *  @return
 */
+ (instancetype)shareInstance;


#pragma mark - Setter 方法

/**
 *  更新当前的用户信息
 */
- (void) updateCurrentUser:(UserEntity *)user;

/**
 *  用户登录
 *
 *  @param user 用户实例
 *
 */
- (void)userLogin:(NSDictionary *)dic;

#pragma mark -  Getter 方法

/**
 *  获取当前用户
 *
 *  @return 用户实体
 */
- (UserEntity *) getCurrentUser;

/**
 *  获取当前用户的真实姓名
 *
 *  @return 
 */
- (NSString *) getCurrentUserRealName;

/**
 *  获取当前用户的环信账号
 *
 *  @return 账号
 */
- (NSString *) getCurrentUserHXID;

/**
 *  获取当前用户的换新密码
 *
 *  @return 密码
 */
- (NSString *) getCurrentUserHXpwd;

/**
 *  获取当前用户的nickname
 *
 *  @return
 */
- (NSString *) getCurrentUserName;

/**
 *  获取当前用户的UserID
 *
 *  @return
 */
- (long long) getCurrentUserID;

/**
 *  获取当前用户的头像
 *
 *  @return
 */
- (NSString *) getCurrentUserAvatar;

/**
 *  是否绑定了银行卡
 *
 *  @return
 */
- (BOOL) isBindBankcard;


- (NSString *) getWeixinUName;

/**
 *  是否绑定了 alipay
 *
 *  @return 
 */
- (BOOL) isBindAliAccount;

/**
 *  获取当前用户是否为买手
 *
 *  @return
 */
- (BOOL) getCurrentUserIsBuyer;

/**
 *  获取当前用户是否为认证买手
 *
 *  @return 
 */
- (BOOL) getCurrentUserIsVbuyer;


- (NSString *) getCurrentUserServiceHxUId;

/**
 *  获取当前用户的推送ID
 *
 *  @return
 */
- (NSString *) getCurrentUserRegistrationID;

/**
 *  设置用户已经绑定过支付宝
 */
- (void) setUserIsSubmitBindAlipayAccount;

/**
 *  获取用户是否绑定过支付宝
 *
 *  @return
 */
- (BOOL) getUserIsSubmitBindAlipayAccount;

/**
 *  获取当前用户的设置
 *
 *  @return
 */
- (NSDictionary *) getCurrentUserSetting;

/**
 *  设置用的个人设置
 *
 *  @param dic
 */
- (void) setCurrentUserSettingWithDic:(NSDictionary *)dic;

/**
 *  检查资料是否完整
 */
- (void) checkUserInfoIsFull:(void(^)(BOOL isSuccess, NSString *error))blocks;

/**
 *  是否为微信登录 (是否为使用“微信”登录)
 *
 *  @return
 */
- (BOOL) isLoginWithWechat;

- (NSString *)getSessionId;

// ＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝

/**
 *  用户注册校验
 *
 *  @param entity  注册单例
 *  @param success 成功回调
 *  @param failure 失败回调
 *
 *  @return 网络标识
 */
- (NSURLSessionDataTask *)registWithValidataUser:(RegisterUserEntity *)entity
                                         success:(void(^)(id responseObject))success
                                         failure:(void(^)(NSString *error))failure;

/**
 *  用户注册提交
 *
 *  @param entity  用户注册提交
 *  @param success 成功回调
 *  @param failure 失败回调
 *
 *  @return 网络标识
 */
- (NSURLSessionDataTask *)registWithSubmitUser:(RegisterUserEntity *)entity
                                       success:(void(^)(id responseObject))success
                                       failure:(void(^)(NSString *error))failure;

/**
 *  用户登录（手机号）
 *
 *  @param entity
 *  @param success 成功回调
 *  @param failure 失败回调
 *
 *  @return 网络标识
 */
- (NSURLSessionDataTask *)loginWithPhone:(RegisterUserEntity *)entity
                                 success:(void (^)(id responseObject))success
                                 failure:(void (^)(NSString *error))failure;


/**
 *  微信登录
 *
 *  @param code    微信返回的Code
 *  @param success 成功回调
 *  @param failure 失败回调
 *
 *  @return 网络标识
 */
- (NSURLSessionDataTask *)loginWithWeChatCode:(NSString *)code
                                      success:(void (^)(id responseObject))success
                                      failure:(void (^)(NSString *error))failure;

/**
 *  重发验证码
 *
 *  @param entity
 *  @param isVerifyPhone  0 不检验手机号，1检验手机号
 *  @param success 成功回调
 *  @param failure 失败回调
 *
 *  @return 网络标识
 */
- (NSURLSessionDataTask *)reSendSMSWithPhone:(RegisterUserEntity *)entity
                               isVerifyPhone:(BOOL)isVerifyPhone
                                     success:(void (^)(id responseObject))success
                                     failure:(void (^)(NSString *error))failure;

/**
 *  密码找回第一步
 *
 *  @param entity
 *  @param success 成功回调
 *  @param failure 失败回调
 *
 *  @return 网络标识
 */
- (NSURLSessionDataTask *)forgotPwdWithOne:(RegisterUserEntity *)entity
                                   success:(void (^)(id responseObject))success
                                   failure:(void (^)(NSString *error))failure;

/**
 *  密码找回第二步
 *
 *  @param entity
 *  @param newPwd  新密码
 *  @param success 成功回调
 *  @param failure 失败回调
 *
 *  @return 网络标识
 */
- (NSURLSessionDataTask *)forgotPwdWithTwo:(RegisterUserEntity *)entity
                                    newPwd:(NSString *)newPwd
                                   success:(void (^)(id responseObject))success
                                   failure:(void (^)(NSString *error))failure;

/**
 *  重设密码
 *
 *  @param entity
 *  @param oldPwd  旧密码
 *  @param newPwd  新密码
 *  @param success 成功回调
 *  @param failure 失败回调
 *
 *  @return 网络标识
 */
- (NSURLSessionDataTask *)reSetPWDWithPhone:(RegisterUserEntity *)entity
                                     oldPwd:(NSString *)oldPwd
                                     newPwd:(NSString *)newPwd
                                    success:(void (^)(id responseObject))success
                                    failure:(void (^)(NSString *error))failure;

/**
 *  获取用户信息
 *
 *  @param success 成功回调
 *  @param failure 失败回调
 *
 *  @return 
 */
- (NSURLSessionDataTask *)getUserInfoSuccess:(void (^)(id responseObject))success
                                     failure:(void (^)(NSString *error))failure;

/**
 *  修改资料
 *
 *  @param dicData 修改的字典
 *  @param success 成功回调
 *  @param failure 失败回调
 *
 *  @return 网络标识
 */
- (NSURLSessionDataTask *)updateInfoWithPhone:(NSDictionary *)dicData
                                      success:(void (^)(id responseObject))success
                                      failure:(void (^)(NSString *error))failure;

/**
 *  用户退出
 *
 *  @param userEntity 用户实例
 *  @param success    成功回调
 *  @param failure    失败回调
 *
 *  @return
 */
- (NSURLSessionDataTask *)userLogout:(void (^)(id responseObject))success
                                      failure:(void (^)(NSString *error))failure;

/**
 *  添加关注
 *
 *  @param userId  被关注人的UID
 *  @param success 成功回调
 *  @param failure 失败回调
 *
 *  @return 网络标识
 */
- (NSURLSessionDataTask *)addFollowWithUserId:(long long)userId
                                      success:(void (^)(id responseObject))success
                                      failure:(void (^)(NSString *error))failure;

/**
 *  取消关注
 *
 *  @param userId  被取消关注人的ID
 *  @param success 成功回调
 *  @param failure 失败回调
 *
 *  @return 网络标识
 */
- (NSURLSessionDataTask *)delFollowWithUserId:(long long)userId
                                      success:(void (^)(id responseObject))success
                                      failure:(void (^)(NSString *error))failure;


/**
 *  添加一键下图授权
 *
 *  @param userId  被关注人的UID
 *  @param success 成功回调
 *  @param failure 失败回调
 *
 *  @return 网络标识
 */
- (NSURLSessionDataTask *)addImageGrantWithUserId:(long long)userId
                                      success:(void (^)(id responseObject))success
                                      failure:(void (^)(NSString *error))failure;

/**
 *  取消一键下图授权
 *
 *  @param userId  被取消关注人的ID
 *  @param success 成功回调
 *  @param failure 失败回调
 *
 *  @return 网络标识
 */
- (NSURLSessionDataTask *)delImageGrantWithUserId:(long long)userId
                                      success:(void (^)(id responseObject))success
                                      failure:(void (^)(NSString *error))failure;

/**
 *  获取关注列表
 *
 *  @param userId      用户ID
 *  @param currentPage 当前页数
 *  @param pageSize    没页数量
 *  @param success     成功回调
 *  @param failure     失败回调
 *
 *  @return 网络标识
 */
- (NSURLSessionDataTask *)getFollowListWithUserId:(long long)userId
                                      CurrentPage:(NSInteger)currentPage
                                         pageSize:(NSInteger)pageSize
                                          success:(void (^)(id responseObject))success
                                          failure:(void (^)(NSString *error))failure;

/**
 *  获取粉丝列表
 *
 *  @param userId      用户ID
 *  @param currentPage 当前页数
 *  @param pageSize    没页数量
 *  @param success     成功回调
 *  @param failure     失败回调
 *
 *  @return 网络标识
 */
- (NSURLSessionDataTask *)getFansListWithUserId:(long long)userId
                                      CurrentPage:(NSInteger)currentPage
                                         pageSize:(NSInteger)pageSize
                                          success:(void (^)(id responseObject))success
                                          failure:(void (^)(NSString *error))failure;

/**
 *  获取一键下图列表
 *
 *  @param currentPage 当前页码
 *  @param pageSize    每页数量
 *  @param success     成功回调
 *  @param failure     失败回调
 *
 *  @return 网络标识
 */
- (NSURLSessionDataTask *)getVerifyListWithCurrentPage:(NSInteger)currentPage
                                       pageSize:(NSInteger)pageSize
                                        success:(void (^)(id responseObject))success
                                        failure:(void (^)(NSString *error))failure;

/**
 *  获取用户信息（根据环信ID）
 *
 *  @param hxid    环信ID
 *  @param success 成功回调
 *  @param failure 失败回调
 *
 *  @return 网络标识
 */
- (NSURLSessionDataTask *)getUserInfoByHXUid:(NSString *)hxid
                                        success:(void (^)(id responseObject))success
                                        failure:(void (^)(NSString *error))failure;


- (void) getUserEntityWithHXID:(NSString *)hxid
                               result:(void (^)(UserEntity *userEntity))result;

/**
 *  获取愿望清单
 *
 *  @param success 成功回调
 *  @param failure 失败回调
 *
 *  @return 网络标识
 */
- (NSURLSessionDataTask *)getCollectListWithCurrentPage:(NSInteger)currentPage
                                               pageSize:(NSInteger)pageSize
                                                success:(void (^)(id responseObject))success
                                                failure:(void (^)(NSString *error))failure;

/**
 *  给买手评分
 *
 *  @param toUserId 给谁评分
 *  @param score    评分值
 *  @param success  成功回调
 *  @param failure  失败回调
 *
 *  @return 网络标识
 */
- (NSURLSessionDataTask *)userMarkScoreWithToUid:(long long)toUserId
                                           score:(NSInteger)score
                                     success:(void (^)(id responseObject))success
                                     failure:(void (^)(NSString *error))failure;

/**
 *  买手搜索
 *
 *  @param keyword     关键字
 *  @param currentPage 当前页数
 *  @param pageSize    每页数量
 *  @param success     成功回调
 *  @param failure     失败回调
 *
 *  @return 网络标识
 */
- (NSURLSessionDataTask *)searchBuyerWithKeyWord:(NSString *)keyword
                                    CurrentPage:(NSInteger)currentPage
                                       pageSize:(NSInteger)pageSize
                                        success:(void (^)(id responseObject))success
                                        failure:(void (^)(NSString *error))failure;


/**
 *  搜索授权--粉丝列表
 *
 *  @param keyword     关键字
 *  @param currentPage 当前页数
 *  @param pageSize    每页数量
 *  @param success     成功回调
 *  @param failure     失败回调
 *
 *  @return 网络标识
 */
- (NSURLSessionDataTask *)searchUserWithKeyWord:(NSString *)keyword
                                     CurrentPage:(NSInteger)currentPage
                                        pageSize:(NSInteger)pageSize
                                         success:(void (^)(id responseObject))success
                                         failure:(void (^)(NSString *error))failure;


/**
 *  买手列表
 *
 *  @param success 成功回调
 *  @param failure 失败回调
 *
 *  @return 网络标识
 */
- (NSURLSessionDataTask *)getBuyerListWithCurrentPage:(NSInteger)currentPage
                                             pageSize:(NSInteger)pageSize
                                              Success:(void (^)(id responseObject))success
                                              failure:(void (^)(NSString *error))failure;


/**
 *  用户列表
 *
 *  @param success 成功回调
 *  @param failure 失败回调
 *
 *  @return 网络标识
 */
- (NSURLSessionDataTask *)getUserListWithCurrentPage:(NSInteger)currentPage
                                             pageSize:(NSInteger)pageSize
                                              Success:(void (^)(id responseObject))success
                                              failure:(void (^)(NSString *error))failure;

/**
 *  根据ChannelID获取买手列表
 *
 *  @param channelId
 *  @param currentPage
 *  @param pageSize
 *  @param success
 *  @param failure
 *
 *  @return 网络标识
 */
- (NSURLSessionDataTask *)getBuyerListWithChannelId:(NSInteger)channelId
                                        CurrentPage:(NSInteger)currentPage
                                           pageSize:(NSInteger)pageSize
                                            Success:(void (^)(id responseObject))success
                                            failure:(void (^)(NSString *error))failure;

/**
 *  反馈意见
 *
 *  @param content 内容
 *  @param email   邮箱
 *  @param success 成功回调
 *  @param failure 失败回调
 *
 *  @return 网络标识
 */
- (NSURLSessionDataTask *)postFeedBackWith:(NSString *)content
                                     email:(NSString *)email
                                   Success:(void (^)(id responseObject))success
                                   failure:(void (^)(NSString *error))failure;

/**
 *  申请认证买手
 *
 *  @param flag     上传的资料类型
 *  @param imageUrl 图片 URL
 *  @param success  成功回掉
 *  @param failure  失败回掉
 *
 *  @return 网络标识
 */
- (NSURLSessionDataTask *)uploadVerifyBuyerFileWithUploadFlag:(VerifyBuyerUploadFlag)flag
                                          imageUrl:(NSString *)imageUrl
                                           Success:(void (^)(id responseObject))success
                                           failure:(void (^)(NSString *error))failure;

/**
 *  申请买手认证
 *
 *  @param idno     身份证
 *  @param imageUrl 身份证URL
 *  @param flag     类型
 *  @param success  成功回调
 *  @param failure  失败回调
 *
 *  @return 网络标识
 */
- (NSURLSessionDataTask *)uploadVerifyFileWithIDNO:(NSString *)idno
                                          imageUrl:(NSString *)imageUrl
                                        uploadFlag:(NSInteger)flag
                                   Success:(void (^)(id responseObject))success
                                   failure:(void (^)(NSString *error))failure;

/**
 *  绑定银行卡借口
 *
 *  @param bankCardNo 银行卡
 *  @param bankName   银行名称
 *  @param branchName 银行地址
 *  @param success    成功回调
 *  @param failure    失败回调
 *
 *  @return 网络标识
 */
- (NSURLSessionDataTask *)bindBankCardWithCardID:(NSString *)bankCardNo
                                          bankName:(NSString *)bankName
                                        branchName:(NSString *)branchName
                                           Success:(void (^)(id responseObject))success
                                           failure:(void (^)(NSString *error))failure;

/**
 *  获取绑定的银行卡
 *
 *  @param success 成功回调
 *  @param failure 失败回调
 *
 *  @return 网络标识
 */
- (NSURLSessionDataTask *)getBindCardSuccess:(void (^)(id responseObject))success
                                         failure:(void (^)(NSString *error))failure;

/**
 *  绑定支付宝帐号
 *
 *  @param success 成功回调
 *  @param failure 失败回调
 *
 *  @return 网络标识
 */
- (NSURLSessionDataTask *)bindAlipaySuccess:(void (^)(id responseObject))success
                                    failure:(void (^)(NSString *error))failure;


/**
 *  @brief  发送手机短信
 *
 *  @param mobile
 *  @param countryCode
 *  @param success 成功回调
 *  @param failure 失败回调
 *
 *  @return 网络标识
 */
- (NSURLSessionDataTask *)sendMsgWithBindMobile:(NSString *)mobile
                                        countryCode:(NSString *)countryCode
                                         Success:(void (^)(id responseObject))success
                                         failure:(void (^)(NSString *error))failure;

/**
 *  @brief  绑定手机号码
 *
 *  @param mobile
 *  @param countryCode
 *  @param smsCode
 *  @param success 成功回调
 *  @param failure 失败回调
 *
 *  @return 网络标识
 */
- (NSURLSessionDataTask *)bindMobile:(NSString *)mobile
                                    countryCode:(NSString *)countryCode
                                        smsCode:(NSString *)smsCode
                                        Success:(void (^)(id responseObject))success
                                        failure:(void (^)(NSString *error))failure;

/**
 *  @brief  更新用户的SendId
 *
 *  @param sendId  SENDID
 *  @param success 成功回调
 *  @param failure 失败回调
 *
 *  @return 网络标识
 */
- (NSURLSessionDataTask *)updateSendId:(NSString *)sendId
                             Success:(void (^)(id responseObject))success
                             failure:(void (^)(NSString *error))failure;
@end
