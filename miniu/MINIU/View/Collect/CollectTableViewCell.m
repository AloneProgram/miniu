//
//  CollectTableViewCell.m
//  miniu
//
//  Created by SimMan on 4/27/15.
//  Copyright (c) 2015 SimMan. All rights reserved.
//

#import "CollectTableViewCell.h"
#import "RTLabel.h"
#import "GoodsEntity.h"

@interface CollectTableViewCell()

@property (nonatomic, strong) UIImageView *goodsImageView;
@property (nonatomic, strong) RTLabel *goodsDesLable;
@property (nonatomic, strong) RTLabel *goodsPriceLable;

@end

@implementation CollectTableViewCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self.contentView addSubview:self.goodsImageView];
        [self.contentView addSubview:self.goodsDesLable];
        [self.contentView addSubview:self.goodsPriceLable];
    }
    return self;
}

- (UIImageView *)goodsImageView
{
    if (!_goodsImageView) {
        _goodsImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 90, 90)];
    }
    
    return _goodsImageView;
}

- (RTLabel *) goodsDesLable
{
    if (!_goodsDesLable) {
        _goodsDesLable = [[RTLabel alloc] initWithFrame:CGRectZero];
        _goodsDesLable.font = [UIFont systemFontOfSize:14];
        _goodsDesLable.textColor = [UIColor blackColor];
    }
    return _goodsDesLable;
}

- (RTLabel *)goodsPriceLable
{
    if (!_goodsPriceLable) {
        _goodsPriceLable = [[RTLabel alloc] initWithFrame:CGRectZero];
        _goodsPriceLable.font = [UIFont systemFontOfSize:14];
        _goodsPriceLable.textColor = [UIColor blackColor];
    }
    return _goodsPriceLable;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _goodsDesLable.frame = CGRectMake(_goodsImageView.selfW + 25, 10, kScreen_Width - _goodsImageView.selfW - 25 - 10 - 10, 60);
    
    _goodsPriceLable.frame = CGRectMake(_goodsImageView.selfW + 25, self.selfH - 25, 150, 15);
}

- (void)setGoodsEntity:(GoodsEntity *)goodsEntity
{
    _goodsEntity = goodsEntity;
    
    [self.goodsImageView setImageWithUrl:goodsEntity.firstImageUrl withSize:ImageSizeOfAuto];
    
    [self.goodsDesLable setText:goodsEntity.goodsDescription];
    self.goodsDesLable.textColor = [UIColor darkGrayColor];
    
    [self.goodsPriceLable setText:[NSString stringWithFormat:@"%@", [NSString formatPriceWithPrice:[_goodsEntity.price doubleValue]]]];
    self.goodsPriceLable.textColor = [UIColor darkGrayColor];
}



@end
