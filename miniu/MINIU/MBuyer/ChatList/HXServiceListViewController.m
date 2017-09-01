//
//  HXServiceListViewController.m
//  miniu
//
//  Created by SimMan on 15/6/30.
//  Copyright (c) 2015年 SimMan. All rights reserved.
//

#import "HXServiceListViewController.h"
#import "UserEntity.h"
#import "ChatListCell.h"


@interface HXServiceListViewController ()

@end

@implementation HXServiceListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"可用客服列表";

    self.tableView.rowHeight = 60.0f;
    
    [self setupRefresh];
    [self.view beginLoading];
}
#pragma mark 上拉加载，下拉刷新
- (void)setupRefresh
{
    __weak __typeof(&*self)weakSelf_SC = self;
    [self addRefreshBlockWithHeader:^{
        weakSelf_SC.pageNum = 1;
        [weakSelf_SC netWorkRequestForUserListWithPage:weakSelf_SC.pageNum Type:LOAD_UPDATE];
    } AndFooter:nil autoRefresh:YES];
}

- (void)netWorkRequestForUserListWithPage:(NSInteger)pageNum Type:(LOAD_TYPE)type
{
    WeakSelf
    
    [[logicShareInstance getEasemobManage] getServiceListSuccess:^(id responseObject) {
        @try {
            NSMutableArray *tmpDataArray = [NSMutableArray arrayWithCapacity:1];
            
            for (NSDictionary *dic in [responseObject objectForKey:@"data"]){
                UserEntity *user = [[UserEntity alloc] init];
                [user setValuesForKeysWithDictionary:dic];
                [tmpDataArray addObject:user];
            }
            
            if ([tmpDataArray count]) {
                if (type == LOAD_UPDATE) {
                    [weakSelf_SC.dataArray removeAllObjects];
                }
                [weakSelf_SC.dataArray addObjectsFromArray:tmpDataArray];
                
                [weakSelf_SC.tableView reloadData];
            } else {
                if (type == LOAD_MORE) {
                    weakSelf_SC.pageNum --;
                }
            }
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            [weakSelf_SC.view endLoading];
        };
    } failure:^(NSString *error) {
        [weakSelf_SC.view endLoading];
        [weakSelf_SC showStatusBarError:error];
    }];
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
    }
    
    cell.indexPath = indexPath;
    
    UserEntity *user = self.dataArray[indexPath.row];
    [cell.imageView setImageWithUrl:user.avatar withSize:ImageSizeOf100];
    
    NSMutableString *titleStr = [NSMutableString string];
    [titleStr appendString:user.nickName];
    [cell setName:titleStr];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UserEntity *user = self.dataArray[indexPath.row];
    
    [self showHudLoad:@"正在更换..."];
    [[logicShareInstance getEasemobManage] switchServiceHx:self.changeUId serviceHxUId:user.hxUId success:^(id responseObject) {
        
        [self showHudSuccess:@"更换成功!"];
        
        [self bk_performBlock:^(id obj) {
            [self.navigationController popViewControllerAnimated:YES];
        } afterDelay:1.3];
        
    } failure:^(NSString *error) {
        [self showHudError:error];
    }];
}

@end
