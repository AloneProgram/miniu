//
//  HomeTableViewCell.m
//  miniu
//
//  Created by SimMan on 4/20/15.
//  Copyright (c) 2015 SimMan. All rights reserved.
//

#import "HomeTableViewCell.h"
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

@interface HomeTableViewCell() <TTTAttributedLabelDelegate>

@property (nonatomic, strong) UIImageView *avatarImageView;  //头像
@property (nonatomic, strong) UILabel *nickNameLable;   //昵称lable
@property (nonatomic, strong) UILabel *timeLable;       //时间lable
@property (nonatomic, strong) UIAwesomeButton *locationButtom; //(uibutton的一个类目,添加了新的方法,用文本格式的图标设置button.)
@property (nonatomic, strong) UITTTAttributedLabel *contentLable; //(UILable 的改进，支持 NSAttributedStrings)
@property (nonatomic, strong) RTLabel *priceAndLikesLable; //(RTLabel 基于UILabel类的拓展,能够支持Html标记的富文本显示，它是基于Core Text,因此也支持Core Text上的一些东西)
@property (nonatomic, strong) GoodsEntity *goods;
@property (nonatomic, copy) void (^desTapBlock)(HomeTableViewCell *);

@property (nonatomic, strong) UIButton *moreButton;

@end

@implementation HomeTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self.contentView addSubview:self.avatarImageView];
        [self.contentView addSubview:self.nickNameLable];
        [self.contentView addSubview:self.timeLable];
        [self.contentView addSubview:self.locationButtom];
        [self.contentView addSubview:self.contentLable];
        [self.contentView addSubview:self.imageBackView];
        [self.contentView addSubview:self.priceAndLikesLable];
        [self.contentView addSubview:self.moreButton];
        
        [self.contentView addSubview:self.moreButtonView];
    }
    return self;
}

- (void)setCellFrame:(HomeTableViewCellFrame *)cellFrame
{
    _cellFrame = cellFrame;
    
    _goods = cellFrame.goodsEntity;
    
    // 头像
    [_avatarImageView setImageWithUrl:_goods.goodsUserInfo.avatar withSize:ImageSizeOfAuto];
    
    // 昵称
    [_nickNameLable setText:_goods.goodsUserInfo.nickName];
    
    // 发布时间
    NSDate *create_date = [NSDate dateWithTimeIntervalInMilliSecondSince1970:_goods.createTime];
    [_timeLable setText:[NSString stringWithFormat:@"%@", [create_date timeIntervalDescription]]];
    
    // 地址
    [_locationButtom setButtonText:_goods.position];
    
    // 内容
    [self scontentLable];
    
    
    // 图片
//    [self loadImageView];
    
    // 价格 -- 喜欢
    NSString *priceStr = nil;
    if (_goods.isShowPrice) {
        priceStr = [NSString stringWithFormat:@"%@", [NSString formatPriceWithPrice:[_goods.price doubleValue]]];
        [self.moreButton setHidden:NO];

    } else {
        priceStr = @"询价请私信";
        [self.moreButton setHidden:YES];
    }
    [_priceAndLikesLable setText:[NSString stringWithFormat:@"<font face='HelveticaNeue-Condensed' size=14 color='#7F80F1'>%@</font>   <font size=11 color='#999999'>%d人喜欢</font>", priceStr, (int)_goods.likesCount]];
    
    // 更多按钮
}

- (void) scontentLable
{
    [self.contentLable setText:_goods.goodsDescription afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        
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
    NSRange linkRange = [regexp rangeOfFirstMatchInString:_goods.goodsDescription options:0 range:NSMakeRange(0, [_goods.goodsDescription length])];
    
    if (linkRange.location != NSNotFound && [_goods.goodsDescription length]) {
        NSString *subStr = [_goods.goodsDescription substringWithRange:linkRange];
        [subStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [subStr base64String]]];
        [self.contentLable addLinkToURL:url withRange:linkRange];
    }
}

