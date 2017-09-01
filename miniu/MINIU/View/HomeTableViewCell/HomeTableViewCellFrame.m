//
//  HomeTableViewCellFrame.m
//  miniu
//  单元格布局 cell布局
//  Created by SimMan on 4/20/15.
//  Copyright (c) 2015 SimMan. All rights reserved.
//

#import "HomeTableViewCellFrame.h"
#import "GoodsEntity.h"
#import "NSString+Common.h"

#define MARGIN 10
#define FONT_HEIGHT 15
#define IMAGE_MARGIN 4
#define IMAGE_LEFT_MARGIN [self getImageLeftMargin]


/*
 // 1张：368 x 550
 // 2张：306 x 394
 // 3-4张：306 x 306
 // 5-9张：200 x 200
 */

#define ONE_IMAGE_SIZE CGSizeMake((kScreen_Width - (IMAGE_LEFT_MARGIN + 100) / 2), (kScreen_Width - (IMAGE_LEFT_MARGIN + 100) / 2))
#define TWO_IMAGE_SIZE CGSizeMake((kScreen_Width - IMAGE_LEFT_MARGIN - MARGIN - IMAGE_MARGIN) / 2, (kScreen_Width - IMAGE_LEFT_MARGIN - MARGIN - IMAGE_MARGIN) / 2)
#define T_F_IMAGE_SIZE CGSizeMake((kScreen_Width - IMAGE_LEFT_MARGIN - MARGIN - IMAGE_MARGIN) / 2, (kScreen_Width - IMAGE_LEFT_MARGIN - MARGIN - IMAGE_MARGIN) / 2)
#define F_N_IMAGE_SIZE CGSizeMake((kScreen_Width - IMAGE_LEFT_MARGIN - MARGIN - IMAGE_MARGIN - IMAGE_MARGIN) / 3, (kScreen_Width - IMAGE_LEFT_MARGIN - MARGIN - IMAGE_MARGIN - IMAGE_MARGIN) / 3)

@implementation HomeTableViewCellFrame

- (float) getImageLeftMargin
{
//    if (IS_IPHONE6PLUS) {
//        return 40 * 1.2 + MARGIN * 2;
//    } else
    if (IS_IPAD) {
        return 40 * 2 + MARGIN * 2;
    }
    return 40 + MARGIN * 2;
}

- (instancetype) initWithObject:(GoodsEntity *)object
{
    self = [super init];
    if (self) {
        self.goodsEntity = object;
        self.avatarImageViewFrame = CGRectZero;
        self.nickNameLableFrame = CGRectZero;
        self.timeLableFrame = CGRectZero;
        self.locationButtomFrame = CGRectZero;
        self.contentLableFrame = CGRectZero;
        self.imageBackViewFrame = CGRectZero;
        self.imagesFrame = [NSMutableArray arrayWithCapacity:object.goodsImagesCount];
        self.priceAndLikesLableFrame = CGRectZero;
        self.moreButtonFrame = CGRectZero;

        [self calculateSize];
    }
    return self;
}

#pragma mark 计算尺寸
- (void) calculateSize
{
    [self avatarImageViewFrame];

// 头像
    CGFloat avatarImageViewW = 40;
    if (IS_IPAD) {
        avatarImageViewW = 40 * 2;
    }
    
    _avatarImageViewFrame = CGRectMake(MARGIN, 24, avatarImageViewW, avatarImageViewW);
    
// 昵称
    CGFloat nickNameLableX = CGRectGetMaxX(_avatarImageViewFrame) + MARGIN;
    CGFloat nickNameLableY = CGRectGetMinY(_avatarImageViewFrame) + 3;
    CGFloat nickNameLableW = kScreen_Width - nickNameLableX - MARGIN;
    CGFloat nickNameLableH = FONT_HEIGHT;
    _nickNameLableFrame = CGRectMake(nickNameLableX, nickNameLableY, nickNameLableW, nickNameLableH);

// 时间
    CGFloat timeLableY = CGRectGetMaxY(_avatarImageViewFrame) - FONT_HEIGHT;
    CGFloat timeLableW = 55.0f;
    _timeLableFrame = CGRectMake(nickNameLableX, timeLableY, timeLableW, FONT_HEIGHT);
    
// 地点
    if ([_goodsEntity.position length]) {
        CGFloat locationX = CGRectGetMaxX(_timeLableFrame) + MARGIN;
        CGFloat locationY = CGRectGetMinY(_timeLableFrame);
        CGSize locationStrSize = [_goodsEntity.position getSizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(CGFLOAT_MAX, 15)];
        CGFloat locationW = locationStrSize.width + 5; // 5是图片的宽度
        CGFloat locationH = FONT_HEIGHT;
        _locationButtomFrame = CGRectMake(locationX, locationY, locationW, locationH);
    }

// 内容主体
    CGFloat contentX = CGRectGetMinX(_timeLableFrame);
    CGFloat contentY = CGRectGetMaxY(_timeLableFrame) + MARGIN;
    
    CGFloat contentW = kScreen_Width - contentX - MARGIN;
    CGSize contentSize = [_goodsEntity.depictRemark getSizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(contentW, CGFLOAT_MAX) andLineSpacing:3.5];
    CGFloat contentH = contentSize.height;
    _contentLableFrame = CGRectMake(contentX, contentY, contentW, contentH);
    
// 图片View
    
    // 图片底层View的大小
    CGFloat backImageViewX = CGRectGetMinX(_timeLableFrame);
    CGFloat backImageViewY = CGRectGetMaxY(_contentLableFrame) + MARGIN;
    CGFloat backImageViewW = kScreen_Width - MARGIN - backImageViewX;
    CGFloat backImageViewH = MARGIN;
    
    switch (_goodsEntity.goodsImagesCount) {
        case 1: {
            backImageViewH += ONE_IMAGE_SIZE.height;
        }
            break;
        case 2: {
            backImageViewH += TWO_IMAGE_SIZE.height;
        }
            break;
        case 3:
        case 4: {
            backImageViewH += (T_F_IMAGE_SIZE.height * 2) + IMAGE_MARGIN;
        }
            break;
            
        case 5:
        case 6: {
            backImageViewH += (F_N_IMAGE_SIZE.height * 2) + IMAGE_MARGIN;
        }
            break;
        case 7:
        case 8:
        case 9: {
            backImageViewH += (F_N_IMAGE_SIZE.height * 3) + IMAGE_MARGIN + IMAGE_MARGIN;
        }
            break;
        default:
            break;
    }
    _imageBackViewFrame = CGRectMake(backImageViewX, backImageViewY, backImageViewW, backImageViewH);
    
// 所有的图片View的Frame
    
    [self calculateImageSize];
    
    
// 价格和喜欢按钮等的位置
    
    CGFloat priceAndLikeX = CGRectGetMinX(_timeLableFrame);
    CGFloat priceAndLikeY = CGRectGetMaxY(_imageBackViewFrame) + MARGIN;
    CGFloat priceAndLikeW = kScreen_Width - priceAndLikeX - MARGIN - 50; // 50 为morebutton的宽度
    CGFloat priceAndLikeH = 22;
    
    _priceAndLikesLableFrame = CGRectMake(priceAndLikeX, priceAndLikeY, priceAndLikeW, priceAndLikeH);
    
    
// 更多按钮的位置
    CGFloat moreButtonX = kScreen_Width - MARGIN - 39;
#if TARGET_IS_MINIU
    CGFloat moreButtonY = priceAndLikeY - 5;
    CGFloat moreButtonW = 39;
    CGFloat moreButtonH = 26;
#else
    CGFloat moreButtonY = priceAndLikeY - 8;
    CGFloat moreButtonW = 32;
    CGFloat moreButtonH = 32;
#endif
    _moreButtonFrame = CGRectMake(moreButtonX, moreButtonY, moreButtonW, moreButtonH);
    
    
// 计算 cell 的尺寸
    _cellSize = CGSizeMake(kScreen_Width, CGRectGetMaxY(_priceAndLikesLableFrame) + MARGIN);
}

