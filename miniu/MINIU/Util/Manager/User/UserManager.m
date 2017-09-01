//
//  UserManager.m
//  DLDQ_IOS
//
//  Created by simman on 14-8-29.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import "UserManager.h"
#import "UserEntity.h"
#import "RegisterUserEntity.h"
#import "NSUserDefaults+Category.h"

#import "STDb.h"

#define API_USER_VALIDATE               @{@"method":     @"user.validate"}         // 用户注册的校验
#define API_USER_REGISTER               @{@"method":     @"user.register"}         // 用户注册提交
#define API_USER_LOGIN_WITH_PHONE       @{@"method":     @"user.login.phone"}      // 用户登录
#define API_USER_LOGIN_WITH_WECHAT      @{@"method":     @"user.login.weixin"}      // 微信登录

#define API_USER_RESEND_SMS             @{@"method":            @"smsCode.resend"}        // 重发验证码
#define API_USER_RESET_PWD              @{@"method":             @"user.resetpwd"}         // 重置密码
#define API_USER_UPDATE_INFO            @{@"method":           @"user.update"}           // 更新资料
#define API_USER_FORGOT_PWD_ONE         @{@"method":        @"user.forgetpwd.stepOne"}// 第一步发送验证码和校验手机号码
#define API_USER_FORGOT_PWD_TWO         @{@"method":        @"user.forgetpwd.stepTwo"}// 提交修改的密码
#define API_USER_LOGOUT                 @{@"method":        @"user.logout"}           // 用户退出

#define API_USER_ADD_FOLLOW             @{@"method":    @"user.follow.add"}   // 添加关注
#define API_USER_CANCEL_FOLLOW          @{@"method": @"user.follow.cancel"}// 取消关注
#define API_USER_FOLLW_LIST             @{@"method":    @"otherUser.follow.list"}  // 关注列表
#define API_USER_FANS_LIST              @{@"method":     @"otherUser.fans.list"}    // 粉丝列表

#define API_USER_VERIFY_LIST            @{@"method":     @"user.fans.list"}    // 授权接口
#define API_USER_ADD_GRANT              @{@"method":    @"imgdownload.grant.add"}   // 添加授权
#define API_USER_CANCEL_GRANT           @{@"method": @"imgdownload.grant.cancel"}// 取消授权
#define API_USER_SEARCH_GRANT           @{@"method": @"imgdownload.grant.usersearch"}// 搜索我的粉丝

#define API_USER_USERINFO_HXID          @{@"method":     @"user.hxUId"}

#define API_USER_COLLECT_LIST           @{@"method":   @"user.collect.list"}// 愿望清单
#define API_USER_MARK_SCORE             @{@"method": @"user.markScore"}

#define API_USER_SEARCH_BUYER           @{@"method": @"search.user.list"}    // 搜索买手
#define API_USER_BUYER_LIST             @{@"method": @"buyer.classify.list"}    // 买手列表
#define API_USER_LIST                   @{@"method": @"user.pageList"}    // 用户列表
#define API_USER_RECOMMENT_BUYER        @{@"method": @"channel.buyer.list"}    // 发现推荐买手

#define API_USER_INFO                   @{@"method": @"user.baseInfo"}    // 用户详情

#define API_POST_FEEDBACK               @{@"method": @"user.feedBack.add"}    // 反馈意见

#define API_UPLOAD_VERIFY_FILE          @{@"method": @"user.upload.auth"}

#define API_BUYER_BIND_BANKCARD         @{@"method": @"buyer.bind.bankcard"}

#define API_BUYER_BIND_ALIPAY           @{@"method": @"user.bind.alipayAccount"}

#define API_BUYER_GET_BIND_BANKCARD     @{@"method": @"buyer.getbind.bankcard"}

#define API_SEND_BIND_MOBILE_MSG        @{@"method": @"phone.bind.stepone"}
#define API_SEND_BIND_MOBILE_CODE       @{@"method": @"phone.bind.steptwo"}

#define API_USER_UPDATE_SENDID          @{@"method": @"user.update.sendId"}

//#define USER_INFO_PATH     [NSString stringWithFormat:@"%@/%@", PATH_OF_DOCUMENT, @"lastUserInfo.plist"]

//#define USER_INFO_CACHE_NAME    @"cf79ae6addba60ad018347359bd144d2"

@interface UserManager() {
    
}
@property (nonatomic, retain) UserEntity *currentLoginUser;   // 当前登录的用户
@property (nonatomic, strong) TMDiskCache *hxUserCacheEntity;       // 环信缓存相关的实体

@end

@implementation UserManager

