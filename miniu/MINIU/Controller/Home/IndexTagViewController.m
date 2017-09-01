//
//  IndexTagViewController.m
//  miniu
//
//  Created by SimMan on 5/20/15.
//  Copyright (c) 2015 SimMan. All rights reserved.
//

#import "IndexTagViewController.h"
#import "MJRefresh.h"

#import "PutGoodTableViewController.h"
#import "REFrostedNavigationController.h"
#import "SearchViewController.h"
#import "HomeViewController.h"

#import "SearchWebViewController.h"

#import "SMActionSheet.h"

typedef NS_ENUM(NSUInteger, LZJWebType) {
    LZJWebTypeNormal,
    LZJWebTypeGroupon,
    LZJWebTypeGame
};
@interface IndexTagViewController ()<UIWebViewDelegate>
@property (nonatomic,strong)SMActionSheet *actionSheet;
@property (nonatomic,strong)UIImage *imageShare;
@property (nonatomic,strong)NSString *titleShare;
@property (nonatomic,strong)NSString *remarkShare;
@property (nonatomic,strong)NSString *urlShare;

@property (nonatomic,strong)TOWebViewController *tOWebViewController;

@property WebViewJavascriptBridge*bridge1;

@end

@implementation IndexTagViewController

- (void)saveHTMLCaches:(NSString*)urlStr
{
    NSString * htmlResponseStr=[NSString stringWithContentsOfURL:[NSURL URLWithString:urlStr] encoding:NSUTF8StringEncoding error:Nil];
//    NSString *resourcePath = [ [NSBundle mainBundle] resourcePath];
//    [_fileManager createDirectoryAtPath:[resourcePath stringByAppendingString:@"/Caches"] withIntermediateDirectories:YES attributes:nil error:nil];
    NSString*resourcePath = NSHomeDirectory();
    
    NSString * path=[resourcePath stringByAppendingString:[NSString stringWithFormat:@"/Documents/home.html"]];//(unsigned long)[urlStr hash]
    
    NSError *err;
//    [[NSFileManager defaultManager]createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&err];
//    NSLog(@"err : %@",[err description]);

    [htmlResponseStr writeToFile:path atomically:NO encoding:NSUTF8StringEncoding error:&err];
    NSLog(@"err : %@",[err description]);
}

//- (instancetype)initWithURLString:(NSString *)urlString
//{
//    
//    if ([[NSFileManager defaultManager]fileExistsAtPath:[NSString stringWithFormat:@"%@/Documents/home.html",NSHomeDirectory()]]) {
//        self = [super init];
//        if (self) {
//            [self.webView loadHTMLString:[NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/Documents/home.html",NSHomeDirectory()] encoding:NSUTF8StringEncoding error:nil] baseURL:nil];
//        }
//        return self;
//    }
//    [self saveHTMLCaches:urlString];
//    return [super initWithURLString:urlString];
//    
//}

+ (void)initialize
{
    [super initialize];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.showLoadingBar = YES;
        self.showUrlWhileLoading = NO;
        self.showActionButton = NO;
        
        //米妞买家版push侧边栏的监听 that is bad
#if TARGET_IS_MINIU
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushViewcontroller:) name:@"MENU_PUSH_VIEW_CONTROLLER" object:nil];
#endif
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
#if TARGET_IS_MINIU
    [self.navigationController chatToolBarShow];//保持显示chat bar
#endif
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
#if TARGET_IS_MINIU_BUYER
    [self.rdv_tabBarController setTabBarHidden:NO animated:YES];
#endif
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.backBarButtonItem = [UIBarButtonItem blankBarButton];
    
    // 下拉刷新功能添加
    [self addRefresh];
    
    // 进入Loging状态
    [self.view beginLoading];
    
    // 如果是买手版那么右侧的按钮是添加新商品
#if TARGET_IS_MINIU_BUYER
    WeakSelf
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] bk_initWithBarButtonSystemItem:UIBarButtonSystemItemAdd handler:^(id sender) {
        PutGoodTableViewController *postGoodsVC = [[PutGoodTableViewController alloc] initWithNibName:nil bundle:nil];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:postGoodsVC];
        //        [weakSelf_SC.navigationController pushViewController:postGoodsVC animated:YES];
        [weakSelf_SC presentViewController:nav animated:YES completion:nil];
    }];
#endif
    
    // 如果是普通用户版,则左侧按钮是显示左边的菜单
#if TARGET_IS_MINIU
    //    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"我"] style:UIBarButtonItemStylePlain target:(REFrostedNavigationController *)self.navigationController action:@selector(showMenu)];
    
    WeakSelf
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] bk_initWithImage:[UIImage imageNamed:@"我"] style:UIBarButtonItemStylePlain handler:^(id sender) {
        [[weakSelf_SC mainDelegate].frostedViewController presentMenuViewController];
    }];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"分类"] style:UIBarButtonItemStylePlain target:self action:@selector(pushSearchViewController)];
    [self.webView setHeight:self.webView.selfH - 44.0f];
