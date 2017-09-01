//
//  CXTapDetectingImageView.m
//  CXPhotoBrowserDemo
//
//  Created by ChrisXu on 13/4/23.
//  Copyright (c) 2013年 ChrisXu. All rights reserved.
//

#import "CXTapDetectingImageView.h"

@interface CXTapDetectingImageView () <UIActionSheetDelegate>
{
    CGPoint panGestureStartLocation;
}

- (void)setup;
- (void)longPressGestureAction:(UILongPressGestureRecognizer *)gesture;
@end

@implementation CXTapDetectingImageView

@synthesize tapDelegate;

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
        [self setup];
	}
	return self;
}

- (id)initWithImage:(UIImage *)image {
	if ((self = [super initWithImage:image])) {
        [self setup];
	}
	return self;
}

- (id)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage {
	if ((self = [super initWithImage:image highlightedImage:highlightedImage])) {
        [self setup];
	}
	return self;
}

#pragma mark - 
- (void)setup
{
    self.userInteractionEnabled = YES;
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureAction:)];
    [longPressGesture setNumberOfTouchesRequired:1];
    [longPressGesture setMinimumPressDuration:0.6f];
    [self addGestureRecognizer:longPressGesture];
}

- (void)longPressGestureAction:(UILongPressGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        return;
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"分享给微信好友", @"保存到相册", nil];
        sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        [sheet showInView:self];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {         // 微信好友
        [self weChatShareGoodsImageWithchat];
//    } else if (buttonIndex == 1) {  // 朋友圈
//        [self weChatShareGoodsImageWithchatFriend];
    } else if (buttonIndex == 1) {  // 保存
        [self saveImage];
    }
}

/**
 *  分享到微信
 */
- (void) weChatShareGoodsImageWithchat
{
    @try {
        WXMediaMessage *message = [WXMediaMessage message];
        
        [message setThumbImage:[self.image scaledToSize:CGSizeMake(300, MAXFLOAT)]];
        WXImageObject *ext = [WXImageObject object];
        ext.imageData = UIImageJPEGRepresentation(self.image, 0.3);
        message.mediaObject = ext;
        SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
        req.bText = NO;
        req.message = message;
        req.scene = WXSceneSession;
        [WXApi sendReq:req];
    }
    @catch (NSException *exception) {
        //        [self message:@"分享失败!"];
    }
    @finally {
        //        [self successMessage:@"分享成功!"];
    }
}

/**
 *  分享到微信
 */
- (void) weChatShareGoodsImageWithchatFriend
{
    @try {
        [[logicShareInstance getWeChatManage] weChatShareForFriendsWithImage:self.image title:@"我在米妞等你..." description:nil openURL:@"http://miniu.dldq.org" WithSuccessBlock:^{
           
            [self showStatusBarSuccessStr:@"分享成功!"];
        } errorBlock:^(NSString *error) {
            [self showStatusBarError:@"分享失败!"];
        }];
        
    }
    @catch (NSException *exception) {
        //        [self message:@"分享失败!"];
    }
    @finally {
        //        [self successMessage:@"分享成功!"];
    }
}

/**
 *  保存图片
 */
- (void)saveImage
{
    [[logicShareInstance getAssetManager] saveImage:self.image success:^(NSString *success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showStatusBarSuccessStr:success];
        });
    } failure:^(NSString *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showStatusBarError:error];
        });
    }];
}

- (void)handleSingleTap:(UITouch *)touch {
//    NSLog(@"handleSingleTap");
	if ([tapDelegate respondsToSelector:@selector(imageView:singleTapDetected:)])
		[tapDelegate imageView:self singleTapDetected:touch];
}

- (void)handleDoubleTap:(UITouch *)touch {
//    NSLog(@"handleDoubleTap");
	if ([tapDelegate respondsToSelector:@selector(imageView:doubleTapDetected:)])
		[tapDelegate imageView:self doubleTapDetected:touch];
}

- (void)handleTripleTap:(UITouch *)touch {
//    NSLog(@"handleTripleTap");
	if ([tapDelegate respondsToSelector:@selector(imageView:tripleTapDetected:)])
		[tapDelegate imageView:self tripleTapDetected:touch];
}

#pragma mark - Touched
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	NSUInteger tapCount = touch.tapCount;
	switch (tapCount) {
		case 1:
			[self handleSingleTap:touch];
			break;
		case 2:
			[self handleDoubleTap:touch];
			break;
		case 3:
			[self handleTripleTap:touch];
			break;
		default:
			break;
	}
	[[self nextResponder] touchesEnded:touches withEvent:event];
}


@end
