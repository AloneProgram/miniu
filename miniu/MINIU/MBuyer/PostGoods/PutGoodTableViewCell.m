//
//  PutGoodTableViewCell.m
//  DLDQ_IOS
//
//  Created by simman on 15/1/12.
//  Copyright (c) 2015年 Liwei. All rights reserved.
//

#import "PutGoodTableViewCell.h"

@implementation PutGoodTableViewCell

- (void)awakeFromNib {

    [NSNotificationDefaultCenter addObserver:self selector:@selector(hiddenKeyBoard) name:@"hiddenKeyBoard" object:nil];
    [NSNotificationDefaultCenter addObserver:self selector:@selector(clearViewData) name:@"clearPutGoodCellViewData" object:nil];
    [_buyButton.layer setMasksToBounds:YES];
    [_buyButton.layer setCornerRadius:5.0]; //设置矩形四个圆角半径
    _GoodsPriceTextField.delegate = self;
    _GoodsDescriptionTextView.delegate = self;
    
    _totalAmount.delegate = self;
    _totalAmount.tag = 100011;
    _totalBailAmount.delegate = self;
    _totalBailAmount.tag = 100012;
    
//    [_showOfflinePay addTarget:self action:@selector(showOfflinePayIsChange:) forControlEvents:UIControlEventValueChanged];
    
    [_IsShowPriceSwitch addTarget:self action:@selector(switchIsChange:) forControlEvents:UIControlEventValueChanged];
    [_isShowMark addTarget:self action:@selector(markSwitchIsChange:) forControlEvents:UIControlEventValueChanged];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self setWidth:kScreen_Width];
    
    // 设置描述frame
    [self.GoodsDescriptionTextView setWidth:(kScreen_Width - self.GoodsDescriptionTextView.selfX)];
    
    // 设置价格frame
    
    [self.GoodsPriceTextField setWidth:(kScreen_Width - self.GoodsPriceTextField.selfX - 50)];
    
    
    [self.totalAmount setWidth:(kScreen_Width - self.totalAmount.selfX - 50)];
    [self.totalBailAmount setWidth:(kScreen_Width - self.totalBailAmount.selfX - 50)];
}

- (void) clearViewData
{
    self.GoodsPriceTextField.text = @"";
    self.GoodsDescriptionTextView.text = @"";
    self.LocationButton.selected = NO;
    self.canCelLocationButton.hidden = YES;
    [_placeholderLable setHidden:NO];
    [self.LocationButton setTitle:@"显示位置" forState:UIControlStateNormal];
    [_TagButton setTitle:@"选择标签" forState:UIControlStateNormal];
    _TagButton.selected = NO;
}

- (void) setImagesWith:(NSArray *)images
{

    NSInteger lNums = kScreen_Width / 73;
    
    int k;
    for (k = 900; k < 909; k ++) {
        
        UIImageView *imageView = (UIImageView *)[self.contentView viewWithTag:k];
        if (imageView) {
            imageView.image = nil;
            [imageView removeFromSuperview];
        }
    }
    UIImageView *imageView = (UIImageView *)[self.contentView viewWithTag:8888];
    if (imageView) {
        imageView.image = nil;
        [imageView removeFromSuperview];
    }
    
    
    NSInteger imagesCount = [images count];
    int i = 0;
    if (imagesCount) {

        for (UIImage *image in images) {
            CGRect buttonframe = CGRectMake((65 + 8) * (i % lNums) + 15, (65 + 8) * (i / lNums) + 86, 65, 65);
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:buttonframe];
            [imageView setImage:image];
            imageView.tag = i + 900;
            imageView.clipsToBounds = YES;
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.userInteractionEnabled = YES;
            [imageView bk_whenTapped:^{
                if (_delegate && [_delegate respondsToSelector:@selector(clickImageWithImageView:)]) {
                    [_delegate clickImageWithImageView:imageView];
                }
            }];
            
            [self.contentView addSubview:imageView];
            i ++;
        }
        
        if (imagesCount < 9) {
            CGRect buttonframe = CGRectMake((65 + 8) * (i % lNums) + 15, (65 + 8) * (i / lNums) + 86, 65, 65);
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:buttonframe];
            [imageView setImage:[UIImage imageNamed:@"++++___"]];
            imageView.tag = 8888;
            imageView.clipsToBounds = YES;
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.userInteractionEnabled = YES;
            [imageView bk_whenTapped:^{
                if (_delegate && [_delegate respondsToSelector:@selector(clickImageWithImageView:)]) {
                    [_delegate clickImageWithImageView:imageView];
                }
            }];
            [self.contentView addSubview:imageView];
        }
        
    } else {
        CGRect buttonframe = CGRectMake((65 + 8) * (i % (lNums-1)) + 15, (65 + 8) * (i / (lNums-1)) + 86, 65, 65);
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:buttonframe];
        [imageView setImage:[UIImage imageNamed:@"++++___"]];
        imageView.tag = 8888;
        imageView.clipsToBounds = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.userInteractionEnabled = YES;
        [imageView bk_whenTapped:^{
            if (_delegate && [_delegate respondsToSelector:@selector(clickImageWithImageView:)]) {
                [_delegate clickImageWithImageView:imageView];
            }
        }];
        [self.contentView addSubview:imageView];
    }
}

