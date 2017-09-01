//
//  HomeTableViewCell.h
//  miniu
//
//  Created by SimMan on 4/20/15.
//  Copyright (c) 2015 SimMan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeTableViewCellFrame.h"

@class HomeTableViewCell;

@protocol HomeTableViewCellDelegate <NSObject>

#if TARGET_IS_MINIU_BUYER //不知道为何报错

- (void) didDeleteWithCell:(HomeTableViewCell *)cell;
#endif

- (void) didSelectTagName:(NSString *)tagName;
@end

@interface HomeTableViewCell : UITableViewCell

@property (nonatomic, assign) id<HomeTableViewCellDelegate> delegate;

@property (nonatomic, strong) HomeTableViewCellFrame *cellFrame;

@property (nonatomic, strong, readonly) UIButton *moreButton;
@property (nonatomic, strong) UIButton *moreButtonView;
@property (nonatomic, strong) UIView *imageBackView;

- (void) loadImageView;
- (void) unLoadImageView;

-(void)addTapDesBlock:(void(^)(HomeTableViewCell *cell))block;

@end
