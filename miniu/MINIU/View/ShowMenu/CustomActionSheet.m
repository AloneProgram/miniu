//
//  CustomActionSheet.m
//  miniu
//
//  Created by SimMan on 4/24/15.
//  Copyright (c) 2015 SimMan. All rights reserved.
//

#import "CustomActionSheet.h"

@implementation CustomActionSheet

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    
    CGRect selfFrame = self.frame;
    
    selfFrame.size.width = kScreen_Width;
    
    self.frame = selfFrame;
    
    for (UIView *view in self.subviews) {
        
        
        NSLog(@"%@ --- %@", view, GetPropertyListOfObject(view));
    }
    
    
}

@end
