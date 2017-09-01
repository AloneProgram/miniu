//
//  IndexTagViewController.h
//  miniu
//
//  Created by SimMan on 5/20/15.
//  Copyright (c) 2015 SimMan. All rights reserved.
//

#import "TOWebViewController.h"

@interface IndexTagViewController : TOWebViewController

@property (nonatomic,strong) NSString *htmlResponseStr;//缓存地址

@property (nonatomic,strong) NSString *urlStr;//请求地址
@end
