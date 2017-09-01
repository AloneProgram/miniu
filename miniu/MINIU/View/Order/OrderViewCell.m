//
//  OrderViewCell.m
//  miniu
//
//  Created by Apple on 15/9/24.
//  Copyright © 2015年 LZJ. All rights reserved.
//

#import "OrderViewCell.h"

#import "UITTTAttributedLabel.h"
#import "UIAwesomeButton.h"
#import "MMPlaceHolder.h"
#import "GoodsEntity.h"
#import "UserEntity.h"
#import "NSDate+Category.h"
#import "UIAwesomeButton.h"
#import "RTLabel.h"

#import "PhotoZooo.h"

#import "ShowMenuView.h"

#define RandomColor [UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:1]

static inline NSRegularExpression * TagRegularExpression() {
    static NSRegularExpression *_tagRegularExpression = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _tagRegularExpression = [[NSRegularExpression alloc] initWithPattern:@"#([^\\#|.]+)#" options:NSRegularExpressionCaseInsensitive error:nil];
    });
    
    return _tagRegularExpression;
}
@interface OrderViewCell()

@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *nickNameLable;
@property (nonatomic, strong) UILabel *timeLable;
@property (nonatomic, strong) UIAwesomeButton *locationButtom;
@property (nonatomic, strong) UITTTAttributedLabel *contentLable;
@property (nonatomic, strong) RTLabel *priceAndLikesLable;
@property (nonatomic, strong) GoodsEntity *goods;
@property (nonatomic, copy) void (^desTapBlock)(HomeTableViewCell *);

//@property (nonatomic, strong) UIButton *moreButton;

@end
@implementation OrderViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier Order:(OrderEntity *)order
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    [self.moreButton removeFromSuperview];

    if (self) {
        self.order = order;
        HomeTableViewCellFrame * cellFrame = [[HomeTableViewCellFrame alloc]initWithObject:[order transferToGoodsEntity]];
        
        _goods = cellFrame.goodsEntity;
        
        // 头像
        [_avatarImageView setImageWithUrl:_order.buyerAvatar withSize:ImageSizeOfAuto];
        
        // 昵称
        [_nickNameLable setText:_order.buyerNickName];
        
        // 发布时间
        NSDate *create_date = [NSDate dateWithTimeIntervalInMilliSecondSince1970:_order.createTime];
        [_timeLable setText:[NSString stringWithFormat:@"%@", [create_date timeIntervalDescription]]];
        
        // 地址
//        [_locationButtom setButtonText:_goods.position];
        
        // 内容
        [self setupContentLable];
        
        
        // 图片
        //    [self loadImageView];
        
        // 价格 -- 喜欢
        NSString *priceStr = nil;
        if (_goods.isShowPrice) {
            priceStr = [NSString stringWithFormat:@"%@", [NSString formatPriceWithPrice:_order.totalAmount]];
        
        [_priceAndLikesLable setText:[NSString stringWithFormat:@"<font face='HelveticaNeue-Condensed' size=14 color='#7F80F1'>%@</font>", priceStr]];
        }
        // 更多按钮
    }
    return self;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    HomeTableViewCellFrame *_cellFrame = self.cellFrame;
    _avatarImageView.frame = _cellFrame.avatarImageViewFrame;
    _nickNameLable.frame = _cellFrame.nickNameLableFrame;
    _timeLable.frame = _cellFrame.timeLableFrame;
    _locationButtom.frame = _cellFrame.locationButtomFrame;
    _contentLable.frame = _cellFrame.contentLableFrame;
//    _imageBackView.frame = _cellFrame.imageBackViewFrame;
    _priceAndLikesLable.frame = _cellFrame.priceAndLikesLableFrame;
//    _moreButton.frame = _cellFrame.moreButtonFrame;
    
//    CGRect moreButtonFrame = _cellFrame.moreButtonFrame;
//    moreButtonFrame.origin.x -= 5;
//    moreButtonFrame.size.width += 10;
//    moreButtonFrame.size.height += 10;
//    _moreButtonView.frame = moreButtonFrame;
    
//    //添加手势用于退出键盘
//    WeakSelf
//    UITapGestureRecognizer *tap = [UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
//        [weakSelf_SC hiddenMoreButtonAction];
//    }];
//    [self.contentView addGestureRecognizer:tap];
    
    //    [self.imageBackView showPlaceHolderWithAllSubviews];
}


- (UIImageView *)avatarImageView
{
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        //        _avatarImageView.backgroundColor = RandomColor;
    }
    return _avatarImageView;
}

- (UILabel *)nickNameLable
{
    if (!_nickNameLable) {
        _nickNameLable = [[UILabel alloc] initWithFrame:CGRectZero];
        _nickNameLable.font = [UIFont boldSystemFontOfSize:16];
        _nickNameLable.textColor = [UIColor colorWithRed:0.106 green:0.102 blue:0.102 alpha:1];
        
        // 1A1A1A
        //        _nickNameLable.backgroundColor = RandomColor;
    }
    return _nickNameLable;
}

- (UILabel *)timeLable
{
    if (!_timeLable) {
        _timeLable = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLable.font = [UIFont systemFontOfSize:12];
        _timeLable.textColor = [UIColor colorWithRed:0.749 green:0.749 blue:0.749 alpha:1];
        //        _timeLable.backgroundColor = RandomColor;
    }
    return _timeLable;
}

