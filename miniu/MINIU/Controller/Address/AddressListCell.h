//
//  AddressListCell.h
//  DLDQ_IOS
//
//  Created by simman on 14-9-2.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AddressEntity.h"

@interface AddressListCell : UITableViewCell

/**
 *  设置数据
 *
 *  @param entity 地址对象
 */
- (void)setCellDataWithAddressEntity:(AddressEntity *)entity;


+ (instancetype)shareXibView;

@end
