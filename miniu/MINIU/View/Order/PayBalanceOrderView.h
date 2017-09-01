//
//  PayBalanceOrderView.h
//  miniu
//
//  Created by SimMan on 15/6/5.
//  Copyright (c) 2015年 SimMan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaySuccessOrderView.h"
@class OrderEntity;


@protocol PayBalanceOrderViewDelegate <NSObject>
- (void) logisticsAction:(logisticsAction)action;
- (void) choosePayMentButton;
@end


@interface PayBalanceOrderView : UIView

@property (nonatomic, assign) id <PayBalanceOrderViewDelegate> delegate;
@property (nonatomic, strong) OrderEntity *order;

@end
