//
//  AddressEditView.m
//  DLDQ_IOS
//
//  Created by simman on 14-9-2.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import "AddressEditView.h"

@interface AddressEditView()


@property (nonatomic, strong) AddressEntity *addressEntity;
@end

@implementation AddressEditView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (instancetype)shareXibView
{
    // 读出xib文件
    return [[[NSBundle mainBundle] loadNibNamed:@"AddressEditView" owner:nil options:nil] lastObject];
}

- (void)setAddressDataWithAddressEntity:(AddressEntity *)entity
{
    self.addressEntity = entity;

    if (self.addressEntity) {
        self.realNameLable.text = _addressEntity.realName;
        self.phoneLable.text = _addressEntity.phone;
        self.addressLable.text = _addressEntity.address;
        [self.defaultSwitch setOn:_addressEntity.isDefault animated:YES];
    } else {
        self.realNameLable.placeholder = @"请输入收货人姓名";
        self.phoneLable.placeholder = @"请输入手机号码";
        self.addressLable.placeholder = @"请输入收货地址";
    }
}

@end
