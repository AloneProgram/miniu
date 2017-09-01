//
//  GoodsDetailsViewController.m
//  miniu
//
//  Created by SimMan on 4/27/15.
//  Copyright (c) 2015 SimMan. All rights reserved.
//

#import "GoodsDetailsViewController.h"
#import "GoodsDeailsCell.h"
#import "HomeTableViewCellFrame.h"
#import "ApplyOrderViewController.h"
#import "SearchListViewController.h"

#import "OrderViewCell.h"
#define TOOLBAR_HEIGHT 44.0f
#define LEFTVIEW_TAG    8001
#define RIGHTVIEW_TAG   8002

@interface GoodsDetailsViewController () <HomeTableViewCellDelegate>
@property (nonatomic, strong) UIButton *chatButton;
@property (nonatomic, strong) UIButton *buyButton;
@end

@implementation GoodsDetailsViewController

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

-(instancetype)initWithOrder:(OrderEntity *)order
{

    self = [super init];
    if (self) {
        self.order = order;
        //do some thing
        _cellFrame = [[HomeTableViewCellFrame alloc]initWithObject:[order transferToGoodsEntity]];;
    }
    return self;

}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"商品详情页(goodDetailsVC)";
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"米妞logo"]];

    self.navigationItem.backBarButtonItem = [UIBarButtonItem blankBarButton];
    
    if (_order) {
        //return;
        
    }
    
    if (!_cellFrame) {
        [self.view beginLoading];
        [self netWrokRequest];
    } else {
        self.tableView.tableFooterView = [self footerView];
    }
}

- (void)setCellFrame:(HomeTableViewCellFrame *)cellFrame
{
    _cellFrame = cellFrame;
    self.tableView.tableFooterView = [self footerView];
    [_buyButton setEnabled:YES];
}

- (void) setToolbarView
{
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width * 0.3, TOOLBAR_HEIGHT)];
    leftView.backgroundColor = [UIColor colorWithRed:0.941 green:0.941 blue:0.941 alpha:1];
    
    leftView.tag = LEFTVIEW_TAG;
    
    _chatButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 75, 30)];
    [_chatButton setBackgroundImage:[UIImage imageNamed:@"详情页-私聊"] forState:UIControlStateNormal];
    _chatButton.center = leftView.center;
    [_chatButton addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
    [leftView addSubview:_chatButton];
    
    
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(leftView.selfW, 0, kScreen_Width * 0.7, TOOLBAR_HEIGHT)];
    rightView.tag = RIGHTVIEW_TAG;
    rightView.backgroundColor = [UIColor colorWithRed:0.498 green:0.502 blue:0.945 alpha:1];
    
    _buyButton = [[UIButton alloc] initWithFrame:CGRectMake((rightView.selfW - 110) / 2, _chatButton.selfY, 110, 30)];
    [_buyButton setBackgroundImage:[UIImage imageNamed:@"详情页-一键代购"] forState:UIControlStateNormal];
    [_buyButton addTarget:self action:@selector(buyButtonAction) forControlEvents:UIControlEventTouchUpInside];
    UIEdgeInsets titleEdgeInsets = _buyButton.titleEdgeInsets;
    titleEdgeInsets.left = 20;
    _buyButton.titleEdgeInsets = titleEdgeInsets;
    [_buyButton setTitle:@"一键代购" forState:UIControlStateNormal];
    [_buyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _buyButton.titleLabel.font = [UIFont systemFontOfSize:15];
    
    [rightView addSubview:_buyButton];
    
    [self.navigationController.toolbar addSubview:leftView];
    [self.navigationController.toolbar addSubview:rightView];
}

- (void) buyButtonAction
{
    ApplyOrderViewController *appleyOrderVC = [[ApplyOrderViewController alloc] init];
    appleyOrderVC.goodsId = _cellFrame.goodsEntity.goodsId;
    [self.navigationController pushViewController:appleyOrderVC animated:YES];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
#if TARGET_IS_MINIU_BUYER
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    [self.navigationController setToolbarHidden:YES animated:YES];
#else
    if(!_order){
        [self setToolbarView];
        
        [self.navigationController setToolbarHidden:NO animated:NO];
        [self.navigationController chatToolBarHidden];
    }
//    [self setToolbarView];
//    
//    [self.navigationController setToolbarHidden:NO animated:NO];
//    [self.navigationController chatToolBarHidden];
#endif
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
#if TARGET_IS_MINIU
    for (UIView *view in self.navigationController.toolbar.subviews) {
        if (view.tag == LEFTVIEW_TAG || view.tag == RIGHTVIEW_TAG) {
            [view removeFromSuperview];
        }
    }
    [self.navigationController setToolbarHidden:YES animated:NO];
    [self.navigationController chatToolBarShow];
#endif
}

