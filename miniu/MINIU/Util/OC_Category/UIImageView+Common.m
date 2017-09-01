//
//  UIImageView+Common.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-8.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "UIImageView+Common.h"

@implementation UIImageView (Common)
- (void)doCircleFrame{
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = self.frame.size.width/2;
    self.layer.borderWidth = 0.5;
    self.layer.borderColor = [UIColor colorWithHexString:@"0xdddddd"].CGColor;
}
- (void)doNotCircleFrame{
    self.layer.cornerRadius = 0.0;
    self.layer.borderWidth = 0.0;
}

- (void) doCircleFrameNoBorder
{
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = self.frame.size.width/2;
}

- (void)doBorderWidth:(CGFloat)width color:(UIColor *)color cornerRadius:(CGFloat)cornerRadius{
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = cornerRadius;
    self.layer.borderWidth = width;
    if (!color) {
        self.layer.borderColor = [UIColor colorWithHexString:@"0xdddddd"].CGColor;
    }else{
        self.layer.borderColor = color.CGColor;
    }
}

- (void)setImageWithUrl:(NSString *)url withSize:(ImageSize)imageSize
{
    // 自定义后缀,大小
    NSString *preString;
    
    switch (imageSize) {
        case ImageSizeOf20:
            preString = @"!20";
            break;
        case ImageSizeOf64:
            preString = @"!64";
            break;
        case ImageSizeOf100:
            preString = @"!100";
            break;
        case ImageSizeOf200:
            preString = @"!200";
            break;
        case ImageSizeOf300:
            preString = @"!300";
            break;
        case ImageSizeOf400:
            preString = @"!400";
            break;
        case ImageSizeOf500:
            preString = @"!500";
            break;
        case ImageSizeOf600:
            preString = @"!600";
            break;
        case ImageSizeOf700:
            preString = @"!700";
            break;
        case ImageSizeOf800:
            preString = @"!800";
            break;
        case ImageSizeOf900:
            preString = @"!900";
            break;
        case ImageSizeOf1000:
            preString = @"!1000";
            break;
        case ImageSizeOf1280:
            preString = @"!1280";
            break;
        case ImageSizeOfNone:
            preString = @"";
            break;
        // 如果为 auto 那么启用自适应
        case ImageSizeOfAuto:
        default: {
            [self setImageWithUrl:url withSize:[self autoSize]];
            return;
        }
            break;
    }
    
    // 查找是否有 http ,https, 如果错误则不进行网络请求
    NSRange httprange = [url rangeOfString:@"http://"];
    NSRange httsprange = [url rangeOfString:@"https://"];
    
    if (url && url.length > 0 && (httprange.location != NSNotFound || httsprange.location != NSNotFound)) {
        
        NSString *newURL = [NSString stringWithFormat:@"%@%@", url, preString];
        
//        self.alpha = 0.2;
//        NSLog(@"image_url: %@", newURL);
        
        [self sd_setImageWithURL:[NSURL URLWithString:newURL] placeholderImage:[UIImage imageNamed:@"timeline_img__"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
            /** 不闪屏 2015.09.23
            self.alpha=0.2;
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.5];
            
            
            [self setNeedsDisplay];
            self.alpha = 1;
            [UIView commitAnimations];
            
            [self setNeedsDisplay];
            */
//            [UIView animateWithDuration:0.5 animations:^{
//                self.alpha = 0.8;
//            } completion:^(BOOL finished) {
//                self.alpha = 1.0f;
//            }];
        }];
        
    } else {
        [self setImage:[UIImage imageNamed:@"timeline_img__"]];
    }
}

- (ImageSize) autoSize
{
    CGFloat imageViewWidth = self.bounds.size.width;

    //
    imageViewWidth += 50;
    
    if (imageViewWidth < 70) {
        return ImageSizeOf64;
    } else if (imageViewWidth <= 100) {
        return ImageSizeOf100;
    } else if (imageViewWidth <= 200) {
        return ImageSizeOf200;
    } else if (imageViewWidth <= 300) {
        return ImageSizeOf300;
    } else if (imageViewWidth <= 400) {
        return ImageSizeOf400;
    } else if (imageViewWidth <= 500) {
        return ImageSizeOf500;
    } else if (imageViewWidth <= 600) {
        return ImageSizeOf600;
    } else if (imageViewWidth <= 700) {
        return ImageSizeOf700;
    } else if (imageViewWidth <= 800) {
        return ImageSizeOf800;
    } else if (imageViewWidth <= 900) {
        return ImageSizeOf900;
    } else if (imageViewWidth <= 1000) {
        return ImageSizeOf1000;
    } else if (imageViewWidth > 1000) {
        return ImageSizeOf1280;
    }
    return ImageSizeOf20;
}

@end
