//
//  NSDictionary+Category.h
//  DLDQ_IOS
//
//  Created by simman on 14-9-29.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Category)

- (void)safeSetObject:(id)anObject forKey:(NSString *)aKey;

/**
 *  检查 Key 是否存在字典里
 *
 *  @param key key 值
 *
 *  @return  BOOL
 */
- (BOOL) keyIsExits:(NSString *)key;

@end


@interface NSMutableDictionary (Category)

- (void)safeSetObject:(id)anObject forKey:(id <NSCopying>)aKey;

/**
 *  检查 Key 是否存在字典里
 *
 *  @param key key 值
 *
 *  @return  BOOL
 */
- (BOOL) keyIsExits:(NSString *)key;

@end