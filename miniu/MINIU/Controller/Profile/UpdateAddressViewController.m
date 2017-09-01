//
//  UpdateAddressViewController.m
//  miniu
//
//  Created by SimMan on 15/6/2.
//  Copyright (c) 2015年 SimMan. All rights reserved.
//

#import "UpdateAddressViewController.h"
#import "AddressEntity.h"
#import "UIPlaceHolderTextView.h"
#import "ApplyOrderViewController.h"
#import "OrderManager.h"

#import "IQKeyboardManager.h"

@interface UpdateAddressViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UITextField *realNameTextField;
@property (nonatomic, strong) UITextField *phoneTextField;
@property (nonatomic, strong) UIPlaceHolderTextView *addressTextView;
@end

@implementation UpdateAddressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.address) {
        self.title = @"编辑收货地址";
    } else {
        self.title = @"添加收货地址";

        UIBarButtonItem *rButton = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:(UIBarButtonItemStyleBordered) target:self action:@selector(cancelAddAddress:)];
        [self.navigationItem setLeftBarButtonItem: rButton];
    }
    
    self.view.backgroundColor = [UIColor colorWithRed:0.922 green:0.922 blue:0.922 alpha:1];
    
    
    _realNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 45)];
    UILabel *realLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 75, 40)];
    [realLable setText:@"       收货人："];
    [realLable setTextColor:[UIColor darkGrayColor]];
    realLable.font = [UIFont flatFontOfSize:14];
    _realNameTextField.placeholder = @"请填写收货人真实姓名";
    if (_address) {
        _realNameTextField.text = [NSString stringWithFormat:@"%@", _address.realName];
    }
    _realNameTextField.leftView = realLable;
    _realNameTextField.leftViewMode = UITextFieldViewModeAlways;
    [_realNameTextField addLineUp:NO andDown:YES];
    _realNameTextField.font = [UIFont flatFontOfSize:14];
    _realNameTextField.keyboardType = UIKeyboardTypeNamePhonePad;
    _realNameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    
    _phoneTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_realNameTextField.frame), kScreen_Width, 45)];
    UILabel *phoneLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 90, 40)];
    [phoneLable setText:@"       电话号码："];
    [phoneLable setTextColor:[UIColor darkGrayColor]];
    phoneLable.font = [UIFont flatFontOfSize:14];
    _phoneTextField.placeholder = @"请填写电话号码";
    if (_address) {
        _phoneTextField.text = [NSString stringWithFormat:@"%@", _address.phone];
    }
    _phoneTextField.leftView = phoneLable;
    _phoneTextField.leftViewMode = UITextFieldViewModeAlways;
    [_phoneTextField addLineUp:NO andDown:YES];
    _phoneTextField.font = [UIFont flatFontOfSize:14];
    _phoneTextField.keyboardType = UIKeyboardTypePhonePad;
    _phoneTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    _addressTextView = [[UIPlaceHolderTextView alloc] initWithFrame:CGRectMake(90, CGRectGetMaxY(_phoneTextField.frame) + 3, kScreen_Width - 92, 85)];
    UILabel *addressTitleLable = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_phoneTextField.frame), 90, 40)];
    [addressTitleLable setText:@"       收货地址："];
    [addressTitleLable setTextColor:[UIColor darkGrayColor]];
    addressTitleLable.font = [UIFont flatFontOfSize:14];
    _addressTextView.font = [UIFont flatFontOfSize:14];
    _addressTextView.backgroundColor = [UIColor clearColor];
    _addressTextView.placeholder = @"请填写详细的收货地址";
    if (_address) {
        _addressTextView.text = [NSString stringWithFormat:@"%@", self.address.address];
    }
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_addressTextView.frame)+5, kScreen_Width, 0.5)];
    lineView.backgroundColor = [UIColor colorWithHexString:@"0xc8c7cc"];
    
    FUIButton *submitButton = [[FUIButton alloc] initWithFrame:CGRectMake(20, 30, kScreen_Width - 40, 40)];
    [submitButton setTitle:@"保 存" forState:UIControlStateNormal];
    [submitButton setButtonColor:[UIColor colorWithRed:0.325 green:0.843 blue:0.412 alpha:1]];
    submitButton.titleLabel.font = [UIFont boldFlatFontOfSize:15];
    [submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    submitButton.cornerRadius = 5;
    [submitButton bk_addEventHandler:^(id sender) {
        [self saveAndUpdate];
    } forControlEvents:UIControlEventTouchUpInside];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(lineView.frame), kScreen_Width, 100)];
    [view addSubview:submitButton];
    
    [self.scrollView addSubview:_realNameTextField];
    [self.scrollView addSubview:_phoneTextField];
    [self.scrollView addSubview:addressTitleLable];
    [self.scrollView addSubview:_addressTextView];
    [self.scrollView addSubview:lineView];
    [self.scrollView addSubview:view];
    
    [self.view addSubview:self.scrollView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [IQKeyboardManager sharedManager].enable = false;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [IQKeyboardManager sharedManager].enable = true;
    
}

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        [_scrollView setContentSize:CGSizeMake(kScreen_Width, 500)];
        _scrollView.alwaysBounceVertical = YES;
        _scrollView.delegate = self;
    }
    return _scrollView;
}

