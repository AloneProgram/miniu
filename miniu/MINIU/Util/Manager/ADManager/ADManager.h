//
//  ADManager.h
//  DLDQ_IOS
//
//  Created by simman on 15/1/19.
//  Copyright (c) 2015年 Liwei. All rights reserved.
//

#import "ManagerBase.h"
@interface ADentity : BaseModel

@property (nonatomic, strong) NSString *linkedUrl;        // 链接地址
@property (nonatomic, strong) NSString *imageUrl;       // 图片地址
@property (nonatomic, strong) NSString *title;          //标题
@property (nonatomic, strong) NSString *depictRemark;   //描述


@end
@interface ADManager : ManagerBase <LogicBaseModel>

/**
 *  单例
 *
 *  @return
 */
+ (instancetype)shareInstance;


/**
 *  刷新广告，并异步回调
 *
 *  @param block
 */
- (void) refreshAdsWithTag:(NSString *)tagName block:(void (^)(NSArray *ads))block;

@property (nonatomic,strong)ADentity *currentADentity;
@end