+ (instancetype)shareInstance
{
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype) init
{
    self = [super init];
    if (self) {
        self.currentLoginUser = [[UserEntity alloc] init];
        [self loadUserInfo];
        self.hxUserCacheEntity = [[TMCache alloc] initWithName:@"HXUSERCACHE"].diskCache;
        self.hxUserCacheEntity.ageLimit = 3600 * 24 * 3;//3天
    }
    return self;
}

- (void) loadUserInfo
{
    // 首先更新数据库
    NSArray *users = [UserEntity dbObjectsWhere:[NSString stringWithFormat:@"userId=%lld", [self getCurrentUserID]] orderby:nil];
 
    if ([users firstObject]) {
        self.currentLoginUser = [users firstObject];
        [NSUSER_DEFAULT setObj:[NSString stringWithFormat:@"%lld", self.currentLoginUser.userId] forKey:@"CURRENT_USER_ID"];
    } else {
        [NSUSER_DEFAULT setObj:@"" forKey:@"CURRENT_USER_ID"];
    }
}

- (void)userLogin:(NSDictionary *)dic
{
    UserEntity *user = [[UserEntity alloc] init];
    [user setValuesForKeysWithDictionary:dic];
    if ([user insertToDb]) {
        [NSUSER_DEFAULT setObj:[NSString stringWithFormat:@"%lld", user.userId] forKey:@"CURRENT_USER_ID"];
        self.currentLoginUser = user;
    }
}

- (long long)getCurrentUserID
{
    NSString *currentUserId = [NSUSER_DEFAULT objForKey:@"CURRENT_USER_ID"];
    return [currentUserId longLongValue];
}

- (NSString *)getSessionId
{
    return self.currentLoginUser.sessionKey ? self.currentLoginUser.sessionKey : @"";
}

- (void) updateCurrentUser:(UserEntity *)user
{
    UserEntity *updateUser = self.currentLoginUser;

    [updateUser removeFromDb];
    
    if ([user insertToDb]) {
        self.currentLoginUser = user;
    }
}

- (NSString *)getCurrentUserHXID
{
    return self.currentLoginUser.hxUId;
}

- (NSString *)getCurrentUserHXpwd
{
    return self.currentLoginUser.hxPwd;
}

- (NSString *) getCurrentUserRealName
{
    return self.currentLoginUser.realName;
}

- (UserEntity *) getCurrentUser
{
    return self.currentLoginUser;
}

- (NSString *)getCurrentUserServiceHxUId
{
    return self.currentLoginUser.serviceHxUId;
}

- (BOOL)isBindAliAccount
{
    return self.currentLoginUser.isBindAliAccount;
}

- (void) setUserIsSubmitBindAlipayAccount
{
    [NSUSER_DEFAULT setBool:YES forKey:@"setUserIsSubmitBindAlipayAccount"];
    [NSUSER_DEFAULT synchronize];
}

- (BOOL) getUserIsSubmitBindAlipayAccount
{
    return [NSUSER_DEFAULT boolForKey:@"setUserIsSubmitBindAlipayAccount"];
}

- (BOOL)isBindBankcard
{
    return self.currentLoginUser.isBindBankcard;
}

- (NSString *)getWeixinUName
{
    return self.currentLoginUser.weixinUName;
}

- (NSString *) getCurrentUserName
{
    return self.currentLoginUser.nickName;
}

- (NSString *) getCurrentUserAvatar
{
    return self.currentLoginUser.avatar;
}

- (BOOL) getCurrentUserIsBuyer
{
    return (self.currentLoginUser.roleType > 1);
}

- (BOOL) getCurrentUserIsVbuyer
{
    return (self.currentLoginUser.roleType == 3);
}

- (BOOL)isLoginWithWechat
{
    // 如果有正确的手机号码，则为手机号码登录，否则为微信登录
    if ([self.currentLoginUser.phone length] > 5) {
        return NO;
    }
    return YES;
}

#pragma mark 检查用户完整
- (void)checkUserInfoIsFull:(void (^)(BOOL, NSString *))blocks
{
    BOOL isFull = YES;
    
    NSString *error = nil;
    NSRange range = [[self getCurrentUserAvatar] rangeOfString:@"Default"];
    if (range.location != NSNotFound){ //不包含
        isFull = NO;
        error = @"你必须上传头像!";
    }
    
    if (![[self getCurrentUserName] length] || [[self getCurrentUserName] isEqualToString:@"匿名用户"]) {
        isFull = NO;
        error = @"您需要修改用户昵称!";
    }
    
    if (![[CURRENT_USER_INSTANCE getCurrentUser].countryName length] || ![[CURRENT_USER_INSTANCE getCurrentUser].cityName length]) {
        isFull = NO;
        error = @"您需要选择国家区域!";
    }
    
    if (![[CURRENT_USER_INSTANCE getCurrentUser].signature length]) {
        isFull = NO;
        error = @"您需要完善签名!";
    }
    
    if (![[CURRENT_USER_INSTANCE getCurrentUser].realName length]) {
        isFull = NO;
        error = @"您需要填写真实姓名!";
    }
    
    if (![CURRENT_USER_INSTANCE getCurrentUser].borndate) {
        isFull = NO;
        error = @"您需要填写出生日期!";
    }
    
    if (![[CURRENT_USER_INSTANCE getCurrentUser].sex length]) {
        isFull = NO;
        error = @"您需要选择性别!";
    }
    
    if (![[CURRENT_USER_INSTANCE getCurrentUser].email length]) {
        isFull = NO;
        error = @"您需要填写Email地址!";
    }
    
    if (!error) {
        error = @"";
    }
    
    blocks(isFull, error);
}

