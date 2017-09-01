//
//  HomeTableViewCellFrame.h
//  miniu
//
//  Created by SimMan on 4/20/15.
//  Copyright (c) 2015 SimMan. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GoodsEntity.h"

@interface HomeTableViewCellFrame : NSObject


@property (nonatomic, assign) CGSize cellSize;

@property (nonatomic, assign) CGRect avatarImageViewFrame;
@property (nonatomic, assign) CGRect nickNameLableFrame;
@property (nonatomic, assign) CGRect timeLableFrame;
@property (nonatomic, assign) CGRect locationButtomFrame;
@property (nonatomic, assign) CGRect contentLableFrame;
@property (nonatomic, assign) CGRect imageBackViewFrame;
@property (nonatomic, strong) NSMutableArray *imagesFrame;
@property (nonatomic, assign) CGRect priceAndLikesLableFrame;
@property (nonatomic, assign) CGRect moreButtonFrame;

@property (nonatomic, strong) GoodsEntity *goodsEntity;

- (instancetype) initWithObject:(GoodsEntity *)object;

@end


@interface ImageFrame : NSObject

@property (nonatomic, assign) CGRect frame;

@property (nonatomic, assign) CGFloat X;
@property (nonatomic, assign) CGFloat Y;
@property (nonatomic, assign) CGFloat W;
@property (nonatomic, assign) CGFloat H;

@end
