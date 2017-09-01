//
//  SearchWebViewController.m
//  miniu
//
//  Created by Apple on 15/8/31.
//  Copyright (c) 2015年 SimMan. All rights reserved.
//

#import "SearchWebViewController.h"

#import "MJRefresh.h"

#import "PutGoodTableViewController.h"
#import "REFrostedNavigationController.h"
#import "SearchViewController.h"
#import "HomeViewController.h"

#import "SearchListViewController.h"


@interface SearchWebViewController ()<UISearchBarDelegate>
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UIScrollView *brandBackgroundView;
@property (nonatomic, strong) UISearchBar *searchBar;

@end

@implementation SearchWebViewController


- (UISearchBar *)searchBar
{
    if (!_searchBar) {
        // 初始化SearchBar
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width/2, 50)];
        // 加入到根视图
        _searchBar.barStyle = UISearchBarStyleDefault;
        _searchBar.placeholder = @"请输入品牌或宝贝名称";
        _searchBar.translucent = YES;
        _searchBar.delegate = self;
        if (IS_IOS7) {
            UIView *subView0 = _searchBar.subviews[0];
            for (UIView *subView in subView0.subviews)
            {
                if ([subView isKindOfClass:[UIButton class]]) {
                    UIButton *cannelButton = (UIButton*)subView;
                    [cannelButton setTitle:@"取消"forState:UIControlStateNormal];
                    [cannelButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
                    break;
                }
                
                if ([subView isKindOfClass:[UITextField class]]) {
                    UIView *aaaa = [[UIView alloc] initWithFrame:subView.frame];
                    aaaa.backgroundColor = [UIColor yellowColor];
                    [subView addSubview:aaaa];
                }
            }
        } else {
            for(id cc in [_searchBar subviews])
            {
                if([cc isKindOfClass:[UIButton class]])
                {
                    UIButton *sbtn = (UIButton *)cc;
                    [sbtn setTitle:@"取消"  forState:UIControlStateNormal];
                    [sbtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    [sbtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
                }
            }
        }
    }
    return _searchBar;
}

/**
 *  搜索关键字
 *
 *  @param searchBar searchBar
 */
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
    SearchListViewController *searchListVC = [[SearchListViewController alloc] init];
    searchListVC.keyWord = searchBar.text;
    searchListVC.tagName = self.tagName;
    [self.navigationController pushViewController:searchListVC animated:YES];
}

#pragma mark 开始编辑时 searchbar代理
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
}

#pragma mark 结束搜索的时候
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
}

#pragma mark 点击取消按钮时
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //self.navigationItem.backBarButtonItem = [UIBarButtonItem blankBarButton];
    
    //配置搜索框
    self.dataArray = [NSMutableArray arrayWithCapacity:1];

    [self.navigationItem.titleView removeFromSuperview];
    //self.searchBar;

    // 下拉刷新功能添加
    [self addRefresh];
    
    // 进入Loging状态
    [self.view beginLoading];
    
//self.navigationItem.rightBarButtonItem = [UIBarButtonItem blankBarButton];
    
    // 如果是买手版那么右侧的按钮是添加
#if TARGET_IS_MINIU_BUYER
//    WeakSelf
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] bk_initWithBarButtonSystemItem:UIBarButtonSystemItemAdd handler:^(id sender) {
//        PutGoodTableViewController *postGoodsVC = [[PutGoodTableViewController alloc] init];
//        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:postGoodsVC];
//        //        [weakSelf_SC.navigationController pushViewController:postGoodsVC animated:YES];
//        [weakSelf_SC presentViewController:nav animated:YES completion:nil];
//    }];
#endif
    
    // 如果是普通用户版,则左侧按钮是显示左边的菜单
//#if TARGET_IS_MINIU
//    //    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"我"] style:UIBarButtonItemStylePlain target:(REFrostedNavigationController *)self.navigationController action:@selector(showMenu)];
//    
//   // WeakSelf
//    
//   // [self.webView setHeight:self.webView.selfH - 44.0f];
//#endif
    
    // 添加View 
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"米妞logo"]];
    self.navigationItem.titleView = logoImageView;
}

