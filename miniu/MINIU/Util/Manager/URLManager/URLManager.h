//
//  URLManager.h
//  DLDQ_IOS
//
//  Created by simman on 15/2/11.
//  Copyright (c) 2015年 Liwei. All rights reserved.
//

#import "ManagerBase.h"

@interface URLManager : ManagerBase <LogicBaseModel>

/**
 *  单例
 *
 *  @return
 */
+ (instancetype)shareInstance;

/**
 *  获取 baseURL
 */
- (NSString *) getBaseURL;


/**
 *  是否为测试环境
 *
 *  @return
 */
- (BOOL) isProduct;

/**
 *  设置环境
 *
 *  @param product
 */
- (void) setCurrentIsProduct:(BOOL)product;


/**
 *  @brief  获取非服务接口的BaseURL
 *
 *  @return
 */
- (NSString *) getNoServerBaseURL;

- (void) resolvingUrlAndOpenAction:(NSURL *)url;

@end
