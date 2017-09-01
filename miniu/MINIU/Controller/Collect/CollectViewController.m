//
//  CollectViewController.m
//  miniu
//
//  Created by SimMan on 4/27/15.
//  Copyright (c) 2015 SimMan. All rights reserved.
//

#import "CollectViewController.h"
#import "CollectTableViewCell.h"
#import "GoodsEntity.h"
#import "GoodsDetailsViewController.h"

@interface CollectViewController ()

@end

@implementation CollectViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"我的收藏";
    
    [self setupRefresh];
    
    [self.view beginLoading];
}

- (void)customTable
{
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth
    |UIViewAutoresizingFlexibleHeight;
    

    
    if (IS_IOS7) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if (IS_IOS8) {
        if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
            [self.tableView setSeparatorInset:UIEdgeInsetsMake(0,-20,0,0)];
        }
        
        if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
            [self.tableView setLayoutMargins:UIEdgeInsetsMake(0,-20,0,0)];
        }
    }
    
    self.tableView.rowHeight = 110.0f;
    
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CollectTableViewCell";
    CollectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[CollectTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    GoodsEntity *goods = self.dataArray[indexPath.section];
    //处理已下架的情况
    if(goods.status == 2)
    {
        UILabel *offLabel =[[UILabel alloc]initWithFrame:CGRectMake(120, 80, 180, 20)];
        [offLabel setTextColor:[UIColor redColor]];
        [offLabel setText:@"此商品已下架"];
        [cell addSubview:offLabel];
    }
    cell.goodsEntity = goods;
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1.0f;
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GoodsEntity *goods = self.dataArray[indexPath.section];
    if(goods.status == 2)return;
    GoodsDetailsViewController *goodsDetailsVC = [[GoodsDetailsViewController alloc] init];
    goodsDetailsVC.goodsId = goods.goodsId;
    
    [self.navigationController pushViewController:goodsDetailsVC animated:YES];
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

- (void)netWorkRequestForGoodsListWithPage:(NSInteger)pageNum Type:(LOAD_TYPE)type
{
    WeakSelf
    
    [self.currentRequest addObject:[[logicShareInstance getUserManager] getCollectListWithCurrentPage:pageNum pageSize:0 success:^(id responseObject) {
        @try {
            NSMutableArray *tmpDataArray = [NSMutableArray arrayWithCapacity:1];
            
            for (NSDictionary *dic in [responseObject objectForKey:@"data"]){
                GoodsEntity *goods = [[GoodsEntity alloc] init];
                [goods setValuesForKeysWithDictionary:dic];
                
                [tmpDataArray addObject:goods];
            }
            
            if ([tmpDataArray count]) {
                if (type == LOAD_UPDATE) {
                    [weakSelf_SC.dataArray removeAllObjects];
                }
                [weakSelf_SC.dataArray addObjectsFromArray:tmpDataArray];
                
                if ([weakSelf_SC.dataArray count] >= 20) {
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

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除它";
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        GoodsEntity *goods = self.dataArray[indexPath.section];
        [[logicShareInstance getGoodsManager] delCollectGoodsWithGoodsId:goods.goodsId success:^(id responseObject) {
            [self.dataArray removeObjectAtIndex:indexPath.section];
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationBottom];
            //do some network things
        } failure:^(NSString *error) {
            [self showStatusBarSuccessStr:@"删除收藏商品失败!"];}
         ];
        

    }
}


@end
