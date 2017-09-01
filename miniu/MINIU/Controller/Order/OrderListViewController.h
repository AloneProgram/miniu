//
//  OrderListViewController.h
//  miniu
//
//  Created by SimMan on 15/6/4.
//  Copyright (c) 2015年 SimMan. All rights reserved.
//

#import "BaseTableViewController.h"

@interface OrderListViewController : BaseTableViewController

@property (nonatomic, assign) long long withUserId;     // 查看谁的订单,如果是自己的则为0 (好像改了不能提交0)

@end