#pragma mark 获取当前用户的推送ID
- (NSString *) getCurrentUserRegistrationID
{
    // 直接拿Jpush的推送Id
    NSString *registerid = [APService registrationID];
    
    // 如果没有拿到,则使用本地存储的数值
    if (registerid || ![registerid length]) {
        
        NSString *loc = [NSUSER_DEFAULT objForKey:JPUSH_SENDID];
        if (loc) {
            registerid = [NSString stringWithFormat:@"%@", loc];
        }
    }
    return registerid;
}

#pragma mark 设置用的个人设置
- (void) setCurrentUserSettingWithDic:(NSDictionary *)dic
{
    [NSUSER_DEFAULT setObj:dic forKey:@"user_setting"];
}

#pragma mark 获取当前用户的设置
- (NSDictionary *) getCurrentUserSetting
{
    return [NSUSER_DEFAULT objForKey:@"user_setting"];
}


#pragma mark 根据环信ID获取用户实体
- (void)getUserEntityWithHXID:(NSString *)hxid
                       result:(void (^)(UserEntity *))result;
{
    UserEntity *user = [[UserEntity alloc] init];
    
    if (hxid && [hxid length]) {
        // 如果是当前用户 快速获取当前用户实体
        if ([hxid isEqualToString:[self getCurrentUserHXID]]) {
            if (result) {
                result(self.currentLoginUser);
            }
            return;
        }
        
        //[[UIApplication sharedApplication] currentUserNotificationSettings].types = 0;
        
        // 查询本地是否有数据
        NSString *hxUsercacheName = [NSString stringWithFormat:@"HXUSERCACHE%@", hxid];
        NSString *hxUserCacheURL = [NSString stringWithFormat:@"%@%@%@", PATH_OF_LIBRARY, @"/Caches/com.tumblr.TMDiskCache.HXUSERCACHE/", hxUsercacheName];
        
        // 如果存在
        if ([[NSFileManager defaultManager] fileExistsAtPath:hxUserCacheURL]) {
            
            @try {
                // 取出数据字典
                NSDictionary *userDic = (NSDictionary *)[self.hxUserCacheEntity objectForKey:hxUsercacheName];
                
                user.userId     = [[userDic objectForKey:@"userId"] integerValue];
                user.nickName   = [userDic objectForKey:@"nickName"];
                user.avatar     = [userDic objectForKey:@"avatar"];
                user.sendId     = [userDic objectForKey:@"sendId"];
                user.hxUId      = [userDic objectForKey:@"hxUId"];
                user.roleType   = [[userDic objectForKey:@"roleType"] integerValue];
            }
            @catch (NSException *exception) {
                NSLog(@"error :  %@", exception.reason);
            }
            @finally {
                
            }
            
            if (result) {
                result(user);
            }
        }else { // 如果不存在
            
            [self getUserInfoByHXUid:hxid success:^(id responseObject) {
                UserEntity *tmpUser = [[UserEntity alloc] init];
                [tmpUser setValuesForKeysWithDictionary:[responseObject objectForKey:@"data"]];
                NSDictionary *userDic = [tmpUser toDictionary];
                [self.hxUserCacheEntity setObject:userDic forKey:[NSString stringWithFormat:@"HXUSERCACHE%@", tmpUser.hxUId]];
                if (result) {
                    result(tmpUser);
                }
            } failure:^(NSString *error) {
                if (result) {
                    result(user);
                }
            }];
        }
    } else {
        if (result) {
            result(user);
        }
    }
}

#pragma mark 用户注册校验
- (NSURLSessionDataTask *)registWithValidataUser:(RegisterUserEntity *)entity
                                         success:(void (^)(id))success
                                         failure:(void (^)(NSString *))failure
{
    NSMutableDictionary *dic = [self mergeDictionWithDicone:API_USER_VALIDATE AndDicTwo:[entity toDictionary]];
    return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:dic success:^(NSURLSessionDataTask *task, id responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSString *error) {
        failure(error);
    }];
}

