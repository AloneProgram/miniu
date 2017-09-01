//
//  SearchListViewController.m
//  miniu
//
//  Created by SimMan on 4/28/15.
//  Copyright (c) 2015 SimMan. All rights reserved.
//

#import "SearchListViewController.h"
#import "REFrostedNavigationController.h"
#import "BlocksKit.h"
#import "HomeTableViewCell.h"
#import "GoodsEntity.h"
#import "SDWebImageManager.h"
#import "ShowMenuView.h"
#import "ApplyOrderViewController.h"
#import "UserEntity.h"
#import "SearchViewController.h"

#import "GoodsDetailsViewController.h"

#import "IndexTagViewController.h"

#if TARGET_IS_MINIU_BUYER
@interface SearchListViewController () <ShowMenuViewDelegate, HomeTableViewCellDelegate> {
    CGFloat _oldPanOffsetY;
}
#else
@interface SearchListViewController () <ShowMenuViewDelegate, HomeTableViewCellDelegate> {
    CGFloat _oldPanOffsetY;
}
#endif

#if TARGET_IS_MINIU
@property (nonatomic, strong) UIBarButtonItem *chatButtonItem;
#endif

@end

@implementation SearchListViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [ShowMenuView shareInstance].delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.backBarButtonItem = [UIBarButtonItem blankBarButton];
    
    self.title = self.keyWord;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self setupRefresh];
    
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 44)];
    //留白
    footView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = footView;
    
    [self.view beginLoading];
}

/**
 *  点击"分类"进入搜索界面 新版本改用web版
 */
- (void) pushSearchViewController
{
   // 旧版本
    SearchViewController *searchVC = [[SearchViewController alloc] init];
    [self.navigationController pushViewController:searchVC animated:YES];
    //新版本
//    NSString *tagIndexViewURL = [NSString stringWithFormat:@"%@/goods/goodsLabel.action?appKey=ios", [[URLManager shareInstance] getNoServerBaseURL]];
//    
//    IndexTagViewController *searchVC = [[IndexTagViewController alloc]initWithURLString:tagIndexViewURL];
//
    
    //[self.navigationController pushViewController:searchVC animated:YES];

}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HomeTableViewCellFrame *cellFrame = [self.dataArray objectAtIndex:indexPath.row];
    return cellFrame.cellSize.height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataArray count];
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.0f;
}

/**
 *  头部的 view
 *
 *  @param tableView 获取的结果表格视图
 *  @param section   只有1个
 *
 *  @return 头部view
 */
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 40)];
    
    UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 40)];
    [lable setText:[NSString stringWithFormat:@"与\"%@\"相关的结果", self.keyWord]];
    [lable setTextColor:[UIColor lightGrayColor]];
    [lable setFont:[UIFont flatFontOfSize:14]];
    [lable setTextAlignment:NSTextAlignmentCenter];
    [lable setBackgroundColor:[UIColor colorWithRed:0.965 green:0.965 blue:0.965 alpha:1]];
    [view addSubview:lable];
    
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier=@"HomeTableViewCell";
    HomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[HomeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    HomeTableViewCellFrame *cellFrame = self.dataArray[indexPath.row];
    cell.cellFrame = cellFrame;
    
    cell.delegate = self;
    
    WeakSelf
    [cell addTapDesBlock:^(HomeTableViewCell *cell) {
        GoodsDetailsViewController *goodsDes = [[GoodsDetailsViewController alloc] init];
        goodsDes.cellFrame = cell.cellFrame;
        [weakSelf_SC.navigationController pushViewController:goodsDes animated:YES];
    }];
    
    [cell loadImageView];
    
    return cell;
}

/**
 *  @brief  点击Cell中的活动标签
 *
 *  @param tagName
 */
- (void)didSelectTagName:(NSString *)tagName
{
    if (![tagName length] || [tagName isEqualToString:self.tagName]) {
        return;
    }
    SearchListViewController *searchListVC = [SearchListViewController new];
    searchListVC.keyWord = tagName;
    [self.navigationController pushViewController:searchListVC animated:YES];
}

