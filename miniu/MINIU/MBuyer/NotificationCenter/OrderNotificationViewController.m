//
//  OrderNotificationViewController.m
//  miniu
//
//  Created by SimMan on 5/9/15.
//  Copyright (c) 2015 SimMan. All rights reserved.
//

#import "OrderNotificationViewController.h"
#import "ApplyOrderTableViewCell.h"
#import "GoodsDetailsViewController.h"

#if TARGET_IS_MINIU_BUYER
#import "ChatController.h"
#endif

@interface OrderNotificationViewController () <ApplyOrderTableViewCellDelegate>
@property (nonatomic, strong) RLMResults *dataResults;

@end

@implementation OrderNotificationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"订单通知";
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadDataSource) name:LOGMANAGER_DID_UPDATE object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor colorWithRed:0.953 green:0.957 blue:0.976 alpha:1];
    //    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.rowHeight = 150.f;
    [self setupRefresh];
}

- (void) reloadDataSource
{
    WeakSelf
    [self asyncMainQueue:^{
        [weakSelf_SC.tableView reloadData];
    }];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:NO animated:YES];
}

#pragma mark 上拉加载，下拉刷新
- (void)setupRefresh
{
    __weak __typeof(&*self)weakSelf_SC = self;
    [self addRefreshBlockWithHeader:^{
        [weakSelf_SC.tableView reloadData];
        [weakSelf_SC endRefresh];
    } AndFooter:nil autoRefresh:NO];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier=@"ApplyOrderTableViewCell";
    ApplyOrderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ApplyOrderTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
    }
    
    cell.log = self.dataResults[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    LogEntity *log = self.dataResults[indexPath.row];
    [[logicShareInstance getLogManager] setIsReadWith:log];
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark loadData
- (RLMResults *)dataResults
{
    return [[logicShareInstance getLogManager] getLogsWithLogType:LogTypeOfApplyOrder];
}

- (void) avatarImageViewDidTap:(LogEntity *)log
{
#if TARGET_IS_MINIU_BUYER

    [[logicShareInstance getLogManager] setIsReadWith:log];
    [self reloadDataSource];
    
    if ([log.hxUId length]) {
        ChatController *cvc = [[ChatController alloc] initWithChatter:log.hxUId];
        [self.navigationController pushViewController:cvc animated:YES];
    }
#endif
}

- (void) goodsDidTap:(LogEntity *)log
{
    [[logicShareInstance getLogManager] setIsReadWith:log];
    [self reloadDataSource];
    
    if (log.goodsId) {
        GoodsDetailsViewController *goodsVC = [[GoodsDetailsViewController alloc] init];
        goodsVC.goodsId = log.goodsId;
        [self.navigationController pushViewController:goodsVC animated:YES];
    }
}

- (void)scrollWillDown
{
    [self.rdv_tabBarController setTabBarHidden:NO animated:YES];
}

- (void)scrollWillUp
{   //yes to no
    [self.rdv_tabBarController setTabBarHidden:NO animated:YES];
}


@end
