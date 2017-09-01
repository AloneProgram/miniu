//
//  UserReNameViewController.h
//  DLDQ_IOS
//
//  Created by simman on 14-6-12.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface UserReNameViewController : BaseViewController <UITextFieldDelegate>

/**
 *  设置数据
 *
 *  @param placeholder  提示
 *  @param defaultValue 默认
 *  @param maxlenght    最大长度
 *  @param minLenght    最小长度
 *  @param tipString    提示（下方）
 *  @param title        nav标题
 *  @param saveAction   保存按钮的回调
 */
- (void) setDataWithPlaceholder:(NSString *)placeholder
                   defaultValue:(NSString *)defaultValue
                      maxLenght:(NSInteger )maxlenght
                      minLenght:(NSInteger)minLenght
                      tipString:(NSString *)tipString
                       NavTitle:(NSString *)title
                   keyBoardType:(UIKeyboardType)keyType
                     saveAction:(void (^)(NSString *string))saveAction;



@end
