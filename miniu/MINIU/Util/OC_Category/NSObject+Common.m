//
//  NSObject+Common.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-7-31.
//  Copyright (c) 2014年 Coding. All rights reserved.
//
#define kPath_ImageCache @"ImageCache"
#define kPath_ResponseCache @"ResponseCache"

#import "NSObject+Common.h"
#import "JDStatusBarNotification.h"
#import "AppDelegate.h"
#import "MBProgressHUD+Add.h"

@implementation NSObject (Common)

#pragma mark Tip M
//- (NSString *)tipFromError:(NSError *)error{
//    if (error && error.userInfo) {
//        NSMutableString *tipStr = [[NSMutableString alloc] init];
//        if ([error.userInfo objectForKey:@"msg"]) {
//            NSArray *msgArray = [[error.userInfo objectForKey:@"msg"] allValues];
//            NSUInteger num = [msgArray count];
//            for (int i = 0; i < num; i++) {
//                NSString *msgStr = [msgArray objectAtIndex:i];
//                if (i+1 < num) {
//                    [tipStr appendString:[NSString stringWithFormat:@"%@\n", msgStr]];
//                }else{
//                    [tipStr appendString:msgStr];
//                }
//            }
//        }else{
//            if ([error.userInfo objectForKey:@"NSLocalizedDescription"]) {
//                tipStr = [error.userInfo objectForKey:@"NSLocalizedDescription"];
//            }else{
//                [tipStr appendFormat:@"ErrorCode%ld", (long)error.code];
//            }
//        }
//        return tipStr;
//    }
//    return nil;
//}

- (void)showHudError:(NSString *)error
{
    if (error && error.length > 0) {
        
        [self endHudLoad];
        
        [MBProgressHUD showError:error toView:kKeyWindow];
    }
}

- (void) showHudSuccess:(NSString *) success
{
    if (success && success.length > 0) {
        
        [self endHudLoad];
        
        [MBProgressHUD showSuccess:success toView:kKeyWindow];
    }
}

- (void) showHudLoad:(NSString *)str
{
    if (str && str.length > 0) {
        
        [self endHudLoad];
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:kKeyWindow animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = str;
        hud.labelFont = [UIFont systemFontOfSize:14];
        hud.minSize = CGSizeMake(100, 80);
        hud.margin = 10.f;
        hud.minShowTime = 1;
        hud.removeFromSuperViewOnHide = YES;
    }
}

- (void) endHudLoad
{
    [MBProgressHUD hideHUDForView:kKeyWindow animated:YES];
}

- (void)showHudTipStr:(NSString *)tipStr{
    if (tipStr && tipStr.length > 0) {
        
        [self endHudLoad];
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:kKeyWindow animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = tipStr;
        hud.margin = 10.f;
        hud.removeFromSuperViewOnHide = YES;
        [hud hide:YES afterDelay:1.0];
    }
}
- (void)showStatusBarQueryStr:(NSString *)tipStr{
    
    [self endHudLoad];
    
    [JDStatusBarNotification showWithStatus:tipStr styleName:JDStatusBarStyleSuccess];
    [JDStatusBarNotification showActivityIndicator:YES indicatorStyle:UIActivityIndicatorViewStyleWhite];
}
- (void)showStatusBarSuccessStr:(NSString *)tipStr{
    
    [self endHudLoad];
    
    if ([JDStatusBarNotification isVisible]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [JDStatusBarNotification showActivityIndicator:NO indicatorStyle:UIActivityIndicatorViewStyleWhite];
            [JDStatusBarNotification showWithStatus:tipStr dismissAfter:1.5 styleName:JDStatusBarStyleSuccess];
        });
    }else{
        [JDStatusBarNotification showActivityIndicator:NO indicatorStyle:UIActivityIndicatorViewStyleWhite];
        [JDStatusBarNotification showWithStatus:tipStr dismissAfter:1.0 styleName:JDStatusBarStyleSuccess];
    }
}
- (void)showStatusBarError:(NSString *)error
{
    [self endHudLoad];
    
    if ([JDStatusBarNotification isVisible]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [JDStatusBarNotification showActivityIndicator:NO indicatorStyle:UIActivityIndicatorViewStyleWhite];
            [JDStatusBarNotification showWithStatus:error dismissAfter:1.5 styleName:JDStatusBarStyleError];
        });
    }else{
        [JDStatusBarNotification showActivityIndicator:NO indicatorStyle:UIActivityIndicatorViewStyleWhite];
        [JDStatusBarNotification showWithStatus:error dismissAfter:1.5 styleName:JDStatusBarStyleError];
    }
}
- (void)showStatusBarProgress:(CGFloat)progress{
    
    [self endHudLoad];
    
    [JDStatusBarNotification showProgress:progress];
}
- (void)hideStatusBarProgress{
    [JDStatusBarNotification showProgress:0.0];
}

