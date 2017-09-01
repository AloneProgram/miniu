//
//  AddressListCell.m
//  DLDQ_IOS
//
//  Created by simman on 14-9-2.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import "AddressListCell.h"

@interface AddressListCell () {

}

@property (weak, nonatomic) IBOutlet UILabel *realNameLable;
@property (weak, nonatomic) IBOutlet UILabel *telLable;
@property (weak, nonatomic) IBOutlet UILabel *addressLable;
@property (weak, nonatomic) IBOutlet UIImageView *defaultImageView;

@end
@implementation AddressListCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (instancetype)shareXibView
{
    // 读出xib文件
    return [[[NSBundle mainBundle] loadNibNamed:@"AddressListCell" owner:nil options:nil] lastObject];
}

- (void)setCellDataWithAddressEntity:(AddressEntity *)entity
{
    self.realNameLable.text = entity.realName;
    self.telLable.text = entity.phone;
    self.addressLable.text = entity.address;
    if ( !entity.isDefault) {
        self.defaultImageView.hidden = YES;
    } else {
        self.defaultImageView.hidden = NO;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect defaultImageView = self.defaultImageView.frame;
    defaultImageView.origin.x = kScreen_Width - 50;
    self.defaultImageView.frame = defaultImageView;
}


@end
