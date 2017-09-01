//
//  FeedBackViewController.m
//  DLDQ_IOS
//
//  Created by simman on 14-8-25.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import "FeedBackViewController.h"
#import "UIPlaceHolderTextView.h"

#import "IQKeyboardManager.h"
@interface FeedBackViewController ()<UITextFieldDelegate, UITextViewDelegate>
@property (strong, nonatomic) UIPlaceHolderTextView *feedbackTextView;
@end

@implementation FeedBackViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setNavTitle:@"我要吐槽"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.902 green:0.902 blue:0.902 alpha:1];
    
    WeakSelf
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] bk_initWithTitle:@"发送" style:UIBarButtonItemStyleDone handler:^(id sender) {
        [weakSelf_SC sendFeedBack];
    }];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] bk_initWithImage:[UIImage imageNamed:@"backBtn_Nav"] style:UIBarButtonItemStyleDone handler:^(id sender) {
        [weakSelf_SC dismissViewController];
    }];
    
    [self.view addSubview:self.feedbackTextView];
    
    
//    [self.feedbackTextView becomeFirstResponder];
}

-(void)loadView
{
    //this method is used to adjust the iq keyboard by lzj
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view = scrollView;
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.feedbackTextView resignFirstResponder];
}

- (UIPlaceHolderTextView *)feedbackTextView
{
    if (!_feedbackTextView) {
        
        _feedbackTextView = [[UIPlaceHolderTextView alloc] initWithFrame:CGRectMake(15, 20, kScreen_Width - 30, 250)];
        _feedbackTextView.delegate = self;
        _feedbackTextView.placeholder = @"Hi，您对米妞App有什么要吐槽的，都可以在这儿吐哦，小米一定洗耳恭听，发奋改进，么么哒！";
        _feedbackTextView.backgroundColor = [UIColor whiteColor];
        _feedbackTextView.layer.borderColor = [UIColor whiteColor].CGColor;
        _feedbackTextView.layer.borderWidth = 1.0;
        _feedbackTextView.layer.cornerRadius = 5.0;
        _feedbackTextView.font = [UIFont systemFontOfSize:14];
    }
    return _feedbackTextView;
}

- (void) inputEmailTextField
{
    [self.feedbackTextView resignFirstResponder];
}

- (void) inputFeedBackTextView
{
    [self.feedbackTextView becomeFirstResponder];
}

- (void) sendFeedBack
{
    if ([self.feedbackTextView.text length] > 0) {
        [self.feedbackTextView resignFirstResponder];
        [self showHudLoad:@"正在提交..."];
        
        WeakSelf
        [[logicShareInstance getUserManager] postFeedBackWith:self.feedbackTextView.text email:@"" Success:^(id responseObject) {

            [weakSelf_SC showHudSuccess:@"发送成功!"];

            [weakSelf_SC performSelector:@selector(dismissViewController) withObject:self afterDelay:1.2];
            
        } failure:^(NSString *error) {
            [weakSelf_SC showHudError:error];
        }];
        
    } else {
        [self showHudError:@"请输入正确的内容!"];
    }
}

- (void) dismissViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([self.feedbackTextView.text length]) {
        [self sendFeedBack];
    }
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
