//
//  NotificationViewController.m
//  miniu
//
//  Created by SimMan on 5/8/15.
//  Copyright (c) 2015 SimMan. All rights reserved.
//

#import "NotificationViewController.h"

@interface NotificationViewController ()


@end

@implementation NotificationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"系统通知";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view configBlankPage:EaseBlankPageTypeSysnotification hasData:NO hasError:NO reloadButtonBlock:nil];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.rdv_tabBarController setTabBarHidden:NO animated:YES];
}


@end
