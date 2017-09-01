//
//  IVersionManage.h
//  DLDQ_IOS
//
//  Created by simman on 14-8-28.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LogicBaseModel.h"
#import "iVersion.h"

@interface IVersionManage : NSObject <iVersionDelegate>

/**
 *  检测版本单例
 *
 *  @return
 */
+ (instancetype)shareInstance;

/**
 *  启用版本检测
 */
- (void) startApplicationIversion;

/**
 *  获取当前版本
 *
 *  @return
 */
- (NSString *) getCurrentVersionNum;

@end
