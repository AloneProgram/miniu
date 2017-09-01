//
//  JKPhotoBrowser.h
//  JKPhotoBrowser
//
//  Created by Jecky on 14/12/29.
//  Copyright (c) 2014年 Jecky. All rights reserved.
// 图片预览

#import <UIKit/UIKit.h>
#import "JKImagePickerController.h"

@class JKPhotoBrowser;

@protocol JKPhotoBrowserDelegate <NSObject>
@optional
- (void)photoBrowser:(JKPhotoBrowser *)photoBrowser didSelectAtIndex:(NSInteger)index;
- (void)photoBrowser:(JKPhotoBrowser *)photoBrowser didDeselectAtIndex:(NSInteger)index;

- (void)photoBrowser:(JKPhotoBrowser *)photoBrowser deleteCalback:(NSArray *)assetsArray;

@end

@interface JKPhotoBrowser : UIView

@property (nonatomic, weak  ) JKImagePickerController *pickerController;
@property (nonatomic, weak  ) id<                              JKPhotoBrowserDelegate  > delegate;
@property (nonatomic, assign) BOOL                    isJkAsset;
@property (nonatomic, strong) NSMutableArray          *assetsArray;
@property (nonatomic, assign) NSInteger               currentPage;

- (void)show:(BOOL)animated;
- (void)hide:(BOOL)animated;

@end
