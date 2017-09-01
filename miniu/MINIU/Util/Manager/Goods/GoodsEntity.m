//
//  GoodsEntity.m
//  DLDQ_IOS
//
//  Created by simman on 14-9-3.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import "GoodsEntity.h"
#import "UserEntity.h"

@implementation GoodsEntity

- (instancetype) init
{
    self = [super init];
    if ( self ) {
        self.goodsId = 0;
        self.price = [NSNumber numberWithFloat:0.0];
        self.position   = @"";
        self.gpsPosition = @"";
        self.isShowPrice = 1;
        self.commentsCount = 0;
        self.goodsDescription = @"";
        self.likesCount = 0;
        self.complaintsCount = 0;
        self.weiboSharesCount = 0;
        self.weixinSharesCount = 0;
        self.commendPoints = 0;
        self.status = 1;
        self.createUserId = 0;
//        self.createTime = [[[NSDate alloc] init] timeIntervalSince1970InMilliSecond];
        self.goodsImages = @"";
        self.goodsTags = @"";
        self.isMyLike = 0;
        self.firstImageUrl  = @"";
        self.isSysRecommend = 0;
        self.goodsUserInfo = [[UserEntity alloc] init];
        self.isNeedConfirmPrice = YES;
        self.isShowBuyBtn = YES;
        
        self.isShowImgDLBtn = YES;
        self.isMyPraise = NO;
        self.praiseCount = 0;
        self.depictRemark = @"";
        
        self.isShowMark = YES;
        self.goodsImagesArray = [NSArray array];
    }
    return self;
}

- (void) setValue:(id)value forUndefinedKey:(NSString *)key
{
    if ( [key isEqualToString:@"userInfo"] ) {
        UserEntity *user = [[UserEntity alloc] init];
        [user setValuesForKeysWithDictionary:value];
        self.goodsUserInfo = user;
    }
    
    if ([key isEqualToString:@"description"]) {
        _goodsDescription = value;
    }
    
//    if ( [key isEqualToString:@"description"]) {
//        self.goodsDescription = value;
//    }
}

- (void)setDepictRemark:(NSString *)depictRemark
{
    _depictRemark = depictRemark;
    _goodsDescription = depictRemark;
}

- (void)setGoodsImages:(NSString *)goodsImages
{
    _goodsImages = goodsImages;
    _goodsImagesArray = [goodsImages componentsSeparatedByString:@","];
}

- (void) setNilValueForKey:(NSString *)key{};

- (GoodsEntity *)initWithGoodsId:(NSString *)goodsId
{
    self = [self init];
    if (self) {
        self.goodsId = [goodsId longLongValue];
    }
    return self;
}

@end
