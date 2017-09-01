//
//  LoginIndexView.h
//  DLDQ_IOS
//
//  Created by simman on 14-8-22.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginIndexView : UIView

/**
 *  返回视图
 *
 *  @return
 */
+ (instancetype)shareXibView;

/**
 *  添加页面按钮的回调
 *
 *  @param registerAction    注册按钮
 *  @param WXLoginAction     微信登录按钮
 *  @param MobileLoginAction 手机号登录按钮
 */
-(void) addButtonActionCallBackWithRegister:(void (^)())registerAction
                              WXLoginAction:(void (^)())WXLoginAction
                          MobileLoginAction:(void (^)())MobileLoginAction;
@end
