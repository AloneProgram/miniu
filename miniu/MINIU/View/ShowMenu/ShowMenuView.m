
//
//  ShowMenuView.m
//  miniu
//
//  Created by SimMan on 4/23/15.
//  Copyright (c) 2015 SimMan. All rights reserved.
//

#import "ShowMenuView.h"
#import "HomeTableViewCell.h"
#import "GoodsEntity.h"

#define SELF_BACKGROUND_COLOR [UIColor colorWithRed:0.243 green:0.192 blue:0.376 alpha:1]
#define FAV_BUTTON_FRAME CGRectMake(12, (self.bounds.size.height - 23) / 2, 55, 23)
#define FAV_BUTTON_TOP_FRAME CGRectMake(0, 0, SELF_WIDTH / 2, SELF_HEIGHT)
#define BUY_BUTTON_FRAME CGRectMake(90, (self.bounds.size.height - 23) / 2, 75, 23)
#define BUY_BUTTON_TOP_FRAME CGRectMake(SELF_WIDTH / 2, 0, SELF_WIDTH / 2 ,SELF_HEIGHT)

#define SELF_WIDTH   190
#define SELF_HEIGHT  42

@interface ShowMenuView()

@property (nonatomic, strong) UIButton *favButton;
@property (nonatomic, strong) UIButton *buyButton;

@property (nonatomic, assign) BOOL isShow;

@property (nonatomic, strong) HomeTableViewCell *cell;

@end

@implementation ShowMenuView


+ (instancetype)shareInstance
{
    static ShowMenuView * instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = SELF_BACKGROUND_COLOR;
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 5;
        
        [self addSubview:[self favButton]];
        UIButton *favTopButton = [[UIButton alloc] initWithFrame:FAV_BUTTON_TOP_FRAME];
        [favTopButton addTarget:self action:@selector(favButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:favTopButton];
        
        [self addSubview:[self buyButton]];
        UIButton *buyTopButton = [[UIButton alloc] initWithFrame:BUY_BUTTON_TOP_FRAME];
        [buyTopButton addTarget:self action:@selector(buyButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:buyTopButton];
        
        _isShow = NO;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.favButton.frame = FAV_BUTTON_FRAME;
    self.buyButton.frame = BUY_BUTTON_FRAME;
}

+ (void) showViewIn:(UIView *)view withObject:(HomeTableViewCell *)cell
{
    ShowMenuView *showMenuView = [ShowMenuView shareInstance];
    [showMenuView.favButton setSelected:cell.cellFrame.goodsEntity.isMyLike];
 
    showMenuView.cell = cell;
    
    if (showMenuView.isShow) {
        showMenuView.isShow = NO;
        [ShowMenuView hidden];
    } else {
        showMenuView.isShow = YES;
        CGFloat showMenuViewX = view.frame.origin.x - SELF_WIDTH;
        CGFloat showMenuViewY = view.frame.origin.y - 10;
        CGFloat showMenuViewW = SELF_WIDTH;
        CGFloat showMenuViewH = SELF_HEIGHT;
        
        CGRect showMenuViewFrame = CGRectMake(showMenuViewX, showMenuViewY, showMenuViewW, showMenuViewH);
        
        [view.superview addSubview:showMenuView];
        
        [UIView animateWithDuration:0 animations:^{
            showMenuView.frame = CGRectMake(showMenuViewX + showMenuViewW, showMenuViewY, 1, showMenuViewH);
            showMenuView.alpha = 0.1;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3 animations:^{
                showMenuView.frame = showMenuViewFrame;
                showMenuView.alpha = 1;
            } completion:^(BOOL finished) {
            }];
        }];
    }
}

+ (void)hidden
{
    
    ShowMenuView *showMenuView = [ShowMenuView shareInstance];

    showMenuView.isShow = NO;
    
    CGFloat showMenuViewX = showMenuView.frame.origin.x;
    CGFloat showMenuViewY = showMenuView.frame.origin.y;
    CGFloat showMenuViewW = SELF_WIDTH;
    CGFloat showMenuViewH = SELF_HEIGHT;
    
    [UIView animateWithDuration:0.3 animations:^{
        showMenuView.frame = CGRectMake(showMenuViewX + showMenuViewW, showMenuViewY, 1, showMenuViewH);
    } completion:^(BOOL finished) {
        [showMenuView removeFromSuperview];
    }];
}

- (UIButton *)favButton
{
    if (!_favButton) {
        _favButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [_favButton setBackgroundImage:[UIImage imageNamed:@"收藏-normal"] forState:UIControlStateNormal];
        [_favButton setTitle:@"收藏" forState:UIControlStateNormal];
        [_favButton setBackgroundImage:[UIImage imageNamed:@"收藏-focus"] forState:UIControlStateSelected];
        [_favButton.titleLabel setFont:[UIFont systemFontOfSize:13]];
        _favButton.titleEdgeInsets = UIEdgeInsetsMake(3, 21, 0, 0);
    }
    return _favButton;
}

- (UIButton *)buyButton
{
    if (!_buyButton) {
        _buyButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [_buyButton setBackgroundImage:[UIImage imageNamed:@"买买买"] forState:UIControlStateNormal];
        [_buyButton setTitle:@"一键代购" forState:UIControlStateNormal];
        [_buyButton.titleLabel setFont:[UIFont systemFontOfSize:13]];
        _buyButton.titleEdgeInsets = UIEdgeInsetsMake(3, 23, 0, 0);
    }
    return _buyButton;
}


- (void) favButtonAction:(UIButton *)sender
{
    sender = self.favButton;
    [sender setSelected:!sender.isSelected];
    if (self.delegate && [self.delegate respondsToSelector:@selector(favoriteButtonAction:object:)]) {
        [self.delegate favoriteButtonAction:sender.isSelected object:self.cell];
    }
}

- (void) buyButtonAction:(UIButton *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(buyButtonOnClickobject:)]) {
        [self.delegate buyButtonOnClickobject:self.cell];
    }
}

@end
