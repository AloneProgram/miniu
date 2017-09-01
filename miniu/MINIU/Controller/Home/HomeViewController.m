//
//  HomeViewController.m
//  miniu
//
//  Created by SimMan on 4/16/15.
//  Copyright (c) 2015 SimMan. All rights reserved.
//

#import "HomeViewController.h"
#import "BlocksKit.h"
#import "HomeTableViewCell.h"
#import "GoodsEntity.h"
#import "SDWebImageManager.h"
#import "ShowMenuView.h"
#import "ApplyOrderViewController.h"
#import "UserEntity.h"
#import "SearchViewController.h"
#import "ImagePlayerView.h"

#import "UIBarButtonItem+Badge.h"
#import "SearchListViewController.h"

#import "GoodsDetailsViewController.h"

#import "MBProgressHUD.h"

#if TARGET_IS_MINIU
@interface HomeViewController () <ShowMenuViewDelegate, ImagePlayerViewDelegate, HomeTableViewCellDelegate> {
    CGFloat _oldPanOffsetY;
}
#else
@interface HomeViewController () <ShowMenuViewDelegate, ImagePlayerViewDelegate, HomeTableViewCellDelegate>
#endif

#if TARGET_IS_MINIU
@property (nonatomic, strong) UIBarButtonItem *chatButtonItem;
#endif

@property (strong, nonatomic) ImagePlayerView *imagePlayerView;

@property (nonatomic, strong) NSMutableArray *adsData;

@end

@implementation HomeViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _adsData = [NSMutableArray new];
        [ShowMenuView shareInstance].delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    WeakSelf
    //作用??
    self.navigationItem.backBarButtonItem = [UIBarButtonItem blankBarButton];
    //导航栏右边的按钮
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"分类"] style:UIBarButtonItemStylePlain target:self action:@selector(pushSearchViewController)];
    //设置导航栏中间的图
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    UIButton *button = [[UIButton alloc] initWithFrame:titleView.frame];
    [button setTitle:self.tagName forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button bk_addEventHandler:^(id sender) {
        [weakSelf_SC.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
        //点击标题事件处理
        NSLog(@"click checked!");
    } forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:button];
    
    self.navigationItem.titleView = titleView;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self setupRefresh];
    
    [self.view beginLoading];
    
    //导航栏下方广告处理
    [[logicShareInstance getADManager] refreshAdsWithTag:self.tagName block:^(NSArray *ads) {
        if ([ads count]) {
            [weakSelf_SC.adsData addObjectsFromArray:ads];
            [self setUpAdView];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
#if TARGET_IS_MINIU_BUYER
    //买家版隐藏tabbar
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
#endif
}

- (void) pushSearchViewController
{
    SearchViewController *searchVC = [[SearchViewController alloc] init];
    searchVC.tagName = self.tagName;
    [self.navigationController pushViewController:searchVC animated:YES];
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
    } AndFooter:^{
        weakSelf_SC.pageNum ++;
        [weakSelf_SC netWorkRequestForGoodsListWithPage:weakSelf_SC.pageNum Type:LOAD_MORE];
    } autoRefresh:YES];
}

/**
 *  返回cell高
 *  @return 高度
 */
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

//    [cell loadImageView];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    HomeTableViewCell *homeCell = (HomeTableViewCell *)cell;
    [homeCell loadImageView];
}

- (void) tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    HomeTableViewCell *homeCell = (HomeTableViewCell *)cell;
    [homeCell unLoadImageView];
}

