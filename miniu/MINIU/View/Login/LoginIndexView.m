//
//  LoginIndexView.m
//  DLDQ_IOS
//
//  Created by simman on 14-8-22.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import "LoginIndexView.h"
#import "WXApi.h"

@interface LoginIndexView() {
    void (^_registerAction) ();
    void (^_WXLoginAction) ();
    void (^_MobileLoginAction) ();
}

@property (strong, nonatomic) UIButton *WXloginButton;
@property (strong, nonatomic) UIButton *MobileLoginButton;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIImageView *logoImageView;

- (IBAction)WXLoginAction:(id)sender;
- (IBAction)MobileLoginAction:(id)sender;
- (IBAction)RegisterAction:(id)sender;

@end

@implementation LoginIndexView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        _backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LoginIndexBG"]];
//        _logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"miniu_login_logo"]];

        _backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"登录页"]];
        _WXloginButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 201, 44)];
        [_WXloginButton setBackgroundImage:[UIImage imageNamed:@"WXLogin"] forState:UIControlStateNormal];
        [_WXloginButton addTarget:self action:@selector(WXLoginAction:) forControlEvents:UIControlEventTouchUpInside];
        
        _MobileLoginButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 201, 44)];
        [_MobileLoginButton setBackgroundImage:[UIImage imageNamed:@"MobileLogin"] forState:UIControlStateNormal];
        [_MobileLoginButton addTarget:self action:@selector(MobileLoginAction:) forControlEvents:UIControlEventTouchUpInside];
        
        
        [self addSubview:_backgroundImageView];
        [self addSubview:_logoImageView];
        [self addSubview:_MobileLoginButton];
        [self addSubview:_WXloginButton];
        NSLog(@"%@",NSStringFromCGRect(_backgroundImageView.frame));
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

//    float logoImageViewY = 80.0f;
//    if (IS_IPHONE_5) {
//        logoImageViewY = 115.0f;
//    } else if (kDevice_Is_iPhone6) {
//        logoImageViewY = 136.0f;
//    } else if (IS_IPHONE6PLUS) {
//        logoImageViewY = 238.0f;
//    }
    
    self.backgroundImageView.frame = self.bounds;
//    CGRect logoImageViewFrame = self.logoImageView.frame;
//    logoImageViewFrame.origin.y = logoImageViewY;
//    logoImageViewFrame.origin.x = (kScreen_Width - logoImageViewFrame.size.width) / 2;
//    self.logoImageView.frame = logoImageViewFrame;
    
#if TARGET_IS_MINIU
    if ([WXApi isWXAppInstalled]) {
        
        self.WXloginButton.center = self.center;
        CGRect WXloginButtonFrame = self.WXloginButton.frame;
        WXloginButtonFrame.origin.y = kScreen_Height - 140;
        self.WXloginButton.frame = WXloginButtonFrame;
        
#ifdef DEBUG
        
        self.MobileLoginButton.center = self.center;
        
        CGRect mobileLoginButtonFrame = self.MobileLoginButton.frame;
        mobileLoginButtonFrame.origin.y = kScreen_Height - 70;
        self.MobileLoginButton.frame = mobileLoginButtonFrame;
#else
        self.MobileLoginButton.hidden = YES;
#endif
    } else {
        
        self.WXloginButton.hidden = YES;
        
        self.MobileLoginButton.center = self.center;
        CGRect mobileLoginButtonFrame = self.MobileLoginButton.frame;
        mobileLoginButtonFrame.origin.y = kScreen_Height - 130;
        self.MobileLoginButton.frame = mobileLoginButtonFrame;
    }
    
#else
    
    self.WXloginButton.hidden = YES;
    self.MobileLoginButton.hidden = NO;
    self.MobileLoginButton.center = self.center;
    CGRect mobileLoginButtonFrame = self.MobileLoginButton.frame;
    mobileLoginButtonFrame.origin.y = kScreen_Height - 130;
    self.MobileLoginButton.frame = mobileLoginButtonFrame;
    
#endif
    
    
}


+ (instancetype)shareXibView
{
    // 读出xib文件

    return nil;
}

- (IBAction)WXLoginAction:(id)sender {
    _WXLoginAction();
}

- (IBAction)MobileLoginAction:(id)sender {
    _MobileLoginAction();
}

- (IBAction)RegisterAction:(id)sender {
//    _registerAction();
}

- (void) addButtonActionCallBackWithRegister:(void (^)())registerAction
                               WXLoginAction:(void (^)())WXLoginAction
                           MobileLoginAction:(void (^)())MobileLoginAction
{
    _registerAction = registerAction;
    _WXLoginAction = WXLoginAction;
    _MobileLoginAction = MobileLoginAction;
}
@end
