//
//  ChatToolBar.m
//  miniu
//
//  Created by SimMan on 15/5/26.
//  Copyright (c) 2015年 SimMan. All rights reserved.
//

#import "ChatToolBar.h"
#import "UIBarButtonItem+Badge.h"

@interface ChatToolBar()

@property (nonatomic, strong) UIToolbar       *toolBar;
@property (nonatomic, strong) UIBarButtonItem *chatButtonItem;

@end

@implementation ChatToolBar

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
        [[logicShareInstance getEasemobManage] setDelegate:self];
        
        [self addSubview:self.toolBar];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self setY:self.superview.frame.size.height - 44];
}


- (UIToolbar *)toolBar
{
    if (!_toolBar) {
        
        _toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 44)];
        
        UIImage *chatBtnimage = [[UIImage imageNamed:@"找米妞私聊"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIButton *chatButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, chatBtnimage.size.width, chatBtnimage.size.height)];
        [chatButton setBackgroundImage:chatBtnimage forState:UIControlStateNormal];
        [chatButton addTarget:self action:@selector(sendMessage:) forControlEvents:UIControlEventTouchUpInside];
        _chatButtonItem = [[UIBarButtonItem alloc] initWithCustomView:chatButton];
        _chatButtonItem.target = self;
       // _chatButtonItem.action = @selector(sendMessage);
        _chatButtonItem.badgeOriginX -= 150;
        _chatButtonItem.badgeOriginY += 10;
        _chatButtonItem.shouldAnimateBadge = YES;
        _chatButtonItem.shouldHideBadgeAtZero = YES;
        UIBarButtonItem *fix = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        _toolBar.translucent = YES;
        [_toolBar setItems:@[fix,fix, _chatButtonItem, fix, fix] animated:YES];
        
        UITapGestureRecognizer *singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sendMessage:)];
        
        [_toolBar addGestureRecognizer:singleRecognizer];
    }
    return _toolBar;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{

}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    if (point.y >= 0) {
        return YES;
    }
    return NO;
}

#pragma mark 发送消息
- (void) sendMessage: (UIToolbar*)sender
{
    [MAIN_DELEGATE changeToChatView];
}

#pragma mark 消息发生变化
- (void) messageDidUnreadMessagesCountChanged:(NSUInteger)unreadNum
{
    _chatButtonItem.badgeValue = [NSString stringWithFormat:@"%lu", (unsigned long)[[EasemobManage shareInstance]getAllUnreadNum]];
//    [[EasemobManage shareInstance]getAllUnreadNum];
    
}

#pragma mark 手动更新数量
- (void) updateBadge
{
    NSLog(@"&&&&&&&&&&&& %ld",(unsigned long)[[ChatViewController shareInstance].conversation unreadMessagesCount]);
    
    _chatButtonItem.badgeValue = [NSString stringWithFormat:@"%lu", (unsigned long)[[ChatViewController shareInstance].conversation unreadMessagesCount]];
    ;
//    _chatButtonItem.badgeValue = @"0";
    
    if ([_chatButtonItem.badgeValue isEqual:@"0"]) {
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];

    }
//    _chatButtonItem.badgeValue = @"";
}


- (void) hidden
{
    [UIView animateWithDuration:0.5f animations:^{
        [self setY:self.superview.frame.size.height + 45];
    } completion:^(BOOL finished) {
        if (finished) {
//            [self removeFromSuperview];
        }
    }];
}

- (void)show
{
    [[UIApplication sharedApplication].delegate.window.rootViewController.view addSubview:self];
    [UIView animateWithDuration:0.5f animations:^{
        [self setY:self.superview.frame.size.height - 44];
    } completion:^(BOOL finished) {
    }];
}

@end
