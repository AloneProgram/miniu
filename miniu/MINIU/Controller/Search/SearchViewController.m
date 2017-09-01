//
//  SearchViewController.m
//  miniu
//
//  Created by SimMan on 4/28/15.
//  Copyright (c) 2015 SimMan. All rights reserved.
//

#import "SearchViewController.h"
#import "BrandEntity.h"
#import "UIButton+WebCache.h"
#import "SearchListViewController.h"

#import "WebViewJavascriptBridge.h"
#import "TOWebViewController.h"
#import "HomeViewController.h"

#import <WebKit/WebKit.h>

#import "UIView+Common.h"
@interface SearchViewController () <UISearchBarDelegate,UIWebViewDelegate,WKNavigationDelegate>
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UIScrollView *brandBackgroundView;
@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic, strong) UIWebView *web;
@property (nonatomic, strong) WebViewJavascriptBridge *bridge;
@end

@implementation SearchViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.dataArray = [NSMutableArray arrayWithCapacity:1];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.brandBackgroundView];
    
    self.navigationItem.titleView = self.searchBar;
    
    //[self.view beginLoading];//死循环导致cpu高负载
    
    [self loadWebData];
    
   // [self loadData];
}

- (void)loadWebData
{
    NSString *tagIndexViewURL = [NSString stringWithFormat:@"%@/goods/goodsLabel.action?appKey=ios", [[URLManager shareInstance] getNoServerBaseURL]];
    
    // SearchWebViewController *sWeb = [[SearchWebViewController alloc]initWithURLString:tagIndexViewURL];
    
    //    TOWebViewController * tWeb = [[TOWebViewController alloc]initWithURLString:tagIndexViewURL];
    
    /**wkweb view
    WKWebView *wkWeb = [[WKWebView alloc]initWithFrame:self.view.frame];
    [wkWeb loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:tagIndexViewURL]]];
    wkWeb.navigationDelegate = self;
    self.view = wkWeb;
    
    [wkWeb evaluateJavaScript:@"openTagPage" completionHandler:^(id data, NSError *) {
        NSLog(@"as style action %@",data);
    }];
     */
    // web view
    _web = [[UIWebView alloc]initWithFrame:self.view.bounds];
//    _web.delegate = self;//需要在jsBridge 初始化中设置
    NSMutableURLRequest *url = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:tagIndexViewURL]];
    [url setTimeoutInterval:5];
    [_web loadRequest:url];
    _web.scalesPageToFit = YES;
    self.view = _web;
//    [_web setHeight:_web.frame.size.height-40];
    self.title = @"分类搜索";
     [self setUpJsBridge];// webview delegate 冲突
    
}

- (UISearchBar *)searchBar
{
    if (!_searchBar) {
        // 初始化SearchBar
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 50)];
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

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
#if TARGET_IS_MINIU
    [self.navigationController setToolbarHidden:YES];
#else
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
#endif
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self endHudLoad];
    [self.searchBar resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadUIView
{
    // 清除所有View
    for (UIView *view in self.brandBackgroundView.subviews) {
        
        if ([view isKindOfClass:[UIButton class]]) {
            [view removeFromSuperview];
        }
    }
    
    //    NSInteger dataCount = self.dataArray.count;
    
    NSInteger lineNum = 3;  // 每行显示的个数
    
    int tag = 100;
    
    float buttonW = (kScreen_Width - (4 * 1)) / lineNum;
    float buttonH = buttonW / 2.35f; //60 + (buttonW - 90);
    
    int y = 0;
    for (BrandEntity *brand in self.dataArray) {
        float j = (tag - 100) % lineNum;
        
        float buttonX = ((j + 1) * 1) + j * buttonW;
        float buttonY = (y/lineNum +1) * 1 + (y / lineNum * buttonH);
        
        //        if (y < 3) {
        buttonY += 56;
        //        }
        
        UIButton *button = [[UIButton alloc] init];
        button.frame = CGRectMake(buttonX, buttonY, buttonW, buttonH);
        button.tag = tag;
        
        NSURL *iconUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@", brand.iconUrl]];
        
        [button sd_setBackgroundImageWithURL:iconUrl forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"timeline_img__"]];
        [button addTarget:self action:@selector(brandButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.brandBackgroundView addSubview:button];
        y ++;
        tag ++;
    }
    
    int row = y / lineNum;
    
    if (y - row * lineNum == 1) {
        row = row + 1;
    }
    
    float brandH = buttonH * row + row * 1 + 175;
    
    [_brandBackgroundView setContentSize:CGSizeMake(kScreen_Width, brandH)];
}

- (void) brandButtonAction:(UIButton *)sender
{
    SearchListViewController *searchListVC = [[SearchListViewController alloc] init];
    BrandEntity *brand = self.dataArray[sender.tag - 100];
    NSString *keyword = brand.brandTag;
    searchListVC.keyWord = keyword;
    searchListVC.tagName = self.tagName;
    [self.navigationController pushViewController:searchListVC animated:YES];
}


- (UIScrollView *)brandBackgroundView
{
    if (!_brandBackgroundView) {
        CGRect frame = self.view.bounds;
        _brandBackgroundView = [[UIScrollView alloc] initWithFrame:frame];
        _brandBackgroundView.backgroundColor = [UIColor whiteColor];
        
        UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, kScreen_Width, 16)];
        line.textAlignment = NSTextAlignmentCenter;
        [line setTextColor:[UIColor colorWithRed:0.525 green:0.525 blue:0.529 alpha:1]];
        [line setFont:[UIFont systemFontOfSize:16]];
        [line setText:@"···························· 热搜 ····························"];
        [_brandBackgroundView addSubview:line];
    }
    return _brandBackgroundView;
}

