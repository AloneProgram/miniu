//
//  BaseTableViewController.m
//  miniu
//
//  Created by SimMan on 4/16/15.
//  Copyright (c) 2015 SimMan. All rights reserved.
//

#import "BaseTableViewController.h"
#import "MJRefresh.h"

@interface BaseTableViewController () <UIScrollViewDelegate, UIGestureRecognizerDelegate>{
    void (^_headerAction) ();
    void (^_footerAction) ();
    BOOL autoRefresh;
    CGFloat _oldPanOffsetY;
}

@end

@implementation BaseTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        autoRefresh = YES;
        self.dataArray = [NSMutableArray arrayWithCapacity:1];
        self.pageNum = 1;
    }
    return self;
}

- (void)initControllerData{};

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self customTable];
    
    // 消除多余的 cell 横线
    [self setExtraCellLineHidden:self.tableView];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)customTable
{
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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

    [self.view addSubview:self.tableView];
}

- (void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier=@"tableviewcell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] init];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

#pragma mark 自动加载更多
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row + 4 == [self.dataArray count] && [self.dataArray count] >= 20) {
        if (!self.tableView.footer.isRefreshing) {
            [self.tableView.footer beginRefreshing];
        }
    }
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark 上拉加载，下拉刷新
- (void) addRefreshBlockWithHeader:(void (^)())headerAction AndFooter:(void (^)())footerAction autoRefresh:(BOOL)autoRe
{
    _headerAction = headerAction;
    _footerAction = footerAction;
    autoRefresh = autoRe;
    
    
    // 1.下拉刷新(进入刷新状态就会调用self的headerRereshing)
    if (_headerAction) {
        WeakSelf
        
        [self.tableView addGifHeaderWithRefreshingBlock:^{
            [weakSelf_SC headerRereshing];
        }];
        
        self.tableView.header.updatedTimeHidden = YES;
        self.tableView.header.stateHidden = YES;
        
        // 设置普通状态的动画图片
        NSMutableArray *idleImages = [NSMutableArray array];
        for (NSUInteger i = 0; i<=17; i++) {
            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"风车%d.png", i % 9 + 1]];
            [idleImages addObject:image];
        }
        [self.tableView.gifHeader setImages:idleImages forState:MJRefreshHeaderStateIdle];
        
        // 设置即将刷新状态的动画图片（一松开就会刷新的状态）
        NSMutableArray *refreshingImages = [NSMutableArray array];
        for (NSUInteger i = 0; i<=17; i++) {
            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"风车%d.png", i % 9 + 1]];
            [refreshingImages addObject:image];
        }
        [self.tableView.gifHeader setImages:refreshingImages forState:MJRefreshHeaderStatePulling];
        
        // 设置正在刷新状态的动画图片
        [self.tableView.gifHeader setImages:refreshingImages forState:MJRefreshHeaderStateRefreshing];
    }

    // 是否自动加载
    if (autoRefresh && _headerAction) {
        [self.tableView.header beginRefreshing];
    }
    
    // 2.上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    if (_footerAction && !self.tableView.legendFooter) {
        WeakSelf
        
        [self.tableView addLegendFooterWithRefreshingBlock:^{
            [weakSelf_SC footerRereshing];
        }];
        
//        // 设置正在刷新状态的动画图片
//        NSMutableArray *refreshingImages = [NSMutableArray array];
//        for (NSUInteger i = 1; i<=3; i++) {
//            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"dropdown_loading_0%zd", i]];
//            [refreshingImages addObject:image];
//        }
//        self.tableView.gifFooter.refreshingImages = refreshingImages;
    }
}

- (void) addRefreshBlockWithFooter:(void (^)())footerAction
{
    
    _footerAction = footerAction;
    
    // 2.上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    if (_footerAction && !self.tableView.legendFooter) {
        WeakSelf
        
        [self.tableView addLegendFooterWithRefreshingBlock:^{
            [weakSelf_SC footerRereshing];
        }];
        
//        // 设置正在刷新状态的动画图片
//        NSMutableArray *refreshingImages = [NSMutableArray array];
//        for (NSUInteger i = 1; i<=3; i++) {
//            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"dropdown_loading_0%zd", i]];
//            [refreshingImages addObject:image];
//        }
//        self.tableView.gifFooter.refreshingImages = refreshingImages;
    }
}

- (void)headerRereshing
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endRefresh) name:NetWorkTaskFinish object:nil];
    _headerAction();
}

- (void)footerRereshing
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endRefresh) name:NetWorkTaskFinish object:nil];
    if(_footerAction){
        _footerAction();
    };
}

- (void)endRefresh
{
    if (self.tableView.header.isRefreshing) {
        [self.tableView.header endRefreshing];
    }
    
    if (self.tableView.footer.isRefreshing) {
        [self.tableView.footer endRefreshing];
    }
}

#pragma mark ScrollView Delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self scrollWillScroll];
    _oldPanOffsetY = [scrollView.panGestureRecognizer translationInView:scrollView.superview].y;
}



- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    _oldPanOffsetY = 0;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentSize.height <= CGRectGetHeight(scrollView.bounds)-50) {
        [self scrollWillDown];
        return;
    }else if (scrollView.panGestureRecognizer.state == UIGestureRecognizerStateChanged){
        CGFloat nowPanOffsetY = [scrollView.panGestureRecognizer translationInView:scrollView.superview].y;
        CGFloat diffPanOffsetY = nowPanOffsetY - _oldPanOffsetY;
        //        CGFloat contentOffsetY = scrollView.contentOffset.y;
        if (diffPanOffsetY > 0.f) {
            [self scrollWillDown];
        }else if (ABS(diffPanOffsetY) > 50.f) {
            [self scrollWillUp];
            _oldPanOffsetY = nowPanOffsetY;
        }
    }
}

- (void) scrollWillDown{}
- (void) scrollWillUp{}
- (void) scrollWillScroll{}

@end
