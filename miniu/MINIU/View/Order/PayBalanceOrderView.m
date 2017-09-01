//
//  PayBalanceOrderView.m
//  miniu
//
//  Created by SimMan on 15/6/5.
//  Copyright (c) 2015年 SimMan. All rights reserved.
//

#import "PayBalanceOrderView.h"

@interface PayBalanceOrderView()

@property (nonatomic, strong) UILabel *topTipLable;         // 提示信息
@property (nonatomic, strong) UILabel *priceLable;          // 价格
@property (nonatomic, strong) FUIButton *selectPayButton;     //微信支付按钮
@property (nonatomic, strong) UIButton *logisticsInfoButton;    // 物流信息
@property (nonatomic, strong) UIButton *addLogisticsButton;     // 添加物流信息按钮
@property (nonatomic, strong) UILabel *logisticsInfoLable;      // 物流信息

@end

@implementation PayBalanceOrderView

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        
        WeakSelf
        self.topTipLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, kScreen_Width, 18)];
        [self.topTipLable setTextColor:[UIColor colorWithRed:0.318 green:0.843 blue:0.408 alpha:1]];
        [self.topTipLable setFont:[UIFont systemFontOfSize:24]];
        [self.topTipLable setTextAlignment:NSTextAlignmentCenter];
        [self.topTipLable setText:@"定金支付成功"];
        
        
        self.priceLable = [[UILabel alloc] initWithFrame:CGRectMake(0, _topTipLable.selfMaxY + 21, kScreen_Width, 30)];
        [self.priceLable setTextAlignment:NSTextAlignmentCenter];
        [self.priceLable setFont:[UIFont systemFontOfSize:30]];
        [self.priceLable setTextColor:[UIColor colorWithRed:0.439 green:0.439 blue:0.439 alpha:1]];
        
        self.selectPayButton = [[FUIButton alloc] initWithFrame:CGRectMake(50, _priceLable.selfMaxY + 25, kScreen_Width - 100, 43)];
        [self.selectPayButton setButtonColor:[UIColor colorWithRed:0.325 green:0.843 blue:0.412 alpha:1]];
        self.selectPayButton.titleLabel.font = [UIFont boldFlatFontOfSize:15];
        [self.selectPayButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.selectPayButton.cornerRadius = 5;
        [self.selectPayButton bk_addEventHandler:^(id sender) {
            
            if (weakSelf_SC.delegate && [weakSelf_SC.delegate respondsToSelector:@selector(choosePayMentButton)]) {
                [weakSelf_SC.delegate choosePayMentButton];
            }
            
        } forControlEvents:UIControlEventTouchUpInside];
        
        
        self.logisticsInfoButton = [[UIButton alloc] initWithFrame:CGRectMake(0, _selectPayButton.selfMaxY + 100, kScreen_Width, 16)];
        [self.logisticsInfoButton setTitle:@"查看物流详情" forState:UIControlStateNormal];
        [self.logisticsInfoButton setTitleColor:[UIColor colorWithRed:0.678 green:0.678 blue:0.678 alpha:1] forState:UIControlStateNormal];
        [self.logisticsInfoButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [self.logisticsInfoButton bk_addEventHandler:^(id sender) {
            if (weakSelf_SC.delegate && [weakSelf_SC.delegate respondsToSelector:@selector(logisticsAction:)]) {
                [weakSelf_SC.delegate logisticsAction:logisticsActionWithInfo];
            }
        } forControlEvents:UIControlEventTouchUpInside];
        
        
        self.addLogisticsButton = [[UIButton alloc] initWithFrame:CGRectMake(0, _logisticsInfoButton.selfMaxY + 19, kScreen_Width, 16)];
        [self.addLogisticsButton setTitle:@"添加收货地址" forState:UIControlStateNormal];
        [self.addLogisticsButton setTitleColor:[UIColor colorWithRed:0.678 green:0.678 blue:0.678 alpha:1] forState:UIControlStateNormal];
        [self.addLogisticsButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
        self.addLogisticsButton.hidden = YES;
        [self.addLogisticsButton bk_addEventHandler:^(id sender) {
            if (weakSelf_SC.delegate && [weakSelf_SC.delegate respondsToSelector:@selector(logisticsAction:)]) {
                [weakSelf_SC.delegate logisticsAction:logisticsActionWithAddAddress];
            }
        } forControlEvents:UIControlEventTouchUpInside];
        
        //支付订单 - 定金界面
        self.logisticsInfoLable = [[UILabel alloc] initWithFrame:CGRectMake(20, _logisticsInfoButton.selfMaxY + 19, kScreen_Width - 40, 0)];
        [self.logisticsInfoLable setTextColor:[UIColor colorWithRed:0.537 green:0.537 blue:0.537 alpha:1]];
        [self.logisticsInfoLable setFont:[UIFont systemFontOfSize:16]];
        [self.logisticsInfoLable setTextAlignment:NSTextAlignmentCenter];
        self.logisticsInfoLable.hidden = YES;
        self.logisticsInfoLable.numberOfLines = 0;
        self.logisticsInfoLable.userInteractionEnabled = YES;
        [self.logisticsInfoLable bk_whenTapped:^{
            if (weakSelf_SC.delegate && [weakSelf_SC.delegate respondsToSelector:@selector(logisticsAction:)]) {
                [weakSelf_SC.delegate logisticsAction:logisticsActionWithAddAddress];
            }
        }];
        
        
        [self addSubview:_topTipLable];
        [self addSubview:_priceLable];
        [self addSubview:_selectPayButton];
        [self addSubview:self.logisticsInfoButton];
        [self addSubview:self.addLogisticsButton];
        [self addSubview:self.logisticsInfoLable];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.frame = CGRectMake(0, 145 + 30, kScreen_Width, _logisticsInfoButton.selfMaxY + 60);
    
    
#if TARGET_IS_MINIU_BUYER
    [self.selectPayButton setEnabled:NO];
#endif
}

- (void)setOrder:(OrderEntity *)order
{
    _order = order;
    
    // 价格
    [self.priceLable setText:[NSString stringWithFormat:@"￥%0.2f", order.totalBailAmount]];
    
    // 支付按钮
    [self.selectPayButton setTitle:[NSString stringWithFormat:@"支付尾款 ￥%0.2f", order.totalBalanceAmount] forState:UIControlStateNormal];
    
    // 如果有地址
    if ([order.consignee length]) {
        [self.addLogisticsButton setHidden:YES];
        [self.logisticsInfoLable setHidden:NO];
        
        [self.logisticsInfoLable setLongString:[NSString stringWithFormat:@"收货地址: \n%@  %@\n%@", order.consignee, order.phone, order.address] withFitWidth:kScreen_Width - 40];
    } else {
        [self.addLogisticsButton setHidden:NO];
        [self.logisticsInfoLable setHidden:YES];
    }
}

@end
