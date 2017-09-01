//
//  AppDelegate.h
//  miniu
//
//  Created by SimMan on 4/13/15.
//  Copyright (c) 2015 SimMan. All rights reserved.
//

#import <UIKit/UIKit.h>

#include "REFrostedViewController.h"
#import "RDVTabBarController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

#if TARGET_IS_MINIU_BUYER
@property (nonatomic, strong) RDVTabBarController *tabBarController;

#endif

@property (nonatomic, strong) REFrostedViewController *frostedViewController;

@property  bool isTalking;//标志位是否在聊天界面
- (void) changeToChatView;
- (void) changeToLoginView;
- (void) changeRootViewController;

@end