- (void) sendMessage
{
    [[self mainDelegate] changeToChatView];
}


/**
 *  设置分享的两个按钮
 *
 *  @return footer view
 */
- (UIView *) footerView
{
    WeakSelf
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 100)];
    
    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(_cellFrame.imageBackViewFrame.origin.x, 0.5, kScreen_Width, 0.5)];
    line.backgroundColor = [UIColor lightGrayColor];
    [view addSubview:line];
    
    UILabel *shareTo = [[UILabel alloc] initWithFrame:CGRectMake(_cellFrame.imageBackViewFrame.origin.x, 5, 50, 15)];
    shareTo.text = @"分享至";
    shareTo.font = [UIFont systemFontOfSize:14];
    shareTo.textColor = [UIColor lightGrayColor];
    [view addSubview:shareTo];
    
    float margin = (kScreen_Width - CGRectGetMaxX(shareTo.frame) - (54 * 2)) / 2;
    
    UIButton *wechatFried = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(shareTo.frame), CGRectGetMaxY(shareTo.frame), 54, 44)];
    [wechatFried setBackgroundImage:[UIImage imageNamed:@"分享-微信"] forState:UIControlStateNormal];
    
    //点击分享好友
    [wechatFried bk_addEventHandler:^(id sender) {
        [weakSelf_SC weChatShareGoodsWithchat];
    } forControlEvents:UIControlEventTouchUpInside];

    UIButton *wechatP = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(wechatFried.frame) + margin, CGRectGetMaxY(shareTo.frame), 54, 44)];
    [wechatP setBackgroundImage:[UIImage imageNamed:@"分享-微信朋友圈"] forState:UIControlStateNormal];
    //点击分享朋友圈
    [wechatP bk_addEventHandler:^(id sender) {
        [weakSelf_SC weChatShareGoodsWithFrieds];
    } forControlEvents:UIControlEventTouchUpInside];
    
    //以后增加的微博分享功能!
    UIButton *sinaB = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(wechatP.frame) + margin, CGRectGetMaxY(shareTo.frame), 54, 44)];
    [sinaB setBackgroundImage:[UIImage imageNamed:@"分享-微博"] forState:UIControlStateNormal];
    [sinaB bk_addEventHandler:^(id sender) {
        [weakSelf_SC showHudError:@"功能开发中^_^!"];
    } forControlEvents:UIControlEventTouchUpInside];
    
    
    [view addSubview:wechatFried];
    [view addSubview:wechatP];
//    [view addSubview:sinaB];
    
    return view;
}

/**
 *  分享到微信
 */
- (void) weChatShareGoodsWithchat
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    GoodsDeailsCell *cell = (GoodsDeailsCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    NSArray *array = [NSArray arrayWithArray:cell.imageBackView.subviews];
    UIImageView *goodsImageView = [array firstObject];
    
    //我们服务器的商品链接
    NSString *url = [NSString stringWithFormat:@"%@/share/goods.action?appKey=ios&userId=%lld&goodsId=%lld", [[URLManager shareInstance] getNoServerBaseURL],USER_IS_LOGIN, _cellFrame.goodsEntity.goodsId];
    
    //设置并发送这个图文并茂的消息
    [[logicShareInstance getWeChatManage] weChatShareForFriendListWithImage:goodsImageView.image title:ShareWeChatTitle description:_cellFrame.goodsEntity.goodsDescription openURL:url WithSuccessBlock:^{
        [self bk_performBlock:^(id obj) {
            [self showStatusBarSuccessStr:@"成功分享到微信!"];
        } afterDelay:0.5];
    } errorBlock:^(NSString *error) {
        [self bk_performBlock:^(id obj) {
            [self showStatusBarError:error];
        } afterDelay:0.5];
    }];
}