- (void) loadData
{
    WeakSelf
    [[logicShareInstance getGoodsManager] searchBrandListSuccess:^(id responseObject) {
        
        NSMutableArray *tmpDataArray = [NSMutableArray arrayWithCapacity:1];
        for (NSDictionary *dic in responseObject[@"data"]) {
            BrandEntity *brandEntity = [[BrandEntity alloc] init];
            [brandEntity setValuesForKeysWithDictionary:dic];
            [tmpDataArray addObject:brandEntity];
        }
        [weakSelf_SC.dataArray removeAllObjects];
        [weakSelf_SC.dataArray addObjectsFromArray:tmpDataArray];
        
        [weakSelf_SC loadUIView];
        
        [weakSelf_SC.view endLoading];
        
    } failure:^(NSString *error) {
        [weakSelf_SC.view configBlankPage:EaseBlankPageTypeSearch hasData:NO hasError:YES reloadButtonBlock:^(id sender) {
            [weakSelf_SC loadData];
        }];
        [weakSelf_SC.view endLoading];
    }];
}

/**
 *  js 桥接
 */
- (void)setUpJsBridge
{
    //必须注册一个webviewjsbridge
    _bridge = [WebViewJavascriptBridge bridgeForWebView:_web webViewDelegate:self handler:^(id data, WVJBResponseCallback responseCallback) {
        
    }];
//    _bridge = [WebViewJavascriptBridge bridgeForWebView:_web handler:^(id data, WVJBResponseCallback responseCallback) {
//        NSLog(@"search view controller ");
//    }];
//    //打开调试
#ifdef DEBUG
    [WebViewJavascriptBridge enableLogging];
#endif
    //注册方法
    [_bridge registerHandler:@"openTagPage" handler:^(id data, WVJBResponseCallback responseCallback) {
   
        @try {

            NSDictionary *dic = [NSDictionary dictionaryWithDictionary:data];
            
            NSString *tagName = [dic objectForKey:@"tagName"];
            
            if (tagName && [tagName length]) {
                [self openTagViewController:tagName];
            }
            
            long long userid = [[logicShareInstance getUserManager]getCurrentUserID];
            
            //传参回调
            responseCallback([self sendJsonResponseWithMessage:@"成功!" status:YES data:@{@"user_id":[NSNumber numberWithLongLong:userid]}]);
            
        }
        
        @catch (NSException *exception) {
            responseCallback([self sendJsonResponseWithMessage:@"失败!" status:NO data:nil]);
        }
        
        @finally {
            
        }
    }];
    
    //[_bridge class];
    
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

/**
 *  字典转json字符串
 *
 *  @param message 内容
 *  @param status  布尔
 *  @param data    字典
 *
 *  @return json string
 */
- (NSString *) sendJsonResponseWithMessage:(NSString *)message status:(BOOL)status data:(NSDictionary *)data

{
    if (!data) {
        data = [NSDictionary dictionary];
    }
    NSString *jsonString = [@{@"status": [NSNumber numberWithBool:status],
                              @"message": [NSString stringWithFormat:@"%@", message],
                              @"data":  data
                              } JSONString];
    
    return jsonString;
    
}

#pragma mark - web view delegate 
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
{
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView{

    [self.view showHudLoad:@"正在加载"];

    NSLog(@"webViewDidStartLoad");
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self.view endHudLoad];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error;
{
    [self.view endHudLoad];
    NSLog(@"didFailLoadWithError:%@",[error description]);
}

#pragma mark -  wk web navigation delegate
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    [self showHudLoad:@"正在加载"];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [self endHudLoad];
}

-(void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    [self showHudError:[error description]];

}
@end
