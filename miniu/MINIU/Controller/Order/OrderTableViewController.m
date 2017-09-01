//
//  OrderTableViewController.m
//  miniu
//
//  Created by SimMan on 15/7/1.
//  Copyright (c) 2015年 SimMan. All rights reserved.
//

#import "OrderTableViewController.h"
#import "OrderListTableViewCell.h"
#import "ApplyOrderViewController.h"
#import "UITTTAttributedLabel.h"
#import "ChatController.h"

#import "MBProgressHUD.h"

#import "DZNSegmentedControl.h"

#import "MJRefresh.h"


#import <Foundation/Foundation.h>
@interface OrderTableViewController ()
@property (nonatomic, strong) UISegmentedControl *seg;
@property (nonatomic, strong) DZNSegmentedControl *dSeg;

@property (nonatomic, strong) NSMutableArray *oringeDataArray;//筛选前的数据
@property (nonatomic, strong) NSMutableArray *resultDataArray;//筛选后的数据

@property (nonatomic, assign) NSInteger *indexChoosed;//选择好的标签下标
@end

@implementation OrderTableViewController
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [ super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //#if TARGET_IS_MINIU_BUYER
        //        self.withUserId = 0;
        ////#else
        self.withUserId = USER_IS_LOGIN;
        //#endif
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"订单列表";
    
    self.navigationItem.backBarButtonItem = [UIBarButtonItem blankBarButton];
    
    [self setupRefresh];
    
    [self.view beginLoading];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (TARGET_IS_MINIU_BUYER) {
        [self.rdv_tabBarController setTabBarHidden:NO animated:YES];
    }
    
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
    
    [self.view addSubview:self.tableView];
    
    [self setupSegmentedControlHeader];
    //[self.tableView setBackgroundView:[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"blank__xxxx_ooo"]] ];
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//
//{
//    if (scrollView == self.tableView)
//    {
//        CGFloat sectionHeaderHeight = 40;
//        
//        if (scrollView.contentOffset.y <= sectionHeaderHeight
//            && scrollView.contentOffset.y >= 0) {
//            scrollView.contentInset = UIEdgeInsetsMake(- scrollView.contentOffset.y, 0, 0, 0);
//        }
//        else if (scrollView.contentOffset.y >= sectionHeaderHeight) {
//            scrollView.contentInset = UIEdgeInsetsMake(- sectionHeaderHeight, 0, 0, 0);
//        }
//    }
//}

/**
 *  配置分栏过滤
 */
- (void)setupSegmentedControlHeader
{
//    _seg = [[UISegmentedControl alloc]initWithItems:@[@"所有订单",@"未付款",@"已付款",@"已发货",@"退货"]];
//    _seg.backgroundColor = self.tableView.backgroundColor;
//    _seg.frame = CGRectMake(0, 0, kScreen_Width, 40);
//    _seg.tintColor = [self LZJcolorWithHex:0x3e3160 alpha:1];
//    _seg.backgroundColor = [UIColor whiteColor];
//    _seg.segmentedControlStyle = UISegmentedControlStyleBordered;
//    _seg.selectedSegmentIndex = 0;
//    [_seg addTarget:self action:@selector(changeSegment:) forControlEvents:(UIControlEventValueChanged)];
//    self.tableView.tableHeaderView = _seg;
    
    //自定义的
    _dSeg = [[DZNSegmentedControl alloc]initWithItems:@[@"所有订单",@"未付款",@"已付款",@"已发货",@"退货"]];
    _dSeg.tintColor = [UIColor colorWithRed:0.408 green:0.400 blue:0.388 alpha:1.0];//[self LZJcolorWithHex:0x3e3160 alpha:1];
//    _dSeg.delegate = self;
    [_dSeg addTarget:self action:@selector(changeSegment:) forControlEvents:(UIControlEventValueChanged)];
    _dSeg.frame = CGRectMake(0, 0, kScreen_Width, 40);
    _dSeg.showsCount = NO;
    _dSeg.font = [UIFont systemFontOfSize:14];
    _dSeg.autoAdjustSelectionIndicatorWidth = NO;
    _dSeg.showsGroupingSeparators = YES;
    _dSeg.adjustsButtonTopInset = NO;
    self.tableView.tableHeaderView = _dSeg;
    
    
}

/**
 *  用多参数的请求方式
 *
 *  @param sender segment
 */
-(void)changeSegment:(UISegmentedControl*)sender
{
    [self setupRefresh];
//    //NSLog(@"dataarray  ->> %@",self.dataArray);
//    if (!_resultDataArray) {
//        _resultDataArray = [[NSMutableArray alloc]init];
//    }
//    [_resultDataArray removeAllObjects];
//    //int key = 0;
//    NSPredicate *apredicate;
//    
//    switch (sender.selectedSegmentIndex) {
//        case 0:
//            //全部订单
//            [_resultDataArray addObjectsFromArray:self.oringeDataArray];
//            break;
//        case 1:{
//            //已付款
//            apredicate = [NSPredicate predicateWithFormat:@"SELF.orderStatus = 2"];
//            
//            NSArray*arr = [self.oringeDataArray filteredArrayUsingPredicate:apredicate];
//            _resultDataArray = [[NSMutableArray alloc]initWithArray:arr];
//            break;
//        }
//        case 2:{
//            //已发货
//            apredicate = [NSPredicate predicateWithFormat:@"SELF.orderStatus = 3"];
//            
//            NSArray*arr = [self.oringeDataArray filteredArrayUsingPredicate:apredicate];
//            _resultDataArray = [[NSMutableArray alloc]initWithArray:arr];
//            break;
//        }
//        case 3:
//        {
//            //test
//            self.pageNum = 1;
//            [[logicShareInstance getOrderManager] getOrderListWithUserId:USER_IS_LOGIN QueryType:0 orderListType:2 CurrentPage:self.pageNum pageSize:30 limitTime:10 success:^(id responseObject) {
//                NSLog(@"%@",responseObject);
//            } failure:^(NSString *error) {
//                NSLog(@"error - >%@",error);
//            }];
//            
//            //未付款
////            apredicate = [NSPredicate predicateWithFormat:@"SELF.orderStatus != 2"];
////            
////            NSArray*arr = [self.oringeDataArray filteredArrayUsingPredicate:apredicate];
////            _resultDataArray = [[NSMutableArray alloc]initWithArray:arr];
//            break;
//        }
//        default:
//            break;
//    }
//    self.dataArray = _resultDataArray;
//    //[self.tableView reloadData];
//    [self refreshControl];
}

-(void)refreshControl
{
    [self.tableView reloadData];
    
    if (self.dataArray.count ==0) {
        UIAlertView *noResultAlert = [[UIAlertView alloc]initWithTitle:@"没有数据!" message:@"等待后台接口提供" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [noResultAlert show];
//       UIWebView *web = [[UIWebView alloc]initWithFrame:kScreen_Bounds];
//
//        [web loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.baidu.com/s?wd=gif&tn=myie2_2_dg"]]];
//        [self.view addSubview:web];
    }
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
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
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
    //根据seg选中状态 进行更新数据
    __weak __typeof(&*self)weakSelf_SC = self;
    
    //简化处理
    [self addRefreshBlockWithHeader:^{
        weakSelf_SC.pageNum = 1;
        [weakSelf_SC netWorkRequestForGoodsListWithPage:weakSelf_SC.pageNum Type:LOAD_UPDATE ListType:weakSelf_SC.dSeg.selectedSegmentIndex QueryType:weakSelf_SC.dSeg.selectedSegmentIndex];
        //[weakSelf_SC netWorkRequestForGoodsListWithPage:weakSelf_SC.pageNum Type:LOAD_UPDATE];
    } AndFooter:nil autoRefresh:YES];
    
    
//复杂处理
//    
//    if (_seg.selectedSegmentIndex == 0) {
//        [self addRefreshBlockWithHeader:^{
//            weakSelf_SC.pageNum = 1;
//            [weakSelf_SC netWorkRequestForGoodsListWithPage:weakSelf_SC.pageNum Type:LOAD_UPDATE];
//        } AndFooter:nil autoRefresh:YES];
//    }else if (_seg.selectedSegmentIndex == 1){
//        
//        [self addRefreshBlockWithHeader:^{
//            weakSelf_SC.pageNum = 1;
//            
//            [weakSelf_SC netWorkRequestForGoodsListWithPage:weakSelf_SC.pageNum Type:LOAD_UPDATE ListType:(orderListTypeOfisPaymentFull) QueryType:3];
//            
//            
//        } AndFooter:nil autoRefresh:YES];
//        
//    }else if (_seg.selectedSegmentIndex == 2){
//    
//        [self addRefreshBlockWithHeader:^{
//            weakSelf_SC.pageNum = 1;
//            
//            [weakSelf_SC netWorkRequestForGoodsListWithPage:weakSelf_SC.pageNum Type:LOAD_UPDATE ListType:(orderListTypeOfisDeliver) QueryType:3];
//            
//
//        } AndFooter:nil autoRefresh:YES];
//        
//    } else if (_seg.selectedSegmentIndex == 3)
//        {
//            
//            [self addRefreshBlockWithHeader:^{
//                weakSelf_SC.pageNum = 1;
//                
//                [weakSelf_SC netWorkRequestForGoodsListWithPage:weakSelf_SC.pageNum Type:LOAD_UPDATE ListType:(orderListTypeOfWaitPayment) QueryType:0];
//                
////                [[logicShareInstance getOrderManager] getOrderListWithUserId:USER_IS_LOGIN QueryType:0 orderListType:2 CurrentPage:weakSelf_SC.pageNum pageSize:30 limitTime:10 success:^(id responseObject) {
////                    NSLog(@"%@",responseObject);
////                } failure:^(NSString *error) {
////                    NSLog(@"error - >%@",error);
////                }];
//
//            } AndFooter:nil autoRefresh:YES];
//
//        }
    
}

/**
 *  根据订单类型查询订单
 *
 *  @param pageNum  页码
 *  @param type     刷新 还是 加载更多
 *  @param listType 订单类型
 */
- (void)netWorkRequestForGoodsListWithPage:(NSInteger)pageNum Type:(LOAD_TYPE)type ListType:(int)listType QueryType:(int)que
{
    WeakSelf
    
    [[logicShareInstance getOrderManager]getOrderListWithUserId:_withUserId==0 ?USER_IS_LOGIN:_withUserId QueryType:que orderListType:(listType) CurrentPage:pageNum pageSize:50 limitTime:10 success:^(id responseObject) {
        
//        NSLog(@"page -> %@",responseObject);
        
        
        @try {
            NSMutableArray *tmpDataArray = [NSMutableArray arrayWithCapacity:1];
            NSLog(@"currentRequest 请求的id-> %lld",_withUserId);
            for (NSDictionary *dic in [responseObject objectForKey:@"data"]){
                OrderEntity *order = [[OrderEntity alloc] init];
                [order setValuesForKeysWithDictionary:dic];
                [tmpDataArray addObject:order];
            }
            
//            //没有内容的时候 设置footer 为nil
//            if([tmpDataArray count]==0){
//                weakSelf_SC.tableView.tableFooterView = nil;
//                return ;
//            }
            
            if ([tmpDataArray count]) {
                if (type == LOAD_UPDATE) {
                    [weakSelf_SC.dataArray removeAllObjects];
                    
                }
                [weakSelf_SC.dataArray addObjectsFromArray:tmpDataArray];
                //保存一份副本
//                if (!weakSelf_SC.oringeDataArray) {
//                    weakSelf_SC.oringeDataArray = [[NSMutableArray alloc]init];
//                }
               // [weakSelf_SC.oringeDataArray removeAllObjects];
                //[weakSelf_SC.oringeDataArray addObjectsFromArray:weakSelf_SC.dataArray];
                
                if ([weakSelf_SC.dataArray count] > 0) {
                    [weakSelf_SC addRefreshBlockWithFooter:^{
                        weakSelf_SC.pageNum ++;
                        
                        [weakSelf_SC  netWorkRequestForGoodsListWithPage:weakSelf_SC.pageNum Type:LOAD_MORE ListType:listType QueryType:que];
                    }];
                }else{
                }
                [((MJRefreshFooter*)weakSelf_SC.tableView.footer) setTitle:@"点击加载更多" forState:MJRefreshFooterStateIdle];
                [weakSelf_SC.tableView reloadData];
                
            } else {
                [((MJRefreshFooter*)weakSelf_SC.tableView.footer) setTitle:@"没有更多数据" forState:MJRefreshFooterStateIdle];
                if (type == LOAD_MORE) {
                    weakSelf_SC.pageNum --;
                    //没有更多数据了
                    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    hud.mode = MBProgressHUDModeText;
                    hud.labelText = @"米妞没有更多数据啦";
                    
                    [hud hide:YES afterDelay:1];
                }else if (type == LOAD_UPDATE){
                    //一次数据都没有
                    [weakSelf_SC.dataArray removeAllObjects];
                    
                    //如果没有数据 需要去掉尾部加载的方法
                    [weakSelf_SC addRefreshBlockWithFooter:^{
                        [self showHudSuccess:@"米妞没有相关数据"];
                        [self endRefresh];
                    }];
                    
                    [weakSelf_SC.tableView reloadData];
                }
            }
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            [weakSelf_SC.view endLoading];
            
//[weakSelf_SC.view configBlankPage:EaseBlankPageTypeCollect hasData:[weakSelf_SC.dataArray count] hasError:NO reloadButtonBlock:nil];
        };

    } failure:^(NSString *error) {
        if (type == LOAD_MORE) {
            weakSelf_SC.pageNum --;
        }
        [weakSelf_SC.view endLoading];
        [weakSelf_SC showStatusBarError:error];
    }];
}


- (void)netWorkRequestForGoodsListWithPage:(NSInteger)pageNum Type:(LOAD_TYPE)type
{
//    //超级帐号可以看全部订单
//    if (USER_IS_LOGIN == 99 || USER_IS_LOGIN == 1) {
//        self.withUserId = 0;
//    }else if(self.withUserId == 0){
//        self.withUserId = USER_IS_LOGIN;
//    }
    WeakSelf
    
    [self.currentRequest addObject:[[logicShareInstance getOrderManager] getOrderListWithUserId:self.withUserId CurrentPage:pageNum pageSize:50 limitTime:0 success:^(id responseObject) {
        @try {
            NSMutableArray *tmpDataArray = [NSMutableArray arrayWithCapacity:1];
            NSLog(@"currentRequest 请求的id-> %lld",self.withUserId);
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
                //保存一份副本
                if (!weakSelf_SC.oringeDataArray) {
                    weakSelf_SC.oringeDataArray = [[NSMutableArray alloc]init];
                }
                [weakSelf_SC.oringeDataArray removeAllObjects];
                [weakSelf_SC.oringeDataArray addObjectsFromArray:weakSelf_SC.dataArray];
                
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

- (UIColor*) LZJcolorWithHex:(NSInteger)hexValue alpha:(CGFloat)alphaValue
{
    return [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0
                           green:((float)((hexValue & 0xFF00) >> 8))/255.0
                            blue:((float)(hexValue & 0xFF))/255.0 alpha:alphaValue];
}
@end