#pragma mark File M
//获取fileName的完整地址
+ (NSString* )pathInCacheDirectory:(NSString *)fileName
{
    NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [cachePaths objectAtIndex:0];
    return [cachePath stringByAppendingPathComponent:fileName];
}
//创建缓存文件夹
+ (BOOL) createDirInCache:(NSString *)dirName
{
    NSString *dirPath = [self pathInCacheDirectory:dirName];
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:dirPath isDirectory:&isDir];
    BOOL isCreated = NO;
    if ( !(isDir == YES && existed == YES) )
    {
        isCreated = [fileManager createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if (existed) {
        isCreated = YES;
    }
    return isCreated;
}



// 图片缓存到本地
+ (BOOL) saveImage:(UIImage *)image imageName:(NSString *)imageName inFolder:(NSString *)folderName
{
    if (!folderName) {
        folderName = kPath_ImageCache;
    }
    if ([self createDirInCache:folderName]) {
        NSString * directoryPath = [self pathInCacheDirectory:folderName];
        BOOL isDir = NO;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL existed = [fileManager fileExistsAtPath:directoryPath isDirectory:&isDir];
        bool isSaved = false;
        if ( isDir == YES && existed == YES )
        {
            isSaved = [UIImageJPEGRepresentation(image, 1.0) writeToFile:[directoryPath stringByAppendingPathComponent:imageName] options:NSAtomicWrite error:nil];
        }
        return isSaved;
    }else{
        return NO;
    }
}
// 获取缓存图片
+ (NSData*) loadImageDataWithName:( NSString *)imageName inFolder:(NSString *)folderName
{
    if (!folderName) {
        folderName = kPath_ImageCache;
    }
    NSString * directoryPath = [self pathInCacheDirectory:folderName];
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL dirExisted = [fileManager fileExistsAtPath:directoryPath isDirectory:&isDir];
    if ( isDir == YES && dirExisted == YES )
    {
        NSString *abslutePath = [NSString stringWithFormat:@"%@/%@", directoryPath, imageName];
        BOOL fileExisted = [fileManager fileExistsAtPath:abslutePath];
        if (!fileExisted) {
            return NULL;
        }
        NSData *imageData = [NSData dataWithContentsOfFile : abslutePath];
        return imageData;
    }
    else
    {
        return NULL;
    }
}

// 删除图片缓存
+ (BOOL) deleteImageCacheInFolder:(NSString *)folderName{
    if (!folderName) {
        folderName = kPath_ImageCache;
    }
    return [self deleteCacheWithPath:folderName];
}


+ (BOOL) deleteResponseCache{
    return [self deleteCacheWithPath:kPath_ResponseCache];
}

+ (BOOL) deleteCacheWithPath:(NSString *)cachePath{
    NSString *dirPath = [self pathInCacheDirectory:cachePath];
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:dirPath isDirectory:&isDir];
    bool isDeleted = false;
    if ( isDir == YES && existed == YES )
    {
        isDeleted = [fileManager removeItemAtPath:dirPath error:nil];
    }
    return isDeleted;
}



- (UINavigationController *) getTopNavigationController
{
    id viewcontroller = kKeyWindow.rootViewController;
    
    if ([viewcontroller isKindOfClass:[UINavigationController class]]) {
        return (UINavigationController *)viewcontroller;
    } else if ([viewcontroller isKindOfClass:[REFrostedViewController class]]) {
        REFrostedViewController *REFcontroller = (REFrostedViewController *)viewcontroller;
        UINavigationController *nav = (UINavigationController *)REFcontroller.contentViewController;
        return nav.topViewController.navigationController;
    }
    return nil;
}

- (NSDictionary *) getUrlDictionary:(NSURL *)url
{
    // 验证
    NSString *baseURL = [NSString stringWithFormat:@"%@:%@", [url scheme], [url host]];
    if (![baseURL isEqualToString:@"miniu:api-callback-url"]) {
        return nil;
    }
    
    NSString *urlString = [url query];
    
    NSArray *urlArray = [urlString componentsSeparatedByString:@"&"];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    
    if ([urlArray count] == 2) {
        
        NSArray *p = [urlArray[0] componentsSeparatedByString:@"="];
        [params setObject:[NSString stringWithFormat:@"%@", p[1]] forKey:@"name"];
        
        NSArray *p1 = [urlArray[1] componentsSeparatedByString:@"="];
        
        [params setObject:[NSString stringWithFormat:@"%@", p1[1]] forKey:@"v"];
        
        return params;
    }
    return nil;
}


@end
