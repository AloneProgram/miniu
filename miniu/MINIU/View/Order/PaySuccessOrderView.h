//
//  PaySuccessOrderView.h
//  miniu
//
//  Created by SimMan on 15/6/5.
//  Copyright (c) 2015年 SimMan. All rights reserved.
//

#import <UIKit/UIKit.h>
@class OrderEntity;

typedef NS_ENUM(NSInteger, logisticsAction){
    /**
     *  查看物流信息
     */
    logisticsActionWithInfo,
    /**
     *  添加收货地址
     */
    logisticsActionWithAddAddress,
    
//    /**
//     *  申请退款
//     */
//    logisticsActionWithRefund
//    
    
};

@protocol PaySuccessOrderViewDelegate <NSObject>
- (void) logisticsAction:(logisticsAction)action;
@end

@interface PaySuccessOrderView : UIView

@property (nonatomic, strong) UILabel *topTipLable;       // 提示信息
@property (nonatomic, strong) UILabel *centerTipLable;        // 价格
@property (nonatomic, strong) UIButton *logisticsInfoButton;    // 物流信息
@property (nonatomic, strong) UIButton *addLogisticsButton;     // 添加物流信息按钮
@property (nonatomic, strong) UILabel *logisticsInfoLable;      // 物流信息

@property (nonatomic, assign) id <PaySuccessOrderViewDelegate> delegate;
@property (nonatomic, strong) OrderEntity *order;

@end
