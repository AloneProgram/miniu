//
//  OrderListViewController.m
//  miniu
//  这是侧边栏的订单详情
//  Created by SimMan on 15/6/4.
//  Copyright (c) 2015年 SimMan. All rights reserved.
//

#import "OrderListViewController.h"
#import "OrderListTableViewCell.h"
#import "ApplyOrderViewController.h"
#import "UITTTAttributedLabel.h"

#if TARGET_IS_MINIU_BUYER
#import "ChatController.h"
#endif

@interface OrderListViewController ()<UISearchBarDelegate>

@end

@implementation OrderListViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [ super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
//#if TARGET_IS_MINIU_BUYER
//        self.withUserId = 0;
////#else
        //#endif
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //self.withUserId = USER_IS_LOGIN;//不能这样改 ta的订单也是这里

    self.title = @"订单列表";
    
    self.navigationItem.backBarButtonItem = [UIBarButtonItem blankBarButton];
    
    //获取内容
    [self setupRefresh];
    
    [self.view beginLoading];
    
    //配置order search bar
//    UISearchBar * searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, kScreen_Width, 40)];
//    searchBar.searchBarStyle = UISearchBarStyleProminent;
//    //searchBar.showsCancelButton = YES;
//    searchBar.placeholder = @"搜索订单";
//    searchBar.delegate = self;
//    self.tableView.tableHeaderView = searchBar;
    
    //设为标签过滤
    CGRect rect = CGRectMake(0, 0, kScreen_Width, 40);
    UIView *selectFilter =[[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreen_Width, 40)];
    
    UIButton *btn1 = [UIButton buttonWithType:(UIButtonTypeRoundedRect)];
    //btn1.titleLabel.font = [UIFont flatFontOfSize:14];
    [btn1 setTitle: @"待发货" forState:(UIControlStateNormal)];
    [btn1 setTintColor:[UIColor orangeColor]];
    btn1.frame = CGRectMake(0, 0, kScreen_Width/4, rect.size.height);
    [selectFilter addSubview:btn1];
    [btn1 bk_addEventHandler:^(id sender) {
        //do something
        NSLog(@"asd");
    } forControlEvents:(UIControlEventTouchUpInside)];
    //btn1.backgroundColor = [UIColor blackColor];
    
    UIButton *btn2 = [UIButton buttonWithType:(UIButtonTypeRoundedRect)];
    [btn2 setTitle:@"未付款" forState:(UIControlStateNormal)] ;
    //btn2.titleLabel.font = [UIFont flatFontOfSize:14];
    btn2.frame = CGRectMake(kScreen_Width/4, 0, kScreen_Width/4, rect.size.height);
    [selectFilter addSubview:btn2];
    //btn2.backgroundColor = [UIColor blueColor];
    
    UIButton *btn3 = [UIButton buttonWithType:(UIButtonTypeRoundedRect)];
    //btn3.titleLabel.font = [UIFont flatFontOfSize:14];
    [btn3 setTitle:@"已发货" forState:(UIControlStateNormal)];
    btn3.frame = CGRectMake(kScreen_Width * 2/4, 0, kScreen_Width /4, rect.size.height);
    [selectFilter addSubview:btn3];
    //btn3.backgroundColor = [UIColor redColor];
    
    UIButton *btn4 = [UIButton buttonWithType:(UIButtonTypeRoundedRect)];
    //btn3.titleLabel.font = [UIFont flatFontOfSize:14];
    [btn4 setTitle:@"已成交" forState:(UIControlStateNormal)];
    btn4.frame = CGRectMake(kScreen_Width * 3/4, 0, kScreen_Width /4, rect.size.height);
    [selectFilter addSubview:btn4];
    //self.tableView.tableHeaderView = selectFilter;
}

