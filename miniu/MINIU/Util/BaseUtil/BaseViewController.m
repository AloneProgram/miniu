//
//  BaseViewController.m
//  Base
//
//  Created by simman on 14-7-17.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import "BaseViewController.h"
//#import "SVProgressHUD.h"
#import "AFURLSessionManager.h"

#import "UserLoginViewController.h"
#import "UserLoginIndexViewController.h"
#import "TOWebViewController.h"

#import "BaseNavigationController.h"

#import "LogicManager.h"

//#import "ProgressHUD.h"

// 推送直接打开窗口用
//#import "TOWebViewController.h"

@interface BaseViewController ()
@property (nonatomic, assign) BOOL needGesturePop;
@end

@implementation BaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.currentRequest = [NSMutableArray arrayWithCapacity:1];
        
        // 在iOS 7中，苹果引入了一个新的属性，叫做[UIViewController setEdgesForExtendedLayout:]，它的默认值为UIRectEdgeAll。当你的容器是navigation controller时，默认的布局将从navigation bar的顶部开始。这就是为什么所有的UI元素都往上漂移了44pt。
        if(IS_IOS7) {
            if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
                [self setEdgesForExtendedLayout:0];
            }
        }
    }

    self.needGesturePop = YES;
    
    return self;
}

#pragma mark 视图加载完
-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSString* cName = [NSString stringWithFormat:@"%@",  self.title, nil];
    if (!cName) {
        cName = [NSString stringWithFormat:@"%@", self.description];
    }
    [[BaiduMobStat defaultStat] pageviewStartWithName:cName];
    
    if (!_needGesturePop) {
        // 禁用 iOS7 返回手势
        if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
            self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        }
    }
    
    if ([self.navigationController respondsToSelector:@selector(setTransitionInProcess:)]) {
        ((BaseNavigationController *)self.navigationController).transitionInProcess = NO;
    }
}

#pragma mark viewDidLoad
- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark 视图将要退出
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (!_needGesturePop) {
        // 开启
        if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
            self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        }
    }
}

- (BaseNavigationController *)navigationController
{
    return (BaseNavigationController *)super.navigationController;
}

#pragma mark 视图已经消失
-(void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    NSString* cName = [NSString stringWithFormat:@"%@", self.title, nil];
    if (!cName) {
        cName = [NSString stringWithFormat:@"%@", self.description];
    }
    [[BaiduMobStat defaultStat] pageviewEndWithName:cName];
}

#pragma mark 视图被销毁
- (void) dealloc
{
    // 取消网络连接
    [self cancelCurrentNetWorkRequest];
}

#pragma mark 全局AppDelegate
-(AppDelegate *)mainDelegate
{
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

#pragma mark - 导航设置
#pragma mark 设置标题
- (void) setNavTitle:(NSString *)title
{
    self.title = title;
}

// ######################################################  工具方法  ##################################################
// #####################################################################################################################

#pragma mark - 网络相关
#pragma mark 取消当前页面的网络连接
- (void) cancelCurrentNetWorkRequest
{
    if (![self.currentRequest count]) {
        return;
    }
    
    @try {
        for (NSURLSessionDataTask *task in self.currentRequest) {
            [NET_WORK_HANDLE cancelAllHTTPOperationsWithPath:task];
        }
    }
    @catch (NSException *exception) {}
    @finally {};
}


#pragma mark - 手势相关
#pragma mark 隐藏键盘
- (void)Hidden_Keyboard_With_GestureAction:(void (^)())action
{
    //添加手势用于退出键盘
    UITapGestureRecognizer *tap = [UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        action();
    }];
    [self.view addGestureRecognizer:tap];
}


#pragma mark 网络加载完毕
- (void) netWorkTaskFinish
{
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:NetWorkTaskFinish];
}

#pragma 打开一个网页
- (void) openUrlOnWebViewWithURL:(NSURL *)url type:(CHANGE_VIEWCONTROLLER_TYPE)type
{
    if (!url) {
        [self showHudError:@"URL地址错误,请检查后重试!"];
    }
    
    TOWebViewController *webViewController = [[TOWebViewController alloc] initWithURL:url];
    webViewController.navigationButtonsHidden = YES;
    webViewController.hideWebViewBoundaries = YES;
    
    if (type == MODAL) {
        [self presentViewController:[[UINavigationController alloc] initWithRootViewController:webViewController] animated:YES completion:nil];
    }else if (type == ADPUSH) {
        UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
        temporaryBarButtonItem.title = @"返回";
        self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
        webViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] bk_initWithImage:[UIImage imageNamed:@"moreBtn_Nav"] style:UIBarButtonItemStyleDone handler:^(id sender) {
            [self shareWX:sender];
        }];

        [self.navigationController pushViewController:webViewController animated:YES];
        
    }else {
        UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
        temporaryBarButtonItem.title = @"返回";
        self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
        [self.navigationController pushViewController:webViewController animated:YES];
    }
}