#pragma mark 用户注册提交
- (NSURLSessionDataTask *)registWithSubmitUser:(RegisterUserEntity *)entity
                                       success:(void (^)(id))success
                                       failure:(void (^)(NSString *))failure
{
    NSMutableDictionary *dic = [self mergeDictionWithDicone:API_USER_REGISTER AndDicTwo:[entity toDictionary]];
    return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:dic success:^(NSURLSessionDataTask *task, id responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSString *error) {
        failure(error);
    }];
}

#pragma mark 用户登录(手机号码)
- (NSURLSessionDataTask *)loginWithPhone:(RegisterUserEntity *)entity
                                 success:(void (^)(id))success
                                 failure:(void (^)(NSString *))failure
{
    NSMutableDictionary *dic = [self mergeDictionWithDicone:API_USER_LOGIN_WITH_PHONE AndDicTwo:[entity toDictionary]];
    return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:dic success:^(NSURLSessionDataTask *task, id responseObject) {
        success(responseObject);
        [logicShareInstance doLoginSuccessfulLogic];
    } failure:^(NSURLSessionDataTask *task, NSString *error) {
        failure(error);
    }];
}

#pragma mark 重发验证码
- (NSURLSessionDataTask *)reSendSMSWithPhone:(RegisterUserEntity *)entity
                               isVerifyPhone:(BOOL)isVerifyPhone
                                 success:(void (^)(id))success
                                 failure:(void (^)(NSString *))failure
{
    NSMutableDictionary *dic = [self mergeDictionWithDicone:API_USER_RESEND_SMS AndDicTwo:[entity toDictionary]];
    if (isVerifyPhone) {
        [dic setObject:@"1" forKey:@"checkPhone"];
    } else {
        [dic setObject:@"0" forKey:@"checkPhone"];
    }
    return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:dic success:^(NSURLSessionDataTask *task, id responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSString *error) {
        failure(error);
    }];
}

#pragma mark 密码找回第一步
- (NSURLSessionDataTask *)forgotPwdWithOne:(RegisterUserEntity *)entity
                                     success:(void (^)(id))success
                                     failure:(void (^)(NSString *))failure
{
    NSMutableDictionary *dic = [self mergeDictionWithDicone:API_USER_FORGOT_PWD_ONE AndDicTwo:[entity toDictionary]];
    return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:dic success:^(NSURLSessionDataTask *task, id responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSString *error) {
        failure(error);
    }];
}

#pragma mark 密码找回第二步
- (NSURLSessionDataTask *)forgotPwdWithTwo:(RegisterUserEntity *)entity
                                    newPwd:(NSString *)newPwd
                                   success:(void (^)(id))success
                                   failure:(void (^)(NSString *))failure
{
    NSMutableDictionary *dic = [self mergeDictionWithDicone:API_USER_FORGOT_PWD_TWO AndDicTwo:[entity toDictionary]];
    [dic setObject:newPwd forKey:@"newPwd"];
    return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:dic success:^(NSURLSessionDataTask *task, id responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSString *error) {
        failure(error);
    }];
}

#pragma mark 获取个人信息
- (NSURLSessionDataTask *)getUserInfoSuccess:(void (^)(id))success
                                     failure:(void (^)(NSString *))failure
{
    return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:API_USER_INFO success:^(NSURLSessionDataTask *task, id responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSString *error) {
        failure(error);
    }];
}

#pragma mark 重设密码
- (NSURLSessionDataTask *)reSetPWDWithPhone:(RegisterUserEntity *)entity
                                     oldPwd:(NSString *)oldPwd
                                     newPwd:(NSString *)newPwd
                                 success:(void (^)(id))success
                                 failure:(void (^)(NSString *))failure
{
    NSMutableDictionary *dic = [self mergeDictionWithDicone:API_USER_RESET_PWD AndDicTwo:[entity toDictionary]];
    [dic setObject:oldPwd forKey:@"oldPwd"];
    [dic setObject:newPwd forKey:@"newPwd"];
    
    return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:dic success:^(NSURLSessionDataTask *task, id responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSString *error) {
        failure(error);
    }];
}

#pragma mark 修改资料
- (NSURLSessionDataTask *)updateInfoWithPhone:(NSDictionary *)dicData
                                 success:(void (^)(id))success
                                 failure:(void (^)(NSString *))failure
{
    NSMutableDictionary *dic = [self mergeDictionWithDicone:API_USER_UPDATE_INFO AndDicTwo:dicData];
    return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:dic success:^(NSURLSessionDataTask *task, id responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSString *error) {
        failure(error);
    }];
}

