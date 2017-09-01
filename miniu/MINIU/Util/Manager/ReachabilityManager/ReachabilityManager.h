//
//  ReachabilityManager.h
//  DLDQ_IOS
//
//  Created by simman on 14-8-28.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LogicBaseModel.h"

@interface ReachabilityManager : NSObject <LogicBaseModel>


+ (instancetype)shareInstance;

/**
 *  启用网络检测
 */
- (void) startMonitoring;

@end
