//
//  AboutUSViewController.m
//  DLDQ_IOS
//
//  Created by simman on 14-6-12.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import "AboutUSViewController.h"
#import "FeedBackViewController.h"

#import <WebKit/WebKit.h>

@interface AboutUSViewController ()

@end

@implementation AboutUSViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //test wkwebview
    //WKWebView *web1 = [[WKWebView alloc]initWithFrame:CGRectMake(0, 100, 320, 400)];
    //[web1 loadHTMLString:@"www.baidu.com" baseURL:nil];
   // [self.view addSubview:web1];
    

    self.title = @"关于米妞";
    
    WeakSelf
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] bk_initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStyleDone handler:^(id sender) {
        [weakSelf_SC.navigationController popViewControllerAnimated:YES];
    }];
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"关于米妞-logo"]];
    logoImageView.center = self.view.center;
    [logoImageView setY:40];
    [self.view addSubview:logoImageView];
    
    UILabel *nameLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 20)];
    [nameLable setText:[NSString stringWithFormat:@"%@ v%@",@"米妞", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]]];
    [nameLable setTextColor:[UIColor lightGrayColor]];
    [nameLable setFont:[UIFont systemFontOfSize:14]];
    [nameLable setTextAlignment:NSTextAlignmentCenter];
    [nameLable setCenter:[self.view center]];
    [nameLable setY:CGRectGetMaxY(logoImageView.frame) + 15];
    [self.view addSubview:nameLable];
    
    UIImageView *feedBackImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"关于米妞-意见反馈"]];
    feedBackImageView.userInteractionEnabled = YES;
    [feedBackImageView bk_whenTapped:^{
        [weakSelf_SC feedback];
    }];
    feedBackImageView.center = self.view.center;
    [feedBackImageView setY:kScreen_Height - 160];
    [self.view addSubview:feedBackImageView];
    
    UILabel *copyrightLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 40)];
    [copyrightLable setText:@"深圳市代来代去网络科技有限公司\nShenZhen DLDQ Network Technology Co.limtied"];
    [copyrightLable setTextColor:[UIColor lightGrayColor]];
    [copyrightLable setFont:[UIFont systemFontOfSize:12]];
    [copyrightLable setTextAlignment:NSTextAlignmentCenter];
    [copyrightLable setCenter:[self.view center]];
    [copyrightLable setY:kScreen_Height - 110];
    [copyrightLable setNumberOfLines:2];

    [self.view addSubview:copyrightLable];
}

#pragma mark 建议与反馈
- (void)feedback
{
    FeedBackViewController *feedbackVC = [[FeedBackViewController alloc] init];
    [self.navigationController pushViewController:feedbackVC animated:YES];
//    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:feedbackVC];
//    [self presentViewController:nav animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