#pragma mark 用户退出
- (NSURLSessionDataTask *)userLogout:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    NSMutableDictionary *userDic = [NSMutableDictionary dictionaryWithCapacity:1];
    [userDic setObject:[NSString stringWithFormat:@"%@", [self.currentLoginUser.userCode MD5Hash]] forKey:@"secretKey"];
    
    NSMutableDictionary *dic = [self mergeDictionWithDicone:API_USER_LOGOUT AndDicTwo:userDic];
    return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:dic success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask *task, NSString *error) {
        if (failure) {
            failure(error);
        }
    }];
}

#pragma mark 微信登录
- (NSURLSessionDataTask *)loginWithWeChatCode:(NSString *)code
                                      success:(void (^)(id))success
                                      failure:(void (^)(NSString *))failure
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:API_USER_LOGIN_WITH_WECHAT];
    [dic setObject:code forKey:@"weixinAccessToken"];
    
    return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:dic success:^(NSURLSessionDataTask *task, id responseObject) {
        success(responseObject);
        [logicShareInstance doLoginSuccessfulLogic];
    } failure:^(NSURLSessionDataTask *task, NSString *error) {
        failure(error);
    }];
}

#pragma mark 添加关注
- (NSURLSessionDataTask *)addFollowWithUserId:(long long)userId
                                      success:(void (^)(id))success
                                      failure:(void (^)(NSString *))failure
{
    NSDictionary *dicData = @{@"followUserId": [NSString stringWithFormat:@"%lld", userId]};
    NSMutableDictionary *dic = [self mergeDictionWithDicone:API_USER_ADD_FOLLOW AndDicTwo:dicData];
    return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:dic success:^(NSURLSessionDataTask *task, id responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSString *error) {
        failure(error);
    }];
}

#pragma mark 取消关注
- (NSURLSessionDataTask *)delFollowWithUserId:(long long)userId
                                      success:(void (^)(id))success
                                      failure:(void (^)(NSString *))failure
{
    NSDictionary *dicData = @{@"followUserId": [NSString stringWithFormat:@"%lld", userId]};
    NSMutableDictionary *dic = [self mergeDictionWithDicone:API_USER_CANCEL_FOLLOW AndDicTwo:dicData];
    return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:dic success:^(NSURLSessionDataTask *task, id responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSString *error) {
        failure(error);
    }];
}


#pragma mark 添加一键下图授权
- (NSURLSessionDataTask *)addImageGrantWithUserId:(long long)userId success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    NSDictionary *dicData = @{@"fansUserId": [NSString stringWithFormat:@"%lld", userId]};
    NSMutableDictionary *dic = [self mergeDictionWithDicone:API_USER_ADD_GRANT AndDicTwo:dicData];
    return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:dic success:^(NSURLSessionDataTask *task, id responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSString *error) {
        failure(error);
    }];
}

#pragma mark 取消一键下图授权
- (NSURLSessionDataTask *)delImageGrantWithUserId:(long long)userId success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    NSDictionary *dicData = @{@"fansUserId": [NSString stringWithFormat:@"%lld", userId]};
    NSMutableDictionary *dic = [self mergeDictionWithDicone:API_USER_CANCEL_GRANT AndDicTwo:dicData];
    return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:dic success:^(NSURLSessionDataTask *task, id responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSString *error) {
        failure(error);
    }];
}

#pragma mark 获取关注列表
- (NSURLSessionDataTask *)getFollowListWithUserId:(long long)userId
                                      CurrentPage:(NSInteger)currentPage
                                         pageSize:(NSInteger)pageSize
                                          success:(void (^)(id))success
                                          failure:(void (^)(NSString *))failure
{
    NSDictionary *dicData = @{@"otherUserId": [NSString stringWithFormat:@"%lld", userId],
                              @"currentPage": [NSString stringWithFormat:@"%d", (int)currentPage],
                              @"pageSize": [NSString stringWithFormat:@"%d", (int)pageSize]};
    NSMutableDictionary *dic = [self mergeDictionWithDicone:API_USER_FOLLW_LIST AndDicTwo:dicData];
    return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:dic success:^(NSURLSessionDataTask *task, id responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSString *error) {
        failure(error);
    }];
}

#pragma mark 获取一键下图授权
- (NSURLSessionDataTask *)getVerifyListWithCurrentPage:(NSInteger)currentPage
                                       pageSize:(NSInteger)pageSize
                                        success:(void (^)(id))success
                                        failure:(void (^)(NSString *))failure
{
    NSDictionary *dicData = @{@"currentPage": [NSString stringWithFormat:@"%d", (int)currentPage],
                              @"pageSize": [NSString stringWithFormat:@"%d", (int)pageSize]};
    NSMutableDictionary *dic = [self mergeDictionWithDicone:API_USER_VERIFY_LIST AndDicTwo:dicData];
    return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:dic success:^(NSURLSessionDataTask *task, id responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSString *error) {
        failure(error);
    }];
}