//#pragma mark 网络请求 商品列表
- (void)netWorkRequestForGoodsListWithPage:(NSInteger)pageNum Type:(LOAD_TYPE)type
{    
    WeakSelf
    [[logicShareInstance getGoodsManager] getGoodsListWithTagName:[NSString stringWithFormat:@"%@", self.tagName] CurrentPage:pageNum pageSize:0 success:^(id responseObject) {
        @try {
            [self asyncBackgroundQueue:^{
                
                NSMutableArray *tmpDataArray = [NSMutableArray arrayWithCapacity:1];
                
                for (NSDictionary *dic in [responseObject objectForKey:@"data"]){
                    GoodsEntity *goods = [[GoodsEntity alloc] init];
                    [goods setValuesForKeysWithDictionary:dic];
                    
                    //获取数据时计算各种cell frame
                    HomeTableViewCellFrame *cellFrame = [[HomeTableViewCellFrame alloc] initWithObject:goods];
                    [tmpDataArray addObject:cellFrame];
                }
                
                if (type == LOAD_UPDATE) {
                    [weakSelf_SC.dataArray removeAllObjects];
                }
                
                if ([tmpDataArray count]) {
                    [weakSelf_SC.dataArray addObjectsFromArray:tmpDataArray];
                } else {
                    if (type == LOAD_MORE) {
                        weakSelf_SC.pageNum --;
                    }
                }
                
                [weakSelf_SC asyncMainQueue:^{
                    if (![tmpDataArray count] && [self.dataArray count]) {
                        //[weakSelf_SC showStatusBarError:@"没有更多了!"];//据说太丑了 需要换成弹出的 然后提示

                        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                        hud.mode = MBProgressHUDModeCustomView;// MBProgressHUDModeText;
                        hud.customView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_result_signed"]];
                        hud.labelText = @"没有更多内容啦!";
                        //hud..backgroundTintColor = [uic];
                        [hud hide:YES afterDelay:1];
                        
                    }
                    [weakSelf_SC.tableView reloadData];
                }];
            }];
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            [weakSelf_SC.view endLoading];
        };
    } failure:^(NSString *error) {
        if (type == LOAD_MORE) {
            weakSelf_SC.pageNum --;
        }
        [weakSelf_SC.view endLoading];
        [weakSelf_SC showStatusBarError:error];
    }];
}

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
    
    if (selected) {
        cellFrame.goodsEntity.likesCount ++;
    } else {
        cellFrame.goodsEntity.likesCount --;
    }
    
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
    [ShowMenuView hidden];
    ApplyOrderViewController *appleyOrderVC = [[ApplyOrderViewController alloc] init];
    appleyOrderVC.goodsId = cell.cellFrame.goodsEntity.goodsId;
    [self.navigationController pushViewController:appleyOrderVC animated:YES];
}

/**
 *  @brief  点击Cell中的活动标签
 *
 *  @param tagName
 */
- (void)didSelectTagName:(NSString *)tagName
{
    if (![tagName length]) {
        return;
    }
    SearchListViewController *searchListVC = [SearchListViewController new];
    searchListVC.keyWord = tagName;
    [self.navigationController pushViewController:searchListVC animated:YES];
}

#if TARGET_IS_MINIU_BUYER
- (void) didDeleteWithCell:(HomeTableViewCell *)cell
{
//    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    WeakSelf
    [WCAlertView showAlertWithTitle:@"提示" message:@"删除后不可恢复,继续？" customizationBlock:^(WCAlertView *alertView) {
        
    } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
        
        if (buttonIndex == 1) {
            
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


#pragma mark 幻灯片
- (void) setUpAdView
{
    if (!self.imagePlayerView) {
        self.imagePlayerView = [[ImagePlayerView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Width / 2.37)];
        self.imagePlayerView.imagePlayerViewDelegate = self;
        
        // set auto scroll interval to x seconds
        self.imagePlayerView.scrollInterval = 4.0f;
        
        // adjust pageControl position
        self.imagePlayerView.pageControlPosition = ICPageControlPosition_BottomCenter;
        
        // hide pageControl or not
        self.imagePlayerView.hidePageControl = NO;
        
        // adjust edgeInset
        //    self.imagePlayerView.edgeInsets = UIEdgeInsetsMake(10, 20, 30, 40);
        //设置头部广告栏
        [self asyncMainQueue:^{
            self.tableView.tableHeaderView = self.imagePlayerView;
        }];
    }
    
    [self.imagePlayerView reloadData];
}

#pragma mark - ImagePlayerViewDelegate
- (NSInteger)numberOfItems
{
    NSInteger count = [_adsData count];
    return count;
}

- (void)imagePlayerView:(ImagePlayerView *)imagePlayerView loadImageForImageView:(UIImageView *)imageView index:(NSInteger)index
{
    ADentity *adentity = [_adsData objectAtIndex:index];
    NSString *imageURL = [NSString stringWithFormat:@"%@", adentity.imageUrl];
    [imageView setImageWithUrl:imageURL withSize:ImageSizeOfNone];
}

- (void)imagePlayerView:(ImagePlayerView *)imagePlayerView didTapAtIndex:(NSInteger)index
{
    ADentity *adentity = [_adsData objectAtIndex:index];
    //传递当前广告实体
    [logicShareInstance getADManager].currentADentity = adentity;
    [self openUrlOnWebViewWithURL:[NSURL URLWithString:adentity.linkedUrl] type:ADPUSH];
}

- (void)scrollWillUp
{
#if TARGET_IS_MINIU
//    [self.navigationController setToolbarHidden:YES animated:YES];
#else
//    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
#endif
}

- (void) scrollWillDown
{
#if TARGET_IS_MINIU
//    [self.navigationController setToolbarHidden:NO animated:YES];
#else
//    [self.rdv_tabBarController setTabBarHidden:NO animated:YES];
#endif
}

- (void)scrollWillScroll
{
    [ShowMenuView hidden];
}

@end
