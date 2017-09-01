//
//  GoodsDeailsCell.h
//  miniu
//
//  Created by SimMan on 4/27/15.
//  Copyright (c) 2015 SimMan. All rights reserved.
//

#import "HomeTableViewCell.h"

@class GoodsEntity;

@interface GoodsDeailsCell : HomeTableViewCell

- (void) favButtonActionBlock:(void (^)(GoodsEntity *goods))block;

@end
