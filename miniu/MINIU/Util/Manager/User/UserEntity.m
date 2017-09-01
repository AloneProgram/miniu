//
//  UserEntity.m
//  DLDQ_IOS
//
//  Created by simman on 14-9-1.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import "UserEntity.h"


@implementation UserEntity

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.userId = 0;
        self.userCode = @"";
        self.modifyTimes = 1;
        self.hxUId = @"";
        self.hxPwd = @"";
        self.sendId = @"";
        self.nickName = @"匿名用户";
        self.phone = @"";
        self.realName = @"";
        self.registerTime = 0;
        self.roleType = 1;
        self.signature = @"暂无描述";
        self.countryCode = @"0";
        self.countryName = @"未知";
        self.cityName = @"未知";
        self.liksCount = 0;
        self.commentsCount = 0;
        self.complaintsCount = 0;
        self.fansCount = 0;
        self.followCount = 0;
        self.markCount = 0;
        self.aDorWorkImageUrl = @"";
        self.applyTime = 0;
        self.area = @"";
        self.avatar = @"http://dldqcdn.b0.upaiyun.com/Avatar/Default/avatar.png";
        self.borndate  = (long long)[[[NSDate alloc] init] timeIntervalSince1970InMilliSecond];
        self.buyerType = @"0";
        self.cash = @"";
        self.confirmStatus = 9;
        self.playdownStatus = 0;
        self.confirmTime = 0;
        self.credits = @"";
        self.email = @"";
        self.frozenCash = @"";
        self.honorRank = @"";
        self.idCardImageUrl = @"";
        self.idCardNo = @"";
        self.isBlack = @"";
        self.localAddressImageUrl = @"";
        self.localBillImageUrl = @"";
        self.localUserPicImageUrl = @"";
        self.logisticsImageUrl = @"";
        self.followStatus = 0;
        self.sex = @"";
        self.sharesCount = 0;
        self.starPoint = 0;
        self.totalAvlidCashAmount = @"";
        self.totalCashAmount = @"";
        self.totalDrawCashAmount = @"";
        self.totalForzenCashAmount = @"";
        self.weixinAccessToken = @"";
        self.weixinUId = @"";
        
        self.isBindBankcard = NO;
        self.isBindAliAccount = NO;
        
        self.userType = 0;
        
        self.alipayAccount = @"暂未绑定";
        
        self.isImgDLAllowed = NO;
        
        self.weixinAccount = @"无";
        self.weixinUName = @"无";
        self.weixinOId = @"无";
        self.weiboXL = @"无";
        self.weiboTX = @"无";
        self.taobao = @"无";
        
        self.serviceHxUId = @"mnhxuser1";
        
        self.sessionKey = @"";
    }
    return self;
}

- (void)setAlipayAccount:(NSString *)alipayAccount
{
    if (!alipayAccount) {
        return;
    }
    if ([alipayAccount length]) {
        _alipayAccount = alipayAccount;
    } else {
        _alipayAccount = @"暂未绑定";
    }
}

- (id)initWithUserId:(long long)userId
{
    self = [self init];
    if (self) {
        self.userId = userId;
    }
    return self;
}

//- (void)setValueForDic:(NSDictionary *)dic
//{
//    NSDictionary *attributes = [[self entity] attributesByName];
//    for (NSString *attribute in attributes) {
//        
//        @try {
//            id value = [dic objectForKey:attribute];
//            //        NSAttributeType attributeType = [[attributes objectForKey:attribute] attributeType];
//            if (value == nil) {
//                continue;
//            } else {
//                value = [value stringValue];
//            }
//            [self setValue:value forKey:attribute];
//        }
//        @catch (NSException *exception) {
//            NSLog(@"UserEntity : %@ 赋值失败,原因：%@", attribute, exception.reason);
//        }
//        @finally {
//            
//        }
//    }
//}

@end
