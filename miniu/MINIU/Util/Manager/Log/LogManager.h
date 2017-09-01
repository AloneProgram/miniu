//
//  LogManager.h
//  DLDQ_IOS
//
//  Created by simman on 14-9-23.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import "ManagerBase.h"

#import "LogEntity.h"

@interface LogManager : ManagerBase <LogicBaseModel>

/**
 *  单例
 *
 *  @return 
 */
+ (instancetype)shareInstance;

/**
 *  @brief  获取内存中的数据
 *
 *  @return
 */
- (RLMResults *) getAllLogs;


/**
 *  @brief  分页加载数据
 *
 *  @param currentPage 当前页码
 *  @param pageSize    每页数量（默认为50）
 *
 *  @return 
 */
- (RLMResults *) getLogsWithLogType:(LogType)type;


/**
 *  @brief  获取所有的条数
 *
 *  @return
 */
- (NSInteger) getAllLogsCount;

/**
 *  @brief  获取未读条数
 *
 *  @return
 */
- (NSInteger) getAllUnreadNum;

/**
 *  @brief  设置此条消息已读
 *
 *  @param log
 */
- (void) setIsReadWith:(LogEntity *)log;


/**
 *  @brief  设置所有消息已读
 */
- (void) setAllLogIsRead;

@end
