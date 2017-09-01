//
//  ChooseCompanyViewController.h
//  miniu
//
//  Created by SimMan on 15/6/10.
//  Copyright (c) 2015年 SimMan. All rights reserved.
//

#import "BaseTableViewController.h"

@interface ChooseCompanyViewController : BaseTableViewController

- (void)addCallBackBlock:(void(^)(NSString *code,NSString *company))Block;

@end
