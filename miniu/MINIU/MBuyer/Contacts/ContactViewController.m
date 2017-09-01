//
//  ContactViewController.m
//  miniu
//
//  Created by SimMan on 5/7/15.
//  Copyright (c) 2015 SimMan. All rights reserved.
//

#import "ContactViewController.h"
#import "ContactResultViewController.h"
#import "ChatController.h"
#import "UserEntity.h"
#import "ChatListCell.h"

#import "AppDelegate.h"

@interface ContactViewController () <ContactResultViewControllerDelegate, ChatListCellDelegate>

@property (nonatomic, strong) UISearchController *searchController;

@end

@implementation ContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //self.navigationItem.titleView = self.searchController.searchBar; 下移到tableheader

//    WeakSelf
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] bk_initWithBarButtonSystemItem:UIBarButtonSystemItemStop handler:^(id sender) {
//        weakSelf_SC.searchController.active = NO;
//        [weakSelf_SC dismissViewControllerAnimated:YES completion:nil];
//    }];
    [self searchController];
    self.navigationItem.titleView = self.searchController.searchBar;
    //self.tableView.tableHeaderView = self.searchController.searchBar;
    self.tableView.rowHeight = 60.0f;
    self.title = @"通讯录";
    [self setupRefresh];
    [self.view beginLoading];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
#if TARGET_IS_MINIU_BUYER
    AppDelegate *ad = [UIApplication sharedApplication].delegate;
    [ad.tabBarController setTabBarHidden:NO animated:YES];
#endif
}
#pragma mark 上拉加载，下拉刷新
- (void)setupRefresh
{
    __weak __typeof(&*self)weakSelf_SC = self;
    [self addRefreshBlockWithHeader:^{
        weakSelf_SC.pageNum = 1;
        [weakSelf_SC netWorkRequestForUserListWithPage:weakSelf_SC.pageNum Type:LOAD_UPDATE];
    } AndFooter:^{
        weakSelf_SC.pageNum ++;
        [weakSelf_SC netWorkRequestForUserListWithPage:weakSelf_SC.pageNum Type:LOAD_MORE];
    } autoRefresh:YES];
}

- (void)netWorkRequestForUserListWithPage:(NSInteger)pageNum Type:(LOAD_TYPE)type
{
    WeakSelf
    
    [[logicShareInstance getUserManager] getUserListWithCurrentPage:pageNum pageSize:40 Success:^(id responseObject) {
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
        if (type == LOAD_MORE) {
            weakSelf_SC.pageNum --;
        }
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

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UserEntity *user = self.dataArray[indexPath.row];
    
    [self pushChatControllerWith:user];
}

- (void) pushChatControllerWith:(UserEntity *)user
{
    if ([user.hxUId length]) {
        
        self.searchController.active = NO;
        
        ChatController *chatVC = [[ChatController alloc] initWithChatter:user.hxUId];
        [self.navigationController pushViewController:chatVC animated:YES];
    } else {
        [self showHudError:@"用户信息获取失败!"];
    }
}

- (void) didSelectedUser:(UserEntity *)user
{
    [self pushChatControllerWith:user];
}

- (void) longPressAtIndexPath:(NSIndexPath *)indexPath
{
    UserEntity *user = self.dataArray[indexPath.row];
    
    if ([user.phone length]) {
        
        NSMutableString *telUrl= [[NSMutableString alloc] initWithFormat:@"tel:%@", user.phone];
        [WCAlertView showAlertWithTitle:@"提示" message:[NSString stringWithFormat:@"确认拨打: %@ ?", user.phone] customizationBlock:^(WCAlertView *alertView) {
        } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
            if (buttonIndex == 1) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:telUrl]];
            }
        } cancelButtonTitle:@"取消" otherButtonTitles:@"拨打", nil];
        
    }
}

- (UISearchController *)searchController
{
    if (!_searchController) {
        ContactResultViewController *resultVC = [[ContactResultViewController alloc] init];
        //resultVC.delegate = self;
//        BaseNavigationController *navt = [[BaseNavigationController alloc]initWithRootViewController:resultVC];
        _searchController = [[UISearchController alloc] initWithSearchResultsController:resultVC];
        //_searchController.delegate = self;
        _searchController.dimsBackgroundDuringPresentation = NO;
        _searchController.hidesNavigationBarDuringPresentation = NO;
        _searchController.searchResultsUpdater = resultVC;
        
        if (IS_IOS7) {
            UIView *subView0 = _searchController.searchBar.subviews[0];
            for (UIView *subView in subView0.subviews)
            {
                if ([subView isKindOfClass:[UIButton class]]) {
                    UIButton *cannelButton = (UIButton*)subView;
                    [cannelButton setTitle:@"取消"forState:UIControlStateNormal];
                    [cannelButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
                    break;
                }

                if ([subView isKindOfClass:[UITextField class]]) {
                    UIView *aaaa = [[UIView alloc] initWithFrame:subView.frame];
                    aaaa.backgroundColor = [UIColor yellowColor];
                    [subView addSubview:aaaa];
                }
            }
        } else {
            for(id cc in [_searchController.searchBar subviews])
            {
                if([cc isKindOfClass:[UIButton class]])
                {
                    UIButton *sbtn = (UIButton *)cc;
                    [sbtn setTitle:@"取消"  forState:UIControlStateNormal];
                    [sbtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    [sbtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
                }
            }
        }
        
    }
    return _searchController;
}

@end
