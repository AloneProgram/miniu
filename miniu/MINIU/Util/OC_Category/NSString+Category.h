//
//  NSString+Category.h
//  DLDQ_IOS
//
//  Created by simman on 14-6-14.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Category)
+ (NSString *)timeStamp;
- (NSString *) MD5Hash;
/**
 *  获取首字母
 *
 *  @return
 */
- (NSString *)firstLetter;
+ (NSString *)formatPriceWithPrice:(double)price;

- (NSString *)stringByReplacingEmojiCheatCodesWithUnicode;
- (NSString *)stringByReplacingEmojiUnicodeWithCheatCodes;
+ (BOOL)stringContainsEmoji:(NSString *)string;
+ (NSString *) formatPriceWithFloat:(double)price;
+ (NSString *) formatPriceWithFloatWhenNoFloat:(double)price;
@end
