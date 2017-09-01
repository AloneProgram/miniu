//
//  URLManager.m
//  DLDQ_IOS
//
//  Created by simman on 15/2/11.
//  Copyright (c) 2015年 Liwei. All rights reserved.
//

#import "URLManager.h"

//test url
//#define API_BASE_URL @"http://hnhcc39.oicp.net/rest"
//#define API_TEST_URL @"http://hnhcc39.oicp.net/rest"
//#define API_NO_SERVER_URL @"http://hnhcc39.oicp.net"

//real environment url
#define API_BASE_URL @"http://server.dldq.org:7070/rest"
#define API_TEST_URL @"http://server.dldq.org:7070/rest"
#define API_NO_SERVER_URL @"http://server.dldq.org:7070"

#import "TOWebViewController.h"
#import "GoodsDetailsViewController.h"
#import "HomeViewController.h"
#import "ChatViewController.h"
#import "REFrostedViewController.h"

@interface URLManager()

@property (nonatomic, assign) BOOL CurrentIsProduct;

@end

@implementation URLManager

+ (instancetype)shareInstance
{
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
#ifdef DEBUG
        _CurrentIsProduct = NO;
#else
        _CurrentIsProduct = YES;
#endif
        
    }
    return self;
}

- (NSString *)getBaseURL
{
    if (_CurrentIsProduct) {
        return API_BASE_URL;
    } else {
        return API_TEST_URL;
    }
    //return API_BASE_URL;
}

- (BOOL)isProduct
{
    return _CurrentIsProduct;
}

- (void) setCurrentIsProduct:(BOOL)product
{
    _CurrentIsProduct = product;
}

- (NSString *) getNoServerBaseURL
{
    return API_NO_SERVER_URL;
}

- (void) resolvingUrlAndOpenAction:(NSURL *)url
{
    if (!USER_IS_LOGIN) {
        return;
    }
    
#if TARGET_IS_MINIU_BUYER
    return;
#endif
    
    NSDictionary *dic = [self getUrlDictionary:url];
    
    if (dic) {
        // 转码 v
        NSString *v = [NSString stringFromBase64String:dic[@"v"]];
        
        NSString *c = [NSString stringWithFormat:@"%@", dic[@"name"]];
        
        UINavigationController *nav = [self getTopNavigationController];
        
        if (!nav) {
            return;
        }
        
        // 如果是打开网页
        if ([c isEqualToString:@"openUrl"]) {
        
            NSURL *openUrl = [NSURL URLWithString:v];
            
            TOWebViewController *webViewController = [[TOWebViewController alloc] initWithURL:openUrl];
            webViewController.navigationButtonsHidden = YES;
            webViewController.hideWebViewBoundaries = YES;
            
            [nav pushViewController:webViewController animated:YES];
            
        // 打开标签
        } else if ([c isEqualToString:@"openTagPage"]) {
            
            HomeViewController *homeVC = [[HomeViewController alloc] init];
            homeVC.tagName = v;
            [nav pushViewController:homeVC animated:YES];
            
        // 打开商品详情
        } else if ([c isEqualToString:@"openGoodsDetail"]) {
            GoodsDetailsViewController *goodsVC = [GoodsDetailsViewController new];
            goodsVC.goodsId = [v longLongValue];
            [nav pushViewController:goodsVC animated:YES];
        }
    }
}



@end
