//
//  CXPhotoLoadingView.m
//  CXPhotoBrowserDemo
//
//  Created by ChrisXu on 13/4/22.
//  Copyright (c) 2013年 ChrisXu. All rights reserved.
//

#import "CXPhotoLoadingView.h"
#import "CXPhotoBrowser.h"
#import "PhotoZooo.h"
#import <QuartzCore/QuartzCore.h>

@interface CXPhotoLoadingView ()
{
    __unsafe_unretained CXPhotoBrowser *_photoBrowser;
    
    UIButton *reloadButton;
    UIButton *closeButton;
    UILabel *failureLabel;
}
@property (nonatomic, assign) CXPhoto *photo;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;

@end

@implementation CXPhotoLoadingView
@synthesize photo = _photo;
@synthesize supportReload = _supportReload;
- (id)initWithPhoto:(CXPhoto *)photo
{
    self = [super init];
    if (self)
    {
        _photo = photo;
        reloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        failureLabel = [[UILabel alloc] init];
    }
    return self;
}
#pragma mark - PV

- (void)displayLoading
{
    [reloadButton removeFromSuperview];
    [failureLabel removeFromSuperview];
    [closeButton removeFromSuperview];
    if (!self.indicator)
    {
        self.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [self.indicator setCenter:self.center];
        [self.indicator setHidesWhenStopped:YES];
        [self addSubview:self.indicator];
    }
    [self.indicator startAnimating];
}

- (void)displayFailure
{
    [self.indicator stopAnimating];
    
    // reloadButton
    
    [reloadButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12.]];
    [reloadButton setTitle:@"重试" forState:UIControlStateNormal];
    [reloadButton setFrame:CGRectMake(20, 10, 150, 35)];
    [reloadButton setCenter:self.center];
    [reloadButton addTarget:self.photo action:@selector(reloadImage) forControlEvents:UIControlEventTouchUpInside];
    [reloadButton.layer setMasksToBounds:YES];
    [reloadButton.layer setCornerRadius:4.0];
    [reloadButton.layer setBorderWidth:1.0];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef colorref = CGColorCreate(colorSpace,(CGFloat[]){ 1, 1, 1, 1 });
    [reloadButton.layer setBorderColor:colorref];
    reloadButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [self addSubview:reloadButton];
    
    [reloadButton setHidden:!_supportReload];
    
    
    // closeButton
    
    [closeButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12.]];
    [closeButton setTitle:@"关闭" forState:UIControlStateNormal];
    [closeButton setFrame:CGRectMake(reloadButton.selfX, reloadButton.selfY + reloadButton.selfH + 25, reloadButton.selfW, reloadButton.selfH)];
    [closeButton addTarget:[PhotoZooo shareInstance] action:@selector(dismissViewControllerAnimated) forControlEvents:UIControlEventTouchUpInside];
    [closeButton.layer setMasksToBounds:YES];
    [closeButton.layer setCornerRadius:4.0];
    [closeButton.layer setBorderWidth:1.0];
    CGColorSpaceRef closeButtoncolorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef closeButtoncolorref = CGColorCreate(closeButtoncolorSpace,(CGFloat[]){ 1, 1, 1, 1 });
    [closeButton.layer setBorderColor:closeButtoncolorref];
    closeButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [self addSubview:closeButton];
    
//    [closeButton setHidden:!_supportReload];
    
    
    [failureLabel setFrame:CGRectMake(CGRectGetMidX(reloadButton.frame) - self.bounds.size.width/2, CGRectGetMinY(reloadButton.frame) - 60, self.bounds.size.width, 44)];
    [failureLabel setNumberOfLines:0.];
    [failureLabel setTextAlignment:NSTextAlignmentCenter];
    [failureLabel setText:NSLocalizedString(@"图片无法加载!",nil)];
    [failureLabel setFont:[UIFont boldSystemFontOfSize:15.]];
    [failureLabel setTextColor:[UIColor whiteColor]];
    [failureLabel setBackgroundColor:[UIColor clearColor]];
    failureLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [self addSubview:failureLabel];
}
@end
