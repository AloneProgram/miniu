//
//  UserAddressViewController.h
//  miniu
//
//  Created by SimMan on 15/6/1.
//  Copyright (c) 2015年 SimMan. All rights reserved.
//

#import "BaseTableViewController.h"

@class AddressEntity;
@class OrderEntity;
@interface UserAddressViewController : BaseTableViewController

@property (nonatomic,strong)OrderEntity *order;
@property (nonatomic, strong) UIImageView *selectedMark; //选上的地址

- (void) createAddressApplyId:(long long)applyId
               addCallBackBlock:(void(^)(AddressEntity *address))Block;

@end
