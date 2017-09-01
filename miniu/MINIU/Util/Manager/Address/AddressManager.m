//
//  AddressManager.m
//  DLDQ_IOS
//
//  Created by simman on 14-9-2.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import "AddressManager.h"
#import "AddressEntity.h"

#define API_ADDRESS_LIST    @{@"method":     @"user.address.list"}
#define API_ADDRESS_ADD     @{@"method":     @"user.address.add"}//添加地址
#define API_ADDRESS_UPDATE  @{@"method":     @"user.address.update"}
#define API_ADDRESS_DELETE  @{@"method":     @"user.address.del"}
#define API_ADDRESS_SETDEFAULT  @{@"method": @"user.address.toDefault"}

#define USER_DEFAULT_ADDRES_NAME    @"5b5c5de1c04a647e942b54bbe50d6e87"

@interface AddressManager()
@property (nonatomic, strong) AddressEntity *defaultAddress;
@end
@implementation AddressManager

+ (instancetype)shareInstance
{
    static AddressManager * instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype) init
{
    self = [super init];
    if (self) {
        [[TMCache sharedCache].diskCache objectForKey:USER_DEFAULT_ADDRES_NAME block:^(TMDiskCache *cache, NSString *key, id<NSCoding> object, NSURL *fileURL) {
            self.defaultAddress = (AddressEntity *)object;
        }];
    }
    return self;
}

#pragma mark - 本地存储默认地址
- (void) setUserDefaultAddress:(AddressEntity *)entity
{
    [[TMCache sharedCache].diskCache setObject:entity forKey:USER_DEFAULT_ADDRES_NAME block:^(TMDiskCache *cache, NSString *key, id<NSCoding> object, NSURL *fileURL) {
        self.defaultAddress = (AddressEntity *)object;
    }];
}
#pragma mark - 获取本地的默认地址
- (AddressEntity *) getUserDefaultAddress
{
    return self.defaultAddress;
}

#pragma mark - 网络处理  ----
#pragma mark 获取地址
- (NSURLSessionDataTask *)getAddressList:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    NSDictionary *parameters = API_ADDRESS_LIST;
    return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSString *error) {
        failure(error);
    }];
}

- (NSURLSessionDataTask *)getAddressListWithUid:(long long)userId success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    NSDictionary *parameters = [self mergeDictionWithDicone:API_ADDRESS_LIST AndDicTwo:@{@"userId": [NSString stringWithFormat:@"%lld", userId]}];
    
    return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSString *error) {
        failure(error);
    }];
}

#pragma mark 增加地址
- (NSURLSessionDataTask *)addAddress:(AddressEntity *)entity success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    NSDictionary *parameters = [self mergeDictionWithDicone:API_ADDRESS_ADD AndDicTwo:[entity toDictionary]];
    return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSString *error) {
        failure(error);
    }];
}
#pragma mark 修改地址
- (NSURLSessionDataTask *)updateAddress:(AddressEntity *)entity success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    NSDictionary *parameters = [self mergeDictionWithDicone:API_ADDRESS_UPDATE AndDicTwo:[entity toDictionary]];
    return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSString *error) {
        failure(error);
    }];
}
#pragma mark 删除地址
- (NSURLSessionDataTask *)deleteAddress:(AddressEntity *)entity success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    NSDictionary *parameters = [self mergeDictionWithDicone:API_ADDRESS_DELETE AndDicTwo:[entity toDictionary]];
    return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSString *error) {
        failure(error);
    }];
}

#pragma mark 设置默认地址
- (NSURLSessionDataTask *)setDefaultAddress:(AddressEntity *)entity success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    NSDictionary *parameters = [self mergeDictionWithDicone:API_ADDRESS_SETDEFAULT AndDicTwo:[entity toDictionary]];
    return [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSString *error) {
        failure(error);
    }];
}

#pragma mark
#pragma mark logic层统一管理协议方法
- (void)load{}
- (void)loadUserData{}
- (void)save{}
- (void)reset{}
- (void)enterBackgroundMode{}
- (void)enterForeground{}
- (void)doLoginSuccessfulLogic{}
- (void)doLogoutLogic
{
    [[TMCache sharedCache] removeObjectForKey:USER_DEFAULT_ADDRES_NAME];
}
- (void)disconnectNet{}

@end
