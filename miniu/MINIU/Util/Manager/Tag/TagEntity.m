//
//  TagEntity.m
//  DLDQ_IOS
//
//  Created by simman on 14-9-2.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import "TagEntity.h"

@implementation TagEntity

- (instancetype) init
{
    self = [super init];
    if (self) {
        self.value = @"";
        self.status = [NSNumber numberWithInt:0];
    }
    return self;
}

- (void) setValue:(id)value forUndefinedKey:(NSString *)key{};
- (void) setNilValueForKey:(NSString *)key{};

@end
