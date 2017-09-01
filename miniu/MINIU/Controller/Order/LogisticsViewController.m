//
//  LogisticsViewController.m
//  miniu
//
//  Created by SimMan on 15/6/8.
//  Copyright (c) 2015年 SimMan. All rights reserved.
//

#import "LogisticsViewController.h"
#import "OrderEntity.h"
#import "LogisticsTableViewCell.h"
#import "ApplyOrderView.h"
#import "TOWebViewController.h"

//#if TARGET_IS_MINIU_BUYER
#import "LogisticsAddViewController.h"

@interface LogisticsViewController ()

@end

@implementation LogisticsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"物流信息";


#if TARGET_IS_MINIU_BUYER
    //添加物流信息
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] bk_initWithBarButtonSystemItem:UIBarButtonSystemItemAdd handler:^(id sender) {
        
        LogisticsAddViewController *logisticsVC = [LogisticsAddViewController new];
        logisticsVC.orderNo = self.order.orderNo;
        [self.navigationController pushViewController:logisticsVC animated:YES];
    }];
#endif
    
    self.navigationItem.backBarButtonItem = [UIBarButtonItem blankBarButton];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;

    [self setupRefresh];
    
    [self.view beginLoading];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self netWorkRequestForGoodsListWithPage:self.pageNum Type:LOAD_UPDATE];
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 200.0f;
}

/**
 *  设置头部view
 */
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    ApplyOrderView *applyOrderView = [ApplyOrderView new];
    [applyOrderView setOrderEntity:self.order];
    applyOrderView.backGroundColor = [UIColor whiteColor];
    applyOrderView.isEnableBottomLine = YES;//并没有效果
    return applyOrderView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataArray count];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LogisticsEntity *logistics = [self.dataArray objectAtIndex:indexPath.row];
    
    return [LogisticsTableViewCell cellHeightWith:logistics];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"LogisticsTableViewCell";
    LogisticsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[LogisticsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    LogisticsEntity *logistics = [self.dataArray objectAtIndex:indexPath.row];
    cell.logistics = logistics;
    
    if (indexPath.row == 0) {
        cell.isLast = YES;
    }
    
    //2015.08.05 10000->4
    if (self.order.orderStatus == 100) {
        cell.isFinished = YES;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LogisticsEntity *logistics = [self.dataArray objectAtIndex:indexPath.row];
    
    NSLog(@"物流点击数据 ->%ld,%d",[logistics.code length],[logistics.invoiceNo length]);
    //查物流 [logistics.code length] && 
    if ([logistics.invoiceNo length]) {
        NSString *kuaidi100URL = [NSString stringWithFormat:@"http://m.kuaidi100.com/index_all.html?type=%@&postid=%@&callbackurl=http://miniu/popvc#result", logistics.code, logistics.invoiceNo];
        
        TOWebViewController *webViewController = [[TOWebViewController alloc] initWithURL:[NSURL URLWithString:kuaidi100URL]];
        webViewController.showPageTitles = NO;
        webViewController.title = [NSString stringWithFormat:@"%@", logistics.company];
        webViewController.navigationButtonsHidden = YES;
        webViewController.hideWebViewBoundaries = YES;
        
        [self.navigationController pushViewController:webViewController animated:YES];
        //[self presentViewController:[[UINavigationController alloc] initWithRootViewController:webViewController] animated:YES completion:nil];
    }
}


#pragma mark 上拉加载，下拉刷新
- (void)setupRefresh
{
    __weak __typeof(&*self)weakSelf_SC = self;
    [self addRefreshBlockWithHeader:^{
        weakSelf_SC.pageNum = 1;
        [weakSelf_SC netWorkRequestForGoodsListWithPage:weakSelf_SC.pageNum Type:LOAD_UPDATE];
    } AndFooter:nil autoRefresh:NO];
}

- (void)netWorkRequestForGoodsListWithPage:(NSInteger)pageNum Type:(LOAD_TYPE)type
{
    WeakSelf
    
    [[logicShareInstance getOrderManager] getLogisticsListWithOrderNo:self.order.orderNo success:^(id responseObject) {
        @try {
            NSMutableArray *tmpDataArray = [NSMutableArray arrayWithCapacity:1];
            
            for (NSDictionary *dic in [responseObject objectForKey:@"data"]){
                LogisticsEntity *logistics = [[LogisticsEntity alloc] init];
                [logistics setValuesForKeysWithDictionary:dic];
                [tmpDataArray addObject:logistics];
            }
            
            if ([tmpDataArray count]) {
                if (type == LOAD_UPDATE) {
                    [weakSelf_SC.dataArray removeAllObjects];
                }
                [weakSelf_SC.dataArray addObjectsFromArray:tmpDataArray];
                [weakSelf_SC.tableView reloadData];
                
            }
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            [weakSelf_SC.view endLoading];
            
            [weakSelf_SC.view configBlankPage:EaseBlankPageTypeCollect hasData:[weakSelf_SC.dataArray count] hasError:NO reloadButtonBlock:nil];
        };

    } failure:^(NSString *error) {
        [weakSelf_SC.view endLoading];
        [weakSelf_SC showStatusBarError:error];
    }];
}



@end
