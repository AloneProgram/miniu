//
//  PhotoZooo.m
//  CXPhotoBrowserDemo
//
//  Created by simman on 15/1/9.
//  Copyright (c) 2015年 ChrisXu. All rights reserved.
//

#import "PhotoZooo.h"

#import "CXPhotoBrowser.h"
#import "DemoPhoto.h"
#import "SDImageCache.h"
#import <QuartzCore/QuartzCore.h>
#import "WXApi.h"
#import "ChatViewController.h"

typedef NS_ENUM(NSUInteger, ACTIONSHEET_TAG) {
    ACTIONSHEET_TAG_ALBUM = 100,
    ACTIONSHEET_TAG_WECHAT_F,
    ACTIONSHEET_TAG_WECHAT_Q,
    ACTIONSHEET_TAG_SEND_MESSAGE
};

@interface PhotoZooo()<CXPhotoBrowserDataSource, CXPhotoBrowserDelegate, UIActionSheetDelegate>
{
    CXBrowserNavBarView *navBarView;
    CXBrowserToolBarView *toolBarView;
}

@property (nonatomic, strong) NSMutableArray *imageURLS;
@property (nonatomic, strong) CXPhotoBrowser *browser;
@property (nonatomic, strong) NSMutableArray *photoDataSource;
@property (nonatomic, strong) UIViewController *controller;

@end

@implementation PhotoZooo

+ (instancetype)shareInstance
{
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _enableSavePhoto = YES;
        _enableSendToFriend = YES;
        _enableShareToWechat = YES;
    }
    return self;
}

- (NSMutableArray *)imageURLS
{
    if (!_imageURLS) {
        _imageURLS = [NSMutableArray arrayWithCapacity:1];
    }
    return _imageURLS;
}

- (NSMutableArray *)photoDataSource
{
    if (!_photoDataSource) {
        _photoDataSource = [NSMutableArray arrayWithCapacity:1];
    }
    return _photoDataSource;
}


- (void) setUp
{
    self.browser = [[CXPhotoBrowser alloc] initWithDataSource:self delegate:self];
//    self.browser.wantsFullScreenLayout = NO;
    [self.photoDataSource removeAllObjects];
    
    for (int i = 0; i < [_imageURLS count]; i++)
    {
        DemoPhoto *photo;
        if ([[_imageURLS objectAtIndex:i] rangeOfString:@"http"].location != NSNotFound) {
            NSURL *imgURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@!1280", [_imageURLS objectAtIndex:i]]];
            photo = [[DemoPhoto alloc] initWithURL:imgURL];
        } else {
            photo = [[DemoPhoto alloc] initWithFilePath:[_imageURLS objectAtIndex:i]];
        }
        [self.photoDataSource addObject:photo];
    }
}