/**
 *  TTTAttributedLabelDelegate 点击label协议代理方法
 *
 *  @param label
 *  @param url
 */
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    //解密获取字符串
    NSString *tagNameStr = [NSString stringFromBase64String:url.relativeString];
    //去掉##
    NSString *tagName = [tagNameStr stringByReplacingOccurrencesOfString:@"#" withString:@""];
    //跳转tagName
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectTagName:)]) {
        [self hiddenMoreButtonAction];
        //代理执行方法
        [self.delegate didSelectTagName:tagName];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _avatarImageView.frame = _cellFrame.avatarImageViewFrame;
    _nickNameLable.frame = _cellFrame.nickNameLableFrame;
    _timeLable.frame = _cellFrame.timeLableFrame;
    _locationButtom.frame = _cellFrame.locationButtomFrame;
    _contentLable.frame = _cellFrame.contentLableFrame;
    _imageBackView.frame = _cellFrame.imageBackViewFrame;
    _priceAndLikesLable.frame = _cellFrame.priceAndLikesLableFrame;
    _moreButton.frame = _cellFrame.moreButtonFrame;
    
    CGRect moreButtonFrame = _cellFrame.moreButtonFrame;
    moreButtonFrame.origin.x -= 5;
    moreButtonFrame.size.width += 10;
    moreButtonFrame.size.height += 10;
    _moreButtonView.frame = moreButtonFrame;
    
    //添加手势用于退出键盘
    WeakSelf
    UITapGestureRecognizer *tap = [UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        [weakSelf_SC hiddenMoreButtonAction];
    }];
    [self.contentView addGestureRecognizer:tap];
    
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
        [_contentLable addTapBlock:^(id aObj) {
            if (weakSelf_SC.desTapBlock) {
                [weakSelf_SC hiddenMoreButtonAction];
                weakSelf_SC.desTapBlock(weakSelf_SC);
            }
        }];
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

- (UIView *)imageBackView
{
    if (!_imageBackView) {
        _imageBackView = [[UIView alloc] initWithFrame:CGRectZero];
        _imageBackView.backgroundColor = [UIColor clearColor];
    }
    return _imageBackView;
}

/**
 *  cell的 ... 按钮
 *
 *  @return button
 */
- (UIButton *)moreButton
{
    if (!_moreButton) {
        _moreButton = [[UIButton alloc] initWithFrame:CGRectZero];
#if TARGET_IS_MINIU_BUYER
        [_moreButton setBackgroundImage:[UIImage imageNamed:@"iconfont-gengduo"] forState:UIControlStateNormal];
#else
        [_moreButton setBackgroundImage:[UIImage imageNamed:@"更多"] forState:UIControlStateNormal];
#endif
        [_moreButton addTarget:self action:@selector(showMoreButtonAction) forControlEvents:UIControlEventTouchUpInside];        
    }
    return _moreButton;
}

- (UIButton *)moreButtonView
{
    if (!_moreButtonView) {
        _moreButtonView = [[UIButton alloc] initWithFrame:CGRectZero];
        [_moreButtonView addTarget:self action:@selector(showMoreButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _moreButtonView;
}

- (void) showMoreButtonAction
{
#if TARGET_IS_MINIU_BUYER
    
    [SMActionSheet showSheetWithTitle:@"请选择" buttonTitles:@[@"一键下图", @"删除"] redButtonIndex:-1 completionBlock:^(NSUInteger buttonIndex, SMActionSheet *actionSheet) {
        if (buttonIndex == 0) {
            [[logicShareInstance getAssetManager] saveImagesWithImageUrls:self.cellFrame.goodsEntity.goodsImagesArray isMark:NO success:^(NSString *success) {
                
            } failure:^(NSString *error) {
                
            }];
        } else if (buttonIndex == 1) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(didDeleteWithCell:)]) {
                [self.delegate didDeleteWithCell:self];
            }
        }
    }];
#else
    [ShowMenuView showViewIn:_moreButton withObject:self];
#endif
}

- (void) hiddenMoreButtonAction
{
    [ShowMenuView hidden];
}

- (void) loadImageView
{
    // 首先清空所有图片
    [self unLoadImageView];
    
    for (int i = 0; i < _cellFrame.goodsEntity.goodsImagesCount; i ++) {
        ImageFrame *imageFrame = _cellFrame.imagesFrame[i];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageFrame.frame];
        [_imageBackView addSubview:imageView];
        
        UITapGestureRecognizer *singleFingerOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoomPhoto:)];
        [imageView addGestureRecognizer:singleFingerOne];
        imageView.userInteractionEnabled = YES;
        imageView.tag = i;
       
        [imageView setImageWithUrl:self.goods.goodsImagesArray[i] withSize:ImageSizeOfAuto];
    }
}

- (void) unLoadImageView
{
    // 清除原来的图片
    for (UIImageView *imageView in self.imageBackView.subviews) {
//        [imageView bk_removeAllBlockObservers];
        [imageView sd_cancelCurrentImageLoad];
        imageView.image = nil;
        [imageView removeFromSuperview];
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
        [self hiddenMoreButtonAction];
        [[PhotoZooo shareInstance] showImageWithArray:self.goods.goodsImagesArray setInitialPageIndex:singleFingerOne.view.tag withController:self.getViewController];
    }
    @catch (NSException *exception) {
        NSLog(@"___error: 获取图片错误!");
    }
    @finally {
        
    }
}


#pragma mark 手势
//block在HomeTableViewController中实现,加载
- (void)addTapDesBlock:(void (^)(HomeTableViewCell *))block
{
    _desTapBlock = block;
}

@end