- (void)shareWX:(UIBarButtonItem*)sender
{
    [SMActionSheet showSheetWithTitle:@"请选择" buttonTitles:@[@"分享给微信朋友", @"分享到朋友圈"] redButtonIndex:-1 completionBlock:^(NSUInteger buttonIndex, SMActionSheet *actionSheet) {
        
//        if (!self.chatterEntity.userId) {
//            [self showHudError:@"无法获取UserId,请退出重试!"];
//            return;
//        }
        if ([logicShareInstance getADManager].currentADentity && [[logicShareInstance getUserManager]getCurrentUserID]) {
            ADentity *ad = [logicShareInstance getADManager].currentADentity;
            WeChatManage *wc = [WeChatManage shareInstance];
            if(![WXApi isWXAppInstalled]){
                [self showHudError:@"需要安装微信才可以使用!"];
                return;
            };
            switch (buttonIndex) {
                case 0: {
//                    UIImageView *imgv = [[UIImageView alloc]init];
//                    [imgv setImageWithUrl:ad.imageUrl withSize:ImageSizeOfAuto];
                    
                    NSLog(@"ad.imageUrl -> %@",ad.imageUrl);
                    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString: ad.imageUrl ]options:SDWebImageDownloaderUseNSURLCache progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                        
                    } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                        if (error == nil && image) {
                            [wc weChatShareForFriendListWithImage:image title:ad.title description:ad.depictRemark openURL:ad.linkedUrl WithSuccessBlock:^{
                                
                            } errorBlock:^(NSString *error) {
                                [self showHudError:@"无法获取分享内容!,请退出重试!"];
                                [self endHudLoad];
                            }];
                        }else
                        {
                            [self showHudError:[NSString stringWithFormat:@"无法获取图片内容!,error:%@",[error localizedDescription]]];
                            [self endHudLoad];
                        }
                    }];
                    
                }
                    break;
                case 1: {
                    //分享到朋友圈
                    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString: ad.imageUrl ]options:SDWebImageDownloaderUseNSURLCache progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                        
                    } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                        if (error == nil && image) {
                            [wc weChatShareForFriendsWithImage:image title:ad.title description:ad.depictRemark openURL:ad.linkedUrl WithSuccessBlock:^{
                                
                            } errorBlock:^(NSString *error) {
                                [self showStatusBarError:@"无法获取分享内容!,请退出重试!"];
                            }];
                        }else
                        {
                            [self showStatusBarError:[NSString stringWithFormat:@"无法获取图片内容!,error:%@",[error localizedDescription]]];
                        }
                    }];

                    
                }
                    break;
                default:
                    break;
            }
        }else if (![[logicShareInstance getUserManager]getCurrentUserID]){
            [self showHudError:@"无法获取UserId,请退出重试!"];
            //            return;
        }else if (![logicShareInstance getADManager].currentADentity){
            [self showHudError:@"无法获取分享内容!,请退出重试!"];
            //            return;
        }
        
        
    }];

}
#pragma mark - 线程处理
#pragma mark 在后台线程处理
- (void) asyncBackgroundQueue:(void (^)())block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        block();
    });
}

#pragma mark 在主线程
- (void) asyncMainQueue:(void (^)())block
{
    dispatch_async(dispatch_get_main_queue(), ^{
        block();
    });
}

/**
 *  @brief  设置是否需要使用手势返回  默认为：YES
 */
- (void)setNeedGesturePop:(BOOL)needGesturePop
{
    _needGesturePop = needGesturePop;
}

- (void) userLogoutAction{}


#pragma mark - 网络变化
- (void) changeWork:(NSNotification *)notification
{
    static int count = 0;
    // 如果用户登录才进行消息获取操作
    if (USER_IS_LOGIN && count > 4) {
        NSDictionary *userInfo = [notification userInfo];
        
        NSInteger networkstatus = [[userInfo objectForKey:@"networktype"] integerValue];
        
        NSString *messageTitle = nil;
        switch (networkstatus) {
            case AFNetworkReachabilityStatusNotReachable:{
                messageTitle = @"网络连接失败!";
                [self showStatusBarError:messageTitle];
            }
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN: {
                messageTitle = @"已切换至 蜂窝网络";
                [self showStatusBarError:messageTitle];
            }
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:{
                messageTitle = @"已切换至 WIFI";
                [self showStatusBarError:messageTitle];
            }
                break;
            default:
                messageTitle = @"网络连接失败!";
                [self showStatusBarError:messageTitle];
                break;
        }
        
    }
    if (USER_IS_LOGIN) {
        count ++;
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark didReceiveMemoryWarning
- (void)didReceiveMemoryWarning
{
    NSLog(@"[%@]->didReceiveMemoryWarning.....",NSStringFromClass([self class]));
    [super didReceiveMemoryWarning];
    
    if ([self.view window] == nil)// 是否是正在使用的视图
    {
        // Add code to preserve data stored in the views that might be
        // needed later.
        
        // Add code to clean up other strong references to the view in
        // the view hierarchy.
//        self.view = nil;// 目的是再次进入时能够重新加载调用viewDidLoad函数。
    }
}
@end