- (void)customTable
{
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth
    |UIViewAutoresizingFlexibleHeight;
    
    self.tableView.rowHeight = 178.0f;
    
    //高度减去tabbar的高度
    //self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height-50);
    
    [self.view addSubview:self.tableView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.dataArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 25)];
    UITTTAttributedLabel *orderNoLable = [[UITTTAttributedLabel alloc] initWithFrame:CGRectMake(10, 10, kScreen_Width/2, 15)];
    [orderNoLable addLongPressForCopy];
    [orderNoLable setFont:[UIFont systemFontOfSize:11]];
    [orderNoLable setTextColor:[UIColor colorWithRed:0.624 green:0.624 blue:0.624 alpha:1]];
    
    UITTTAttributedLabel *timeLable = [[UITTTAttributedLabel alloc] initWithFrame:CGRectMake(orderNoLable.selfMaxX + 5, 10, kScreen_Width - orderNoLable.selfMaxX - 5 - 10, 15)];
    [timeLable setFont:[UIFont systemFontOfSize:11]];
    [timeLable setTextColor:[UIColor colorWithRed:0.624 green:0.624 blue:0.624 alpha:1]];
    [timeLable setTextAlignment:NSTextAlignmentRight];
    
    OrderEntity *order = [self.dataArray objectAtIndex:section];

    [orderNoLable setText:[NSString stringWithFormat:@"订单号：%@", order.orderNo]];
    
    NSDate *create_date = [NSDate dateWithTimeIntervalInMilliSecondSince1970:order.createTime];
    [timeLable setText:[NSString stringWithFormat:@"%@", [create_date formattedDateForFull]]];

    [view addSubview:orderNoLable];
    [view addSubview:timeLable];
    
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"OrderListCell";
    OrderListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[OrderListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    OrderEntity *order = [self.dataArray objectAtIndex:indexPath.section];
    cell.order = order;
    
    WeakSelf
    
    
    [cell tapAvatarImageViewCallBackBlock:^(OrderEntity *order) {
#if TARGET_IS_MINIU_BUYER
        ChatController *ChatVC = [[ChatController alloc] initWithChatter:order.applyHxUId];
        [weakSelf_SC.navigationController pushViewController:ChatVC animated:YES];
#endif
    }];
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 25.0f;
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    OrderEntity *order = [self.dataArray objectAtIndex:indexPath.section];
    
    ApplyOrderViewController *applyOrderVC = [[ApplyOrderViewController alloc] init];
    applyOrderVC.order = order;
    [self.navigationController pushViewController:applyOrderVC animated:YES];
}


#pragma mark 上拉加载，下拉刷新
- (void)setupRefresh
{
    __weak __typeof(&*self)weakSelf_SC = self;
    [self addRefreshBlockWithHeader:^{
        weakSelf_SC.pageNum = 1;
        [weakSelf_SC netWorkRequestForGoodsListWithPage:weakSelf_SC.pageNum Type:LOAD_UPDATE];
    } AndFooter:nil autoRefresh:YES];
}

/**
 *  获取页面订单内容
 *  http://api.kuaidi100.com/api?id=bcd9e1e488016de1&com=快递公司代码&nu=快递单号&show=0&muti=1&order=desc
 *  @param pageNum 页码
 *  @param type    刷新 or 加载更多
 */
- (void)netWorkRequestForGoodsListWithPage:(NSInteger)pageNum Type:(LOAD_TYPE)type
{
//    if(USER_IS_LOGIN == 99){
//        //如果请求id = 0 ,则不显示数据
////        [self showHudError:@"user id = 0!\ncan not get any information"];
////        return ;
//        
//        self.withUserId = 0;
//    }else{
//        self.withUserId = USER_IS_LOGIN;
//    }
    if(self.withUserId == 0)
    {
        self.withUserId = USER_IS_LOGIN;
    }
    WeakSelf
    //用一个数组保存当前的网络请求对象
    [self.currentRequest addObject:[[logicShareInstance getOrderManager] getOrderListWithUserId:self.withUserId CurrentPage:pageNum pageSize:50 limitTime:0 success:^(id responseObject) {
        //请求成功时
        @try {
            
            NSLog(@"currentRequest 请求的id-> %lld",self.withUserId);
                        //订单对象数组
            NSMutableArray *tmpDataArray = [NSMutableArray arrayWithCapacity:1];
            
            for (NSDictionary *dic in [responseObject objectForKey:@"data"]){
                OrderEntity *order = [[OrderEntity alloc] init];
                [order setValuesForKeysWithDictionary:dic];
                [tmpDataArray addObject:order];
            }
            
            if ([tmpDataArray count]) {
                if (type == LOAD_UPDATE) {
                    [weakSelf_SC.dataArray removeAllObjects];
                }
                [weakSelf_SC.dataArray addObjectsFromArray:tmpDataArray];
                
                if ([weakSelf_SC.dataArray count] > 20) {
                    [weakSelf_SC addRefreshBlockWithFooter:^{
                        weakSelf_SC.pageNum ++;
                        [weakSelf_SC netWorkRequestForGoodsListWithPage:weakSelf_SC.pageNum Type:LOAD_MORE];
                    }];
                }
                
                [weakSelf_SC.tableView reloadData];
                
            } else {
                if (type == LOAD_MORE) {
                    weakSelf_SC.pageNum --;
                }
            }
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            [weakSelf_SC.view endLoading];
            
            [weakSelf_SC.view configBlankPage:EaseBlankPageTypeCollect hasData:[weakSelf_SC.dataArray count] hasError:NO reloadButtonBlock:nil];
        };
    } failure:^(NSString *error) {
        if (type == LOAD_MORE) {
            weakSelf_SC.pageNum --;
        }
        [weakSelf_SC.view endLoading];
        [weakSelf_SC showStatusBarError:error];
    }]];
}

#pragma mark - search bar delegate
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = NO;
    [searchBar resignFirstResponder];
}

-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = YES;
    return YES;
}
@end
