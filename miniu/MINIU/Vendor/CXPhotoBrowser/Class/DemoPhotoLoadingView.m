//
//  DemoPhotoLoadingView.m
//  CXPhotoBrowserDemo
//
//  Created by ChrisXu on 13/4/23.
//  Copyright (c) 2013年 ChrisXu. All rights reserved.
//

#import "DemoPhotoLoadingView.h"

#define LOADING_FAILURE_LABEL 23412

@implementation DemoPhotoLoadingView

- (id)initWithPhoto:(CXPhoto *)photo
{
    self = [super initWithPhoto:photo];
    if (self)
    {
        self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    }
    return self;
}

- (void)displayFailure
{
    [self.progressView removeFromSuperview];
    
    [super displayFailure];
}

- (void)displayLoading
{

}

#pragma mark - customlize method
- (void)loadWithReceivedSize:(NSUInteger)receivedSize expectedSize:(long)expectedSize
{
    @try {
        [self.progressView setFrame:CGRectMake( 0, 0, 200, 20)];
        [self.progressView setCenter:self.center];
        //主线程调用
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self addSubview:self.progressView];
        });
        
        float fReceivedSize = (float)receivedSize;
        float progress = (fReceivedSize  / expectedSize);
        progress += 0.01;
        if (progress != 1)
        {
            [self.progressView setProgress:progress];
        }
        else
        {
            [self.progressView removeFromSuperview];
        }
    }
    @catch (NSException *exception) {}
    @finally {}
}
@end
