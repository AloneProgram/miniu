//
//  ApplyOrderCell.m
//  miniu
//
//  Created by SimMan on 15/6/1.
//  Copyright (c) 2015年 SimMan. All rights reserved.
//

#import "ApplyOrderView.h"

#import "PhotoZooo.h"

@implementation ApplyOrderView


- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.backgroundColor = [UIColor colorWithRed:0.922 green:0.922 blue:0.922 alpha:1];
        
        self.userInteractionEnabled = YES;
        
        _goodsImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 20, 100, 100)];
        [self addSubview:_goodsImageView];
        
        _goodsImageView.userInteractionEnabled = YES;
        [_goodsImageView bk_whenTapped:^{
            [[PhotoZooo shareInstance] showImageWithArray:@[self.orderEntity.firstImageUrl] setInitialPageIndex:0 withController:[self getViewController]];
        }];
        
        
        _goodsDetailsLable = [[UITTTAttributedLabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_goodsImageView.frame) + 6, CGRectGetMinY(_goodsImageView.frame), kScreen_Width - CGRectGetMaxX(_goodsImageView.frame) - 6 - 6, 100 - 25)];
        [_goodsDetailsLable setTextColor:[UIColor colorWithRed:0.333 green:0.333 blue:0.333 alpha:1]];
        [_goodsDetailsLable setFont:[UIFont systemFontOfSize:12]];
        [_goodsDetailsLable addLongPressForCopyWithBGColor:[UIColor colorWithRed:0.922 green:0.922 blue:0.922 alpha:1]];
        [self addSubview:_goodsDetailsLable];
        
        CGFloat goodsPriceX = kScreen_Width - CGRectGetMaxX(_goodsImageView.frame) - 60;
        _goodsPriceLable = [[UILabel alloc] initWithFrame:CGRectMake(goodsPriceX, CGRectGetMaxY(_goodsImageView.frame) - 25, kScreen_Width - goodsPriceX - 6, 25)];
        [_goodsPriceLable setTextAlignment:NSTextAlignmentRight];
        [_goodsPriceLable setTextColor:[UIColor colorWithRed:0.333 green:0.333 blue:0.333 alpha:1]];
        [_goodsPriceLable setFont:[UIFont systemFontOfSize:18]];
        [self addSubview:_goodsPriceLable];
        
        UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(_goodsImageView.frame) + 18, kScreen_Width - 10, 0.5)];
        [line setBackgroundColor:[UIColor colorWithRed:0.710 green:0.710 blue:0.710 alpha:1]];
        [self addSubview:line];
        
        _orderNoLable = [[UITTTAttributedLabel alloc] initWithFrame:CGRectMake(line.selfX, line.selfY + 7, (kScreen_Width - 20) / 2 + 30, 20)];
        [_orderNoLable setFont:[UIFont systemFontOfSize:12]];
        [_orderNoLable setTextColor:[UIColor colorWithRed:0.478 green:0.478 blue:0.478 alpha:1]];
        [_orderNoLable addLongPressForCopyWithBGColor:[UIColor colorWithRed:0.922 green:0.922 blue:0.922 alpha:1]];
        
        [self addSubview:_orderNoLable];
        
        _createTimeLable = [[UILabel alloc] initWithFrame:CGRectMake(_orderNoLable.selfW - 20, line.selfY + 7, (kScreen_Width - 20) / 2, 20)];
        [_createTimeLable setFont:[UIFont systemFontOfSize:12]];
        [_createTimeLable setTextColor:[UIColor colorWithRed:0.478 green:0.478 blue:0.478 alpha:1]];
        [_createTimeLable setTextAlignment:NSTextAlignmentRight];
        [self addSubview:_createTimeLable];
        
        UILabel *lineBottom = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_createTimeLable.frame)-0.5, kScreen_Width, 0.5)];
        [lineBottom setBackgroundColor:[UIColor colorWithRed:0.710 green:0.710 blue:0.710 alpha:1]];
        [self addSubview:lineBottom];
    }
    return self;
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    self.frame = CGRectMake(0, 0, kScreen_Width, _createTimeLable.selfMaxY);

    if (self.backGroundColor) {
        self.backgroundColor = self.backGroundColor;
    } else {
        self.backgroundColor = [UIColor colorWithRed:0.922 green:0.922 blue:0.922 alpha:1];
    }
    
    if (self.isEnableBottomLine) {
        UILabel *lineBottom = [[UILabel alloc] initWithFrame:CGRectMake(0, _createTimeLable.selfMaxY-0.5, kScreen_Width, 0.5)];
        [lineBottom setBackgroundColor:[UIColor colorWithRed:0.710 green:0.710 blue:0.710 alpha:1]];
        [self addSubview:lineBottom];
    }
}

- (void)setOrderEntity:(OrderEntity *)orderEntity
{
    _orderEntity = orderEntity;
    
    [self.goodsImageView setImageWithUrl:_orderEntity.firstImageUrl withSize:ImageSizeOfAuto];
    
    [self.goodsDetailsLable setLongString:_orderEntity.depictRemark withFitWidth:kScreen_Width - (CGRectGetMaxX(_goodsImageView.frame) + 6 + 6) maxHeight:100 - 25];
    
    [self.goodsPriceLable setText:[NSString stringWithFormat:@"￥%0.2f", [_orderEntity.price floatValue]]];
    
    [self.orderNoLable setText:[NSString stringWithFormat:@"订单号:%@", orderEntity.orderNo]];
    
    NSDate *create_date = [NSDate dateWithTimeIntervalInMilliSecondSince1970:_orderEntity.createTime];
    [self.createTimeLable setText:[NSString stringWithFormat:@"时间:%@", [create_date formattedDateForFull]]];
}



@end