#endif
    
    // 添加View
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"米妞logo"]];
    self.navigationItem.titleView = logoImageView;
          
    }

- (void) pushSearchViewController
{
    
    SearchViewController *searchVC = [[SearchViewController alloc] init];
    searchVC.tagName = @"";
    //
    //    //新版本
    //    NSString *tagIndexViewURL = [NSString stringWithFormat:@"%@/goods/goodsLabel.action?appKey=ios", [[URLManager shareInstance] getNoServerBaseURL]];
    //
    //    SearchWebViewController *searchVC = [[SearchWebViewController alloc]initWithURLString:tagIndexViewURL];
    //    BaseNavigationController *nav = [[BaseNavigationController alloc]initWithRootViewController:searchVC];
    //    [self presentViewController:nav animated:YES completion:nil];
    [self.navigationController pushViewController:searchVC animated:YES];
}

#pragma mark 根据TagName 打开商品页面
- (void) openTagViewController:(NSString *)tagName
{
    //处理有的请求是跳转web界面的 ios7用不了 containString
    NSRange range = [tagName rangeOfString:@"http"];
    if (range.length != 0) {
        
        //地址 ? 和 & 处理
        NSRange ran = [tagName rangeOfString:@"?"];
        
        //没有问号s
        if (ran.length !=0) {
            tagName = [NSString stringWithFormat:@"%@&userId=%lld",tagName,USER_IS_LOGIN];
        }else{
            tagName = [NSString stringWithFormat:@"%@?userId=%lld",tagName,USER_IS_LOGIN];
        }
        
        
        
        TOWebViewController *webVC = [[TOWebViewController alloc]initWithURLString:tagName];
        webVC.showUrlWhileLoading = NO;
        webVC.navigationButtonsHidden = NO;
        webVC.showActionButton = NO;
        //        webVC.webView.tag = 1132;
        webVC.webView.delegate = self;
        webVC.webView.tag = 1001;
        
        _tOWebViewController = webVC;
        [self.navigationController pushViewController:_tOWebViewController animated:YES];
        UIBarButtonItem *barbut = [[UIBarButtonItem alloc]initWithTitle:@"分享" style:(UIBarButtonItemStyleBordered) target:self action:@selector(shareWX:)];
        webVC.navigationItem.rightBarButtonItem = barbut;
        
        //        _bridge1 = [WebViewJavascriptBridge bridgeForWebView:_tOWebViewController.webView handler:^(id data, WVJBResponseCallback responseCallback) {
        //            NSLog(@"-------->%@",data);
        //        }];
        
        //        [bridge send:@"A string sent from ObjC before Webview has loaded." responseCallback:^(id responseData) {
        //            NSLog(@"objc got response! %@", responseData);
        //        }];
        
        //处理内部跳转
    }else{
        HomeViewController *homeVC = [HomeViewController new];
        homeVC.tagName = tagName;
        [self.navigationController pushViewController:homeVC animated:YES];
    }
}

- (void)shareWX:(id)sender
{
    _actionSheet = [SMActionSheet showSheetWithTitle:@"请选择操作" buttonTitles:@[@"分享给微信好友", @"分享到朋友圈"] redButtonIndex:-1 completionBlock:^(NSUInteger buttonIndex, SMActionSheet *actionSheet) {
        if (buttonIndex == 0) {
            
            //                NSString *imageUrl = [self.dataDic objectForKey:@"imageUrl"];
            //                NSString *titleStr = [self.dataDic objectForKey:@"title"];
            //                NSString *des = [self.dataDic objectForKey:@"description"];
            //                NSString *actionUrl = [self.dataDic objectForKey:@"actionUrl"];
            //
            NSDictionary*dicInfo = [WeChatManage shareInstance].webShareDic;

            [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:dicInfo[@"imageUrl"]] options:SDWebImageDownloaderUseNSURLCache progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                
            } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                if (error == nil && image) {
                    [[logicShareInstance getWeChatManage] weChatShareForFriendListWithImage:image title:dicInfo[@"title"] description:dicInfo[@"description"] openURL:dicInfo[@"actionUrl"] WithSuccessBlock:^{
                        [_tOWebViewController showHudSuccess:@"分享成功!"];
                    } errorBlock:^(NSString *error) {
                        [_tOWebViewController showHudError:error];
                    }];
                } else {
                    [self showHudError:@"图片加载失败!"];
                }
            }];
            
            
        } else if (buttonIndex == 1) {
            //                NSString *imageUrl = [self.dataDic objectForKey:@"imageUrl"];
            //                NSString *titleStr = [self.dataDic objectForKey:@"title"];
            //                NSString *des = [self.dataDic objectForKey:@"description"];
            //                NSString *actionUrl = [self.dataDic objectForKey:@"actionUrl"];
            NSDictionary*dicInfo = [WeChatManage shareInstance].webShareDic;
            
            [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:dicInfo[@"imageUrl"]] options:SDWebImageDownloaderUseNSURLCache progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                
            } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                if (error == nil && image) {
                    
                    [[logicShareInstance getWeChatManage] weChatShareForFriendsWithImage:image title:dicInfo[@"title"] description:dicInfo[@"description"] openURL:dicInfo[@"actionUrl"] WithSuccessBlock:^{
                        [_tOWebViewController showHudSuccess:@"分享成功!"];
                    } errorBlock:^(NSString *error) {
                        [_tOWebViewController showHudError:error];
                    }];
                } else {
                    [self showHudError:@"图片加载失败!"];
                }
            }];
            
            
            
        }
    }];
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
    if (webView.tag == 1001) {
        
        _bridge1 = [WebViewJavascriptBridge bridgeForWebView:_tOWebViewController.webView handler:^(id data, WVJBResponseCallback responseCallback) {
            NSLog(@"-------->%@",data);
        }];
        return;
    }
    
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

