//
//  LogisticsEditView.m
//  miniu
//
//  Created by SimMan on 15/6/10.
//  Copyright (c) 2015年 SimMan. All rights reserved.
//

#import "LogisticsEditView.h"

@interface LogisticsEditView()

@property (nonatomic, strong) UILabel *createTimeLable;
@property (nonatomic, strong) UITextView *contentTextView;
@property (nonatomic, strong) UILabel *companyLable;
@property (nonatomic, strong) UITextField *invoiceNoTextField;

@end

@implementation LogisticsEditView

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        // 创建时间
        _createTimeLable = [[UILabel alloc] initWithFrame:CGRectMake(25, 45, 250, 30)];
        [_createTimeLable setTextColor:[UIColor colorWithRed:0.682 green:0.682 blue:0.682 alpha:1]];
        [_createTimeLable setFont:[UIFont systemFontOfSize:18]];
    }
    return self;
}


@end
