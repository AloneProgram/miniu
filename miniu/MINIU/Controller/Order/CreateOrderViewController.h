//
//  CreateOrderViewController.h
//  miniu
//
//  Created by SimMan on 15/6/2.
//  Copyright (c) 2015年 SimMan. All rights reserved.
//

#import "BaseTableViewController.h"

@interface CreateOrderViewController : BaseTableViewController

- (void) createOrderWithApplyId:(long long)applyId
               addCallBackBlock:(void(^)(OrderEntity *createOrder))Block;

@end
