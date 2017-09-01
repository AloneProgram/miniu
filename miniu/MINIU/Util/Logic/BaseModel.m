//
//  BaseModel.m
//  DLDQ_IOS
//
//  Created by simman on 14/12/10.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import "BaseModel.h"

@implementation BaseModel


- (void) setNilValueForKey:(NSString *)key{};
- (void) setValue:(id)value forUndefinedKey:(NSString *)key{}
- (void) setValue:(id)value forKey:(NSString *)key
{
    @try {
        [super setValue:value forKey:key];
    }
    @catch (NSException *exception) {
        NSLog(@"当前 model 发生错误，error：key = %@, value = %@", key, value);
    }
    @finally {}
}

@end