#pragma mark 获取粉丝列表
- (NSURLSessionDataTask *)getFansListWithUserId:(long long)userId
                                    CurrentPage:(NSInteger)currentPage
                                       pageSize:(NSInteger)pageSize
                                        success:(void (^)(id))success
                                        failure:(void (^)(NSString *))failure
{
    NSDictionary *dicData = @{@"otherUserId": [NSString stringWithFormat:@"%lld", userId],
                              @"currentPage": [NSString stringWithFormat:@"%d", (int)currentPage],
                              @"pageSize": [NSString stringWithFormat:@"%d", (int)pageSize]};
    NSMutableDictionary *dic = [self mergeDictionWithDicone:API_USER_FANS_LIST AndDicTwo:dicData];
    return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:dic success:^(NSURLSessionDataTask *task, id responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSString *error) {
        failure(error);
    }];
}

#pragma mark 根据环信ID获取用户信息
- (NSURLSessionDataTask *)getUserInfoByHXUid:(NSString *)hxid
                                     success:(void (^)(id))success
                                     failure:(void (^)(NSString *))failure
{
    NSDictionary *dicData = @{@"hxUId": hxid};
    NSMutableDictionary *dic = [self mergeDictionWithDicone:API_USER_USERINFO_HXID AndDicTwo:dicData];
    return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:dic success:^(NSURLSessionDataTask *task, id responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSString *error) {
        failure(error);
    }];
}

#pragma mark 获取愿望清单列表
- (NSURLSessionDataTask *)getCollectListWithCurrentPage:(NSInteger)currentPage pageSize:(NSInteger)pageSize success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    NSDictionary *dicData = @{
                              @"currentPage": [NSString stringWithFormat:@"%d", (int)currentPage],
                              @"pageSize": [NSString stringWithFormat:@"%d", (int)pageSize]};
    NSMutableDictionary *dic = [self mergeDictionWithDicone:API_USER_COLLECT_LIST AndDicTwo:dicData];
    return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:dic success:^(NSURLSessionDataTask *task, id responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSString *error) {
        failure(error);
    }];
}

#pragma mark 给买手评分
- (NSURLSessionDataTask *)userMarkScoreWithToUid:(long long)toUserId score:(NSInteger)score success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    NSDictionary *dicData = @{@"fromUserId": [NSNumber numberWithLongLong:[CURRENT_USER_INSTANCE getCurrentUserID]],
                              @"toUserId" : [NSNumber numberWithLongLong:toUserId],
                              @"score" : [NSNumber numberWithInteger:score]
                              };
    
    NSMutableDictionary *dic = [self mergeDictionWithDicone:API_USER_MARK_SCORE AndDicTwo:dicData];
    return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:dic success:^(NSURLSessionDataTask *task, id responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSString *error) {
        failure(error);
    }];
}

#pragma mark 搜索买手
- (NSURLSessionDataTask *)searchBuyerWithKeyWord:(NSString *)keyword
                                     CurrentPage:(NSInteger)currentPage
                                        pageSize:(NSInteger)pageSize
                                         success:(void (^)(id))success
                                         failure:(void (^)(NSString *))failure
{
    NSDictionary *dicData = @{@"keyword": keyword,
                              @"currentPage": [NSString stringWithFormat:@"%d", currentPage],
                              @"pageSize": [NSString stringWithFormat:@"%d", pageSize]};
    NSMutableDictionary *dic = [self mergeDictionWithDicone:API_USER_SEARCH_BUYER AndDicTwo:dicData];
    return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:dic success:^(NSURLSessionDataTask *task, id responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSString *error) {
        failure(error);
    }];
}


#pragma mark 搜索买手
- (NSURLSessionDataTask *)searchUserWithKeyWord:(NSString *)keyword
                                     CurrentPage:(NSInteger)currentPage
                                        pageSize:(NSInteger)pageSize
                                         success:(void (^)(id))success
                                         failure:(void (^)(NSString *))failure
{
    NSDictionary *dicData = @{@"keyword": keyword,
                              @"currentPage": [NSString stringWithFormat:@"%d", (int)currentPage],
                              @"pageSize": [NSString stringWithFormat:@"%d", (int)pageSize]};
    NSMutableDictionary *dic = [self mergeDictionWithDicone:API_USER_SEARCH_GRANT AndDicTwo:dicData];
    return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:dic success:^(NSURLSessionDataTask *task, id responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSString *error) {
        failure(error);
    }];
}

