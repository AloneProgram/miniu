//
//  ScanViewController.h
//  miniu
//
//  Created by SimMan on 15/6/10.
//  Copyright (c) 2015年 SimMan. All rights reserved.
//

#import "BaseViewController.h"

@interface ScanViewController : BaseViewController

- (void)addCallBackBlock:(void(^)(NSString *code))Block;

@end
