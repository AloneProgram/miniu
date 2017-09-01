//
//  AddressManager.h
//  DLDQ_IOS
//
//  Created by simman on 14-9-2.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ManagerBase.h"
@class AddressEntity;

@interface AddressManager : ManagerBase <LogicBaseModel>


/**
 *  地址管理对象单例
 *
 *  @return
 */
+ (instancetype)shareInstance;


/**
 *  设置用户的默认地址
 *
 *  @param entity 地址实例
 */
- (void) setUserDefaultAddress:(AddressEntity *)entity;

/**
 *  获取用户的默认地址
 *
 *  @return 地址实例
 */
- (AddressEntity *) getUserDefaultAddress;

// ＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝

/**
 *  获取所有收货地址
 *
 *  @param success 成功回调
 *  @param failure 失败回调
 *
 *  @return 网络标识
 */
- (NSURLSessionDataTask *)getAddressList:(void(^)(id responseObject))success
                                         failure:(void(^)(NSString *error))failure;






- (NSURLSessionDataTask *)getAddressListWithUid:(long long)userId
                                        success:(void(^)(id responseObject))success
                                        failure:(void(^)(NSString *error))failure;

/**
 *  添加地址
 *
 *  @param entity  地址实例
 *  @param success 成功回调
 *  @param failure 失败回调
 *
 *  @return 网络标识
 */
- (NSURLSessionDataTask *)addAddress:(AddressEntity *)entity
                                     success:(void (^)(id responseObject))success
                                     failure:(void (^)(NSString *error))failure;

/**
 *  更新地址
 *
 *  @param entity  地址实例
 *  @param success 成功回调
 *  @param failure 失败回调
 *
 *  @return 网络标识
 */
- (NSURLSessionDataTask *)updateAddress:(AddressEntity *)entity
                             success:(void (^)(id responseObject))success
                             failure:(void (^)(NSString *error))failure;

/**
 *  删除地址
 *
 *  @param entity  地址实例
 *  @param success 成功回调
 *  @param failure 失败回调
 *
 *  @return 网络标识
 */
- (NSURLSessionDataTask *)deleteAddress:(AddressEntity *)entity
                             success:(void (^)(id responseObject))success
                             failure:(void (^)(NSString *error))failure;

/**
 *  设置默认地址
 *
 *  @param entity  地址实例
 *  @param success 成功回调
 *  @param failure 失败回调
 *
 *  @return 网络标识
 */
- (NSURLSessionDataTask *)setDefaultAddress:(AddressEntity *)entity
                                success:(void (^)(id responseObject))success
                                failure:(void (^)(NSString *error))failure;


@end
