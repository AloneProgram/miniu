//
//  ApplyOrderTableViewCell.m
//  miniu
//
//  Created by SimMan on 5/9/15.
//  Copyright (c) 2015 SimMan. All rights reserved.
//

#import "ApplyOrderTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

@interface ApplyOrderTableViewCell()

@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *nickNameLable;
@property (nonatomic, strong) UILabel *timeLable;
@property (nonatomic, strong) UILabel *desLable;


@property (nonatomic, strong) UIImageView *goodsImageView;
@property (nonatomic, strong) UIView *goodsBackgroundView;
@property (nonatomic, strong) UILabel *goodsDesLable;

@property (nonatomic, strong) UIView *lineView;

@end

@implementation ApplyOrderTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.contentView.backgroundColor = [UIColor colorWithRed:0.953 green:0.957 blue:0.976 alpha:1];
        
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(52, 0, kScreen_Width, 0.7)];
        _lineView.backgroundColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_lineView];
        
        // 头像
        self.avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 32, 32)];
        [self.avatarImageView doCircleFrameNoBorder];
        self.avatarImageView.userInteractionEnabled = YES;
        [self.contentView addSubview:self.avatarImageView];
        
        // 昵称
        self.nickNameLable = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.avatarImageView.frame) + 10, CGRectGetMinY(self.avatarImageView.frame), kScreen_Width - self.avatarImageView.selfW - 50, 20)];
        self.nickNameLable.userInteractionEnabled = YES;
        [self.nickNameLable setFont:[UIFont systemFontOfSize:14]];
        [self.nickNameLable setTextColor:[UIColor colorWithRed:0.255 green:0.463 blue:0.663 alpha:1]];
        [self.contentView addSubview:self.nickNameLable];
        
        // 添加手势
        UITapGestureRecognizer *avatarSingleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarImageTap:)];
        
        UITapGestureRecognizer *nickNameSingleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarImageTap:)];
        [self.avatarImageView addGestureRecognizer:avatarSingleRecognizer];
        [self.nickNameLable addGestureRecognizer:nickNameSingleRecognizer];
        
        // 时间
        self.timeLable = [[UILabel alloc] initWithFrame:CGRectMake(kScreen_Width - 50 - 10, CGRectGetMinY(self.nickNameLable.frame) + 5, 50, 20)];
        [self.timeLable setFont:[UIFont systemFontOfSize:10]];
        [self.timeLable setTextColor:[UIColor lightGrayColor]];
        self.timeLable.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:self.timeLable];
        
        // 内容
        self.desLable = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.nickNameLable.frame), CGRectGetMaxY(self.nickNameLable.frame) + 5, kScreen_Width - CGRectGetMaxX(self.avatarImageView.frame) - 20, 20)];
        [self.desLable setFont:[UIFont systemFontOfSize:12]];
        [self.desLable setTextColor:[UIColor darkGrayColor]];
        [self.desLable setText:@"申请了如下代购产品"];
        [self.contentView addSubview:self.desLable];
        
        
        // 商品背景
        self.goodsBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.nickNameLable.frame), CGRectGetMaxY(self.desLable.frame) + 10, kScreen_Width - CGRectGetMaxX(self.avatarImageView.frame) - 20, 70)];
        self.goodsBackgroundView.backgroundColor = [UIColor whiteColor];
        self.goodsBackgroundView.layer.borderWidth = 0.5;
        self.goodsBackgroundView.layer.borderColor = [RGBACOLOR(207, 210, 213, 0.7) CGColor];
        self.goodsBackgroundView.userInteractionEnabled = YES;
        [self.contentView addSubview:self.goodsBackgroundView];
        
        // 商品图片
        self.goodsImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 50, 50)];
        [self.goodsBackgroundView addSubview:self.goodsImageView];
        self.goodsImageView.userInteractionEnabled = YES;
        
        // 商品描述
        self.goodsDesLable = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.goodsImageView.frame) + 10, CGRectGetMinY(self.goodsImageView.frame), self.goodsBackgroundView.selfW - self.goodsImageView.selfW - 30, 20)];
        self.goodsDesLable.numberOfLines = 0;
        [self.goodsDesLable setFont:[UIFont systemFontOfSize:12]];
        [self.goodsDesLable setTextColor:[UIColor darkGrayColor]];
        [self.goodsBackgroundView addSubview:self.goodsDesLable];
        self.goodsDesLable.userInteractionEnabled = YES;
        
        // 添加手势
        UITapGestureRecognizer *goodsImageSingleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goodsTap:)];

        UITapGestureRecognizer *goodsBacSingleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goodsTap:)];
        
        UITapGestureRecognizer *goodsDesSingleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goodsTap:)];
        
        [self.goodsDesLable addGestureRecognizer:goodsDesSingleRecognizer];
        [self.goodsBackgroundView addGestureRecognizer:goodsBacSingleRecognizer];
        [self.goodsImageView addGestureRecognizer:goodsImageSingleRecognizer];
        
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // 头像
    [self.avatarImageView setImageWithUrl:self.log.avatar withSize:ImageSizeOf64];
    
    // 昵称
    [self.nickNameLable setText:self.log.nickName];
    
    // 时间
    NSDate *create_date = [NSDate dateWithTimeIntervalInMilliSecondSince1970:self.log.timeStamp];
    [self.timeLable setText:[NSString stringWithFormat:@"%@", [create_date timeIntervalDescription]]];
    
    // 商品图片
    [self.goodsImageView setImageWithUrl:self.log.goodsImg withSize:ImageSizeOf100];
    
    // 描述
    [self.goodsDesLable setLongString:self.log.content withFitWidth:(self.goodsBackgroundView.selfW - self.goodsImageView.selfW - 30) maxHeight:50.0f];
    
    CGRect frame = _lineView.frame;
    frame.origin.y = self.contentView.frame.size.height - 1;
    _lineView.frame = frame;
    
    
    if (self.log.isRead) {
        self.timeLable.textColor = [UIColor lightGrayColor];
    } else {
        self.timeLable.textColor = [UIColor colorWithRed:0.804 green:0.200 blue:0.200 alpha:1];
    }
}

- (void) avatarImageTap:(UITapGestureRecognizer *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(avatarImageViewDidTap:)]) {
        [self.delegate avatarImageViewDidTap:self.log];
    }
}

- (void) goodsTap:(UITapGestureRecognizer *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(goodsDidTap:)]) {
        [self.delegate goodsDidTap:self.log];
    }
}

@end
