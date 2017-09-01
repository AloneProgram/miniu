//
//  LogisticsTableViewCell.m
//  miniu
//
//  Created by SimMan on 15/6/8.
//  Copyright (c) 2015年 SimMan. All rights reserved.
//

#import "LogisticsTableViewCell.h"
#import "UITTTAttributedLabel.h"

#define KUAIDI_ICON_W  35.0f

@interface LogisticsTableViewCell()

@property (nonatomic, strong) UILabel *YMDTimeLable;
@property (nonatomic, strong) UILabel *HISTimeLable;
@property (nonatomic, strong) UITTTAttributedLabel *detailsLable;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *line;

@property (nonatomic, strong) UIImageView *kuaidiIcon;

@end

@implementation LogisticsTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self.contentView addSubview:self.YMDTimeLable];
        [self.contentView addSubview:self.HISTimeLable];
        
        // 竖线
        _line = [[UILabel alloc] initWithFrame:CGRectMake(75, 0, 0.5, 0)];
        [_line setBackgroundColor:[UIColor lightGrayColor]];
        [self.contentView addSubview:_line];
        
        // icon
        self.iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(_line.selfMaxX - 7.5, 0, 15, 15)];
        
        [self.contentView addSubview:self.iconImageView];
        [self.contentView addSubview:self.detailsLable];
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    //时间
    NSDate *create_date = [NSDate dateWithTimeIntervalInMilliSecondSince1970:_logistics.createTime];
    [self.YMDTimeLable setText:[NSString stringWithFormat:@"%@", [create_date formattedDateForYMDWithPoint]]];
    [self.HISTimeLable setText:[NSString stringWithFormat:@"%@", [create_date formattedDateForHI]]];
    
    
    // 先搞定详情
    CGFloat contentW = kScreen_Width - 75 - 20 - 10;
    
    BOOL isHaveKuaidi = NO;
    if (![self.logistics.code length] && [self.logistics.invoiceNo length]) {
        contentW -= KUAIDI_ICON_W;
        isHaveKuaidi = YES;
        NSString *kuaidiIconStr = [NSString stringWithFormat:@"%@", self.logistics.company];
        [self.kuaidiIcon setImage:[UIImage imageNamed:kuaidiIconStr]];
    }
    
    CGSize contentSize = [_logistics.content getSizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(contentW, CGFLOAT_MAX)];
    
    CGFloat cellHeight;
    
    if (contentSize.height < 60) {
        contentSize.height = 60;
        cellHeight = contentSize.height;
    } else {
        cellHeight = contentSize.height + 6 + 6;
    }
    
    //拼接字符串 应当设置为物流信息直接显示
    if(![self.logistics.invoiceNo isEqualToString:@""]){
        [self.detailsLable setText:[NSString stringWithFormat:@"%@ 快递单号:%@", self.logistics.content,self.logistics.invoiceNo]];
    }else{
        [self.detailsLable setText:[NSString stringWithFormat:@"%@", self.logistics.content]];
    }
    
    //详情布局
    [self.detailsLable setFrame:CGRectMake(self.detailsLable.selfX, self.detailsLable.selfY, contentW, contentSize.height)];
    
    // KUAIDIICON
    [self.kuaidiIcon setX:[self.detailsLable selfMaxX] + 5];
    [self.kuaidiIcon setY:(cellHeight+KUAIDI_ICON_W) /2];
    
    self.kuaidiIcon.backgroundColor = [UIColor orangeColor];
    
    // 确定时间的位置
    [self.YMDTimeLable setY:(cellHeight / 2 - 25)];
    [self.HISTimeLable setY:(cellHeight / 2 - 10)];
    
    // 确定线的位置
    [self.line setHeight:cellHeight];
    
    // 图片
    [self.iconImageView setY:(cellHeight/2 - 7)];
    
    if (self.isLast) {
        
//        UILabel *topLine = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 0.5, kScreen_Width, 0.5)];
//        [topLine setBackgroundColor:[UIColor lightGrayColor]];
//        [self.contentView addSubview:topLine];
        
        if (_isFinished) {
            [self.iconImageView setImage:[UIImage imageNamed:@"icon_result_signed"]];
            [self.YMDTimeLable setTextColor:[UIColor colorWithRed:0.192 green:0.525 blue:0.898 alpha:1]];
            [self.HISTimeLable setTextColor:[UIColor colorWithRed:0.192 green:0.525 blue:0.898 alpha:1]];
            [self.detailsLable setTextColor:[UIColor colorWithRed:0.192 green:0.525 blue:0.898 alpha:1]];
        } else {
            [self.iconImageView setImage:[UIImage imageNamed:@"icon_result_onloading"]];
            [self.YMDTimeLable setTextColor:[UIColor colorWithRed:0.988 green:0.357 blue:0.125 alpha:1]];
            [self.HISTimeLable setTextColor:[UIColor colorWithRed:0.988 green:0.357 blue:0.125 alpha:1]];
            [self.detailsLable setTextColor:[UIColor colorWithRed:0.988 green:0.357 blue:0.125 alpha:1]];
        }
    } else {
        [self.iconImageView setImage:[UIImage imageNamed:@"icon_result_onload"]];
        [self.YMDTimeLable setTextColor:[UIColor darkGrayColor]];
        [self.HISTimeLable setTextColor:[UIColor darkGrayColor]];
        [self.detailsLable setTextColor:[UIColor darkGrayColor]];
    }
}

