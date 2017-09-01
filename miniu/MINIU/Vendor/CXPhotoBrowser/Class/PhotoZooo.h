//
//  PhotoZooo.h
//  CXPhotoBrowserDemo
//
//  Created by simman on 15/1/9.
//  Copyright (c) 2015年 ChrisXu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WechatShareEntity;

@protocol PhotoZoooDelegate <NSObject>

/**
 *  @brief  保存图片到本地后的处理
 *
 *  @param image
 */
- (void) savePhoto:(UIImage *)image success:(BOOL)success;

/**
 *  @brief  分享到微信
 *
 *  @return
 */
- (WechatShareEntity *) shareToWechat;

@end

@interface PhotoZooo : NSObject

@property (nonatomic, assign) id<PhotoZoooDelegate> delegate;

// 是否可以保存图片, 默认为 开启
@property (nonatomic, assign) BOOL enableSavePhoto;

// 是否可以分享到微信, 默认开启
@property (nonatomic, assign) BOOL enableShareToWechat;

// 是否可以转发给系统好友, 默认开启
@property (nonatomic, assign) BOOL enableSendToFriend;


#pragma mark method

/**
 *  @brief  单例
 *
 *  @return
 */
+ (instancetype)shareInstance;

/**
 *  @brief  打开图片浏览器
 *
 *  @param imageArray 图片数组（ImageURLs）
 *  @param index      当前第几页
 */
- (void) showImageWithArray:(NSArray *)imageArray setInitialPageIndex:(NSInteger)index withController:(UIViewController *)controller;

/**
 *  @brief  关闭图片浏览器
 */
- (void) dismissViewControllerAnimated;

@end
