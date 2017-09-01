//
//  SMActionSheet.h
//  SMActionSheet
//
//  Created by SimMan on 15/7/11.
//  Copyright (c) 2015年 SimMan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SMActionSheet : UIView


/**
 *  @brief  返回一个ActionSheet对象, 实例方法，并使用block回调，会自动调用 show方法
 *
 *  @param title        提示标题
 *  @param titles      所有按钮的标题
 *  @param buttonIndex 红色按钮的index
 *  @param block
 *
 *  @return
 */
+ (id)showSheetWithTitle:(NSString *)title
            buttonTitles:(NSArray *)titles
          redButtonIndex:(NSInteger)buttonIndex
         completionBlock:(void (^)(NSUInteger buttonIndex, SMActionSheet *actionSheet))block;

@end
