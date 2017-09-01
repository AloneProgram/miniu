//
//  UserLoginViewController.m
//  DLDQ_IOS
//
//  Created by simman on 14-5-14.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import "UserLoginViewController.h"
#import "RegisterUserEntity.h"
#import "UserEntity.h"

//#import "NarikoTextField.h"
@interface UserLoginViewController ()
//@property NarikoTextField *account;
//@property NarikoTextField *pwd;
@end

@implementation UserLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setNavTitle:@"登录"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"用户登录输入";

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backBtn_Nav"] style:UIBarButtonItemStyleDone target:self action:@selector(dismissView)];
    
    [self Hidden_Keyboard_With_GestureAction:^{
        [self resignResponder];
    }];
    
//    _account = [[NarikoTextField alloc]initWithFrame:self.phone.frame];
//    _pwd = [[NarikoTextField alloc]initWithFrame:self.pwd.frame];
    
//    [self.view addSubview:_account];
//    [self.view addSubview:_pwd];
#if TARGET_IS_MINIU_BUYER
    if([[NSUserDefaults standardUserDefaults]objectForKey:@"mobilPhoneNumber"])
    {
        [self.phone setText:[[NSUserDefaults standardUserDefaults]objectForKey:@"mobilPhoneNumber"]];
    }else{
        [self.phone setText:@""];//取消默认的1856572752
    }
    [self.password becomeFirstResponder];
#endif
    
}

- (void) dismissView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)initControllerData{};


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    [_phone setHidden:YES];
//    [_password setHidden:YES];

    [_phone becomeFirstResponder];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self resignResponder];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
//    [self resignResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)resignResponder
{
    [self.phone resignFirstResponder];
    [self.password resignFirstResponder];
}

- (IBAction)loginAction:(id)sender
{
    [self resignResponder];
    [self netWorkRequest];
}

#pragma mark 网络请求
-(void)netWorkRequest
{
    @try {
        [self showHudLoad:@"登录中..."];
        RegisterUserEntity *registerUserEnti = [[RegisterUserEntity alloc] init];
        registerUserEnti.phone = self.phone.text;
        registerUserEnti.password = self.password.text;
        registerUserEnti.countryCode = 80;
        
        [[logicShareInstance getUserManager] loginWithPhone:registerUserEnti success:^(id responseObject) {
            
            //储存本地手机记录
        [[NSUserDefaults standardUserDefaults]setObj:self.phone.text forKey:@"mobilPhoneNumber"];
            
//#if TARGET_IS_MINIU_BUYER
//            [WCAlertView showAlertWithTitle:@"提示" message:@"登陆成功,是否要启用环信?" customizationBlock:^(WCAlertView *alertView) {
//                
//            } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
//                
//                if (buttonIndex == 1) {
//                    // 开启环信
//                    [[logicShareInstance getEasemobManage] setEnableAutoLogin:YES];
//                } else {
//                    // 不开启环信
//                }
//                
//                [[logicShareInstance getUserManager] userLogin:responseObject[@"data"]];
//                [self endHudLoad];
//                [self dismissViewControllerAnimated:YES completion:nil];
//                
//            } cancelButtonTitle:@"取消" otherButtonTitles:@"开启", nil];
//#else
            [[logicShareInstance getUserManager] userLogin:responseObject[@"data"]];
            [self endHudLoad];
            [self dismissViewControllerAnimated:YES completion:nil];
//#endif
        } failure:^(NSString *error) {
            [self showStatusBarError:error];
        }];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    };
}


/**
 *  全局的TextField样式
 *
 *  @param textFiled
 */
- (void)CommonUITextFieldStyle:(UITextField *)textField
{
    textField.borderStyle = UITextBorderStyleNone;
    textField.layer.cornerRadius = 3.0f;
    textField.layer.masksToBounds = YES;
    textField.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    textField.layer.borderWidth = 1.0f;
    
    UILabel  *paddingView = [[UILabel  alloc] initWithFrame:CGRectMake(0, 0, 10, 0)];
    paddingView.text  = @"";
    textField.leftView  = paddingView;
    textField.leftViewMode  = UITextFieldViewModeAlways;
}

- (void) setLeftViewWithTextField:(UITextField *)textField X:(float)x
{
    UILabel  *paddingView = [[UILabel  alloc] initWithFrame:CGRectMake(0, 0, x, 0)];
    paddingView.text  = @"";
    textField.leftView  = paddingView;
    textField.leftViewMode  = UITextFieldViewModeAlways;
}


@end
