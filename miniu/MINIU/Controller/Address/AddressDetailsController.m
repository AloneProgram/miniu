//
//  AddressDetailsController.m
//  DLDQ_IOS
//
//  Created by simman on 14-9-2.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import "AddressDetailsController.h"
#import "AddressEditView.h"

@interface AddressDetailsController () {
    void (^_addressBlocks)(AddressEntity *);
}
@property (nonatomic, strong) AddressEntity *addressEntity;
@property (nonatomic, strong) AddressEditView *addressEditView;
@end

@implementation AddressDetailsController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)initControllerData{};

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.addressEntity) {
        [self setNavTitle:@"编辑地址"];
    } else {
        [self setNavTitle:@"添加地址"];
    }
    
    [self setAddressEditV];
    
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleDone target:self action:@selector(setNavRightBarButtonAction:)];
}

- (void) setAddressEditV
{
    _addressEditView = [AddressEditView shareXibView];
    [_addressEditView setAddressDataWithAddressEntity:self.addressEntity];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 500)];
    [view addSubview:_addressEditView];
    [self.view addSubview:view];
}


#pragma mark - 保存按钮
- (void)setNavRightBarButtonAction:(id)sender
{
    AddressEntity *address = [[AddressEntity alloc] init];
    
    address.addressId   = self.addressEntity.addressId;
    address.realName = [_addressEditView.realNameLable.text stringByReplacingEmojiUnicodeWithCheatCodes];
    address.phone = [_addressEditView.phoneLable.text stringByReplacingEmojiUnicodeWithCheatCodes];
    address.address = [_addressEditView.addressLable.text stringByReplacingEmojiUnicodeWithCheatCodes];
    
    if ([address.realName length] < 2 || [address.realName length] > 15) {
        [self showHudError:@"收货人姓名为 2 - 15位字符"];
        return;
    } else if ([address.phone length] < 6 || [address.phone length] > 15) {
        [self showHudError:@"手机号码为 6 - 15位字符"];
        return;
    } else if ([address.address length] < 2 || [address.address length] > 40) {
        [self showHudError:@"收货地址为 2 - 40位字符"];
        return;
    }
    
    if (!_addressEditView.defaultSwitch.isOn) {
        [self showHudError:@"您必须有一个默认地址!"];
        return;
    }
    
    // 修改
    if (self.addressEntity) {
        [self showStatusBarQueryStr:@"修改中..."];
        address.isDefault   =  _addressEditView.defaultSwitch.isOn;
        [self.currentRequest addObject:[[logicShareInstance getAddressManager] updateAddress:address success:^(id responseObject) {
            self.addressEntity = address;
            if (_addressBlocks) {
                _addressBlocks(self.addressEntity);
            }
            if (_addressEditView.defaultSwitch.isOn) {
                [[logicShareInstance getAddressManager] setUserDefaultAddress:address];
            }
            [self showStatusBarSuccessStr:@"修改成功!"];
            [self.navigationController popViewControllerAnimated:YES];
        } failure:^(NSString *error) {
            [self showStatusBarError:error];
        }]];
        
    } else {    // 添加
        [self showStatusBarQueryStr:@"添加中..."];
        address.isDefault   =  _addressEditView.defaultSwitch.isOn;
        [self.currentRequest addObject:[[logicShareInstance getAddressManager] addAddress:address success:^(id responseObject) {
            if (_addressBlocks) {
                _addressBlocks(address);
            }
            if (_addressEditView.defaultSwitch.isOn) {
                [[logicShareInstance getAddressManager] setUserDefaultAddress:address];
            }
            [self showStatusBarSuccessStr:@"添加成功!"];
            [self.navigationController popViewControllerAnimated:YES];
        } failure:^(NSString *error) {
            [self showStatusBarError:error];
        }]];
    }
}

- (void)setAddressDataWithAddressEntity:(AddressEntity *)entity
                       addCallBackBlock:(void (^)(AddressEntity *))Block
{
    _addressBlocks = Block;
    self.addressEntity = entity;
}


@end