#pragma mark - CXPhotoBrowserDataSource
- (NSUInteger)numberOfPhotosInPhotoBrowser:(CXPhotoBrowser *)photoBrowser
{
    return [self.photoDataSource count];
}
- (id <CXPhotoProtocol>)photoBrowser:(CXPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index
{
    if (index < self.photoDataSource.count)
        return [self.photoDataSource objectAtIndex:index];
    return nil;
}

- (CXBrowserNavBarView *)browserNavigationBarViewOfOfPhotoBrowser:(CXPhotoBrowser *)photoBrowser withSize:(CGSize)size
{
    CGRect frame;
    frame.origin = CGPointZero;
    frame.size = size;
    if (!navBarView)
    {
        navBarView = [[CXBrowserNavBarView alloc] initWithFrame:frame];
        
        [navBarView setBackgroundColor:[UIColor clearColor]];
        
        UIView *bkgView = [[UIView alloc] initWithFrame:CGRectMake( 0, 0, size.width, size.height)];
        [bkgView setBackgroundColor:[UIColor clearColor]];
        bkgView.alpha = 0.2;
        bkgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [navBarView addSubview:bkgView];
        
//        UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [doneButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12.]];
//        [doneButton setTitle:@"关闭" forState:UIControlStateNormal];
//        [doneButton setFrame:CGRectMake(size.width - 60, 20, 50, 30)];
//        [doneButton addTarget:self action:@selector(dismissViewControllerAnimated) forControlEvents:UIControlEventTouchUpInside];
//        [doneButton.layer setMasksToBounds:YES];
//        [doneButton.layer setCornerRadius:4.0];
//        [doneButton.layer setBorderWidth:1.0];
//        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//        CGColorRef colorref = CGColorCreate(colorSpace,(CGFloat[]){ 1, 1, 1, 1 });
//        [doneButton.layer setBorderColor:colorref];
//        doneButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
//        [navBarView addSubview:doneButton];
    }
    
    return navBarView;
}

- (CXBrowserToolBarView *)browserToolBarViewOfPhotoBrowser:(CXPhotoBrowser *)photoBrowser withSize:(CGSize)size
{
    CGRect frame;
    frame.origin = CGPointZero;
    frame.size = size;
    
    if (!toolBarView)
    {
        toolBarView = [[CXBrowserToolBarView alloc] initWithFrame:frame];
        [toolBarView setBackgroundColor:[UIColor clearColor]];
        
        UIPageControl *_pageControl = [[UIPageControl alloc] init];
        _pageControl.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        _pageControl.numberOfPages = [self.photoDataSource count];
        _pageControl.tag = 199999;
        _pageControl.hidesForSinglePage = YES;
        _pageControl.backgroundColor = [UIColor blackColor];
        _pageControl.center = CGPointMake(toolBarView.frame.size.width/2, toolBarView.frame.size.height/2);
        
        CGRect pageControlFrame = _pageControl.frame;
        pageControlFrame.origin.y += 15;
        _pageControl.frame = pageControlFrame;
        
        [toolBarView addSubview:_pageControl];
        
        
        // actionButton

        if (_enableSavePhoto || _enableSendToFriend || _enableShareToWechat) {
            WeakSelf
            
            UIButton *actionButton = [[UIButton alloc] initWithFrame:CGRectZero];
            
            actionButton.center = CGPointMake(toolBarView.frame.size.width/2, toolBarView.frame.size.height/2);
            
            actionButton.frame = CGRectMake(kScreen_Width - 55,actionButton.selfY, 35, 35);
            
            [actionButton bk_addEventHandler:^(id sender) {
                [weakSelf_SC actionButtonItem];
            } forControlEvents:UIControlEventTouchUpInside];
            
            [actionButton setBackgroundImage:[UIImage imageNamed:@"预览页-转发"] forState:UIControlStateNormal];
            
            
            [toolBarView addSubview:actionButton];
        }
    }
    return toolBarView;
}

#pragma mark ACTION_BUTTON_ITEM_METHOD
- (void) actionButtonItem
{
    WeakSelf
    [SMActionSheet showSheetWithTitle:@"请选择" buttonTitles:@[@"发送给米妞", @"发送给微信好友", @"分享到朋友圈", @"保存到相册"] redButtonIndex:4 completionBlock:^(NSUInteger buttonIndex, SMActionSheet *actionSheet) {
        switch (buttonIndex) {
            case 0: {
                [weakSelf_SC sendToMiniuAction];
            }
                break;
            case 1: {
                [weakSelf_SC shareToWechatAction];
            }
                break;
            case 2: {
                [weakSelf_SC shareToWechatFriendAction];
            }
                break;
            case 3: {
                [weakSelf_SC saveAlbumAction];
            }
                break;
            default:
                break;
        }
        
    }];
//    if (IS_IOS8 && !IS_IPAD) {
//        
//        WeakSelf
//        
//        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
//        
//        if (_enableSendToFriend) {
//            [alertController addAction:[UIAlertAction actionWithTitle:@"发送给米妞" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//                [weakSelf_SC sendToMiniuAction];
//            }]];
//        }
//        
//        [alertController addAction:[UIAlertAction actionWithTitle:@"发送给微信好友" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//            [weakSelf_SC shareToWechatAction];
//        }]];
//        
//        [alertController addAction:[UIAlertAction actionWithTitle:@"分享到朋友圈" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//            [weakSelf_SC shareToWechatFriendAction];
//        }]];
//        
//        [alertController addAction:[UIAlertAction actionWithTitle:@"保存到相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//            [weakSelf_SC saveAlbumAction];
//        }]];
//        
//        [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
//            
//        }]];
//
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.browser presentViewController:alertController animated:YES completion:nil];
//        });
//        
//    } else {
//        
//        if (_enableSendToFriend) {
//            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"发送给微信好友", @"分享到朋友圈", @"保存到相册", nil];
//            [actionSheet showInView:self.browser.view];
//        } else {
//            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"发送给微信好友", @"分享到朋友圈", @"保存到相册", nil];
//            [actionSheet showInView:self.browser.view];
//        }
//    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];

//    if (buttonTitle && [buttonTitle isEqualToString:@"发送给米妞"]) {
//        
//        [self dismissViewControllerAnimated];
//        
//        [self sendToMiniuAction];        
//    }
    
    if (buttonTitle && [buttonTitle isEqualToString:@"发送给微信好友"]) {
        [self shareToWechatAction];
    }
    
    if (buttonTitle && [buttonTitle isEqualToString:@"分享到朋友圈"]) {
        [self shareToWechatFriendAction];
    }
    
    if (buttonTitle && [buttonTitle isEqualToString:@"保存到相册"]) {
        [self saveAlbumAction];
    }
}

