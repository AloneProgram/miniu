//
//  BindMobileViewController.m
//  miniu
//
//  Created by SimMan on 4/28/15.
//  Copyright (c) 2015 SimMan. All rights reserved.
//

#import "BindMobileViewController.h"
#import "SectionsViewController.h"
#import <SMS_SDK/SMS_SDK.h>
#import <SMS_SDK/CountryAndAreaCode.h>
#import "VerifyViewController.h"

@interface BindMobileViewController() <SecondViewControllerDelegate> {
    NSString* _str;
}

@property (weak, nonatomic) IBOutlet UIButton *areaButton;
@property (weak, nonatomic) IBOutlet UITextField *mobileTextField;
@property (weak, nonatomic) IBOutlet FUIButton *submitButton;
@property (weak, nonatomic) IBOutlet UILabel *line1Lable;
@property (weak, nonatomic) IBOutlet UILabel *line2Lable;
- (IBAction)submitButtonAction:(id)sender;
- (IBAction)areaButtonAction:(id)sender;

@property (nonatomic, strong) CountryAndAreaCode *areaData;
@property (nonatomic, strong) NSMutableArray *areaArray;
@property(nonatomic, strong) UITextField* areaCodeField;

@end

@interface BindMobileViewController ()

@end

@implementation BindMobileViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.areaData = [[CountryAndAreaCode alloc] init];
        self.areaData.countryName = @"中国";
        self.areaData.areaCode = @"86";
        self.areaCodeField = [[UITextField alloc] init];
        self.areaCodeField.text = @"+86";
        
        //获取支持的地区列表
        [SMS_SDK getZone:^(enum SMS_ResponseState state, NSArray *array)
         {
             if (1==state)
             {
                 NSLog(@"sucessfully get the area code");
                 //区号数据
                 _areaArray = [NSMutableArray arrayWithArray:array];
             }
             else if (0==state)
             {
                 NSLog(@"failed to get the area code");
             }
             
         }];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"绑定手机号";
    
    self.navigationItem.backBarButtonItem = [UIBarButtonItem blankBarButton];
    
    [self.areaButton setWidth:kScreen_Width - 20];
    [self.mobileTextField setWidth:kScreen_Width - 20];
    [self.line1Lable setWidth:kScreen_Width - 8];
    [self.line2Lable setWidth:kScreen_Width - 8];
    [self.submitButton setWidth:kScreen_Width - 40];
    [self.submitButton setX:20];
}

- (IBAction)submitButtonAction:(id)sender {
    
    int compareResult = 0;
    for (int i=0; i<_areaArray.count; i++)
    {
        NSDictionary* dict1=[_areaArray objectAtIndex:i];
        NSString* code1=[dict1 valueForKey:@"zone"];
        if ([code1 isEqualToString:[_areaCodeField.text stringByReplacingOccurrencesOfString:@"+" withString:@""]])
        {
            compareResult=1;
            NSString* rule1=[dict1 valueForKey:@"rule"];
            NSPredicate* pred=[NSPredicate predicateWithFormat:@"SELF MATCHES %@",rule1];
            BOOL isMatch=[pred evaluateWithObject:self.mobileTextField.text];
            if (!isMatch)
            {
                //手机号码不正确
                UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"notice", nil)
                                                              message:NSLocalizedString(@"errorphonenumber", nil)
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"sure", nil)
                                                    otherButtonTitles:nil, nil];
                [alert show];
                return;
            }
            break;
        }
    }
    
    if (!compareResult)
    {
        if (self.mobileTextField.text.length!=11)
        {
            //手机号码不正确
            UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"notice", nil)
                                                          message:NSLocalizedString(@"errorphonenumber", nil)
                                                         delegate:self
                                                cancelButtonTitle:NSLocalizedString(@"sure", nil)
                                                otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
    }
    
    NSString* str = [NSString stringWithFormat:@"%@:%@ %@",NSLocalizedString(@"willsendthecodeto", nil),self.areaCodeField.text,self.mobileTextField.text];
    _str=[NSString stringWithFormat:@"%@",self.mobileTextField.text];
    UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"surephonenumber", nil)
                                                  message:str delegate:self
                                        cancelButtonTitle:NSLocalizedString(@"cancel", nil)
                                        otherButtonTitles:NSLocalizedString(@"sure", nil), nil];
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (1==buttonIndex)
    {
        [self sendMessageWithMobile];
    }
}


- (void) sendMessageWithMobile
{
    WeakSelf
    [[logicShareInstance getUserManager] sendMsgWithBindMobile:self.mobileTextField.text countryCode:self.areaData.areaCode Success:^(id responseObject) {
        
        NSString *smsCode = responseObject[@"data"][@"smsCode"];
        
        VerifyViewController* verify=[[VerifyViewController alloc] init];
        verify.serverCode = smsCode;
        
        NSString* str2=[weakSelf_SC.areaCodeField.text stringByReplacingOccurrencesOfString:@"+" withString:@""];
        [verify setPhone:weakSelf_SC.mobileTextField.text AndAreaCode:str2];
        [weakSelf_SC.navigationController pushViewController:verify animated:YES];
        
    } failure:^(NSString *error) {
        [weakSelf_SC showHudError:error];
    }];
}



- (IBAction)areaButtonAction:(id)sender {
    SectionsViewController* country2 = [[SectionsViewController alloc] init];
    country2.delegate = self;
    [country2 setAreaArray:_areaArray];
    [self presentViewController:country2 animated:YES completion:^{
        ;
    }];
}


#pragma mark - SecondViewControllerDelegate的方法
- (void)setSecondData:(CountryAndAreaCode *)data
{
    self.areaData = data;
    NSLog(@"the area data：%@,%@", data.areaCode,data.countryName);
    
    [self.areaButton setTitle:[NSString stringWithFormat:@"%@(+%@)", data.countryName,data.areaCode] forState:UIControlStateNormal];
    self.areaCodeField.text = [NSString stringWithFormat:@"+%@",data.areaCode];
}


@end
