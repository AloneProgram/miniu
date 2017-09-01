//
//  AddressEditView.h
//  DLDQ_IOS
//
//  Created by simman on 14-9-2.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddressEntity.h"

@interface AddressEditView : UIView

- (void) setAddressDataWithAddressEntity:(AddressEntity *)entity;

+ (instancetype)shareXibView;

@property (weak, nonatomic) IBOutlet UITextField *realNameLable;
@property (weak, nonatomic) IBOutlet UITextField *phoneLable;
@property (weak, nonatomic) IBOutlet UITextField *addressLable;
@property (weak, nonatomic) IBOutlet UISwitch *defaultSwitch;

@end
