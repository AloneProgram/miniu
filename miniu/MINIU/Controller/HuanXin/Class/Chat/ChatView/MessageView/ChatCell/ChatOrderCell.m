//
//  ChatOrderCell.m
//  miniu
//
//  Created by SimMan on 15/6/11.
//  Copyright (c) 2015年 SimMan. All rights reserved.
//

#import "ChatOrderCell.h"
#import "UITTTAttributedLabel.h"
#import "OrderEntity.h"

@interface ChatOrderCell()

@property (nonatomic, strong) UIView *bgView;

@property (nonatomic, strong) UIImageView *goodsImageView;
@property (nonatomic, strong) UITTTAttributedLabel *goodsDetailsLable;
@property (nonatomic, strong) UITTTAttributedLabel *orderNoLable;
@property (nonatomic, strong) UITTTAttributedLabel *createTimeLable;
@property (nonatomic, strong) UITTTAttributedLabel *orderPrice;
@property (nonatomic, strong) UILabel *orderStatusLable;

@property (nonatomic, strong) UILabel *messageDetailsLable;

@end


@implementation ChatOrderCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
    
        self.contentView.backgroundColor = [UIColor colorWithRed:0.906 green:0.902 blue:0.906 alpha:1];
        
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(10, 2, kScreen_Width - 20, 145)];
        _bgView.backgroundColor = [UIColor whiteColor];
        _bgView.layer.borderWidth = 1;
        _bgView.layer.borderColor = [RGBACOLOR(207, 210, 213, 0.7) CGColor];

        // 头像
        _userAvatar = [[UIImageView alloc] initWithFrame:CGRectMake(8, 10, 30, 30)];
        [_userAvatar doCircleFrameNoBorder];
        
        // 描述
        _messageDetailsLable = [[UILabel alloc] initWithFrame:CGRectMake(_userAvatar.selfMaxX + 12, 15, _bgView.selfW - _userAvatar.selfMaxX - 12 - 12, 20)];
        [_messageDetailsLable setTextColor:[UIColor colorWithRed:0.263 green:0.467 blue:0.667 alpha:1]];
        [_messageDetailsLable setFont:[UIFont systemFontOfSize:15]];
        
        
        // 订单BgView
        UIView *orderBG = [[UIView alloc] initWithFrame:CGRectMake(_messageDetailsLable.selfX, _messageDetailsLable.selfMaxY + 10, _bgView.selfW - _userAvatar.selfMaxX - 12 - 12, 90)];
        orderBG.backgroundColor = [UIColor whiteColor];
        orderBG.layer.borderWidth = 0.5;
        orderBG.layer.borderColor = [RGBACOLOR(207, 210, 213, 0.7) CGColor];
        
        // 订单号
        _orderNoLable = [[UITTTAttributedLabel alloc] initWithFrame:CGRectMake(10, 5, orderBG.selfW / 2 - 10, 10)];
        [_orderNoLable setTextColor:[UIColor colorWithRed:0.616 green:0.616 blue:0.616 alpha:1]];
        [_orderNoLable setFont:[UIFont systemFontOfSize:10]];
        
        // 时间
        _createTimeLable = [[UITTTAttributedLabel alloc] initWithFrame:CGRectMake(_orderNoLable.selfMaxX + 5, 5, orderBG.selfW - _orderNoLable.selfMaxX - 10, 10)];
        [_createTimeLable setTextColor:[UIColor colorWithRed:0.616 green:0.616 blue:0.616 alpha:1]];
        [_createTimeLable setFont:[UIFont systemFontOfSize:10]];
        [_createTimeLable setTextAlignment:NSTextAlignmentRight];
        
        // 商品图片
        _goodsImageView = [[UIImageView alloc] initWithFrame:CGRectMake(_orderNoLable.selfX, _orderNoLable.selfMaxY + 5, 60, 60)];
        
        // 商品描述
        _goodsDetailsLable = [[UITTTAttributedLabel alloc] initWithFrame:CGRectMake(_goodsImageView.selfMaxX + 10, _goodsImageView.selfY, orderBG.selfW - _goodsImageView.selfMaxX - 20, 45)];
        [_goodsDetailsLable setTextColor:[UIColor darkGrayColor]];
        [_goodsDetailsLable setFont:[UIFont systemFontOfSize:12]];
        [_goodsDetailsLable setNumberOfLines:0];
        
        
        // 商品价格
        _orderPrice = [[UITTTAttributedLabel alloc] initWithFrame:CGRectMake(_goodsImageView.selfMaxX + 10, orderBG.selfH - 22,  orderBG.selfW - _goodsImageView.selfMaxX - 20, 10)];
        [_orderPrice setTextColor:[UIColor lightGrayColor]];
        [_orderPrice setFont:[UIFont systemFontOfSize:11]];
        [_orderPrice setTextAlignment:NSTextAlignmentRight];
        
        // 订单状态
        
        
        [_bgView addSubview:_userAvatar];
        [_bgView addSubview:_messageDetailsLable];
        [_bgView addSubview:orderBG];
        [orderBG addSubview:_orderNoLable];
        [orderBG addSubview:_createTimeLable];
        [orderBG addSubview:_goodsImageView];
        [orderBG addSubview:_goodsDetailsLable];
        [orderBG addSubview:_orderPrice];
        
        [self.contentView addSubview:_bgView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    NSLog(@"\nmessageModel --> %@\n",self.messageModel);
    // 头像
    NSString *avatarUrl;

    // 状态描述
    if (self.messageModel.extMessageType == extMessageType_Order) {
        //还没付款
        if (self.messageModel.order.orderStatus == orderStatusOfWaitPayment) {
            if (self.messageModel.order.orderType == 2) {
                if(TARGET_IS_MINIU_BUYER){
                    [self.messageDetailsLable setText:@"创建了新的订单"];
                }else{
                    [self.messageDetailsLable setText:@"米妞为你创建了一个新订单"];
                }
            } else {
                [self.messageDetailsLable setText:@"申请了订单"];
            }
            //已经付款了
        } else if (self.messageModel.order.orderStatus == orderStatusOfisPaymentFull) {
            
            if(TARGET_IS_MINIU){
                [self.messageDetailsLable setText:@"付款成功啦"];
            }else{
                
                [self.messageDetailsLable setText:@"客户已付全款"];
            }
            
        } else if (self.messageModel.order.orderStatus == orderStatusOfisDeliver){
            
            [self.messageDetailsLable setText:@"米妞已发货"];

        } else if (self.messageModel.order.orderStatus == orderStatusOfRefunding){
            
            [self.messageDetailsLable setText:@"正在退款中"];
            
        } else if (self.messageModel.order.orderStatus == orderStatusOfRefund){
            
            [self.messageDetailsLable setText:@"退款成功"];
            
        } else if (self.messageModel.order.orderStatus == orderStatusOfRefundComfirm){
            
            [self.messageDetailsLable setText:@"正在退款中"];
            
        } else if (self.messageModel.order.orderStatus == orderStatusOfClose){
            
            [self.messageDetailsLable setText:@"关闭订单"];
            
        }else if (self.messageModel.order.orderStatus == orderStatusOfisPaymentWaitBalance){
            
            [self.messageDetailsLable setText:@"已付定金"];
            
        }
        else{
            //增加其他状态
            [self.messageDetailsLable setText:@"订单状态发生改变"];
        }
        avatarUrl = self.messageModel.order.applyAvatar;
    } else if (self.messageModel.extMessageType == extMessageType_Order_Address) {
        [self.messageDetailsLable setText:@"订单地址已更改"];
        avatarUrl = self.messageModel.order.applyAvatar;
    } else if (self.messageModel.extMessageType == extMessageType_Order_Logistics) {
        [self.messageDetailsLable setText:@"物流信息已变化"];
        avatarUrl = self.messageModel.order.buyerAvatar;
    } else if (self.messageModel.extMessageType == extMessageType_Order_Refund) {
        [self.messageDetailsLable setText:@"退款已成功"];
        avatarUrl = self.messageModel.order.buyerAvatar;
    }

    // 头像
//    [_userAvatar setImageWithUrl:avatarUrl withSize:ImageSizeOf200];
    
    // 订单号
    [_orderNoLable setText:[NSString stringWithFormat:@"订单号:%@", self.messageModel.order.orderNo]];
    
    // 创建时间
    NSDate *create_date = [NSDate dateWithTimeIntervalInMilliSecondSince1970:self.messageModel.order.createTime];
    [_createTimeLable setText:[NSString stringWithFormat:@"%@", [create_date formattedTime ]]];
    
    
    // 商品图片
    [_goodsImageView setImageWithUrl:self.messageModel.order.firstImageUrl withSize:ImageSizeOfAuto];
    
    //商品描述
    [_goodsDetailsLable setText:[NSString stringWithFormat:@"%@", self.messageModel.order.depictRemark]];
    
    // 商品价格
    [_orderPrice setText:[NSString stringWithFormat:@"￥%0.2f", self.messageModel.order.totalAmount]];
}

+ (CGFloat)cellHeight
{
    return 150.0f;
}

- (void)addCallBackBlock:(void (^)(MessageModel *))Block
{
    WeakSelf
    [self.contentView bk_whenTapped:^{
        if (Block) {
            Block(weakSelf_SC.messageModel);
        }
    }];
}

@end
