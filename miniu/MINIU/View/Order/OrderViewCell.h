//
//  OrderViewCell.h
//  miniu
//
//  Created by Apple on 15/9/24.
//  Copyright © 2015年 LZJ. All rights reserved.
//

#import "HomeTableViewCell.h"

@interface OrderViewCell : HomeTableViewCell

@property (nonatomic,strong) OrderEntity *order;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier Order:(OrderEntity*)order;

@end