#pragma mark 发现频道的买手列表
- (NSURLSessionDataTask *)getBuyerListWithChannelId:(NSInteger)channelId
                                        CurrentPage:(NSInteger)currentPage
                                           pageSize:(NSInteger)pageSize
                                            Success:(void (^)(id))success
                                            failure:(void (^)(NSString *))failure
{
    NSDictionary *dicData = @{@"channelId": [NSString stringWithFormat:@"%d", channelId],
                              @"currentPage": [NSString stringWithFormat:@"%d", currentPage],
                              @"pageSize": [NSString stringWithFormat:@"%d", pageSize]};
    NSMutableDictionary *dic = [self mergeDictionWithDicone:API_USER_RECOMMENT_BUYER AndDicTwo:dicData];
    return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:dic success:^(NSURLSessionDataTask *task, id responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSString *error) {
        failure(error);
    }];
}

#pragma mark 买手列表
- (NSURLSessionDataTask *)getBuyerListWithCurrentPage:(NSInteger)currentPage
                                             pageSize:(NSInteger)pageSize
                                              Success:(void (^)(id))success
                                              failure:(void (^)(NSString *))failure
{
    NSDictionary *dicData = @{
                              @"currentPage": [NSString stringWithFormat:@"%d", (int)currentPage],
                              @"pageSize": [NSString stringWithFormat:@"%d", (int)pageSize]};
    NSMutableDictionary *dic = [self mergeDictionWithDicone:API_USER_BUYER_LIST AndDicTwo:dicData];
    return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:dic success:^(NSURLSessionDataTask *task, id responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSString *error) {
        failure(error);
    }];
}

#pragma mark 用户列表
- (NSURLSessionDataTask *)getUserListWithCurrentPage:(NSInteger)currentPage
                                             pageSize:(NSInteger)pageSize
                                              Success:(void (^)(id))success
                                              failure:(void (^)(NSString *))failure
{
    NSDictionary *dicData = @{
                              @"currentPage": [NSString stringWithFormat:@"%d", (int)currentPage],
                              @"pageSize": [NSString stringWithFormat:@"%d", (int)pageSize]};
    NSMutableDictionary *dic = [self mergeDictionWithDicone:API_USER_LIST AndDicTwo:dicData];
    return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:dic success:^(NSURLSessionDataTask *task, id responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSString *error) {
        failure(error);
    }];
}

#pragma mark 反馈意见
- (NSURLSessionDataTask *)postFeedBackWith:(NSString *)content email:(NSString *)email Success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:1];
    content != nil ? [dic setObject:content forKey:@"content"] : @"";
    email   != nil ? [dic setObject:email forKey:@"email"] : @"";
    return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:[self mergeDictionWithDicone:dic AndDicTwo:API_POST_FEEDBACK] success:^(NSURLSessionDataTask *task, id responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSString *error) {
        failure(error);
    }];
}

#pragma mark 申请认证买手
- (NSURLSessionDataTask *)uploadVerifyBuyerFileWithUploadFlag:(VerifyBuyerUploadFlag)flag
                                          imageUrl:(NSString *)imageUrl
                                           Success:(void (^)(id))success
                                           failure:(void (^)(NSString *))failure
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:1];
    imageUrl   != nil ? [dic setObject:imageUrl forKey:@"imageUrl"] : @"";
    flag ? [dic setObject:[NSString stringWithFormat:@"%d", (int)flag] forKey:@"uploadFlag"] : @"0";
    return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:[self mergeDictionWithDicone:dic AndDicTwo:API_UPLOAD_VERIFY_FILE] success:^(NSURLSessionDataTask *task, id responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSString *error) {
        failure(error);
    }];
}

#pragma mark 申请买手认证
- (NSURLSessionDataTask *)uploadVerifyFileWithIDNO:(NSString *)idno
                                          imageUrl:(NSString *)imageUrl
                                        uploadFlag:(NSInteger)flag
                                           Success:(void (^)(id))success
                                           failure:(void (^)(NSString *))failure
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:1];
    idno != nil ? [dic setObject:idno forKey:@"idCardNo"] : @"";
    imageUrl   != nil ? [dic setObject:imageUrl forKey:@"imageUrl"] : @"";
    flag ? [dic setObject:[NSString stringWithFormat:@"%d", (int)flag] forKey:@"uploadFlag"] : @"0";
    return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:[self mergeDictionWithDicone:dic AndDicTwo:API_UPLOAD_VERIFY_FILE] success:^(NSURLSessionDataTask *task, id responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSString *error) {
        failure(error);
    }];
}

