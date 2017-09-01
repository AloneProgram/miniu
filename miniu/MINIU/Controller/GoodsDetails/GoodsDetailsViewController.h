//
//  GoodsDetailsViewController.h
//  miniu
//
//  Created by SimMan on 4/27/15.
//  Copyright (c) 2015 SimMan. All rights reserved.
//

#import "BaseTableViewController.h"

#import "OrderEntity.h"
@class HomeTableViewCellFrame;

@interface GoodsDetailsViewController : BaseTableViewController

@property (nonatomic, strong) HomeTableViewCellFrame *cellFrame;

@property (nonatomic, assign) long long goodsId;

/**
 *  订单实体
 */
@property (nonatomic, strong) OrderEntity *order;


/**
 *  创建订单详情页面方法
 *  2015.09.24
 *  @param order实体
 *
 *  @return 返回实例
 */
- (instancetype)initWithOrder:(OrderEntity *)order;

@end
