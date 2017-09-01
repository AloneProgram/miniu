//
//  LogisticsAddViewController.h
//  miniu
//
//  Created by SimMan on 15/6/10.
//  Copyright (c) 2015年 SimMan. All rights reserved.
//

#import "BaseViewController.h"

@class LogisticsEntity;

@interface LogisticsAddViewController : BaseViewController

@property (nonatomic, strong) NSString *orderNo;
@property (nonatomic, strong) LogisticsEntity *logistics;

@end
