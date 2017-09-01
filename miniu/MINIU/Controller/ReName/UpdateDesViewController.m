//
//  UpdateDesViewController.m
//  miniu
//
//  Created by SimMan on 4/28/15.
//  Copyright (c) 2015 SimMan. All rights reserved.
//

#import "UpdateDesViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIPlaceHolderTextView.h"

#import "IQKeyboardManager.h"
@interface UpdateDesViewController ()<UITextViewDelegate> {
    void (^saveActionBlocks)(NSString *);
}

@property (nonatomic, strong) UIPlaceHolderTextView *textView;
@property (nonatomic, strong) FUIButton *submitButton;

@end

@implementation UpdateDesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"个人签名";
    
    [self.view addSubview:self.textView];
    [self.view addSubview:self.submitButton];
    
    self.view.backgroundColor = [UIColor colorWithRed:0.965 green:0.965 blue:0.965 alpha:1];
    [IQKeyboardManager sharedManager].enable = NO;
//    [self.textView becomeFirstResponder];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.textView resignFirstResponder];
    [IQKeyboardManager sharedManager].enable = YES;

}


- (UITextView *)textView
{
    if (!_textView) {
        _textView = [[UIPlaceHolderTextView alloc] initWithFrame:CGRectMake(10, 10, kScreen_Width-20, 150)];
        _textView.delegate = self;
        _textView.backgroundColor = [UIColor whiteColor];
        _textView.layer.borderColor = [UIColor whiteColor].CGColor;
        _textView.layer.borderWidth = 1.0;
        _textView.layer.cornerRadius = 5.0;
        _textView.font = [UIFont flatFontOfSize:14];
        if (![self.userDescription isEqualToString:@"暂无描述"]) {
            _textView.text = self.userDescription;
        } else {
            _textView.placeholder = @"请填写描述...";
        }
    }
    return _textView;
}

- (FUIButton *)submitButton
{
    if (!_submitButton) {
        _submitButton = [[FUIButton alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(self.textView.frame)+10, kScreen_Width - 40, 40)];
        [_submitButton setTitle:@"提交" forState:UIControlStateNormal];
        
        [_submitButton addTarget:self action:@selector(saveBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _submitButton;
}

#pragma mark 回调
- (void)saveBtnAction
{
    if (![self.textView.text length]) {
        [self showHudError:@"签名不能为空!"];
        return;
    }
    
    WeakSelf
    if (saveActionBlocks) {
        saveActionBlocks(weakSelf_SC.textView.text);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveAction:(void (^)(NSString *))saveAction
{
    saveActionBlocks = saveAction;
}


@end
