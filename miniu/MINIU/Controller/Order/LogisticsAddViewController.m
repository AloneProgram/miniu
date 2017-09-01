//
//  LogisticsAddViewController.m
//  miniu
//
//  Created by SimMan on 15/6/10.
//  Copyright (c) 2015年 SimMan. All rights reserved.
//

#import "LogisticsAddViewController.h"
#import "UIPlaceHolderTextView.h"
#import "RMDateSelectionViewController.h"
#import "ScanViewController.h"
#import "ChooseCompanyViewController.h"


#define MARGIN_LEFT 20
#define MARGIN_TOP  15

#define TIME_TEXT_FIELD_TAG  1001
#define COMPANY_TEXT_FIELD_TAG 1002
#define INVOICE_TEXT_FIELD_TAG 1003

@interface LogisticsAddViewController () <UIScrollViewDelegate, UITextFieldDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UITextField *createTimeTextField;
@property (nonatomic, strong) UIPlaceHolderTextView *contentTextView;
@property (nonatomic, strong) UITextField *companyTextField;
@property (nonatomic, strong) UITextField *invoiceNoTextField;
@property (nonatomic, strong) UIButton *scanButton;

@property (nonatomic, strong) NSArray *codeArray;

@end

@implementation LogisticsAddViewController

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.logistics = [LogisticsEntity new];
        self.logistics.createTime = [[NSDate date] timeIntervalSince1970InMilliSecond];
        NSString *str = @"010,021,022,023,852,853,310,311,312,313,314,315,316,317,318,319,335,570,571,572,573,574,575,576,577,578,579,580,24,410,411,412,413,414,415,416,417,418,419,421,427,429,27,710,711,712,713,714,715,716,717,718,719,722,724,728,25,510,511,512,513,514,515,516,517,517,518,519,523,470,471,472,473,474,475,476,477,478,479,482,483,790,791,792,793,794,795,796,797,798,799,701,350,351,352,353,354,355,356,357,358,359,930,931,932,933,934,935,936,937,938,941,943,530,531,532,533,534,535,536,537,538,539,450,451,452,453,454,455,456,457,458,459,591,592,593,594,595,595,596,597,598,599,20,751,752,753,754,755,756,757,758,759,760,762,763,765,766,768,769,660,661,662,663,028,810,811,812,813,814,816,817,818,819,825,826,827,830,831,832,833,834,835,836,837,838,839,840,730,731,732,733,734,735,736,737,738,739,743,744,745,746,370,371,372,373,374,375,376,377,378,379,391,392,393,394,395,396,398,870,871,872,873,874,875,876,877,878,879,691,692,881,883,886,887,888,550,551,552,553,554,555,556,557,558,559,561,562,563,564,565,566,951,952,953,954,431,432,433,434,435,436,437,438,439,440,770,771,772,773,774,775,776,777,778,779,851,852,853,854,855,856,857,858,859,029,910,911,912,913,914,915,916,917,919,971,972,973,974,975,976,977,890,898,899,891,892,893,901,902,903,906,908,909,990,991,992,993,994,995,996,997,998,999";
        self.codeArray = [str componentsSeparatedByString:@","];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if (self.logistics.lid) {
        self.title = @"编辑物流信息";
    } else {
        self.title = @"添加物流信息";
    }
    
    // 创建时间
    _createTimeTextField = [[UITextField alloc] initWithFrame:CGRectMake(MARGIN_LEFT, MARGIN_TOP + 10, kScreen_Width - MARGIN_LEFT * 2, 35)];