- (void)setLogistics:(LogisticsEntity *)logistics
{
    _logistics = logistics;
    
    if (self.isLast) {
        
        //        UILabel *topLine = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 0.5, kScreen_Width, 0.5)];
        //        [topLine setBackgroundColor:[UIColor lightGrayColor]];
        //        [self.contentView addSubview:topLine];
        
        if (_isFinished) {
            [self.iconImageView setImage:[UIImage imageNamed:@"icon_result_signed"]];
            [self.YMDTimeLable setTextColor:[UIColor colorWithRed:0.192 green:0.525 blue:0.898 alpha:1]];
            [self.HISTimeLable setTextColor:[UIColor colorWithRed:0.192 green:0.525 blue:0.898 alpha:1]];
            [self.detailsLable setTextColor:[UIColor colorWithRed:0.192 green:0.525 blue:0.898 alpha:1]];
        } else {
            [self.iconImageView setImage:[UIImage imageNamed:@"icon_result_onloading"]];
            [self.YMDTimeLable setTextColor:[UIColor colorWithRed:0.988 green:0.357 blue:0.125 alpha:1]];
            [self.HISTimeLable setTextColor:[UIColor colorWithRed:0.988 green:0.357 blue:0.125 alpha:1]];
            [self.detailsLable setTextColor:[UIColor colorWithRed:0.988 green:0.357 blue:0.125 alpha:1]];
        }
    } else {
        [self.iconImageView setImage:[UIImage imageNamed:@"icon_result_onload"]];
        [self.YMDTimeLable setTextColor:[UIColor darkGrayColor]];
        [self.HISTimeLable setTextColor:[UIColor darkGrayColor]];
        [self.detailsLable setTextColor:[UIColor darkGrayColor]];
    }
}

+ (CGFloat) cellHeightWith:(LogisticsEntity *)logistics
{
    CGFloat contentW = kScreen_Width - 75 - 20 - 10;
    
    if ([logistics.code length] && [logistics.invoiceNo length]) {
        contentW -= KUAIDI_ICON_W;
    }
    
    CGSize contentSize = [logistics.content getSizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(contentW, CGFLOAT_MAX)];
    
    CGFloat cellHeight = contentSize.height + 6 + 6;
    if (cellHeight < 60) {
        return 60.0f;
    }
    return cellHeight;
}

- (UIImageView *)kuaidiIcon
{
    if (!_kuaidiIcon) {
        _kuaidiIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, KUAIDI_ICON_W, KUAIDI_ICON_W)];
    }
    return _kuaidiIcon;
}

- (UITTTAttributedLabel *)detailsLable
{
    if (!_detailsLable) {
        _detailsLable = [[UITTTAttributedLabel alloc] initWithFrame:CGRectMake(75 + 20, 6, kScreen_Width - self.line.selfMaxX + 10 + 10, 0)];
        [_detailsLable setTextAlignment:NSTextAlignmentLeft];
        [_detailsLable setTextColor:[UIColor darkGrayColor]];
        [_detailsLable setFont:[UIFont systemFontOfSize:14]];
        [_detailsLable setNumberOfLines:0];
    }
    return _detailsLable;
}

- (UILabel *)YMDTimeLable
{
    if (!_YMDTimeLable) {
        _YMDTimeLable = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 60, 35)];
        [_YMDTimeLable setTextColor:[UIColor darkGrayColor]];
        [_YMDTimeLable setFont:[UIFont systemFontOfSize:10]];
        [_YMDTimeLable setTextAlignment:NSTextAlignmentCenter];
    }
    return _YMDTimeLable;
}

- (UILabel *)HISTimeLable
{
    if (!_HISTimeLable) {
        _HISTimeLable = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 60, 35)];
        [_HISTimeLable setTextColor:[UIColor darkGrayColor]];
        [_HISTimeLable setFont:[UIFont systemFontOfSize:18]];
        [_HISTimeLable setTextAlignment:NSTextAlignmentCenter];
    }
    return _HISTimeLable;
}

@end