#pragma mark 绑定银行卡
- (NSURLSessionDataTask *)bindBankCardWithCardID:(NSString *)bankCardNo
                                        bankName:(NSString *)bankName
                                      branchName:(NSString *)branchName
                                         Success:(void (^)(id))success
                                         failure:(void (^)(NSString *))failure
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:1];
    bankCardNo != nil ? [dic setObject:bankCardNo forKey:@"bankCardNo"] : @"";
    bankName   != nil ? [dic setObject:bankName forKey:@"bankName"] : @"";
    branchName   != nil ? [dic setObject:branchName forKey:@"branchName"] : @"";
    
    return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:[self mergeDictionWithDicone:dic AndDicTwo:API_BUYER_BIND_BANKCARD] success:^(NSURLSessionDataTask *task, id responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSString *error) {
        failure(error);
    }];
}

#pragma mark 获取绑定的银行卡
- (NSURLSessionDataTask *)getBindCardSuccess:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:API_BUYER_GET_BIND_BANKCARD success:^(NSURLSessionDataTask *task, id responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSString *error) {
        failure(error);
    }];
}

#pragma mark 绑定支付宝
- (NSURLSessionDataTask *)bindAlipaySuccess:(void (^)(id))success
                                    failure:(void (^)(NSString *))failure
{
    return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:API_BUYER_BIND_ALIPAY success:^(NSURLSessionDataTask *task, id responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSString *error) {
        failure(error);
    }];
}

- (NSURLSessionDataTask *)sendMsgWithBindMobile:(NSString *)mobile countryCode:(NSString *)countryCode Success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:1];
    [dic setObject:[NSString stringWithFormat:@"%@", mobile] forKey:@"phone"];
    [dic setObject:[NSString stringWithFormat:@"%@", countryCode] forKey:@"countryCode"];
    
    return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:[self mergeDictionWithDicone:dic AndDicTwo:API_SEND_BIND_MOBILE_MSG] success:^(NSURLSessionDataTask *task, id responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSString *error) {
        failure(error);
    }];
}

- (NSURLSessionDataTask *)bindMobile:(NSString *)mobile countryCode:(NSString *)countryCode smsCode:(NSString *)smsCode Success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:1];
    [dic setObject:[NSString stringWithFormat:@"%@", mobile] forKey:@"phone"];
    [dic setObject:[NSString stringWithFormat:@"%@", countryCode] forKey:@"countryCode"];
    [dic setObject:[NSString stringWithFormat:@"%@", smsCode] forKey:@"smsCode"];
    
    return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:[self mergeDictionWithDicone:dic AndDicTwo:API_SEND_BIND_MOBILE_CODE] success:^(NSURLSessionDataTask *task, id responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSString *error) {
        failure(error);
    }];
}

#pragma mark 更新极光推送
- (NSURLSessionDataTask *)updateSendId:(NSString *)sendId Success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:1];
    [dic setObject:[NSString stringWithFormat:@"%@", sendId] forKey:@"sendId"];
    
    return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:[self mergeDictionWithDicone:dic AndDicTwo:API_USER_UPDATE_SENDID] success:^(NSURLSessionDataTask *task, id responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSString *error) {
        failure(error);
    }];
}

// API_BUYER_BIND_ALIPAY

#pragma mark
#pragma mark logic层统一管理协议方法
- (void)load
{
    @try {
        if (USER_IS_LOGIN) {
            [[logicShareInstance getUserManager] getUserInfoSuccess:^(id responseObject) {
                
                NSDictionary *dic = [responseObject objectForKey:@"data"];
                
                if ([dic isKindOfClass:[NSDictionary class]]) {
                    UserEntity *user = [[UserEntity alloc] init];
                    [user setValuesForKeysWithDictionary:dic];
                    // 此处处理 SessionKey
                    user.sessionKey = [CURRENT_USER_INSTANCE getSessionId];
                    [CURRENT_USER_INSTANCE updateCurrentUser:user];
                }
            } failure:^(NSString *error) {
                NSLog(@"");
            }];
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
}

- (void)loadUserData{}
- (void)save{}
- (void)reset{}
- (void)enterBackgroundMode{}
- (void)enterForeground{}
- (void)doLoginSuccessfulLogic{}
- (void)doLogoutLogic
{
    // 发送退出登陆请求
    [self userLogout:nil failure:nil];
    
    // 删除所有用户的数据
    for (UserEntity *user in [UserEntity allDbObjects]) {
        [user removeFromDb];
    }
    
    [NSUSER_DEFAULT setObj:@"" forKey:@"CURRENT_USER_ID"];
    // 清除相关信息
    [NSUSER_DEFAULT setObj:@"0" forKey:@"user_setting"];
    [NSUSER_DEFAULT removeObjForKey:@"setUserIsSubmitBindAlipayAccount"];
    [NSUSER_DEFAULT removeObjForKey:@"checkUserIsBindPayAccountTime"];
    self.currentLoginUser = nil;
}
- (void)disconnectNet{}

@end