/**
 *  分享到微信朋友圈
 */
- (void) weChatShareGoodsWithFrieds
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    GoodsDeailsCell *cell = (GoodsDeailsCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    NSArray *array = [NSArray arrayWithArray:cell.imageBackView.subviews];
    UIImageView *goodsImageView = [array firstObject];
    
    NSString *url = [NSString stringWithFormat:@"%@/share/goods.action?appKey=ios&userId=%lld&goodsId=%lld", [[URLManager shareInstance] getNoServerBaseURL],USER_IS_LOGIN, _cellFrame.goodsEntity.goodsId];
    
    [[logicShareInstance getWeChatManage] weChatShareForFriendsWithImage:goodsImageView.image title:ShareWeChatTitle description:_cellFrame.goodsEntity.goodsDescription openURL:url WithSuccessBlock:^{
        [self bk_performBlock:^(id obj) {
            [self showStatusBarSuccessStr:@"成功分享到微信!"];
        } afterDelay:0.5];
    } errorBlock:^(NSString *error) {
        [self bk_performBlock:^(id obj) {
            [self showStatusBarError:error];
        } afterDelay:0.5];
    }];
}


- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _cellFrame.cellSize.height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _cellFrame ? 1 : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier=@"GoodsDeailsCell";
    if(_order){
        OrderViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[OrderViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier Order:_order];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.cellFrame = _cellFrame;
            
            [cell loadImageView];
        }
        return cell;
    }else{
        GoodsDeailsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[GoodsDeailsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        cell.delegate = self;
        cell.cellFrame = _cellFrame;
        
        [cell loadImageView];
        
        WeakSelf
        [cell favButtonActionBlock:^(GoodsEntity *goods) {
            [weakSelf_SC favoriteButtonActionobject:goods];
        }];
        return cell;

    }
//    return cell;
}

- (void) favoriteButtonActionobject:(GoodsEntity *)goods
{
    if (goods.isMyLike) {
        [[logicShareInstance getGoodsManager] delCollectGoodsWithGoodsId:goods.goodsId success:^(id responseObject) {} failure:^(NSString *error) {}];
        [self showStatusBarSuccessStr:@"取消收藏成功!"];
    } else {
        [[logicShareInstance getGoodsManager] addCollectGoodsWithGoodsId:goods.goodsId success:^(id responseObject) {} failure:^(NSString *error) {}];
        [self showStatusBarSuccessStr:@"添加收藏成功!"];
    }
    
    if (goods.isMyLike) {
        self.cellFrame.goodsEntity.likesCount --;
    } else {
        self.cellFrame.goodsEntity.likesCount ++;
    }
    self.cellFrame.goodsEntity.isMyLike = !self.cellFrame.goodsEntity.isMyLike;
    [self.tableView reloadData];
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

#pragma mark 网络获取
- (void) netWrokRequest
{
    WeakSelf
    [self.currentRequest addObject:[[logicShareInstance getGoodsManager] goodsDetailWithGoodsId:_goodsId currentPage:0 pageSize:0 success:^(id responseObject) {
        
        @try {
            GoodsEntity *goods = [[GoodsEntity alloc] init];
            [goods setValuesForKeysWithDictionary:responseObject[@"data"]];
            HomeTableViewCellFrame *cellFrame = [[HomeTableViewCellFrame alloc] initWithObject:goods];
            
            weakSelf_SC.cellFrame = cellFrame;
            [weakSelf_SC.tableView reloadData];
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            [weakSelf_SC.view endLoading];
            [weakSelf_SC.view configBlankPage:EaseBlankPageTypeCollect hasData:_cellFrame ? YES : NO hasError:NO reloadButtonBlock:nil];
        };
        
        
    } failure:^(NSString *error) {
        [weakSelf_SC.view endLoading];
        [weakSelf_SC.view configBlankPage:EaseBlankPageTypeCollect hasData:NO hasError:YES reloadButtonBlock:^(id sender) {
            [weakSelf_SC netWrokRequest];
        }];
    }]];
}

#pragma mark - timer
- (void)countDown {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), 1.0*NSEC_PER_MSEC, 0);
    dispatch_source_set_event_handler(_timer, ^{
        //...
    });
}
@end
