//
//  PayOrderView.h
//  miniu
//
//  Created by SimMan on 15/6/5.
//  Copyright (c) 2015年 SimMan. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  支付类型
 */
typedef NS_ENUM(NSInteger, payButtonTag){
    /**
     *  订金
     */
    payButtonTagWithWechatPay = 100,
    /**
     *  定金
     */
    payButtonTagWithAlipay,
    /**
     *  全款
     */
    payButtonTagWithBank
};

@class OrderEntity;

@protocol PayOrderViewDelegate <NSObject>
- (void) payButtonDidClick:(payButtonTag)payButtonTag;
@end

@interface PayOrderView : UIView

@property (nonatomic, assign) id <PayOrderViewDelegate> delegate;
@property (nonatomic, strong) OrderEntity *order;

@end