- (void) calculateImageSize
{
    NSInteger imageCount = _goodsEntity.goodsImagesCount;
    
    if (imageCount == 1) {
        
        ImageFrame *imageFrame = [[ImageFrame alloc] init];
        imageFrame.X = 0;
        imageFrame.Y = 0;
        imageFrame.W = ONE_IMAGE_SIZE.width;
        imageFrame.H = ONE_IMAGE_SIZE.height;
        
        [_imagesFrame addObject:imageFrame];
    }
    
    if (imageCount == 2) {
        ImageFrame *imageFrame1 = [[ImageFrame alloc] init];
        imageFrame1.X = 0;
        imageFrame1.Y = 0;
        imageFrame1.W = TWO_IMAGE_SIZE.width;
        imageFrame1.H = TWO_IMAGE_SIZE.height;
        
        [_imagesFrame addObject:imageFrame1];
        
        ImageFrame *imageFrame2 = [[ImageFrame alloc] init];
        imageFrame2.X = TWO_IMAGE_SIZE.width + IMAGE_MARGIN;
        imageFrame2.Y = 0;
        imageFrame2.W = TWO_IMAGE_SIZE.width;
        imageFrame2.H = TWO_IMAGE_SIZE.height;
        
        [_imagesFrame addObject:imageFrame2];
    }
    
    if (imageCount >= 3 && imageCount <= 4) {
        
        /*
         1: 0 - 0
         2: (W + M) - 0
         3: 0 - (H + M)
         4: W + M - (H + M)
         
         */
        
        for (int i = 0; i < imageCount; i ++) {
            ImageFrame *imageFrame = [[ImageFrame alloc] init];

            if (!(i % 2)) {
                imageFrame.X = 0;
            } else {
                imageFrame.X = T_F_IMAGE_SIZE.width + IMAGE_MARGIN;
            }
            
            if (i < 2) {
                imageFrame.Y = 0;
            } else {
                imageFrame.Y = T_F_IMAGE_SIZE.height + IMAGE_MARGIN;
            }
            
            imageFrame.W = T_F_IMAGE_SIZE.width;
            imageFrame.H = T_F_IMAGE_SIZE.height;
            
            [_imagesFrame addObject:imageFrame];
        }
    }
    
    if (imageCount >=5) {
        
        for (int i = 0; i < imageCount; i ++) {
            
            ImageFrame *imageFrame = [[ImageFrame alloc] init];
            imageFrame.X = (F_N_IMAGE_SIZE.width + IMAGE_MARGIN) * (i % 3);
            imageFrame.Y = (F_N_IMAGE_SIZE.height + IMAGE_MARGIN) * (i / 3);
            imageFrame.W = F_N_IMAGE_SIZE.width;
            imageFrame.H = F_N_IMAGE_SIZE.height;
            
            [_imagesFrame addObject:imageFrame];
        }
    }
}

@end


@implementation ImageFrame

- (instancetype)init
{
    self = [super init];
    if (self) {
        _X = 0;
        _Y = 0;
        _W = 0;
        _H = 0;
    }
    return self;
}

- (CGRect)frame
{
    return CGRectMake(_X, _Y, _W, _H);
}

@end
