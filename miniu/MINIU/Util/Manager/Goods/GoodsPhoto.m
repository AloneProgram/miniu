
//
//  GoodsPhoto.m
//  DLDQ_IOS
//
//  Created by simman on 14-6-6.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import "GoodsPhoto.h"

@implementation GoodsPhoto



- (instancetype) initWithGoodsImage:(UIImage *)gimage thumbnail:(UIImage *)thumbimage
{
    self.goodsImage = gimage;
    
    if (thumbimage == nil) {
        self.thumbnail = gimage;
    } else {
        self.thumbnail = thumbimage;
    }
    
    return self;
}


@end
