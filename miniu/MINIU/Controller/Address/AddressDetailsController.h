//
//  AddressDetailsController.h
//  DLDQ_IOS
//
//  Created by simman on 14-9-2.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import "BaseViewController.h"
#import "AddressEntity.h"

@interface AddressDetailsController : BaseViewController

/**
 *  设置默认数据并添加回调
 *
 *  @param entity 地址实例
 *  @param Block  回调
 */
- (void) setAddressDataWithAddressEntity:(AddressEntity *)entity
                        addCallBackBlock:(void(^)(AddressEntity *addressEntity))Block;


@end
