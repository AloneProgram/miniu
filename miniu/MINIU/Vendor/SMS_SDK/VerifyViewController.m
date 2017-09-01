//
//  VerifyViewController.m
//  SMS_SDKDemo
//
//  Created by admin on 14-6-4.
//  Copyright (c) 2014年 admin. All rights reserved.
//

#import "VerifyViewController.h"

#import <AddressBook/AddressBook.h>

#import <SMS_SDK/SMS_SDK.h>
#import <SMS_SDK/SMS_UserInfo.h>
#import <SMS_SDK/SMS_AddressBook.h>
#import "UserEntity.h"

@interface VerifyViewController ()
{
    NSString* _phone;
    NSString* _areaCode;
    int _state;
    NSMutableData* _data;
    NSString* _localVerifyCode;
    
    NSString* _appKey;
    NSString* _appSecret;
    NSString* _duid;
    NSString* _token;
    NSString* _localPhoneNumber;
    
    NSString* _localZoneNumber;
    NSMutableArray* _addressBookTemp;
    NSString* _contactkey;
    SMS_UserInfo* _localUser;
    
    NSTimer* _timer1;
    NSTimer* _timer2;
    NSTimer* _timer3;
    
    UIAlertView* _alert1;
    UIAlertView* _alert2;
    UIAlertView* _alert3;
    
    UIAlertView *_tryVoiceCallAlertView;

}

@end

static int count = 0;

//最近新好友信息
static NSMutableArray* _userData2;

@implementation VerifyViewController

-(void)clickLeftButton
{
    UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"notice", nil)
                                                  message:NSLocalizedString(@"codedelaymsg", nil)
                                                 delegate:self
                                        cancelButtonTitle:NSLocalizedString(@"back", nil)
                                        otherButtonTitles:NSLocalizedString(@"wait", nil), nil];
    _alert2=alert;
    [alert show];    
}

-(void)setPhone:(NSString*)phone AndAreaCode:(NSString*)areaCode
{
    _phone=phone;
    _areaCode=areaCode;
}

-(void)submit
{
    WeakSelf
    //验证号码
    //验证成功后 获取通讯录 上传通讯录
    [self.view endEditing:YES];
    
    if (![self.verifyCodeField.text length]) {
        [self showStatusBarError:@"请输入验证码!"];
        return;
    }
    
    if (![[self.verifyCodeField.text MD5Hash] isEqualToString:self.serverCode]) {
        [self showStatusBarError:@"请输入正确的验证码!"];
        return;
    }
    
    [[logicShareInstance getUserManager] bindMobile:_phone countryCode:_areaCode smsCode:self.serverCode Success:^(id responseObject) {
        
        NSLog(@"验证成功");
        NSString* str=[NSString stringWithFormat:NSLocalizedString(@"verifycoderightmsg", nil)];
        UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"verifycoderighttitle", nil)
                                                      message:str
                                                     delegate:self
                                            cancelButtonTitle:NSLocalizedString(@"sure", nil)
                                            otherButtonTitles:nil, nil];
        [alert show];
        _alert3=alert;
        
    } failure:^(NSString *error) {
        [weakSelf_SC showStatusBarError:error];
    }];
}