- (void) setAssetWith:(NSArray *)images
{
    NSInteger lNums = kScreen_Width / 73;
    int k;
    for (k = 900; k < 909; k ++) {
        
        UIImageView *imageView = (UIImageView *)[self.contentView viewWithTag:k];
        if (imageView) {
            imageView.image = nil;
            [imageView removeFromSuperview];
        }
    }
    UIImageView *imageView = (UIImageView *)[self.contentView viewWithTag:8888];
    if (imageView) {
        imageView.image = nil;
        [imageView removeFromSuperview];
    }
    
    
    NSInteger imagesCount = [images count];
    int i = 0;
    if (imagesCount) {
        
        for (ALAsset *alasset in images) {
            CGRect buttonframe = CGRectMake((65 + 8) * (i % lNums) + 15, (65 + 8) * (i / lNums) + 8, 65, 65);
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:buttonframe];
            UIImage *img = [UIImage imageWithCGImage:alasset.thumbnail];
            [imageView setImage:img];
            imageView.tag = i + 900;
            imageView.clipsToBounds = YES;
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.userInteractionEnabled = YES;
            [imageView bk_whenTapped:^{
                if (_delegate && [_delegate respondsToSelector:@selector(clickImageWithImageView:)]) {
                    [_delegate clickImageWithImageView:imageView];
                }
            }];
            
            [self.contentView addSubview:imageView];
            i ++;
        }
        
        if (imagesCount < 9) {
            CGRect buttonframe = CGRectMake((65 + 8) * (i % lNums) + 15, (65 + 8) * (i / lNums) + 8, 65, 65);
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:buttonframe];
            [imageView setImage:[UIImage imageNamed:@"++++___"]];
            imageView.tag = 8888;
            imageView.clipsToBounds = YES;
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.userInteractionEnabled = YES;
            [imageView bk_whenTapped:^{
                if (_delegate && [_delegate respondsToSelector:@selector(clickImageWithImageView:)]) {
                    [_delegate clickImageWithImageView:imageView];
                }
            }];
            [self.contentView addSubview:imageView];
        }
        
    } else {
        CGRect buttonframe = CGRectMake((65 + 8) * (i % (lNums-1)) + 15, (65 + 8) * (i / (lNums-1)) + 8, 65, 65);
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:buttonframe];
        [imageView setImage:[UIImage imageNamed:@"++++___"]];
        imageView.tag = 8888;
        imageView.clipsToBounds = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.userInteractionEnabled = YES;
        [imageView bk_whenTapped:^{
            if (_delegate && [_delegate respondsToSelector:@selector(clickImageWithImageView:)]) {
                [_delegate clickImageWithImageView:imageView];
            }
        }];
        [self.contentView addSubview:imageView];
    }
}

- (IBAction)showOfflinePayIsChange:(UISwitch *)sender {
    UISwitch *swi2=(UISwitch *)sender;
    [_showOfflinePay setOn:swi2.isOn animated:YES];
    if (_delegate && [_delegate respondsToSelector:@selector(clickIsShowOfflinePay:)]) {
        [_delegate clickIsShowOfflinePay:swi2];
    }
}


- (void) switchIsChange:(id)sender
{
    UISwitch *swi2=(UISwitch *)sender;
    [_IsShowPriceSwitch setOn:swi2.isOn animated:YES];
    if (_delegate && [_delegate respondsToSelector:@selector(clickIsShowPrice:)]) {
        [_delegate clickIsShowPrice:swi2];
    }
}

- (void) markSwitchIsChange:(id)sender
{
    UISwitch *swi2=(UISwitch *)sender;
    [_IsShowPriceSwitch setOn:swi2.isOn animated:YES];
    if (_delegate && [_delegate respondsToSelector:@selector(clickIsShowMark:)]) {
        [_delegate clickIsShowMark:swi2];
    }
}

- (void) setIsShowPrice:(BOOL)show
{
    [_IsShowPriceSwitch setOn:show animated:YES];
}

- (void) setIsShowMarkS:(BOOL)show
{
    [_isShowMark setOn:show animated:YES];
}

- (void) hiddenKeyBoard
{
    [self.GoodsPriceTextField resignFirstResponder];
    [self.GoodsDescriptionTextView resignFirstResponder];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)LocationButtonAction:(id)sender {

    UIButton *button = (UIButton *)sender;
    button.selected = !button.selected;
    if (_delegate && [_delegate respondsToSelector:@selector(clickShowLocation:cancelButton:)]) {
        [_delegate clickShowLocation:sender cancelButton:self.canCelLocationButton];
    }
}