#pragma mark 网络请求 商品列表
- (void)netWorkRequestForGoodsListWithPage:(NSInteger)pageNum Type:(LOAD_TYPE)type
{
    WeakSelf
    
    [[logicShareInstance getGoodsManager] searchGoodsListWithKeyWordsAndTag:self.keyWord tagName:self.tagName CurrentPage:pageNum pageSize:40 success:^(id responseObject) {
        @try {
            NSMutableArray *tmpDataArray = [NSMutableArray arrayWithCapacity:1];
            
            for (NSDictionary *dic in [responseObject objectForKey:@"data"]){
                GoodsEntity *goods = [[GoodsEntity alloc] init];
                [goods setValuesForKeysWithDictionary:dic];
                HomeTableViewCellFrame *cellFrame = [[HomeTableViewCellFrame alloc] initWithObject:goods];
                [tmpDataArray addObject:cellFrame];
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
            [weakSelf_SC.view configBlankPage:EaseBlankPageTypeSearch hasData:[weakSelf_SC.dataArray count] hasError:NO reloadButtonBlock:nil];
        };
    } failure:^(NSString *error) {
        [weakSelf_SC.view endLoading];
        [weakSelf_SC showStatusBarError:error];
        weakSelf_SC.pageNum --;
    }];
}

#if TARGET_IS_MINIU_BUYER
- (void) didDeleteWithCell:(HomeTableViewCell *)cell
{
    WeakSelf
    [WCAlertView showAlertWithTitle:@"提示" message:@"删除后不可恢复,继续？" customizationBlock:^(WCAlertView *alertView) {
        
    } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
        
        if (buttonIndex == 1) {

#warning        不能随便删除物品 应当设置权限

            [[logicShareInstance getGoodsManager] delGoodsWithGoodsId:cell.cellFrame.goodsEntity.goodsId success:^(id responseObject) {
                [weakSelf_SC.dataArray removeObject:cell.cellFrame];
                [weakSelf_SC.tableView reloadData];
                [weakSelf_SC showHudSuccess:@"删除成功!"];
                
            } failure:^(NSString *error) {
                [weakSelf_SC showHudError:error];
            }];
        }
        
    } cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
}
#endif

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [ShowMenuView hidden];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [SDWebImageManager.sharedManager.imageCache clearMemory];
}

#pragma mark showMenuViewDelegate

- (void) favoriteButtonAction:(BOOL)selected object:(HomeTableViewCell *)cell
{
    if (cell.cellFrame.goodsEntity.isMyLike) {
        [[logicShareInstance getGoodsManager] delCollectGoodsWithGoodsId:cell.cellFrame.goodsEntity.goodsId success:^(id responseObject) {} failure:^(NSString *error) {}];
        [self showStatusBarSuccessStr:@"取消收藏成功!"];
    } else {
        [[logicShareInstance getGoodsManager] addCollectGoodsWithGoodsId:cell.cellFrame.goodsEntity.goodsId success:^(id responseObject) {} failure:^(NSString *error) {}];
        [self showStatusBarSuccessStr:@"添加收藏成功!"];
    }
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    HomeTableViewCellFrame *cellFrame = self.dataArray[indexPath.row];
    cellFrame.goodsEntity.isMyLike = selected;
    
    [self.dataArray replaceObjectAtIndex:indexPath.row withObject:cellFrame];
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [ShowMenuView hidden];
    
    GoodsDetailsViewController *goodsDetails = [[GoodsDetailsViewController alloc] init];
    HomeTableViewCellFrame *cellFrame = self.dataArray[indexPath.row];
    goodsDetails.cellFrame = cellFrame;
    
    [self.navigationController pushViewController:goodsDetails animated:YES];
}

- (void) buyButtonOnClickobject:(HomeTableViewCell *)cell
{
    WeakSelf
    [ShowMenuView hidden];
    ApplyOrderViewController *appleyOrderVC = [[ApplyOrderViewController alloc] init];
    appleyOrderVC.goodsId = cell.cellFrame.goodsEntity.goodsId;
    [self.navigationController pushViewController:appleyOrderVC animated:YES];
}

- (void)scrollWillScroll
{
    [ShowMenuView hidden];
}
@end