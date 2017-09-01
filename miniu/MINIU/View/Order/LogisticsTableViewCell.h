//
//  LogisticsTableViewCell.h
//  miniu
//
//  Created by SimMan on 15/6/8.
//  Copyright (c) 2015年 SimMan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LogisticsEntity.h"
@interface LogisticsTableViewCell : UITableViewCell

@property (nonatomic, strong) LogisticsEntity *logistics;
@property (nonatomic, assign) BOOL isLast;          // 是否是最后一个
@property (nonatomic, assign) BOOL isFinished;      // 是否已经完成（订单已完成状态）
@property (nonatomic, assign) BOOL isFirst;         // 是否是第一个
+ (CGFloat) cellHeightWith:(LogisticsEntity *) logistics;

@end
