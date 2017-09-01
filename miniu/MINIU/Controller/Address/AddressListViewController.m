//
//  AddressListViewController.m
//  DLDQ_IOS
//
//  Created by simman on 14-9-2.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import "AddressListViewController.h"
#import "AddressEntity.h"
#import "AddressListCell.h"
#import "AddressDetailsController.h"

@interface AddressListViewController ()

@end

@implementation AddressListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setNavTitle:@"地址管理"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self setupRefresh];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(setNavRightBarButtonAction:)];
    
    [self.view beginLoading];
}

/**
 *  右侧导航事件
 *
 *  @param sender
 */
- (void) setNavRightBarButtonAction:(id)sender
{
    AddressDetailsController *addressDetailsVC = [[AddressDetailsController alloc] init];
    [addressDetailsVC setAddressDataWithAddressEntity:nil addCallBackBlock:^(AddressEntity *addressEntity) {
        [self getAddressListWithNetWork];
    }];
    [self.navigationController pushViewController:addressDetailsVC animated:YES];
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([self.dataArray count]) {
        return 1;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier=@"AddressListCell";
    AddressListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [AddressListCell shareXibView];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    [cell setCellDataWithAddressEntity:self.dataArray[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    @try {
        [self asyncBackgroundQueue:^{
            AddressEntity *addressEntity = self.dataArray[indexPath.row];
            AddressDetailsController *addressDetailsVC = [[AddressDetailsController alloc] init];
            [addressDetailsVC setAddressDataWithAddressEntity:addressEntity addCallBackBlock:^(AddressEntity *addressEntity) {
                [self getAddressListWithNetWork];
            }];
            [self asyncMainQueue:^{
                [self.navigationController pushViewController:addressDetailsVC animated:YES];
            }];
        }];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    };
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle) editingStyle forRowAtIndexPath:(NSIndexPath *) indexPath
{
    @try {
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            WeakSelf
            AddressEntity *addressEntity = self.dataArray[indexPath.row];
            [[logicShareInstance getAddressManager] deleteAddress:addressEntity success:^(id responseObject) {
                [weakSelf_SC.dataArray removeObject:addressEntity];
                [weakSelf_SC.tableView reloadData];
            } failure:^(NSString *error) {
                [self showHudError:error];
            }];
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    };
}

#pragma mark 上拉加载，下拉刷新
- (void)setupRefresh
{
    __weak __typeof(&*self)weakSelf_SC = self;
    [self addRefreshBlockWithHeader:^{
        [weakSelf_SC getAddressListWithNetWork];
    } AndFooter:nil autoRefresh:YES];
}

#pragma mark 网络获取地址列表
- (void) getAddressListWithNetWork
{
    WeakSelf
    [[logicShareInstance getAddressManager] getAddressList:^(id responseObject) {
        @try {
            NSMutableArray *tmpArray = [NSMutableArray arrayWithCapacity:1];
            for ( NSDictionary *dic in [responseObject objectForKey:@"data"]) {
                AddressEntity *addressEntity = [[AddressEntity alloc] init];
                [addressEntity setValuesForKeysWithDictionary:dic];
                [tmpArray addObject:addressEntity];
            }
            if ([tmpArray count] > 0) {
                [weakSelf_SC.dataArray removeAllObjects];
                [weakSelf_SC.dataArray addObjectsFromArray:tmpArray];
                [weakSelf_SC.tableView reloadData];
            }
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
            [weakSelf_SC.view configBlankPage:EaseBlankPageTypeAddress hasData:[weakSelf_SC.dataArray count] hasError:NO reloadButtonBlock:nil];
            [weakSelf_SC.view endLoading];
            
        };
    } failure:^(NSString *error) {
        [weakSelf_SC.view endLoading];
        [weakSelf_SC showHudError:error];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