#pragma mark 根据TagName 打开商品页面
- (void) openTagViewController:(NSString *)tagName
{
    //处理有的请求是跳转web界面的 ios7用不了 containString
    NSRange range = [tagName rangeOfString:@"http"];
    if (range.length != 0) {
        
        //地址 ? 和 & 处理
        
        NSRange ran = [tagName rangeOfString:@"?"];
        
        if (ran.length !=0) {
            tagName = [NSString stringWithFormat:@"%@&userId=%lld",tagName,USER_IS_LOGIN];
        }else{
            tagName = [NSString stringWithFormat:@"%@?userId=%lld",tagName,USER_IS_LOGIN];
        }
        
        TOWebViewController *webVC = [[TOWebViewController alloc]initWithURLString:tagName];
        
        webVC.showUrlWhileLoading = NO;
        webVC.navigationButtonsHidden = NO;
        webVC.showActionButton = NO;
        
        [self.navigationController pushViewController:webVC animated:YES];
        //处理内部跳转
    }else{
        HomeViewController *homeVC = [HomeViewController new];
        homeVC.tagName = tagName;
        [self.navigationController pushViewController:homeVC animated:YES];
    }
}


#pragma mark 添加下拉刷新
- (void) addRefresh
{
    WeakSelf
    [self.webView.scrollView addGifHeaderWithRefreshingBlock:^{
        [weakSelf_SC reloadWebView];
    }];
    
    self.webView.scrollView.header.updatedTimeHidden = YES;
    self.webView.scrollView.header.stateHidden = YES;
    
    // 设置普通状态的动画图片
    NSMutableArray *idleImages = [NSMutableArray array];
    for (NSUInteger i = 0; i<=17; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"风车%d.png", (int)i % 9 + 1]];
        [idleImages addObject:image];
    }
    [self.webView.scrollView.gifHeader setImages:idleImages forState:MJRefreshHeaderStateIdle];
    
    // 设置即将刷新状态的动画图片（一松开就会刷新的状态）
    NSMutableArray *refreshingImages = [NSMutableArray array];
    for (NSUInteger i = 0; i<=17; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"风车%d.png", (int)i % 9 + 1]];
        [refreshingImages addObject:image];
    }
    [self.webView.scrollView.gifHeader setImages:refreshingImages forState:MJRefreshHeaderStatePulling];
    
    // 设置正在刷新状态的动画图片
    [self.webView.scrollView.gifHeader setImages:refreshingImages forState:MJRefreshHeaderStateRefreshing];
}

#pragma mark 重新加载 WebView
- (void) reloadWebView
{
    WeakSelf
    if (weakSelf_SC.webView.isLoading) {
        
    } else {
        
        NSURLRequest *request = weakSelf_SC.webView.request;
        if (weakSelf_SC.webView.request.URL.absoluteString.length == 0 && weakSelf_SC.url)
        {
            request = [NSURLRequest requestWithURL:weakSelf_SC.url];
            [weakSelf_SC.webView loadRequest:request];
        }
        else {
            [weakSelf_SC.webView reload];
        }
    }
}

#pragma mark Webview 代理方法
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [super webViewDidFinishLoad:webView];
    
    //[webView stringByEvaluatingJavaScriptFromString:@"funtion(id);"];
    
    [self.webView.scrollView.header endRefreshing];
    [self.view configBlankPage:EaseBlankPageTypeSearch hasData:YES hasError:NO reloadButtonBlock:nil];
    [self.view endLoading];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [super webView:webView didFailLoadWithError:error];
    [self.webView.scrollView.header endRefreshing];
    [self.view configBlankPage:EaseBlankPageTypeSearch hasData:NO hasError:YES reloadButtonBlock:^(id sender) {
        [self reloadWebView];
    }];
    [self.view endLoading];
}

///**
// *  跳转至我的订单
// *
// *  @param notification 侧边栏的传递的notificaition
// */
//- (void) pushViewcontroller:(NSNotification *)notification
//{
//    //
//#if TARGET_IS_MINIU
//    //    [self.navigationController chatToolBarHidden];
//#endif
//    if ([notification.object isKindOfClass:[UIViewController class]]) {
//        [self.navigationController pushViewController:(UIViewController *)notification.object animated:YES];
//    }
//}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.searchBar resignFirstResponder];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
