//
//  ShowMenuView.h
//  miniu
//
//  Created by SimMan on 4/23/15.
//  Copyright (c) 2015 SimMan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HomeTableViewCell;

@protocol ShowMenuViewDelegate <NSObject>

/**
 *  @brief ShowMenuView代理方法,按钮被点击
 *
 *  @param selected 是否选中
 */
- (void) favoriteButtonAction:(BOOL)selected object:(HomeTableViewCell *)cell;

/**
 *  @brief  买买买按钮被点击
 */
- (void) buyButtonOnClickobject:(HomeTableViewCell *)cell;

@end

@interface ShowMenuView : UIView

/**
 *  @brief  单例
 *
 *  @return 
 */
+ (instancetype)shareInstance;

/**
 *  @brief  代理
 */
@property (nonatomic, assign) id<ShowMenuViewDelegate> delegate;

/**
 *  @brief  显示MenuView
 *
 *  @param view      显示在那个View上
 *  @param favorited 收藏按钮是否被选中
 */
+ (void) showViewIn:(UIView *)view withObject:(HomeTableViewCell *)cell;

/**
 *  @brief  隐藏View
 */
+ (void) hidden;

@end
