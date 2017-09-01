//
//  UserEntity.h
//  DLDQ_IOS
//
//  Created by simman on 14-9-1.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <CoreData/CoreData.h>
#import "BaseModel.h"

//@interface UserEntity : NSManagedObject
@interface UserEntity : BaseModel

@property (nonatomic, assign) long long userId;// 用户ID
@property (nonatomic, strong) NSString * userCode;// 代号
@property (nonatomic, assign) NSInteger modifyTimes;// 代号修改剩余次数
@property (nonatomic, strong) NSString * hxUId;// 环信ID
@property (nonatomic, strong) NSString * hxPwd; // 环信密码
@property (nonatomic, strong) NSString * sendId;// 推送ID
@property (nonatomic, strong) NSString * nickName;  // 用户昵称
@property (nonatomic, strong) NSString * phone; // 手机号码
@property (nonatomic, strong) NSString * realName;  // 真实姓名
@property (nonatomic, assign) long long registerTime;   // 注册时间
@property (nonatomic, assign) NSInteger roleType;  // 用户类型  （1：普通用户，2：买手，3：认证买手，4：后台管理人员），返回1，2，3或4",
@property (nonatomic, strong) NSString * signature;         // 签名


@property (nonatomic, strong) NSString * countryCode;
@property (nonatomic, strong) NSString * countryName;
@property (nonatomic, strong) NSString * cityName;


@property (nonatomic, assign) NSInteger liksCount; // 被喜欢或收藏的次数
@property (nonatomic, assign) NSInteger commentsCount; //被评论次数
@property (nonatomic, assign) NSInteger complaintsCount;   // 被投诉次数
@property (nonatomic, assign) NSInteger fansCount; //粉丝数量
@property (nonatomic, assign) NSInteger followCount;   //被关注次数
@property (nonatomic, assign) NSInteger markCount;     //被评分次数


@property (nonatomic, strong) NSString * aDorWorkImageUrl;
@property (nonatomic, assign) long long applyTime;
@property (nonatomic, strong) NSString * area;
@property (nonatomic, strong) NSString * avatar;
@property (nonatomic, assign) long long borndate;  // 生日
@property (nonatomic, strong) NSString * buyerType;
@property (nonatomic, strong) NSString * cash;
@property (nonatomic, assign) NSInteger confirmStatus;  //  0:待审核 1:审核通过 2:审核不通过 9:从未申请过
@property (nonatomic, assign) NSInteger playdownStatus; // （0：未降级，1：已降级）
@property (nonatomic, assign) long long  confirmTime;
@property (nonatomic, strong) NSString * credits;
@property (nonatomic, strong) NSString * email;
@property (nonatomic, strong) NSString * frozenCash;
@property (nonatomic, strong) NSString * honorRank;
@property (nonatomic, strong) NSString * idCardImageUrl;
@property (nonatomic, strong) NSString * idCardNo;
@property (nonatomic, strong) NSString * isBlack;
@property (nonatomic, strong) NSString * localAddressImageUrl;
@property (nonatomic, strong) NSString * localBillImageUrl;
@property (nonatomic, strong) NSString * localUserPicImageUrl;
@property (nonatomic, strong) NSString * logisticsImageUrl;


@property (nonatomic, strong) NSString * sex;
@property (nonatomic, assign) NSInteger sharesCount;
@property (nonatomic, assign) NSInteger starPoint;
@property (nonatomic, strong) NSString * totalAvlidCashAmount;
@property (nonatomic, strong) NSString * totalCashAmount;
@property (nonatomic, strong) NSString * totalDrawCashAmount;
@property (nonatomic, strong) NSString * totalForzenCashAmount;

@property (nonatomic, strong) NSString * weixinAccessToken;
@property (nonatomic, strong) NSString * weixinUId;

@property (nonatomic, assign) NSInteger followStatus;  // 0 未关注, 1，已经关注， 99 当前用户


@property (nonatomic, assign) NSInteger userType;  // (1-android,2-iphone)


@property (nonatomic, assign) BOOL isBindAliAccount;
@property (nonatomic, assign) BOOL isBindBankcard;

@property (nonatomic, strong) NSString *alipayAccount;


@property (nonatomic, assign) BOOL isImgDLAllowed;      // 是否授权一键下图


@property (nonatomic, strong) NSString * weixinAccount;
@property (nonatomic, strong) NSString * weixinUName;
@property (nonatomic, strong) NSString * weixinOId;
@property (nonatomic, strong) NSString * weiboXL;
@property (nonatomic, strong) NSString * weiboTX;
@property (nonatomic, strong) NSString * taobao;

@property (nonatomic, strong) NSString * serviceHxUId;      // 客服Id


@property (nonatomic, strong) NSString *sessionKey;

//- (void)setValueForDic:(NSDictionary *)dic;

- (id)initWithUserId:(long long)userId;

@end