//    [_createTimeTextField setBorderStyle:UITextBorderStyleRoundedRect];
    [_createTimeTextField setText:[[NSDate date] formattedDateForFull]];
    [_createTimeTextField setTextColor:[UIColor darkGrayColor]];
    _createTimeTextField.delegate = self;
    _createTimeTextField.tag = TIME_TEXT_FIELD_TAG;
    [_createTimeTextField addLineUp:NO andDown:YES];
    [_createTimeTextField setLeftViewMode:UITextFieldViewModeAlways];
    UILabel *createTimeLeftView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 35)];
    [createTimeLeftView setText:@"时间："];
    [createTimeLeftView setTextColor:[UIColor darkGrayColor]];
    [createTimeLeftView setFont:_createTimeTextField.font];
    [_createTimeTextField setLeftView:createTimeLeftView];
    
    // 内容
    _contentTextView = [[UIPlaceHolderTextView alloc] initWithFrame:CGRectMake(MARGIN_LEFT, _createTimeTextField.selfMaxY + MARGIN_TOP, kScreen_Width - MARGIN_LEFT * 2, 80)];
    [_contentTextView setPlaceholder:@"请输入内容"];
    [_contentTextView setFont:[UIFont systemFontOfSize:14]];
    UIView *lineV = [UIView lineViewWithPointYY:_contentTextView.selfMaxY andColor:[UIColor colorWithHexString:@"0xc8c7cc"]];
    lineV.frame = CGRectMake(_contentTextView.selfX, _contentTextView.selfMaxY, _contentTextView.selfW, lineV.selfH);
    [self.scrollView addSubview:lineV];
    
    // 物流公司
    _companyTextField = [[UITextField alloc] initWithFrame:CGRectMake(MARGIN_LEFT, _contentTextView.selfMaxY + MARGIN_TOP, 100, 35)];
    [_companyTextField setTextColor:[UIColor darkGrayColor]];
    _companyTextField.delegate = self;
    _companyTextField.tag = COMPANY_TEXT_FIELD_TAG;
    [_companyTextField addLineUp:NO andDown:YES];
    if (self.logistics.lid) {
        [_companyTextField setText:[NSString stringWithFormat:@"%@", self.logistics.company]];
    }
    [_companyTextField setPlaceholder:@"快递公司"];
    
    
    // 物流单号
    _invoiceNoTextField = [[UITextField alloc] initWithFrame:CGRectMake(_companyTextField.selfMaxX + 10, _contentTextView.selfMaxY + MARGIN_TOP, kScreen_Width - _companyTextField.selfMaxX - 10 - MARGIN_LEFT - 32, 35)];
    _invoiceNoTextField.delegate = self;
    _invoiceNoTextField.tag = INVOICE_TEXT_FIELD_TAG;
    [_invoiceNoTextField addLineUp:NO andDown:YES];
    if (self.logistics.lid) {
        [_invoiceNoTextField setText:[NSString stringWithFormat:@"%@", self.logistics.invoiceNo]];
    }
    [_invoiceNoTextField setPlaceholder:@"运单号码"];
    _invoiceNoTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    
    _scanButton = [[UIButton alloc] initWithFrame:CGRectMake(_invoiceNoTextField.selfMaxX + 2, _invoiceNoTextField.selfMinY, 32, 32)];
    [_scanButton setBackgroundImage:[UIImage imageNamed:@"iconfont-tiaoxingma"] forState:UIControlStateNormal];
    WeakSelf
    //获取条码信息
    [_scanButton bk_addEventHandler:^(id sender) {
        ScanViewController *scanVC = [ScanViewController new];
        [scanVC addCallBackBlock:^(NSString *code) {
            
            // 获取前三位
            NSString *indexStr = [code substringToIndex:3];
            if ([self.codeArray containsObject:indexStr]) {
                // 则为顺丰
                [weakSelf_SC.companyTextField setText:@"顺丰快递"];
                weakSelf_SC.logistics.company = @"顺丰快递";
                weakSelf_SC.logistics.code = @"shunfeng";
            }
            
            weakSelf_SC.logistics.invoiceNo = code;
            [weakSelf_SC.invoiceNoTextField setText:code];
        }];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:scanVC];
        [self presentViewController:nav animated:YES completion:nil];
        
    } forControlEvents:UIControlEventTouchUpInside];
    
    //提交按钮
    FUIButton *submitButton = [[FUIButton alloc] initWithFrame:CGRectMake(MARGIN_LEFT, _invoiceNoTextField.selfMaxY + 40, kScreen_Width - MARGIN_LEFT * 2, 43)];
    [submitButton setTitle:@"保    存" forState:UIControlStateNormal];
    [submitButton setButtonColor:[UIColor colorWithRed:0.325 green:0.843 blue:0.412 alpha:1]];
    submitButton.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    [submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    submitButton.cornerRadius = 5;
    [submitButton bk_addEventHandler:^(id sender) {
        [weakSelf_SC submitData];
    } forControlEvents:UIControlEventTouchUpInside];
    
    
    [self.scrollView addSubview:_createTimeTextField];
    [self.scrollView addSubview:_contentTextView];
    [self.scrollView addSubview:_companyTextField];
    [self.scrollView addSubview:_invoiceNoTextField];
    [self.scrollView addSubview:_scanButton];
    [self.scrollView addSubview:submitButton];
    
    [self.view addSubview:self.scrollView];
}


- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    // 创建时间
    if (textField.tag == TIME_TEXT_FIELD_TAG) {
        RMDateSelectionViewController *dateSelectionVC = [RMDateSelectionViewController dateSelectionController];
        
        //You can enable or disable bouncing and motion effects
        dateSelectionVC.hideNowButton = YES;
        //You can access the actual UIDatePicker via the datePicker property
        dateSelectionVC.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
        dateSelectionVC.datePicker.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
        dateSelectionVC.datePicker.minuteInterval = 5;
        
        if (self.logistics.lid) {
            dateSelectionVC.datePicker.date = [NSDate dateWithTimeIntervalInMilliSecondSince1970:self.logistics.createTime];
        } else {
            dateSelectionVC.datePicker.date = [NSDate date];
        }
        
        WeakSelf
        [self asyncMainQueue:^{
            [dateSelectionVC showWithSelectionHandler:^(RMDateSelectionViewController *vc, NSDate *aDate) {
                weakSelf_SC.logistics.createTime = [aDate timeIntervalSince1970InMilliSecond];
                [weakSelf_SC.createTimeTextField setText:[NSString stringWithFormat:@"%@", [aDate formattedDateForFull]]];
            } andCancelHandler:^(RMDateSelectionViewController *vc) {}];
        }];
        return NO;
    } else if (textField.tag == COMPANY_TEXT_FIELD_TAG) {
        ChooseCompanyViewController *chooseVC = [ChooseCompanyViewController new];
        WeakSelf
        [chooseVC addCallBackBlock:^(NSString *code, NSString *company) {
            weakSelf_SC.logistics.code = code;
            weakSelf_SC.logistics.company = company;
            [weakSelf_SC.companyTextField setText:company];
        }];
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:chooseVC];
        [self presentViewController:nav animated:YES completion:nil];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
}

- (void) submitData
{
    self.logistics.content = self.contentTextView.text;
    self.logistics.company = self.companyTextField.text;
    self.logistics.invoiceNo = self.invoiceNoTextField.text;
    
    if (([self.logistics.invoiceNo length] && ![self.logistics.company length]) || ([self.logistics.invoiceNo length] < 5)) {
        [self showHudError:@"请填写正确的快递公司&运单号码"];
        return;
    }
    
    if ((![self.logistics.invoiceNo length] && [self.logistics.company length])) {
        [self showHudError:@"请填写正确的快递公司&运单号码"];
        return;
    }
    
    WeakSelf
    [self showHudLoad:@"正在更新..."];
    [[logicShareInstance getOrderManager] editLogisticsListWithOrderNo:self.orderNo logisticsEntity:self.logistics success:^(id responseObject) {
        
        // 如果有lid
        if (weakSelf_SC.logistics.lid) {
            [self showHudSuccess:@"修改成功!"];
            [self bk_performBlock:^(id obj) {
                [weakSelf_SC.navigationController popViewControllerAnimated:YES];
            } afterDelay:1];
            return;
        }
        
        [weakSelf_SC endHudLoad];
        
        [WCAlertView showAlertWithTitle:@"提示" message:@"添加成功,是否继续添加？" customizationBlock:^(WCAlertView *alertView) {
            
        } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {

            if (buttonIndex) {
                
                weakSelf_SC.logistics = [LogisticsEntity new];
                weakSelf_SC.logistics.createTime = [[NSDate date] timeIntervalSince1970InMilliSecond];
                [weakSelf_SC.createTimeTextField setText:[[NSDate date] formattedDateForFull]];
                [weakSelf_SC.contentTextView setText:@""];
                [weakSelf_SC.companyTextField setText:@""];
                [weakSelf_SC.invoiceNoTextField setText:@""];
                
            } else {
                [weakSelf_SC.navigationController popViewControllerAnimated:YES];
            }
            
        } cancelButtonTitle:@"返回" otherButtonTitles:@"继续添加", nil];
        
    } failure:^(NSString *error) {
        [weakSelf_SC showHudError:error];
    }];
}

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        [_scrollView setContentSize:CGSizeMake(kScreen_Width, 600)];
        _scrollView.alwaysBounceVertical = YES;
        _scrollView.delegate = self;
    }
    return _scrollView;
}

@end
