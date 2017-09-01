//
//  UserLoginIndexViewController.m
//  DLDQ_IOS
//
//  Created by simman on 14-8-22.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import "UserLoginIndexViewController.h"
#import "LoginIndexView.h"

#import "UserLoginViewController.h"

@interface UserLoginIndexViewController ()

@end

@implementation UserLoginIndexViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //　判断如果用户已经登录状态则直接退出
    
    if (USER_IS_LOGIN) {
        [[self mainDelegate] changeRootViewController];
    }
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"用户选择登录";
    LoginIndexView *loginIndexView = [[LoginIndexView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:loginIndexView];
    
    UserLoginViewController *loginVC = [[UserLoginViewController alloc] initWithNibName:@"UserLoginViewController" bundle:nil];
    
    [loginIndexView addButtonActionCallBackWithRegister:^{} WXLoginAction:^{
        
        [self showHudLoad:@"登陆中..."];
        
        [[logicShareInstance getWeChatManage] sendAuthRequest:^(NSString *access_code) {
            
            //登录微信
            [[logicShareInstance getUserManager] loginWithWeChatCode:access_code success:^(id responseObject) {
                
               [[logicShareInstance getUserManager] userLogin:responseObject[@"data"]];
                
                [self endHudLoad];
                
                [[self mainDelegate] changeRootViewController];
                
            } failure:^(NSString *error) {

                [self showStatusBarError:error];
            }];
            
        } errorCode:^(AccessErrorCode error_code) {
            [self showStatusBarError:@"您已经取消使用微信登录!"];
        }];
    } MobileLoginAction:^{
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginVC];
        nav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:nav animated:YES completion:^{
            
        }];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