- (void) sendToMiniuAction
{
    if (IS_IOS8) {
        DemoPhoto *photo = [self.photoDataSource objectAtIndex:[_browser currentPageIndex]];
        [[ChatViewController shareInstance] setWillSendImage:photo.underlyingImage];
        [GETMAINDELEGATE changeToChatView];
    }
}

- (void) shareToWechatAction
{
    DemoPhoto *photo = [self.photoDataSource objectAtIndex:[_browser currentPageIndex]];
    WeakSelf
    [[logicShareInstance getWeChatManage] sendImageToWechat:nil imageData:photo.underlyingImage scene:WXShareSceneSession WithSuccessBlock:^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf_SC showHudSuccess:@"分享成功!"];
        });
        
    } errorBlock:^(NSString *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf_SC showHudError:error];
        });
    }];
}

- (void) shareToWechatFriendAction
{
    DemoPhoto *photo = [self.photoDataSource objectAtIndex:[_browser currentPageIndex]];
    WeakSelf
    [[logicShareInstance getWeChatManage] sendImageToWechat:photo.imageUrl imageData:photo.underlyingImage scene:WXShareSceneTimeline WithSuccessBlock:^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf_SC showHudSuccess:@"分享成功!"];
        });
        
    } errorBlock:^(NSString *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf_SC showHudError:error];
        });
    }];
}

- (void) saveAlbumAction
{
    DemoPhoto *photo = [self.photoDataSource objectAtIndex:[_browser currentPageIndex]];
    WeakSelf
    [[logicShareInstance getAssetManager] saveImage:photo.underlyingImage success:^(NSString *success) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf_SC showHudSuccess:success];
        });
        
        if (weakSelf_SC.delegate && [weakSelf_SC.delegate respondsToSelector:@selector(savePhoto:success:)]) {
            [weakSelf_SC.delegate savePhoto:photo.underlyingImage success:YES];
        }
    } failure:^(NSString *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf_SC showHudError:error];
        });
        
        if (weakSelf_SC.delegate && [weakSelf_SC.delegate respondsToSelector:@selector(savePhoto:success:)]) {
            [weakSelf_SC.delegate savePhoto:photo.underlyingImage success:NO];
        }
    }];
}


#pragma mark - CXPhotoBrowserDelegate
- (void)photoBrowser:(CXPhotoBrowser *)photoBrowser didChangedToPageAtIndex:(NSUInteger)index
{
    UIPageControl *pageControl = (UIPageControl *)[toolBarView viewWithTag:199999];
    
    if (pageControl)
    {
        pageControl.currentPage = index;
    }
}


#pragma mark - 打开图片显示器
- (void)showImageWithArray:(NSArray *)imageArray setInitialPageIndex:(NSInteger)index withController:(UIViewController *)controller
{
    self.controller = controller ? controller : kKeyWindow.rootViewController;
    
    [self.imageURLS removeAllObjects];
    [self.imageURLS setArray:imageArray];
    [self setUp];
    
    [self.browser setInitialPageIndex:index];
    
    //self.browser 2015.09.23 点击背景取消展示
    [self.browser.view addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissViewControllerAnimated)]];
    
    self.browser.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [controller presentViewController:self.browser animated:YES completion:nil];
}

- (void) dismissViewControllerAnimated
{
    WeakSelf
    [self.controller dismissViewControllerAnimated:YES completion:^{
        [weakSelf_SC.imageURLS removeAllObjects];
        [weakSelf_SC.photoDataSource removeAllObjects];
        weakSelf_SC.browser = nil;
        toolBarView = nil;
        navBarView = nil;
        weakSelf_SC.enableSendToFriend = YES;
    }];
}

- (BOOL)supportReload
{
    return YES;
}

@end