#pragma mark getter
//-(SMActionSheet *)actionSheet
//{
//    if (!_actionSheet) {
//        _actionSheet = [SMActionSheet showSheetWithTitle:@"请选择操作" buttonTitles:@[@"分享给微信好友", @"分享到朋友圈", @"复制链接"] redButtonIndex:-1 completionBlock:^(NSUInteger buttonIndex, SMActionSheet *actionSheet) {
//            if (buttonIndex == 0) {
//
//                //                NSString *imageUrl = [self.dataDic objectForKey:@"imageUrl"];
//                //                NSString *titleStr = [self.dataDic objectForKey:@"title"];
//                //                NSString *des = [self.dataDic objectForKey:@"description"];
//                //                NSString *actionUrl = [self.dataDic objectForKey:@"actionUrl"];
//                //
////                [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:nil] options:SDWebImageDownloaderUseNSURLCache progress:^(NSInteger receivedSize, NSInteger expectedSize) {
////
////                } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
////                    if (error == nil && image) {
////                        [[logicShareInstance getWeChatManage] weChatShareForFriendListWithImage:image title:nil description:nil openURL:nil WithSuccessBlock:^{
////                            [self showHudSuccess:@"分享成功!"];
////                        } errorBlock:^(NSString *error) {
////                            [self showHudError:error];
////                        }];
////                    } else {
////                        [self showHudError:@"图片加载失败!"];
////                    }
////                }];
//                [[logicShareInstance getWeChatManage] weChatShareForFriendListWithImage:_imageShare title:_titleShare description:_remarkShare openURL:_urlShare WithSuccessBlock:^{
//                    [self showHudSuccess:@"分享成功!"];
//                } errorBlock:^(NSString *error) {
//                    [self showHudError:error];
//                }];
//
//            } else if (buttonIndex == 1) {
//                //                NSString *imageUrl = [self.dataDic objectForKey:@"imageUrl"];
//                //                NSString *titleStr = [self.dataDic objectForKey:@"title"];
//                //                NSString *des = [self.dataDic objectForKey:@"description"];
//                //                NSString *actionUrl = [self.dataDic objectForKey:@"actionUrl"];
//
////                [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:nil] options:SDWebImageDownloaderUseNSURLCache progress:^(NSInteger receivedSize, NSInteger expectedSize) {
////
////                } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
////                    if (error == nil && image) {
////                        [[logicShareInstance getWeChatManage] weChatShareForFriendsWithImage:image title:nil description:nil openURL:nil WithSuccessBlock:^{
////                            [self showHudSuccess:@"分享成功!"];
////                        } errorBlock:^(NSString *error) {
////                            [self showHudError:error];
////                        }];
////                    } else {
////                        [self showHudError:@"图片加载失败!"];
////                    }
////                }];
//                [[logicShareInstance getWeChatManage] weChatShareForFriendsWithImage:_imageShare title:_titleShare description:_remarkShare openURL:_urlShare WithSuccessBlock:^{
//                    [self showHudSuccess:@"分享成功!"];
//                } errorBlock:^(NSString *error) {
//                    [self showHudError:error];
//                }];
//
//
//            }
//        }];
//
//    }
//    return _actionSheet;
//}

/**
 *  跳转至我的订单
 *
 *  @param notification 侧边栏的传递的notificaition
 */
- (void) pushViewcontroller:(NSNotification *)notification
{
    //
#if TARGET_IS_MINIU
    //    [self.navigationController chatToolBarHidden];
#endif
    if ([notification.object isKindOfClass:[UIViewController class]]) {
        [self.navigationController pushViewController:(UIViewController *)notification.object animated:YES];
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if (webView.tag == 1001) {
        
        _bridge1 = [WebViewJavascriptBridge bridgeForWebView:_tOWebViewController.webView handler:^(id data, WVJBResponseCallback responseCallback) {
            NSLog(@"-------->%@",data);
        }];
    }
}


@end
