//
//  PutGoodTableViewCell.h
//  DLDQ_IOS
//
//  Created by simman on 15/1/12.
//  Copyright (c) 2015年 Liwei. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PutGoodTableViewCellDelegate <NSObject>

@optional
- (void) clickShowLocation:(UIButton *)locationButton cancelButton:(UIButton *)cancelButton;
- (void) clickHiddenLocation:(UIButton *)cancelButton locationButton:(UIButton *)locationButton;
- (void) clickTag:(UIButton *)tagButton;
- (void) clickIsShowPrice:(UISwitch *)switchSender;
- (void) clickIsShowMark:(UISwitch *)switchSender;
- (void) clickIsShowOfflinePay:(UISwitch *)switchSender;
- (void) clickImageWithImageView:(UIImageView *)imageView;
- (void) goodsPriceContent:(NSString *)content;
- (void) goodsPriceTextField:(UITextField *)textField;
- (void) goodsDescriptionContent:(NSString *)content;

@end

@interface PutGoodTableViewCell : UITableViewCell <UITextFieldDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *placeholderLable;

@property (weak, nonatomic) IBOutlet UIButton *buyButton;

@property (nonatomic, strong) id<PutGoodTableViewCellDelegate>delegate;

// --->  描述与图片
@property (weak, nonatomic) IBOutlet UITextView *GoodsDescriptionTextView;


// --->  价格信息
@property (weak, nonatomic) IBOutlet UISwitch *IsShowPriceSwitch;
@property (weak, nonatomic) IBOutlet UITextField *GoodsPriceTextField;


// --->  定位
@property (weak, nonatomic) IBOutlet UIButton *LocationButton;
- (IBAction)LocationButtonAction:(id)sender;
- (IBAction)cancelLocationButton:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *canCelLocationButton;

// --->  标签
@property (weak, nonatomic) IBOutlet UIButton *TagButton;
- (IBAction)TagButtonAction:(id)sender;


// --->> 水印
@property (weak, nonatomic) IBOutlet UISwitch *isShowMark;

// ---->> 创建订单
@property (weak, nonatomic) IBOutlet UITextField *totalAmount;
@property (weak, nonatomic) IBOutlet UITextField *totalBailAmount;
@property (weak, nonatomic) IBOutlet UISwitch *showOfflinePay;

//备注
@property (weak, nonatomic) IBOutlet UITextView *remarkTextView;


- (void) setIsShowPrice:(BOOL)show;
- (void) setIsShowMarkS:(BOOL)show;
- (void) setImagesWith:(NSArray *)images;
- (void) setAssetWith:(NSArray *)images;

- (IBAction)showOfflinePayIsChange:(UISwitch *)sender;



+ (instancetype)shareXibImageView;
+ (instancetype)shareXibPriceButtonView;
+ (instancetype)shareXibPriceView;
+ (instancetype)shareXibLocationView;
+ (instancetype)shareXibTagView;
+ (instancetype)shareXibDescription;
+ (instancetype)shareXibShowMark;

+ (instancetype)totalAmountXib;
+ (instancetype)totalBailAmountXib;
+ (instancetype)showOfflinePayXib;
+ (instancetype)remarkXib;

@end
