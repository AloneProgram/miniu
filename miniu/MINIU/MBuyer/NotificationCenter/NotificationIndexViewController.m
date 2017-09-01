//
//  NotificationIndexViewController.m
//  miniu
//
//  Created by SimMan on 5/8/15.
//  Copyright (c) 2015 SimMan. All rights reserved.
//

#import "NotificationIndexViewController.h"
#import "NotificationViewController.h"
#import "OrderNotificationViewController.h"

@interface NotificationIndexViewController ()

@end

@implementation NotificationIndexViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NotificationViewController * child_1 = [[NotificationViewController alloc] init];
    OrderNotificationViewController * child_2 = [[OrderNotificationViewController alloc] init];
    
    [self setViewControllers:@[child_2, child_1]];
    [self setSelectedViewControllerIndex:0];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] bk_initWithTitle:@"全部已读" style:UIBarButtonItemStylePlain handler:^(id sender) {
        [self setAllLogIsRead];
    }];
}

- (void) setAllLogIsRead
{
    [WCAlertView showAlertWithTitle:@"提示" message:@"所有未读通知标为已读？" customizationBlock:^(WCAlertView *alertView) {
        
    } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
        if (buttonIndex == 1) {
            // 获取当前是哪个Seg
            // [self selectedViewControllerIndex]
            [[logicShareInstance getLogManager] setAllLogIsRead];
            OrderNotificationViewController *orderVC = (OrderNotificationViewController*)self.selectedViewController;
            [orderVC.tableView reloadData];
        }
    } cancelButtonTitle:@"取消" otherButtonTitles:@"标记", nil];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.rdv_tabBarController setTabBarHidden:NO animated:YES];
}


//- (instancetype)initWithCoder:(NSCoder *)coder
//{
//    self = [super initWithCoder:coder];
//    if (self) {
//        self.skipIntermediateViewControllers = NO;
////        self.isProgressiveIndicator = YES;
////        self.isElasticIndicatorLimit = YES;
//    }
//    return self;
//}
////
////- (void) viewDidLoad
////{
//////    [self.segmentedControl setFrame:CGRectMake(0, 0, kScreen_Width / 2, 30)];
////    [super viewDidLoad];
////    self.view.backgroundColor = [UIColor grayColor];
////}
//
//-(NSArray *)childViewControllersForPagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController
//{
//    // create child view controllers that will be managed by XLPagerTabStripViewController
//    NotificationViewController * child_1 = [[NotificationViewController alloc] init];
//    OrderNotificationViewController * child_2 = [[OrderNotificationViewController alloc] init];
//    
//    NSMutableArray * childViewControllers = [NSMutableArray arrayWithObjects:child_1, child_2, nil];
//    return childViewControllers;
//}

@end
