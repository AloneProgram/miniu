//
//  BrandEntity.m
//  miniu
//
//  Created by SimMan on 4/28/15.
//  Copyright (c) 2015 SimMan. All rights reserved.
//

#import "BrandEntity.h"

@implementation BrandEntity

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.brandTag= @"";
        self.iconUrl = @"";
    }
    return self;
}


@end
