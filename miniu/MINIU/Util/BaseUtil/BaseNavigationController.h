//
//  BaseNavigationController.h
//  miniu
//
//  Created by SimMan on 15/5/28.
//  Copyright (c) 2015年 SimMan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseNavigationController : UINavigationController

//defaul YE
@property (nonatomic, assign) BOOL dragEnable;

//default is 0.3
@property (nonatomic, assign) NSTimeInterval animationDuration;

@property (nonatomic, assign) CGFloat startX;

@property (nonatomic, assign, getter = isTransitionInProcess) BOOL transitionInProcess;

//default NO (>= iOS7)
@property (nonatomic, assign) BOOL interactivePopGestureRecognizerEnabled;



- (void) chatToolBarHidden;
- (void) chatToolBarShow;

- (void)showMenu;

@end
