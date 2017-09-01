//
//  ManagerBase.m
//  DLDQ_IOS
//
//  Created by simman on 14-8-29.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import "ManagerBase.h"

@implementation ManagerBase

- (NSMutableDictionary *)mergeDictionWithDicone:(NSDictionary *)one AndDicTwo:(NSDictionary *)two
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:1];
    [dic addEntriesFromDictionary:one];
    [dic addEntriesFromDictionary:two];
    
    return dic;
}

@end
