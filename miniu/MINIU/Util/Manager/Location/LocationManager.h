//
//  LocationManager.h
//  DLDQ_IOS
//
//  Created by simman on 14-9-4.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationManager : ManagerBase <LogicBaseModel, CLLocationManagerDelegate>


/**
 *  管理对象单例
 *
 *  @return
 */
+ (instancetype)shareInstance;

/**
 *  获取当前位置信息
 *
 *  @param locationBlock  GPS信息
 *  @param placemarkBlock 解析后的地址
 *  @param errorBlock     错误信息
 */
- (void) getCurrentLocation:(void (^)(CLLocation *location))locationBlock
                  Placemark:(void (^)(CLPlacemark *placemark))placemarkBlock
                      error:(void (^)(NSString *error))errorBlock;
@end
