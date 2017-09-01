//
//  NSMutableArray+BaseNavigationController.m
//  miniu
//
//  Created by SimMan on 15/5/28.
//  Copyright (c) 2015年 SimMan. All rights reserved.
//

#import "NSMutableArray+BaseNavigationController.h"

@implementation NSMutableArray (BaseNavigationController)

- (void)gf_removeObjectsFromIndex:(NSUInteger)index
{
    
    if (self.count > index) {
        NSMutableArray *deletedArray = [NSMutableArray array];
        
        for (NSUInteger startIndex = index + 1; startIndex < self.count; startIndex++) {
            [deletedArray addObject:[self objectAtIndex:startIndex]];
        }
        
        [self removeObjectsInArray:deletedArray];
    }
}

@end
