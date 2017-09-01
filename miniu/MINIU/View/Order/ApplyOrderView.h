//
//  ApplyOrderCell.h
//  miniu
//
//  Created by SimMan on 15/6/1.
//  Copyright (c) 2015年 SimMan. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UITTTAttributedLabel.h"

@interface ApplyOrderView : UIView

@property (nonatomic, strong) UIImageView *goodsImageView;
@property (nonatomic, strong) UITTTAttributedLabel *goodsDetailsLable;
@property (nonatomic, strong) UILabel *goodsPriceLable;
@property (nonatomic, strong) UITTTAttributedLabel *orderNoLable;
@property (nonatomic, strong) UILabel *createTimeLable;

@property (nonatomic, strong) OrderEntity *orderEntity;

@property (nonatomic, strong) UIColor *backGroundColor;

@property (nonatomic, assign) BOOL isEnableBottomLine;

@end
