//
//  GoodsPhoto.h
//  DLDQ_IOS
//
//  Created by simman on 14-6-6.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GoodsPhoto : NSObject

@property (nonatomic, retain) UIImage *thumbnail;
@property (nonatomic, retain) UIImage *goodsImage;

- (instancetype) initWithGoodsImage:(UIImage *)gimage thumbnail:(UIImage *)thumbimage;

@end
