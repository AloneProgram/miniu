//
//  OrderListTableViewCell.m
//  miniu
//
//  Created by SimMan on 15/6/4.
//  Copyright (c) 2015年 SimMan. All rights reserved.
//

#import "OrderListTableViewCell.h"

#import "OrderEntity.h"

@interface OrderListTableViewCell()

@property (nonatomic, strong) UIImageView *goodsImageView;
@property (nonatomic, strong) UILabel *orderNoLable;
@property (nonatomic, strong) UILabel *goodsDescriptionLable;
@property (nonatomic, strong) UILabel *createTimeLable;
@property (nonatomic, strong) UILabel *orderPriceLable;
@property (nonatomic, strong) UILabel *orderStatusLable;

@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel     *nickNameLable;

@property (nonatomic, copy) void (^_Blocks)(OrderEntity *);

@end


@implementation OrderListTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        // 图片
        _goodsImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 15, 100, 100)];
        
//        // 订单号
//        _orderNoLable = [[UILabel alloc] initWithFrame:CGRectMake(_goodsImageView.selfMaxX + 10, _goodsImageView.selfMinY, 150, 15)];
//        [_orderNoLable setFont:[UIFont systemFontOfSize:11]];
//        [_orderNoLable setTextColor:[UIColor colorWithRed:0.624 green:0.624 blue:0.624 alpha:1]];
//        
//        // 时间
//        _createTimeLable = [[UILabel alloc] initWithFrame:CGRectMake(kScreen_Width - 150 - 10, _goodsImageView.selfMinY, 150, 15)];
//        [_createTimeLable setTextAlignment:NSTextAlignmentRight];
//        [_createTimeLable setFont:[UIFont systemFontOfSize:11]];
//        [_createTimeLable setTextColor:[UIColor colorWithRed:0.624 green:0.624 blue:0.624 alpha:1]];
        
        
        // 描述
        _goodsDescriptionLable = [[UILabel alloc] initWithFrame:CGRectMake(_goodsImageView.selfMaxX + 10, _goodsImageView.selfMinY, kScreen_Width - _goodsImageView.selfMaxX - 10 - 10, 0)];
        [_goodsDescriptionLable setTextColor:[UIColor colorWithRed:0.439 green:0.439 blue:0.439 alpha:1]];
        [_goodsDescriptionLable setFont:[UIFont systemFontOfSize:13]];
        
        // 价格
        _orderPriceLable  = [[UILabel alloc] initWithFrame:CGRectMake(_goodsImageView.selfMaxX + 10, _goodsImageView.selfMaxY - 15, 120, 15)];
        [_orderPriceLable setFont:[UIFont systemFontOfSize:15]];
        [_orderPriceLable setTextColor:[UIColor colorWithRed:0.439 green:0.439 blue:0.439 alpha:1]];
        
        
        
        // 线
        UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(_goodsImageView.selfX, _goodsImageView.selfMaxY + 15, kScreen_Width - _goodsImageView.selfX, 0.5)];
        [line setBackgroundColor:[UIColor lightGrayColor]];
        
        
        // 头像
        _avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(_goodsImageView.selfX, line.selfY + 10, 34, 34)];
        [_avatarView doCircleFrameNoBorder];
        
        // 昵称
        _nickNameLable = [[UILabel alloc] initWithFrame:CGRectMake(_avatarView.selfMaxX + 5, 0, 120, 15)];
        [_nickNameLable setTextColor:[UIColor colorWithRed:0.486 green:0.486 blue:0.486 alpha:1]];
        [_nickNameLable setFont:[UIFont systemFontOfSize:11]];
        _nickNameLable.center = CGPointMake(_nickNameLable.center.x, _avatarView.center.y);
        
        // 状态
        
        _orderStatusLable = [[UILabel alloc] initWithFrame:CGRectMake(kScreen_Width - 150 - 10, _goodsImageView.selfMaxY - 15, 150, 15)];
        [_orderStatusLable setTextAlignment:NSTextAlignmentRight];
        [_orderStatusLable setFont:[UIFont systemFontOfSize:15]];
        [_orderStatusLable setTextColor:[UIColor colorWithRed:0.918 green:0.412 blue:0.282 alpha:1]];
        _orderStatusLable.center = CGPointMake(_orderStatusLable.center.x, _avatarView.center.y);
        
        [self.contentView addSubview:_goodsImageView];
//        [self.contentView addSubview:_orderNoLable];
//        [self.contentView addSubview:_createTimeLable];
        [self.contentView addSubview:_goodsDescriptionLable];
        [self.contentView addSubview:_orderPriceLable];
        [self.contentView addSubview:line];
        [self.contentView addSubview:_avatarView];
        [self.contentView addSubview:_nickNameLable];
        [self.contentView addSubview:_orderStatusLable];
        
        _avatarView.userInteractionEnabled = YES;
        _nickNameLable.userInteractionEnabled = YES;
        
        WeakSelf
        [_avatarView bk_whenTapped:^{
            if (weakSelf_SC._Blocks) {
                weakSelf_SC._Blocks(weakSelf_SC.order);
            }
        }];
        
        [_nickNameLable bk_whenTapped:^{
            if (weakSelf_SC._Blocks) {
                weakSelf_SC._Blocks(weakSelf_SC.order);
            }
        }];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    
    [self.goodsImageView setImageWithUrl:self.order.firstImageUrl withSize:ImageSizeOfAuto];
//    [self.orderNoLable setText:[NSString stringWithFormat:@"No：%@", self.order.orderNo]];
//
//    NSDate *create_date = [NSDate dateWithTimeIntervalInMilliSecondSince1970:_order.createTime];
//    [self.createTimeLable setText:[NSString stringWithFormat:@"%@", [create_date formattedTime]]];

    //自适应文本长度值//
    [self.goodsDescriptionLable setLongString:self.order.depictRemark withFitWidth:self.goodsDescriptionLable.selfW maxHeight:65];
    
    [self.orderPriceLable setText:[NSString stringWithFormat:@"￥%0.2f", self.order.totalAmount]];
    [self.orderStatusLable setText:[NSString stringWithFormat:@"%@", [OrderEntity getOrderStatusStringWith:self.order.orderStatus]]];
    
    [_avatarView setImageWithUrl:self.order.applyAvatar withSize:ImageSizeOfAuto];
    [_nickNameLable setText:[NSString stringWithFormat:@"%@", self.order.applyNickName]];
}


- (void)awakeFromNib {
    // Initialization code
}

- (void)tapAvatarImageViewCallBackBlock:(void (^)(OrderEntity *))Block
{
    __Blocks = Block;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
