//
//  LocationManager.m
//  DLDQ_IOS
//
//  Created by simman on 14-9-4.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import "LocationManager.h"

@interface LocationManager() {
    void(^_locationBlock)(CLLocation *);
    void(^_placemarkBlock)(CLPlacemark *);
    void(^_errorBlock)(NSString *);
}

@property (nonatomic, strong) CLLocationManager *currentLocationManager;
//@property (nonatomic, strong) CLLocation *currentLoaction;                  // 当前位置信息(GPS)
//@property (nonatomic, strong) CLPlacemark *currentPlacemark;                // 当前位置，返回是解析后的

@end

@implementation LocationManager

+ (instancetype)shareInstance
{
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (instancetype) init
{
    self = [super init];
    if (self) {
        self.currentLocationManager = [[CLLocationManager alloc] init];
        self.currentLocationManager.delegate = self;
//        [self getCurrentLocation:nil Placemark:nil error:nil];
    }
    return self;
}

- (void)getCurrentLocation:(void (^)(CLLocation *))locationBlock
                 Placemark:(void (^)(CLPlacemark *))placemarkBlock
                     error:(void (^)(NSString *))errorBlock
{
    _locationBlock = locationBlock;
    _placemarkBlock = placemarkBlock;
    _errorBlock = errorBlock;
    
    [self startUpdatingLocation];
}


/**
 *  开始获取位置信息
 */
- (void) startUpdatingLocation
{

    //定位服务是否可用
    BOOL enable=[CLLocationManager locationServicesEnabled];
#ifdef __IPHONE_8_0
    if (IS_IOS8) {
        //是否具有定位权限
        int status=[CLLocationManager authorizationStatus];
        if(!enable || status<3){
            //请求权限
            if (self.currentLocationManager) {
                [self.currentLocationManager requestWhenInUseAuthorization];
            }
        }
    }
#endif
    
    if ( enable ) {
        [self.currentLocationManager startUpdatingLocation];
    } else {
        if (_errorBlock) {
            _errorBlock(@"无法开始定位,请检查定位服务是否开启");
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status >= 3) {
//            _errorBlock(@"无法开始定位,请检查定位服务是否开启");
    } else {
        if (_errorBlock) {
            _errorBlock(@"无法开始定位,请检查定位服务是否开启");
        }
    }
}

/**
 *  获取位置信息的代理方法
 *
 *  @param manager
 *  @param newLocation
 *  @param oldLocation 
 */
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    [self.currentLocationManager stopUpdatingLocation];
    
    if (_locationBlock) {
        _locationBlock(newLocation);
    }
    
//    
//    NSString *strLat = [NSString stringWithFormat:@"%.4f",newLocation.coordinate.latitude];
//    NSString *strLng = [NSString stringWithFormat:@"%.4f",newLocation.coordinate.longitude];
    
    //    // 此处模拟经纬度
    //    float longitude = 116.417492;
    //    float latitude = 39.925338;  //这里可以是任意的经纬度值
    //    CLLocation *location= [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    
    CLGeocoder *clgeo = [[CLGeocoder alloc] init];
    [clgeo reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error == nil && [placemarks count] > 0){
            // CLPlacemark 存储着相应的地址数据
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            if (_placemarkBlock) {
                _placemarkBlock(placemark);
            }
            //            NSLog(@"\n Country = %@ \n", placemark.country);
            //            NSLog(@"\n Locality = %@ \n", placemark.locality);
        }else if (error == nil && [placemarks count] == 0){
//            _errorBlock(@"No results were returned.");
        }else if (error != nil){
            
//            NSLog(@"An error occurred = %@", error);
        }
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
- (void)doLogoutLogic{}
- (void)disconnectNet{}


@end
