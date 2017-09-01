//
//  GoodsDeailsCell.m
//  miniu
//  最后的cell 有收藏 微信好友 有微信朋友圈的界面
//  Created by SimMan on 4/27/15.
//  Copyright (c) 2015 SimMan. All rights reserved.
//

#import "GoodsDeailsCell.h"

@interface GoodsDeailsCell()

@property (nonatomic, copy) void(^favButtonBlock)(GoodsEntity *goods);

@property (nonatomic, strong) UIButton *favButton;

@end

@implementation GoodsDeailsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.favButton];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    
    self.backgroundColor = [UIColor colorWithRed:1.000 green:1.000 blue:1.000 alpha:1];

    CGFloat favButtonX = kScreen_Width - 10 - 50;
    CGFloat favButtonY = self.cellFrame.priceAndLikesLableFrame.origin.y;
    CGFloat favButtonW = 50;
    CGFloat favButtonH = 16;
    
    self.favButton.frame = CGRectMake(favButtonX, favButtonY, favButtonW, favButtonH);
    
//    self.favButton.layer.borderWidth = 1;
//    self.favButton.layer.cornerRadius = 10;
//    self.favButton.layer.borderColor = [UIColor grayColor].CGColor;
    
    CGRect moreButtonFrame = self.favButton.frame;
    moreButtonFrame.origin.x -= 5;
    moreButtonFrame.size.width += 10;
    moreButtonFrame.size.height += 10;
    self.moreButtonView.frame = moreButtonFrame;
    
    [self.favButton setSelected:self.cellFrame.goodsEntity.isMyLike];

    // 隐藏更多按钮
    self.moreButton.hidden = YES;
//    self.moreButtonView.hidden = YES;
}

- (UIButton *)favButton
{
    if (!_favButton) {
        _favButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [_favButton setTitle:@"收藏" forState:UIControlStateNormal];
        [_favButton setBackgroundImage:[UIImage imageNamed:@"详情页-收藏normal"] forState:UIControlStateNormal];
        [_favButton setBackgroundImage:[UIImage imageNamed:@"详情页-收藏focus"] forState:UIControlStateSelected];
        [_favButton.titleLabel setFont:[UIFont systemFontOfSize:13]];
        _favButton.titleEdgeInsets = UIEdgeInsetsMake(3, 21, 0, 0);
        [_favButton addTarget:self action:@selector(favButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_favButton setTitleColor:[UIColor colorWithRed:0.553 green:0.553 blue:0.557 alpha:1] forState:UIControlStateNormal];
    }
    return _favButton;
}

- (void) showMoreButtonAction
{
    [self favButtonAction:self.favButton];
}

- (void) favButtonAction:(UIButton *)sender
{
    [sender setSelected:!sender.isSelected];
    if (_favButtonBlock) {
        _favButtonBlock(self.cellFrame.goodsEntity);
    }
}

- (void)favButtonActionBlock:(void (^)(GoodsEntity *))block
{
    _favButtonBlock = block;
}

@end
