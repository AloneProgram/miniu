//
//  UpdateDesViewController.h
//  miniu
//
//  Created by SimMan on 4/28/15.
//  Copyright (c) 2015 SimMan. All rights reserved.
//

#import "BaseViewController.h"

@interface UpdateDesViewController : BaseViewController

@property (nonatomic, strong) NSString *userDescription;

- (void)saveAction:(void (^)(NSString *string))saveAction;

@end
