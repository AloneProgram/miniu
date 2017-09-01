//
//  ContactResultViewController.m
//  miniu
//
//  Created by SimMan on 5/7/15.
//  Copyright (c) 2015 SimMan. All rights reserved.
//

#import "ContactResultViewController.h"
#import "UserEntity.h"
#import "ChatListCell.h"

#import "ChatController.h"

@interface ContactResultViewController () <UISearchResultsUpdating, ChatListCellDelegate>
{
    //BaseNavigationController *nav;
    UINavigationController *navtemp;
}
@end

@implementation ContactResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //nav = [[BaseNavigationController alloc] initWithRootViewController:self];
    self.tableView.rowHeight = 60.0f;
}


- (void)netWorkRequestForUserListWithkeyword:(NSString *)keyword
{
    WeakSelf
    [self.currentRequest addObject:[[logicShareInstance getUserManager] searchBuyerWithKeyWord:keyword CurrentPage:self.pageNum pageSize:50 success:^(id responseObject) {
        @try {
            NSMutableArray *tmpDataArray = [NSMutableArray arrayWithCapacity:1];
            
            for (NSDictionary *dic in [responseObject objectForKey:@"data"]){
                UserEntity *user = [[UserEntity alloc] init];
                [user setValuesForKeysWithDictionary:dic];
                [tmpDataArray addObject:user];
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                [self.view configBlankPage:EaseBlankPageTypeSearch hasData:[tmpDataArray count] hasError:NO reloadButtonBlock:nil];
                [weakSelf_SC.dataArray removeAllObjects];
                [weakSelf_SC.dataArray addObjectsFromArray:tmpDataArray];
                [weakSelf_SC.tableView reloadData];
            });
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        };
    } failure:^(NSString *error) {

    }]];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier=@"ChatListCell";
    ChatListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ChatListCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        [cell setTextLableWidth:kScreen_Width - 65];
        
        cell.delegate = self;
    }
    
    cell.indexPath = indexPath;
    
    UserEntity *user = self.dataArray[indexPath.row];
    [cell.imageView setImageWithUrl:user.avatar withSize:ImageSizeOf100];
    
    NSMutableString *titleStr = [NSMutableString string];
    [titleStr appendString:user.nickName];
    
    if ([user.realName length]) {
        [titleStr appendFormat:@" [%@]", user.realName];
    }
    
    if ([user.phone length]) {
        [titleStr appendFormat:@" [%@]", user.phone];
    }
    
    if ([user.weixinAccount length] && ![user.weixinAccount isEqualToString:@"无"]) {
        [titleStr appendFormat:@" [%@]", user.weixinAccount];
    }
    
    [cell setName:titleStr];
    
    [cell setDetailMsg:[NSString stringWithFormat:@"%@", user.signature]];
    
    return cell;
}

- (void) longPressAtIndexPath:(NSIndexPath *)indexPath
{
    UserEntity *user = self.dataArray[indexPath.row];
    
    if ([user.phone length]) {
        
        NSMutableString *telUrl= [[NSMutableString alloc] initWithFormat:@"tel:%@",@"18600024377"];
        [WCAlertView showAlertWithTitle:@"提示" message:[NSString stringWithFormat:@"确认拨打: %@ ?", user.phone] customizationBlock:^(WCAlertView *alertView) {
        } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
            if (buttonIndex == 1) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:telUrl]];
            }
        } cancelButtonTitle:@"取消" otherButtonTitles:@"拨打", nil];
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"dataARRAy %@",self.dataArray);
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UserEntity *user = self.dataArray[indexPath.row];

    if ([user.hxUId length]) {
        
        //self.searchController.active = NO;
        
        ChatController *chatVC = [[ChatController alloc] initWithChatter:user.hxUId];
        
        //        [self pushViewController:chatVC animated:YES];
        navtemp = [[UINavigationController alloc]initWithRootViewController:chatVC];
        [self presentViewController:navtemp animated:YES completion:^{
            UIBarButtonItem *dismissBtn = [[UIBarButtonItem alloc] initWithTitle:@"通讯录" style:UIBarButtonItemStylePlain target:self action:@selector(dissmissBtn:)];
            [dismissBtn setAction:@selector(dissmissBtn:)];
            chatVC.navigationItem.leftBarButtonItem = dismissBtn;

        }];

    } else {
        [self showHudError:@"用户信息获取失败!"];
    }

//
//    if ([user.hxUId length]) {
//        if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectedUser:)]) {
//            [self.delegate didSelectedUser:user];
//        }
//    } else {
//        [self showHudError:@"用户信息获取失败!"];
//    }
}
- (void)dissmissBtn:(UIBarButtonItem*)sender
{
    [navtemp dismissViewControllerAnimated:YES completion:nil];
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    if ([searchController.searchBar.text length]) {
        
        for (NSURLSessionDataTask *task in self.currentRequest) {
            [NET_WORK_HANDLE cancelAllHTTPOperationsWithPath:task];
        }
        
        [self netWorkRequestForUserListWithkeyword:searchController.searchBar.text];
    }
}

@end
