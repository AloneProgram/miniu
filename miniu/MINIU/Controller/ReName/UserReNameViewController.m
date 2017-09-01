//
//  UserReNameViewController.m
//  DLDQ_IOS
//
//  Created by simman on 14-6-12.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import "UserReNameViewController.h"

@interface UserReNameViewController () {
    void (^saveActionBlocks)(NSString *);
    NSInteger _maxLenght;
    NSInteger _minLenght;
    NSString *_tip;
    NSString *_value;
    NSString *_placeholder;
    UIKeyboardType _keyBoardType;
}

@property (weak, nonatomic) IBOutlet UILabel *tipLable;
@property (weak, nonatomic) IBOutlet UITextField *Name_Lable;
@property (weak, nonatomic) IBOutlet FUIButton *SaveBtn;
- (IBAction)saveBtnAction:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lineLable;

@end

@implementation UserReNameViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _maxLenght = 0;
        _minLenght = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _Name_Lable.delegate = self;
    [_Name_Lable becomeFirstResponder];
    _Name_Lable.keyboardType = _keyBoardType;
    
    if ([_value isEqualToString:@"匿名用户"]) {
        self.Name_Lable.text = @"";
    }
    self.Name_Lable.text = _value;
    if ([_value length] <= 0) {
        self.Name_Lable.placeholder = _placeholder;
    }
    self.tipLable.text = _tip;

    
    [_SaveBtn setWidth:kScreen_Width - 50];
    [_SaveBtn setX:25];
    
    [_Name_Lable setWidth:kScreen_Width - 28];
    
    [_lineLable setWidth:kScreen_Width - 10];
}

- (void)initControllerData{};



- (void) textFieldDidChange:(id) sender {
    
    if ([self.Name_Lable.text length] > _maxLenght && _maxLenght) {
        NSString *text = _Name_Lable.text;
        _Name_Lable.text = [text substringToIndex:_maxLenght];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    // return NO to not change text
//    NSLog(@"++++%@",textField.text);
//    NSLog(@"----%lu",(unsigned long)range.length);
//    if([self.Name_Lable.text length] >= _maxLenght && range.length != 1) {
//        [self message:[NSString stringWithFormat:@"最多输入 %d 个字符", (int)_maxLenght]];
//        return NO;
//    }
    return YES;
}

#pragma mark 回调
- (IBAction)saveBtnAction:(id)sender {
    if (_minLenght && [_Name_Lable.text length] < _minLenght) {
        [self showHudError:[NSString stringWithFormat:@"最少输入 %d 个字符", (int)_minLenght]];
    } else if (_maxLenght && [_Name_Lable.text length] > _maxLenght) {
        [self showHudError:[NSString stringWithFormat:@"最多输入 %d 个字符", (int)_maxLenght]];
    } else {
        saveActionBlocks(_Name_Lable.text);
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark block 回调
- (void) setDataWithPlaceholder:(NSString *)placeholder
                   defaultValue:(NSString *)defaultValue
                      maxLenght:(NSInteger)maxlenght
                      minLenght:(NSInteger)minLenght
                      tipString:(NSString *)tipString
                       NavTitle:(NSString *)title
                   keyBoardType:(UIKeyboardType)keyType
                     saveAction:(void (^)(NSString *))saveAction
{
    saveActionBlocks = saveAction;
    _maxLenght = maxlenght;
    _minLenght = minLenght;
    [self setNavTitle:title];
    _tip = tipString;
    _value = defaultValue;
    _placeholder = placeholder;
    _keyBoardType = keyType;
}



@end