- (IBAction)cancelLocationButton:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(clickHiddenLocation:locationButton:)]) {
        [_delegate clickHiddenLocation:sender locationButton:self.LocationButton];
    }
}
- (IBAction)TagButtonAction:(id)sender {
    UIButton *button = (UIButton *)sender;
    button.selected = !button.selected;
    if (_delegate && [_delegate respondsToSelector:@selector(clickTag:)]) {
        [_delegate clickTag:sender];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (_delegate && [_delegate respondsToSelector:@selector(goodsPriceContent:)]) {
        [_delegate goodsPriceContent:textField.text];
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(goodsPriceTextField:)]) {
        [_delegate goodsPriceTextField:textField];
    }
    
    NSLog(@"textField: %@", textField.text);
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if (_delegate && [_delegate respondsToSelector:@selector(goodsDescriptionContent:)]) {
        [_delegate goodsDescriptionContent:textView.text];
    }
    NSLog(@"textView: %@", textView.text);
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return [self validateNumber:string text:textField.text textField:textField];
}

#pragma mark UITextView 代理方法
- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length == 0) {
        [_placeholderLable setHidden:NO];
    }else{
        [_placeholderLable setHidden:YES];
    }
}

- (BOOL)validateNumber:(NSString*)number text:(NSString *)text textField:(UITextField *)textField
{
    BOOL res = YES;
    
    // 如果是删除操作
    if ([number isEqualToString:@""]) {
        return YES;
    }
    
    // 1、判断第一个输入的是否为 .
    if (![text length] && [number isEqualToString:@"."]) {
        [self showHudError:@"请输入正确的金额!"];
        res = NO;
    }
    
    //    if (![text length] && [number isEqualToString:@"0"]) {
    //        [self faildMessage:@"请输入正确的金额!"];
    //        res = NO;
    //    }
    
    // 2、如果总金额大于 99999999
    if ([[NSString stringWithFormat:@"%@%@", text, number] integerValue] >= 9999999) {
        [self showHudError:@"亲,这么大的金额,我们帮不了你了...!"];
        res = NO;
    }
    
    // 3、判断是否是正确的数字或者 .
    
    NSCharacterSet* tmpSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
    int i = 0;
    while (i < number.length) {
        NSString * string = [number substringWithRange:NSMakeRange(i, 1)];
        NSRange range = [string rangeOfCharacterFromSet:tmpSet];
        if (range.length == 0) {
            [self showHudError:@"请输入正确的金额!"];
            res = NO;
            break;
        }
        i++;
    }
    
    // 4、判断是否有两个以上的 .
    NSRange range = [text rangeOfString:@"."];
    if ([number isEqualToString:@"."] && range.location != NSNotFound) {
        [self showHudError:@"请输入正确的金额!"];
        res = NO;
    }
    
    // 5、判断小数是否大于99
    if (range.location != NSNotFound) {
        // 分割数组
        NSArray * array = [text componentsSeparatedByString:@"."];
        NSMutableString *s = [NSMutableString stringWithFormat:@"%@%@", [array objectAtIndex:1], number];
        if ([s length] > 2) {
            [self showHudError:@"只允许保留小数点后两位!"];
            res = NO;
        }
    }
    
    return res;
}


+ (instancetype)shareXibDescription
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"PutGoodTableViewCell" owner:nil options:nil];
    return [array objectAtIndex:5];
}

+ (instancetype)shareXibImageView
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"PutGoodTableViewCell" owner:nil options:nil];
    return [array firstObject];
}

+ (instancetype)shareXibPriceButtonView
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"PutGoodTableViewCell" owner:nil options:nil];
    return [array objectAtIndex:1];
}

+ (instancetype)shareXibPriceView
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"PutGoodTableViewCell" owner:nil options:nil];
    return [array objectAtIndex:2];
}

+ (instancetype)shareXibLocationView
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"PutGoodTableViewCell" owner:nil options:nil];
    return [array objectAtIndex:3];
}

+ (instancetype)shareXibTagView
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"PutGoodTableViewCell" owner:nil options:nil];
    return [array objectAtIndex:4];
}

+ (instancetype)shareXibShowMark
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"PutGoodTableViewCell" owner:nil options:nil];
    return [array objectAtIndex:6];
}


+ (instancetype)totalAmountXib
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"PutGoodTableViewCell" owner:nil options:nil];
    return [array objectAtIndex:8];
}

+ (instancetype)totalBailAmountXib
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"PutGoodTableViewCell" owner:nil options:nil];
    return [array objectAtIndex:9];
}

+ (instancetype)showOfflinePayXib
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"PutGoodTableViewCell" owner:nil options:nil];
    return [array objectAtIndex:10];
}

+ (instancetype)remarkXib
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"PutGoodTableViewCell" owner:nil options:nil];
    PutGoodTableViewCell *cell = [array objectAtIndex:11];
    cell.remarkTextView.text = @" 备注:";
    return cell;
}


@end
