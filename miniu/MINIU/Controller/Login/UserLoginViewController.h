//
//  UserLoginViewController.h
//  DLDQ_IOS
//
//  Created by simman on 14-5-14.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface UserLoginViewController : BaseViewController <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *phone;
@property (weak, nonatomic) IBOutlet UITextField *password;
//@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

- (IBAction)loginAction:(id)sender;

@end
