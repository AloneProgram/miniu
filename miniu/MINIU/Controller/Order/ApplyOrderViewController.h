//
//  ApplyOrderViewController.h
//  miniu
//
//  Created by SimMan on 4/27/15.
//  Copyright (c) 2015 SimMan. All rights reserved.
//

#import "BaseViewController.h"

@interface ApplyOrderViewController : BaseViewController

@property (nonatomic, assign) long long goodsId;    // 如果在 webView进来则必传GoodsId

@property (nonatomic, strong) OrderEntity *order;   // 如果订单状态为 已付定金、已付款状态则必传



@end
