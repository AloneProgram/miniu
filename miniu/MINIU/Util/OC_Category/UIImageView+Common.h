//
//  UIImageView+Common.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-8.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ImageSize) {
    ImageSizeOf20,
    ImageSizeOf64,
    ImageSizeOf100,
    ImageSizeOf200,
    ImageSizeOf300,
    ImageSizeOf400,
    ImageSizeOf500,
    ImageSizeOf600,
    ImageSizeOf700,
    ImageSizeOf800,
    ImageSizeOf900,
    ImageSizeOf1000,
    ImageSizeOf1280,
    ImageSizeOfAuto,
    ImageSizeOfNone
};

@interface UIImageView (Common)
- (void)doCircleFrame;
- (void)doNotCircleFrame;
- (void) doCircleFrameNoBorder;
- (void)doBorderWidth:(CGFloat)width color:(UIColor *)color cornerRadius:(CGFloat)cornerRadius;

/**
 *  @brief  使用SDW加载图片
 *
 *  @param url       图片地址,字符串
 *  @param imageSize 图片尺寸,auto为根据当前ImageView的尺寸自动适应.
 */
- (void) setImageWithUrl:(NSString *)url withSize:(ImageSize)imageSize;

@end