-(void)CannotGetSMS
{
    NSString* str=[NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"cannotgetsmsmsg", nil) ,_phone];
    UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"surephonenumber", nil) message:str delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"sure", nil), nil];
    _alert1=alert;
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    WeakSelf
    if (alertView==_alert1)
    {
        if (1==buttonIndex)
        {
            NSLog(@"重发验证码");
            [[logicShareInstance getUserManager] sendMsgWithBindMobile:_phone countryCode:_areaCode Success:^(id responseObject) {
                
                UserEntity *user = [CURRENT_USER_INSTANCE getCurrentUser];
                user.phone = _phone;
                [[logicShareInstance getUserManager] updateCurrentUser:user];
                
                NSString *smsCode = responseObject[@"data"][@"smsCode"];
                weakSelf_SC.serverCode = smsCode;
                [weakSelf_SC showHudSuccess:@"验证码重发成功!"];
                
                weakSelf_SC.repeatSMSBtn.hidden=YES;
                
                [_timer2 invalidate];
                [_timer1 invalidate];
                
                count = 0;
                
                self.timeLabel.hidden = NO;
                NSTimer* timer=[NSTimer scheduledTimerWithTimeInterval:60
                                                                target:self
                                                              selector:@selector(showRepeatButton)
                                                              userInfo:nil
                                                               repeats:YES];
                
                NSTimer* timer2=[NSTimer scheduledTimerWithTimeInterval:1
                                                                 target:self
                                                               selector:@selector(updateTime)
                                                               userInfo:nil
                                                                repeats:YES];
                _timer1=timer;
                _timer2=timer2;
                
                
            } failure:^(NSString *error) {
                [weakSelf_SC showHudError:error];
            }];
        }
        
    }
    
    if (alertView==_alert2) {
        if (0==buttonIndex)
        {
            [self dismissViewControllerAnimated:YES completion:^{
                [_timer2 invalidate];
                [_timer1 invalidate];
            }];
        }
    }
    
    if (alertView==_alert3)
    {
        [_timer2 invalidate];
        [_timer1 invalidate];
        [self.navigationController popToRootViewControllerAnimated:YES];
        
//        YJViewController* yj=[[YJViewController alloc] init];
//        [self presentViewController:yj animated:YES completion:^{
//            //解决等待时间乱跳的问题
//            [_timer2 invalidate];
//            [_timer1 invalidate];
//        }];
    }
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [_timer2 invalidate];
    [_timer1 invalidate];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"输入验证码";
    
    self.view.backgroundColor=[UIColor whiteColor];
    
    float statusBarHeight = 0;
    
    UILabel* label=[[UILabel alloc] init];
    label.frame=CGRectMake(15, 53+statusBarHeight, self.view.frame.size.width - 30, 21);
    label.text=[NSString stringWithFormat:NSLocalizedString(@"verifylabel", nil)];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:@"Helvetica" size:17];
    [self.view addSubview:label];
    
    _telLabel=[[UILabel alloc] init];
    _telLabel.frame=CGRectMake(15, 82+statusBarHeight, self.view.frame.size.width - 30, 21);
    _telLabel.textAlignment = NSTextAlignmentCenter;
    _telLabel.font = [UIFont fontWithName:@"Helvetica" size:17];
    [self.view addSubview:_telLabel];
    self.telLabel.text= [NSString stringWithFormat:@"+%@ %@",_areaCode,_phone];
    
    _verifyCodeField=[[UITextField alloc] init];
    _verifyCodeField.frame=CGRectMake(25, 111+statusBarHeight, self.view.frame.size.width - 50, 42);
    _verifyCodeField.borderStyle=UITextBorderStyleRoundedRect;
    _verifyCodeField.textAlignment=NSTextAlignmentCenter;
    _verifyCodeField.placeholder=NSLocalizedString(@"verifycode", nil);
    _verifyCodeField.font=[UIFont fontWithName:@"Helvetica" size:18];
    _verifyCodeField.keyboardType=UIKeyboardTypePhonePad;
    _verifyCodeField.clearButtonMode=UITextFieldViewModeWhileEditing;
    [self.view addSubview:_verifyCodeField];
    
    _timeLabel=[[UILabel alloc] init];
    _timeLabel.frame=CGRectMake(15, 169+statusBarHeight, self.view.frame.size.width - 30, 40);
    _timeLabel.numberOfLines = 0;
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    _timeLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
    _timeLabel.text=NSLocalizedString(@"timelabel", nil);
    [self.view addSubview:_timeLabel];
    
    _repeatSMSBtn=[UIButton buttonWithType:UIButtonTypeSystem];
    _repeatSMSBtn.frame=CGRectMake(15, 169+statusBarHeight, self.view.frame.size.width - 30, 30);
    [_repeatSMSBtn setTitle:NSLocalizedString(@"repeatsms", nil) forState:UIControlStateNormal];
    [_repeatSMSBtn addTarget:self action:@selector(CannotGetSMS) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_repeatSMSBtn];
    
    _submitBtn=[UIButton buttonWithType:UIButtonTypeSystem];
    [_submitBtn setTitle:NSLocalizedString(@"submit", nil) forState:UIControlStateNormal];
    NSString *icon = [NSString stringWithFormat:@"smssdk.bundle/button4.png"];
    [_submitBtn setBackgroundImage:[UIImage imageNamed:icon] forState:UIControlStateNormal];
    _submitBtn.frame=CGRectMake(25, 220+statusBarHeight, self.view.frame.size.width - 50, 42);
    [_submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_submitBtn addTarget:self action:@selector(submit) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_submitBtn];

    self.repeatSMSBtn.hidden=YES;
    
    [_timer2 invalidate];
    [_timer1 invalidate];
    
    count = 0;
    
    NSTimer* timer=[NSTimer scheduledTimerWithTimeInterval:60
                                           target:self
                                         selector:@selector(showRepeatButton)
                                         userInfo:nil
                                          repeats:YES];
    
    NSTimer* timer2=[NSTimer scheduledTimerWithTimeInterval:1
                                                    target:self
                                                  selector:@selector(updateTime)
                                                  userInfo:nil
                                                   repeats:YES];
    _timer1=timer;
    _timer2=timer2;
    
    [self showHudSuccess:NSLocalizedString(@"sendingin", nil)];
}

-(void)updateTime
{
    count++;
    if (count>=60)
    {
        [_timer2 invalidate];
        return;
    }
    //NSLog(@"更新时间");
    self.timeLabel.text=[NSString stringWithFormat:@"%@%i%@",NSLocalizedString(@"timelablemsg", nil),60-count,NSLocalizedString(@"second", nil)];
}

-(void)showRepeatButton{
    self.timeLabel.hidden=YES;
    self.repeatSMSBtn.hidden=NO;
    
    [_timer1 invalidate];
    return;
}

@end
