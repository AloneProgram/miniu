//
//  EMChatOrderBubbleView.m
//  DLDQ_IOS
//
//  Created by simman on 15/3/4.
//  Copyright (c) 2015年 Liwei. All rights reserved.
//

#import "EMChatOrderBubbleView.h"

#define LABEL_FONT_SIZE 12
#define IMAGE_HEIGHT  60
#define IMAGE_WIDTH   60
#define MARGIN       10
#define TEXT_LABLE_WIDTH  140

#import "RTLabel.h"

@interface EMChatOrderBubbleView()

@property (nonatomic, strong) UILabel *descriptionLable;
@property (nonatomic, strong) UIImageView *goodsImageView;
@property (nonatomic, strong) RTLabel *goodsPriceLable;

@end

@implementation EMChatOrderBubbleView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        _descriptionLable = [[UILabel alloc] initWithFrame:CGRectZero];
        _descriptionLable.numberOfLines = 0;
        _descriptionLable.lineBreakMode = NSLineBreakByCharWrapping;
        _descriptionLable.font = [UIFont systemFontOfSize:LABEL_FONT_SIZE];
        _descriptionLable.backgroundColor = [UIColor clearColor];
        _descriptionLable.userInteractionEnabled = NO;
        _descriptionLable.multipleTouchEnabled = NO;
        [self addSubview:_descriptionLable];
        
        _goodsImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:_goodsImageView];
        
        _goodsPriceLable = [[RTLabel alloc] initWithFrame:CGRectZero];
        _goodsPriceLable.lineBreakMode = NSLineBreakByCharWrapping;
        _goodsPriceLable.font = [UIFont systemFontOfSize:LABEL_FONT_SIZE];
        _goodsPriceLable.backgroundColor = [UIColor clearColor];
        _goodsPriceLable.userInteractionEnabled = NO;
        _goodsPriceLable.multipleTouchEnabled = NO;
        [self addSubview:_goodsPriceLable];
    }
    
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.bounds;
    frame.size.width -= BUBBLE_ARROW_WIDTH;
    frame = CGRectInset(frame, BUBBLE_VIEW_PADDING, BUBBLE_VIEW_PADDING);
    if (self.model.isSender) {
        frame.origin.x = BUBBLE_VIEW_PADDING;
    }else{
        frame.origin.x = BUBBLE_VIEW_PADDING + BUBBLE_ARROW_WIDTH;
    }
    
    frame.origin.y = BUBBLE_VIEW_PADDING;
    
    // 图片 Frame
    _goodsImageView.frame = CGRectMake(frame.origin.x, frame.origin.y, IMAGE_WIDTH, IMAGE_HEIGHT);
    
    
    NSString *goodsDescription = self.model.message.ext[@"extgoodsDescription"];
    
    // 计算 descriptionLable 的高度
    CGFloat descriptionLableHeight = [goodsDescription getSizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(TEXT_LABLE_WIDTH, MAXFLOAT)].height;
    _descriptionLable.frame = CGRectMake(_goodsImageView.frame.origin.x + IMAGE_WIDTH + MARGIN, _goodsImageView.frame.origin.y - 5, TEXT_LABLE_WIDTH, descriptionLableHeight > 50 ? 50 : descriptionLableHeight);
    
    _goodsPriceLable.frame = CGRectMake(_goodsImageView.frame.origin.x + IMAGE_WIDTH + MARGIN, _goodsImageView.frame.origin.y + IMAGE_HEIGHT - MARGIN - 2 , 100, 15);
}

-(CGSize)sizeThatFits:(CGSize)size
{
    // 231
    return CGSizeMake(210 + BUBBLE_VIEW_PADDING * 2 + BUBBLE_ARROW_WIDTH, 2 * BUBBLE_VIEW_PADDING + 60);
}

+(CGFloat)heightForBubbleWithObject:(MessageModel *)object
{
    return 80.0f;
}


#pragma mark - setter

- (void)setModel:(MessageModel *)model
{
    [super setModel:model];
    
    // 图片
    NSString *imageURL = self.model.goodsFirstImageURL;
    
    [self.goodsImageView setImageWithUrl:imageURL withSize:ImageSizeOf200];
    
    // 描述
    NSString *goodsDescription = self.model.goodsDescription;
    [self.descriptionLable setText:[NSString stringWithFormat:@"订单: %@", goodsDescription]];
    
    // 价格
    NSString *goodsPrice = self.model.goodsPrice;
    if ([self.model.goodsPrice doubleValue]) {
        [self.goodsPriceLable setText:[NSString stringWithFormat:@"￥%@",goodsPrice]];
    } else {
        [self.goodsPriceLable setText:@"----"];
    }
    
}

#pragma mark - public

-(void)bubbleViewPressed:(id)sender
{
    [self routerEventWithName:@"kRouterEventOrderBubbleTapEventName" userInfo:@{KMESSAGEKEY:self.model}];
}

@end