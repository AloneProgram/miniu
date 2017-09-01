//
//  ProfileViewController.m
//  miniu
//
//  Created by SimMan on 4/16/15.
//  Copyright (c) 2015 SimMan. All rights reserved.
//

#import "ProfileViewController.h"
#import "ProfileTableViewCell.h"
#import "SettingViewController.h"
#import "ProfileTableHeaderCell.h"
#import "FeedBackViewController.h"
#import "CustomActionSheet.h"
#import "ProfileUpdateViewController.h"
#import "CollectViewController.h"
#import "OrderListViewController.h"

#import "OrderTableViewController.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;


    [self.dataArray addObjectsFromArray:@[
                                          @{@"image": @"我-我的订单", @"title": @"我的订单"},
//                                          @{@"image": @"我-我的红包", @"title": @"我的红包"},
                                          @{@"image": @"我-我的收藏", @"title": @"我的收藏"},
                                          @{@"image": @"我-微信", @"title": @"邀请微信好友"},
                                          @{@"image": @"我-设置", @"title": @"设置"},
                                          @{@"image": @"我-我要吐槽", @"title": @"我要吐槽"}
                                          ]];


    UIButton *button = [[UIButton alloc] initWithFrame:self.view.bounds];
    WeakSelf
    [button bk_addEventHandler:^(id sender) {
        [[weakSelf_SC mainDelegate].frostedViewController hideMenuViewController];
    } forControlEvents:UIControlEventTouchUpInside];
    self.tableView.backgroundView = button;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([self.dataArray count]) {
        NSIndexPath *indexPaht = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[indexPaht] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataArray count] + 1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 140.0f;
    }
    return 44.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        static NSString *CellIdentifier = @"ProfileTableHeaderCell";
        ProfileTableHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [ProfileTableHeaderCell shareInstanceCell];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
        return cell;
        
    } else {
    
        static NSString *CellIdentifier = @"ProfileTableViewCell";
        ProfileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [ProfileTableViewCell shareInstanceCell];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
        
        NSDictionary *dic = self.dataArray[indexPath.row - 1];
        
        cell.leftImageView.image = [UIImage imageNamed:dic[@"image"]];
        cell.title.text = dic[@"title"];
        return cell;
    }
    
    return nil;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0: {    // 个人信息
            ProfileUpdateViewController *proFileUpdateVC = [[ProfileUpdateViewController alloc] init];
            [self presentViewControllerWith:proFileUpdateVC];
        }
            break;
        case 1: {   // 我的订单
           // OrderListViewController *orderListVC = [[OrderListViewController alloc] init];
            OrderTableViewController *orderListVC = [[OrderTableViewController alloc]initWithNibName:nil bundle:nil];
            [self presentViewControllerWith:orderListVC];
        }
            break;
//        case 1: {   // 我的红包
//            [self showHudError:@"暂无页面"];
//        }
            break;
        case 2: {   // 我的收藏
            CollectViewController *collectVC = [[CollectViewController alloc] init];
            [self presentViewControllerWith:collectVC];
        }
            break;
        case 3: {   // 推荐“米妞”好友
            WeakSelf
            [SMActionSheet showSheetWithTitle:@"请选择" buttonTitles:@[@"微信好友", @"朋友圈"] redButtonIndex:2 completionBlock:^(NSUInteger buttonIndex, SMActionSheet *actionSheet) {
                if (buttonIndex == 0) {
                    [[logicShareInstance getWeChatManage] addFriendWithWeChatWithSuccessBlock:^{
                        [weakSelf_SC showHudSuccess:@"推荐成功!"];
                    } errorBlock:^(NSString *error) {
                        [weakSelf_SC showHudError:error];
                    }];
                } else if (buttonIndex == 1) {
                    [[logicShareInstance getWeChatManage] addFriendWithWeChatFriendWithSuccessBlock:^{
                        [weakSelf_SC showHudSuccess:@"推荐成功!"];
                    } errorBlock:^(NSString *error) {
                        [weakSelf_SC showHudError:error];
                    }];
                }
            }];
        }
            break;
        case 4: {   // 设置
            SettingViewController *settVC = [[SettingViewController alloc] init];
            [self presentViewControllerWith:settVC];
        }
            break;
        case 5: {
            FeedBackViewController *feedbackVC = [[FeedBackViewController alloc] init];
            
            [self presentViewControllerWith:feedbackVC];
        }
            break;
        default:
            break;
    }
}

#pragma mark 模态推出视图
- (void) presentViewControllerWith:(UIViewController *)controller
{
    [[self mainDelegate].frostedViewController hideMenuViewController];
//    
//    BaseNavigationController *nc = [[BaseNavigationController alloc]initWithRootViewController:controller];
//    
//    [nc.navigationItem.leftBarButtonItem bk_initWithTitle:@"返回" style:(UIBarButtonItemStyleBordered) handler:^(id sender) {
//        [nc dismissViewControllerAnimated:YES completion:nil];
//    }];
    //[super presentViewController:controller animated:YES completion:nil];
    //麻烦的模态推出视图
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MENU_PUSH_VIEW_CONTROLLER" object:controller];
    
//    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
//    nav.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
//    
//    [self asyncMainQueue:^{
//        [self presentViewController:nav animated:YES completion:nil];
//    }];
}

//#pragma mark 推荐微信朋友
//- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    WeakSelf
//    if (buttonIndex == 0) {
//        [[logicShareInstance getWeChatManage] addFriendWithWeChatWithSuccessBlock:^{
//            [weakSelf_SC showHudSuccess:@"推荐成功!"];
//        } errorBlock:^(NSString *error) {
//            [weakSelf_SC showHudError:error];
//        }];
//    } else if (buttonIndex == 1) {
//        [[logicShareInstance getWeChatManage] addFriendWithWeChatFriendWithSuccessBlock:^{
//            [weakSelf_SC showHudSuccess:@"推荐成功!"];
//        } errorBlock:^(NSString *error) {
//            [weakSelf_SC showHudError:error];
//        }];
//    }
//}

@end