- (UIAwesomeButton *)locationButtom
{
    if (!_locationButtom) {
        
        _locationButtom = [[UIAwesomeButton alloc] initWithFrame:CGRectZero text:@"" iconImage:[UIImage imageNamed:@"坐标"] attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12], NSForegroundColorAttributeName : [UIColor colorWithRed:0.749 green:0.749 blue:0.749 alpha:1], @"IconFont" : [UIFont systemFontOfSize:12]} andIconPosition:IconPositionLeft];
        
        //        _locationButtom.backgroundColor = RandomColor;
    }
    return _locationButtom;
}

- (UITTTAttributedLabel *)contentLable
{
    WeakSelf
    if (!_contentLable) {
        _contentLable = [[UITTTAttributedLabel alloc] initWithFrame:CGRectZero];
        _contentLable.font = [UIFont systemFontOfSize:15];
        _contentLable.numberOfLines = 0;
        _contentLable.delegate = self;
        _contentLable.lineSpacing = 3.5;
        _contentLable.userInteractionEnabled = YES;
        _contentLable.textColor = [UIColor colorWithRed:0.459 green:0.455 blue:0.459 alpha:1];
        _contentLable.enabledTextCheckingTypes = NSTextCheckingTypeLink;
        [_contentLable addLongPressForCopy];
//        [_contentLable addTapBlock:^(id aObj) {
//            if (weakSelf_SC.desTapBlock) {
//                [weakSelf_SC hiddenMoreButtonAction];
//                weakSelf_SC.desTapBlock(weakSelf_SC);
//            }
//        }];
        //        _contentLable.backgroundColor = RandomColor;
    }
    return _contentLable;
}

- (RTLabel *)priceAndLikesLable
{
    if (!_priceAndLikesLable) {
        _priceAndLikesLable = [[RTLabel alloc] initWithFrame:CGRectZero];
        _priceAndLikesLable.font = [UIFont systemFontOfSize:14];
        _priceAndLikesLable.textColor = [UIColor blackColor];
        //        _priceAndLikesLable.backgroundColor = RandomColor;
    }
    return _priceAndLikesLable;
}
- (void) setupContentLable
{
//    [self.contentLable setText:_order.orderDescription];
    [self.contentLable setText:_order.orderDescription afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        
        NSRange stringRange = NSMakeRange(0, [mutableAttributedString length]);
        
        NSRegularExpression *regexp = TagRegularExpression();
        NSRange nameRange = [regexp rangeOfFirstMatchInString:[mutableAttributedString string] options:0 range:stringRange];
        
        UIFont *boldSystemFont = [UIFont boldSystemFontOfSize:14];
        CTFontRef boldFont = CTFontCreateWithName((__bridge CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize, NULL);
        if (boldFont) {
            [mutableAttributedString removeAttribute:(NSString *)kCTFontAttributeName range:nameRange];
            [mutableAttributedString removeAttribute:(NSString *)kCTUnderlineStyleAttributeName range:nameRange];
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)boldFont range:nameRange];
            //设置可点击文本的颜色
            [mutableAttributedString addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)[[UIColor colorWithRed:0.243 green:0.192 blue:0.376 alpha:1] CGColor] range:nameRange];
            CFRelease(boldFont);
        }
        
        if (nameRange.location != NSNotFound) {
            
            NSMutableString *subStr = [NSMutableString stringWithString:[[mutableAttributedString string] substringWithRange:nameRange]];
            [subStr appendString:@" "];
            
            [mutableAttributedString replaceCharactersInRange:nameRange withString:[subStr uppercaseString]];
        }
        
        return mutableAttributedString;
    }];
    self.contentLable.linkAttributes = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:(NSString *)kCTUnderlineStyleAttributeName];
    
    NSRegularExpression *regexp = TagRegularExpression();
    NSRange linkRange = [regexp rangeOfFirstMatchInString:_order.orderDescription options:0 range:NSMakeRange(0, [_order.orderDescription length])];
    
    if (linkRange.location != NSNotFound && [_order.orderDescription length]) {
        NSString *subStr = [_order.orderDescription substringWithRange:linkRange];
        [subStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [subStr base64String]]];
        [self.contentLable addLinkToURL:url withRange:linkRange];
    }


}

- (void) loadImageView
{
    // 首先清空所有图片
    [self unLoadImageView];
    NSArray *arr = [_order.goodsImages componentsSeparatedByString:@","];
    for (int i = 0; i < _order.goodsImagesCount; i ++) {
        ImageFrame *imageFrame = self.cellFrame.imagesFrame[i];//_cellFrame.imagesFrame[i];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageFrame.frame];
        [self.imageBackView addSubview:imageView];
        
        UITapGestureRecognizer *singleFingerOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoomPhoto:)];
        [imageView addGestureRecognizer:singleFingerOne];
        imageView.userInteractionEnabled = YES;
        imageView.tag = i;
        
        [imageView setImageWithUrl:arr[i] withSize:ImageSizeOfAuto];
    }
}

/**
 *  显示大图
 *
 *  @param cell      返回的Cell
 *  @param imageView 返回的ImageView数组
 */
- (void)zoomPhoto:(UITapGestureRecognizer *)singleFingerOne
{
    @try {
//        [self hiddenMoreButtonAction];
        [[PhotoZooo shareInstance] showImageWithArray:[_order.goodsImages           componentsSeparatedByString:@","]
 setInitialPageIndex:singleFingerOne.view.tag withController:self.getViewController];
    }
    @catch (NSException *exception) {
        NSLog(@"___error: 获取图片错误!");
    }
    @finally {
        
    }
}
@end
