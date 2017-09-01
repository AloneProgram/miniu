//
//  NSDictionary+Category.m
//  DLDQ_IOS
//
//  Created by simman on 14-9-29.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import "NSDictionary+Category.h"

@implementation NSDictionary (Category)

- (void)safeSetObject:(id)anObject forKey:(NSString *)aKey
{
    if (anObject == nil) {
        if ([anObject isKindOfClass:[NSString class]]) {
            anObject = @"";
        } else if ([anObject isKindOfClass:[NSNumber class]]) {
            anObject = [NSNumber numberWithInteger:0];
        }
    }
    
    if (anObject == nil) {
        [self setValue:anObject forKey:aKey];
    }
}

- (BOOL)keyIsExits:(NSString *)key
{
    if (!key) {
        return NO;
    }
    NSArray *keyArray = [self allKeys];
    if ([keyArray containsObject:key]) {
        return YES;
    }
    return NO;
}

@end




@implementation NSMutableDictionary (Category)

- (void)safeSetObject:(id)anObject forKey:(id<NSCopying>)aKey
{
    if (anObject == nil) {
        if ([anObject isKindOfClass:[NSString class]]) {
            anObject = @"";
        } else if ([anObject isKindOfClass:[NSNumber class]]) {
            anObject = [NSNumber numberWithInteger:0];
        }
    }
    
    if (anObject != nil) {
        [self setObject:anObject forKey:aKey];
    }
}

- (BOOL)keyIsExits:(NSString *)key
{
    if (!key) {
        return NO;
    }
    NSArray *keyArray = [self allKeys];
    if ([keyArray containsObject:key]) {
        return YES;
    }
    return NO;
}

@end