//
//  GoodsEntity.h
//  DLDQ_IOS
//
//  Created by simman on 14-9-3.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import "BaseModel.h"
@class UserEntity;

@interface GoodsEntity : BaseModel

@property (nonatomic, assign) long long goodsId;
@property (nonatomic, strong) NSNumber *price;
@property (nonatomic, strong) NSString *goodsDescription;
@property (nonatomic, strong) NSString *position;       // 位置
@property (nonatomic, strong) NSString *gpsPosition;    // GPS位置
@property (nonatomic, assign) NSInteger isShowPrice;
@property (nonatomic, assign) NSInteger commentsCount;
@property (nonatomic, assign) NSInteger likesCount;
@property (nonatomic, assign) NSInteger complaintsCount; // 投诉
@property (nonatomic, assign) NSInteger weiboSharesCount;
@property (nonatomic, assign) NSInteger weixinSharesCount;
@property (nonatomic, assign) NSInteger commendPoints;      // 推荐指数
@property (nonatomic, assign) NSInteger status;         // 1：正在热售，2：丢入回收站，3：下架
@property (nonatomic, assign) long long createUserId;
@property (nonatomic, assign) long long createTime;
@property (nonatomic, strong) NSString *goodsImages;
@property (nonatomic, strong) NSString *firstImageUrl;      // 第一张图片
@property (nonatomic, assign) NSInteger goodsImagesCount;
@property (nonatomic, strong) NSString *goodsTags;      // 商品标签
@property (nonatomic, assign) NSInteger goodsTagsCount; // 标签数量
@property (nonatomic, assign) NSInteger isMyLike;       // 是否喜欢
@property (nonatomic, assign) NSInteger isSysRecommend;    // 是否系统推荐
@property (nonatomic, strong) UserEntity *goodsUserInfo;
@property (nonatomic, strong) UIImage *shareImage;      // 分享用的图片（第一张）

@property (nonatomic, assign) BOOL isShowBuyBtn;            // 是否显示代购按钮

@property (nonatomic, assign) BOOL isNeedConfirmPrice;      // 是否需要确定价格（用于发布）

@property (nonatomic, assign) BOOL isShowMark;      // 是否显示水印

@property (nonatomic, assign) BOOL isShowImgDLBtn;      // 用于标识是否对当前用户开放“一键下图”按钮:0-不显示，1-显示
@property (nonatomic, assign) BOOL isMyPraise;           // / 标识当前用户是否点过赞：0-未赞，1-已赞
@property (nonatomic, assign) long praiseCount;         // // 当前商品总的被赞次数

@property (nonatomic, strong) NSString *depictRemark;

@property (nonatomic, strong) NSArray *goodsImagesArray;

- (GoodsEntity *)initWithGoodsId:(NSString *)goodsId;

@end
