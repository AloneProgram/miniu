//
//  LogicBaseModel.h
//  DLDQ_IOS
//
//  Created by simman on 14-7-6.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import <Foundation/Foundation.h>

// logic层统一管理协议， 用于对所有模块统一管理， 每一个logic模块都必须遵守此协议
@protocol LogicBaseModel <NSObject>

@required

/**
 *	@brief	程序启动时调用:统一加载
 */
- (void)load;

/**
 *	@brief	模块加载用户数据,模块需根据userId加载相关信息
 *          [注意:]此方法在点击登录时调用，而不是等待登录成功后调用.
 *          此方法在自动登录时调用，而不是等待自动登录成功后调用.
 */
- (void)loadUserData;

/**
 *	@brief	统一存储
 */
- (void)save;

/**
 *	@brief	重置模块数据
 *          [注意:]此方法在点击失败时会调用
 */
- (void)reset;

/*
 *  @brief  前台进入后台
 */
- (void)enterBackgroundMode;

/*
 *  @brief  从后台进入前台
 */
- (void)enterForeground;

/*
 *  @brief  处理登录成功后逻辑
 */
- (void)doLoginSuccessfulLogic;

/*
 *  @brief  处理注销逻辑
 */
- (void)doLogoutLogic;

/**
 *	@brief	网络断开
 */
- (void)disconnectNet;

/**
 *  @brief  主要的UI已经加载完毕
 */
- (void)uiDidAppear;

///**
// *  重连网络
// */
//- (void) reConnectNetWork;

@end