#pragma mark - 保存按钮
- (void)saveAndUpdate
{
    AddressEntity *address = [[AddressEntity alloc] init];
    
    address.addressId   = self.address.addressId;
    address.realName = [_realNameTextField.text stringByReplacingEmojiUnicodeWithCheatCodes];
    address.phone = [_phoneTextField.text stringByReplacingEmojiUnicodeWithCheatCodes];
    address.address = [_addressTextView.text stringByReplacingEmojiUnicodeWithCheatCodes];
    
    if ([address.realName length] < 2 || [address.realName length] > 15) {
        [self showHudError:@"收货人姓名为 2 - 15位字符"];
        return;
    } else if ([address.phone length] < 6 || [address.phone length] > 15) {
        [self showHudError:@"手机号码为 6 - 15位字符"];
        return;
    } else if ([address.address length] < 2 || [address.address length] > 50) {
        [self showHudError:@"收货地址为 2 - 50位字符"];
        return;
    }
    
    // 修改
    if (self.address.addressId !=0) {
        [self showHudLoad:@"修改中..."];
        [self.currentRequest addObject:[[logicShareInstance getAddressManager] updateAddress:address success:^(id responseObject) {
            [self showHudSuccess:@"修改成功!"];
            
            [self bk_performBlock:^(id obj) {
                [self.navigationController popViewControllerAnimated:YES];
            } afterDelay:1];
            
        } failure:^(NSString *error) {
            [self showHudError:error];
        }]];
        
    } else {    // 添加
        [self showHudLoad:@"添加中..."];
        
        if (self.createUserId) {
            _address.userId = _createUserId;
        }
        //添加地址
        
        if(!self.orderEntity){
            //用户自己添加地址
            [self.currentRequest addObject:[[logicShareInstance getAddressManager] addAddress:address success:^(id responseObject) {
                NSLog(@"self.currentRequest ->%@",self.currentRequest);
                
                [self showHudSuccess:@"添加成功!"];
                [self bk_performBlock:^(id obj) {
                    [self.navigationController popViewControllerAnimated:YES];
                } afterDelay:1];
                
            } failure:^(NSString *error) {
                NSLog(@"self.currentRequest ->%@",self.currentRequest);
                
                [self showHudError:error];
            }]];
            
        }else{
            
            //订单添加新地址
            [[OrderManager shareInstance]addAddressWithOrderNo:self.orderEntity.orderNo address:address success:^(id responseObject) {
                [self showHudSuccess:@"添加成功!"];
                
                [self bk_performBlock:^(id obj) {
                    //pop view controller should refresh
                    // ApplyOrderViewController *avoc = [self.navigationController ]
                    
                    //[self.navigationController popViewControllerAnimated:YES];
                    
                    NSArray *controllers = self.navigationController.childViewControllers;
                    //[controllers[controllers.count-3] reloadInputViews];
                    [self.navigationController popToViewController:controllers[controllers.count-3] animated:YES];
                    //[self.navigationController popToViewController:[self.navigationController childViewControllers][1] animated:YES];
                    //[self.navigationController popToRootViewControllerAnimated:YES];
                } afterDelay:1.0f];
                
            } failure:^(NSString *error) {
                [self showHudError:error];
            }];
        }
    }
}

- (void)cancelAddAddress:(UIBarButtonItem *)sender
{
    NSArray *controllers = self.navigationController.childViewControllers;

    [self.navigationController popToViewController:controllers[controllers.count-3] animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.realNameTextField resignFirstResponder];
    [self.phoneTextField resignFirstResponder];
    //    [self.addressTextView resignFirstResponder]; //using iq keyboard
}

@end
