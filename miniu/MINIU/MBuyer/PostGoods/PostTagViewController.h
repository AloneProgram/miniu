//
//  PostTagViewController.h
//  DLDQ_IOS
//
//  Created by simman on 14-8-24.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import "BaseViewController.h"

@interface PostTagViewController : BaseViewController

- (void) addCallBackWithTag:(void (^)(NSString *tags))tags;

- (id)initWithTags:(NSString *)tags;

@end
