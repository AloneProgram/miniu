//
//  PaySuccessOrderView.m
//  miniu
//
//  Created by SimMan on 15/6/5.
//  Copyright (c) 2015年 SimMan. All rights reserved.
//

#import "PaySuccessOrderView.h"
#import "OrderEntity.h"

@interface PaySuccessOrderView()



@end

@implementation PaySuccessOrderView

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        WeakSelf
        self.topTipLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, kScreen_Width, 38)];//18->38
        [self.topTipLable setTextColor:[UIColor colorWithRed:0.341 green:0.847 blue:0.424 alpha:1]];
        [self.topTipLable setFont:[UIFont systemFontOfSize:34]];
        [self.topTipLable setTextAlignment:NSTextAlignmentCenter];
        [self.topTipLable setText:@"支付成功!"];
        
        
        self.centerTipLable = [[UILabel alloc] initWithFrame:CGRectMake(0, _topTipLable.selfMaxY + 20, kScreen_Width, 30)];
        [self.centerTipLable setTextAlignment:NSTextAlignmentCenter];
        [self.centerTipLable setTextColor:[UIColor colorWithRed:0.784 green:0.784 blue:0.784 alpha:1]];
        [self.centerTipLable setFont:[UIFont systemFontOfSize:12]];
        [self.centerTipLable setText:@"静待收美物吧!"];
        
        self.logisticsInfoButton = [[UIButton alloc] initWithFrame:CGRectMake(50, _centerTipLable.selfMaxY + 20, kScreen_Width-100, 44)];
        [self.logisticsInfoButton setTitle:@"查看物流详情" forState:UIControlStateNormal];
        //添加边框和颜色 //[UIColor colorWithRed:0.678 green:0.678 blue:0.678 alpha:1]
        
        /*
         self.wxpayButton = [[FUIButton alloc] initWithFrame:CGRectMake(50, _priceLable.selfMaxY + 20, kScreen_Width - 100, 43)];//100->20
         [self.wxpayButton setTitle:@"微信支付" forState:UIControlStateNormal];
         [self.wxpayButton setButtonColor:[UIColor colorWithRed:0.325 green:0.843 blue:0.412 alpha:1]];
         self.wxpayButton.titleLabel.font = [UIFont boldFlatFontOfSize:16];
         [self.wxpayButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
         self.wxpayButton.cornerRadius = 5;
         */
        
        [self.logisticsInfoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.logisticsInfoButton.layer.borderWidth = 1;
        self.logisticsInfoButton.layer.borderColor = [UIColor whiteColor].CGColor;
        self.logisticsInfoButton.layer.backgroundColor =[UIColor colorWithRed:0.325 green:0.843 blue:0.412 alpha:1].CGColor;
        self.logisticsInfoButton.layer.cornerRadius = 5;
        
        [self.logisticsInfoButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [self.logisticsInfoButton bk_addEventHandler:^(id sender) {
            if (weakSelf_SC.delegate && [weakSelf_SC.delegate respondsToSelector:@selector(logisticsAction:)]) {
                [weakSelf_SC.delegate logisticsAction:logisticsActionWithInfo];
            }
        } forControlEvents:UIControlEventTouchUpInside];
        
        //太丑
        self.addLogisticsButton = [[UIButton alloc] initWithFrame:CGRectMake(50, _logisticsInfoButton.selfMaxY + 19, kScreen_Width-100, 36)];
        [self.addLogisticsButton setTitle:@" 添加收货地址+" forState:UIControlStateNormal];
        self.addLogisticsButton.layer.cornerRadius = 5;
        self.addLogisticsButton.layer.borderColor = [UIColor colorWithRed:0.325 green:0.843 blue:0.412 alpha:1].CGColor;
        self.addLogisticsButton.layer.borderWidth = 1;
        [self.addLogisticsButton setTitleColor:[UIColor colorWithRed:0.325 green:0.843 blue:0.412 alpha:1] forState:UIControlStateNormal];
        [self.addLogisticsButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
        self.addLogisticsButton.hidden = YES;
        [self.addLogisticsButton bk_addEventHandler:^(id sender) {
            if (weakSelf_SC.delegate && [weakSelf_SC.delegate respondsToSelector:@selector(logisticsAction:)]) {
                [weakSelf_SC.delegate logisticsAction:logisticsActionWithAddAddress];
            }
        } forControlEvents:UIControlEventTouchUpInside];
        
        //地址label
        if ([UIScreen mainScreen].bounds.size.height <=569){
            self.logisticsInfoLable = [[UILabel alloc] initWithFrame:CGRectMake(20, _logisticsInfoButton.selfMaxY + 18, kScreen_Width - 40, 0)];
        }else{
            self.logisticsInfoLable = [[UILabel alloc] initWithFrame:CGRectMake(20, _logisticsInfoButton.selfMaxY + 90, kScreen_Width - 40, 0)];
        }
        [self.logisticsInfoLable setTextColor:[UIColor colorWithRed:0.537 green:0.537 blue:0.537 alpha:1]];
        [self.logisticsInfoLable setFont:[UIFont systemFontOfSize:16]];
        [self.logisticsInfoLable setTextAlignment:NSTextAlignmentCenter];
        self.logisticsInfoLable.hidden = YES;
        self.logisticsInfoLable.userInteractionEnabled = YES;
        //自动换行
        self.logisticsInfoLable.numberOfLines = 0;
        [self.logisticsInfoLable bk_whenTapped:^{
            if (weakSelf_SC.delegate && [weakSelf_SC.delegate respondsToSelector:@selector(logisticsAction:)]) {
                [weakSelf_SC.delegate logisticsAction:logisticsActionWithAddAddress];
            }
        }];
//        
//        if (TARGET_IS_MINIU_BUYER){
//            //添加退款功能
//            UIButton *btnRefund = [UIButton buttonWithType:(UIButtonTypeSystem)];
//            [btnRefund setTitle:@"申请退款" forState:(UIControlStateNormal)];
//            [btnRefund setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
//            btnRefund.frame = CGRectMake(kScreen_Width/2-70, self.logisticsInfoLable.selfMaxY+20, 140, 150);
//            
//            [btnRefund bk_addEventHandler:^(id sender) {
////                [self showHudSuccess:@"申请退款成功"];
//                if (weakSelf_SC.delegate && [weakSelf_SC.delegate respondsToSelector:@selector(logisticsAction:)]) {
//                    [weakSelf_SC.delegate logisticsAction:logisticsActionWithRefund];
//                }
//            } forControlEvents:(UIControlEventTouchUpInside)];
//            
//            [self addSubview:btnRefund];
//        }
        [self addSubview:self.topTipLable];
        [self addSubview:self.centerTipLable];
        [self addSubview:self.logisticsInfoButton];
        [self addSubview:self.addLogisticsButton];
        [self addSubview:self.logisticsInfoLable];
    }
    self.userInteractionEnabled = YES;
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.frame = CGRectMake(0, 145 + 30, kScreen_Width, _logisticsInfoButton.selfMaxY + 60);
}

- (void)setOrder:(OrderEntity *)order
{
    _order = order;
    
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
