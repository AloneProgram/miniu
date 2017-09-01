

//
//  conArea.m
//  DLDQ_IOS
//
//  Created by simman on 14-5-19.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import "conArea.h"

@implementation conArea

// 当没有键值对的时候自动调用此方法抛出异常
- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}

- (void) setNilValueForKey:(NSString *)key{};

- (instancetype) initWitharea_en_name:(NSString *)area_en_name
                            Area_name:(NSString *)area_name
                           Area_index:(NSString *)area_index
                             Area_num:(NSString *)area_num
{
    _area_en_name = area_en_name;
    _area_index = area_index;
    _area_name = area_name;
    _area_num = area_num;
    return self;
}

@end
