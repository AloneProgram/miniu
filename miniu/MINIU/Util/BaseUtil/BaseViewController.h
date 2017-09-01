//
//  BaseViewController.h
//  miniu
//
//  Created by SimMan on 4/16/15.
//  Copyright (c) 2015 SimMan. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NetWorkHandle.h"
#import "AppDelegate.h"
#import "UIViewController+TAPKeyboardPop.h"

typedef NS_ENUM(NSInteger, CHANGE_VIEWCONTROLLER_TYPE) {
    PUSH,
    MODAL,
    ADPUSH//lzj add for ad push with share button
};

@class AppDelegate;

@interface BaseViewController : UIViewController

@property (nonatomic, retain) NSMutableArray *currentRequest;   // 当前的网络请求数组

@property (nonatomic, strong) BaseNavigationController *navigationController;

/**
 *  全局的代理实例
 *
 *  @return
 */
-(AppDelegate *)mainDelegate;

#pragma mark - 导航

/**
 *  设置导航标题
 *
 *  @param title
 */
- (void) setNavTitle:(NSString *)title;


#pragma mark - 网络

/**
 *  取消当前页面的网络请求
 */
- (void) cancelCurrentNetWorkRequest;

#pragma mark - 手势相关

/**
 *  隐藏键盘
 *
 *  @param action
 */
- (void)Hidden_Keyboard_With_GestureAction:(void (^)())action;

#pragma mark - Queue

/**
 *  后台线程执行
 *
 *  @param block
 */
- (void) asyncBackgroundQueue:(void (^)())block;

/**
 *  主线程执行
 *
 *  @param block
 */
- (void) asyncMainQueue:(void (^)())block;

/**
 *  @brief  设置是否需要使用手势返回  默认为：YES
 */
- (void)setNeedGesturePop:(BOOL)needGesturePop;

/**
 *  打开一个网页
 *
 *  @param url  URL 地址
 *  @param type 推出类型
 */
- (void) openUrlOnWebViewWithURL:(NSURL *)url type:(CHANGE_VIEWCONTROLLER_TYPE)type;

@end