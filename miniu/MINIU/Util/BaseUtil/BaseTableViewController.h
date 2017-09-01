//
//  BaseTableViewController.h
//  miniu
//
//  Created by SimMan on 4/16/15.
//  Copyright (c) 2015 SimMan. All rights reserved.
//

#import "BaseViewController.h"

typedef enum  {
    LOAD_MORE = 0,    // 加载更多
    LOAD_UPDATE,           // 刷新
} LOAD_TYPE;

@interface BaseTableViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate>

/**
 *  当前的TableView
 */
@property (nonatomic, retain) UITableView *tableView;

/**
 *  当前的数据数组
 */
@property (nonatomic, retain) NSMutableArray *dataArray;

/**
 *  当前的页数
 */
@property (nonatomic, assign) NSUInteger pageNum;

/**
 *  下拉刷新与上拉加载更多 (如果为nil则取消)
 *
 *  @param headerAction 下拉
 *  @param footerAction 上拉
 *  @param autoRe       是否自动加载
 */
- (void) addRefreshBlockWithHeader:(void (^)())headerAction AndFooter:(void (^)())footerAction autoRefresh:(BOOL)autoRe;

/**
 *  @brief  添加一个Footer刷新
 *
 *  @param footerAction 
 */
- (void) addRefreshBlockWithFooter:(void (^)())footerAction;

/**
 *  停止刷新
 */
- (void)endRefresh;

/**
 *  CustomTableView
 */
- (void)customTable;

#pragma mark - 

/**
 *  @brief  向上移动
 */
- (void) scrollWillUp;

/**
 *  @brief 向下移动
 */
- (void) scrollWillDown;

/**
 *  @brief 将要移动
 */
- (void) scrollWillScroll;

@end
