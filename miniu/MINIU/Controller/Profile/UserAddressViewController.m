//
//  UserAddressViewController.m
//  miniu
//
//  Created by SimMan on 15/6/1.
//  Copyright (c) 2015年 SimMan. All rights reserved.
//

#import "UserAddressViewController.h"
#import "AddressEntity.h"
#import "UpdateAddressViewController.h"

@interface UserAddressViewController ()

@property (nonatomic, copy) void (^_Blocks)(AddressEntity *);
@property (nonatomic, assign) long long applyUserId;


@end

@implementation UserAddressViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"收货地址";
    
    _selectedMark = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"default"]];
    
    self.navigationItem.backBarButtonItem = [UIBarButtonItem blankBarButton];
    
    self.tableView.backgroundColor = [UIColor colorWithRed:0.941 green:0.941 blue:0.941 alpha:1];
    
    [self.view beginLoading];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.rowHeight = 80.0f;
    self.tableView.tableFooterView = [self addButtonWithFooterView];
    
    [self setupRefresh];
}

- (void)customTable
{
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [self.tableView setHeight:self.tableView.frame.size.height -45];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth
    |UIViewAutoresizingFlexibleHeight;
    
    if (IS_IOS7) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if (IS_IOS8) {
        if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
            [self.tableView setSeparatorInset:UIEdgeInsetsMake(0,-20,0,0)];
        }
        
        if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
            [self.tableView setLayoutMargins:UIEdgeInsetsMake(0,-20,0,0)];
        }
    }
    
    [self.view addSubview:self.tableView];


}


- (UIView *) addButtonWithFooterView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 45)];
    view.backgroundColor = [UIColor whiteColor];
    UIButton *addButton = [[UIButton alloc] initWithFrame:view.frame];
    [addButton setTitle:@"＋ 添加新地址" forState:UIControlStateNormal];
    [addButton.titleLabel setFont:[UIFont flatFontOfSize:16]];
    [addButton setTitleColor:[UIColor colorWithRed:0.000 green:0.824 blue:0.212 alpha:1] forState:UIControlStateNormal];
    
    //水平偏移
    addButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    //内容偏移
    [addButton setContentEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
    
    [view addLineUp:YES andDown:YES];
    
    [view addSubview:addButton];
    
    [addButton bk_addEventHandler:^(id sender) {
        UpdateAddressViewController *updateAddressVC = [[UpdateAddressViewController alloc] init];
        updateAddressVC.createUserId = _applyUserId;
        
        updateAddressVC.orderEntity = self.order;
        
        [self.navigationController pushViewController:updateAddressVC animated:YES];
    } forControlEvents:UIControlEventTouchUpInside];
    
    return view;
}

- (void)viewWillAppear:(BOOL)animated
{
//    if (self.tableView.numberOfSections == 0 && self.order) {
//        UpdateAddressViewController *updateAddressVC = [[UpdateAddressViewController alloc] init];
//        updateAddressVC.createUserId = _applyUserId;
//        
//        updateAddressVC.orderEntity = self.order;
//        
//        [self.navigationController pushViewController:updateAddressVC animated:YES];
//
//    }
    [super viewWillAppear:animated];
    [self getAddressListWithNetWork];
    
    
}

#pragma mark 上拉加载，下拉刷新
- (void)setupRefresh
{
    __weak __typeof(&*self)weakSelf_SC = self;
    [self addRefreshBlockWithHeader:^{
        [weakSelf_SC getAddressListWithNetWork];
    } AndFooter:nil autoRefresh:NO];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.dataArray count];;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.001;
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger userNameAndPhoneTag = 1001;
    NSInteger userAddressTag = 1002;
    
    static NSString *CellIdentifier=@"UserAddressCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel *nameAndPhoneLable = [[UILabel alloc] initWithFrame:CGRectMake(20, 17, kScreen_Width - 20 * 2, 20)];
        [nameAndPhoneLable setFont:[UIFont flatFontOfSize:14]];
        nameAndPhoneLable.tag = userNameAndPhoneTag;
        
        UILabel *addressLable =[[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(nameAndPhoneLable.frame) + 16, kScreen_Width - 20 * 2, 20)];
        [addressLable setFont:[UIFont flatFontOfSize:12]];
        [addressLable setTextColor:[UIColor lightGrayColor]];
        addressLable.tag = userAddressTag;
        
        [cell.contentView addSubview:nameAndPhoneLable];
        [cell.contentView addSubview:addressLable];
    }
    
    UILabel *nameAndPhoneLable = (UILabel *)[cell viewWithTag:userNameAndPhoneTag];
    UILabel *addressLable = (UILabel *)[cell viewWithTag:userAddressTag];
    
    AddressEntity *address = self.dataArray[indexPath.section];
    
    [nameAndPhoneLable setText:[NSString stringWithFormat:@"%@       %@", address.realName, address.phone]];
    [addressLable setLongString:[NSString stringWithFormat:@"%@", address.address] withFitWidth:kScreen_Width - 20 * 2 maxHeight:50];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle) editingStyle forRowAtIndexPath:(NSIndexPath *) indexPath
{
    @try {
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            WeakSelf
            AddressEntity *addressEntity = self.dataArray[indexPath.section];
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

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    AddressEntity *address = self.dataArray[indexPath.section];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    [_selectedMark removeFromSuperview];
    [cell addSubview:_selectedMark];
    CGRect cellCect = cell.frame;
    _selectedMark.frame = CGRectMake(cellCect.size.width-50, (cellCect.size.height-_selectedMark.frame.size.height)/2, _selectedMark.frame.size.width, _selectedMark.frame.size.height);
    
    WeakSelf
    if (self.applyUserId) {
        
        [self asyncMainQueue:^{
            [WCAlertView showAlertWithTitle:@"提示" message:@"确定使用此收货地址？" customizationBlock:^(WCAlertView *alertView) {
                
            } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
                
                if (buttonIndex && __Blocks) {
                    __Blocks(address);
                }
                
                [weakSelf_SC.navigationController popViewControllerAnimated:YES];
            } cancelButtonTitle:@"取消" otherButtonTitles:@"使用", nil];
        }];
        
    } else {
        
        UpdateAddressViewController *updateAddressVC = [[UpdateAddressViewController alloc] init];
        updateAddressVC.address = address;
        [self.navigationController pushViewController:updateAddressVC animated:YES];
    }
}

#pragma mark 网络获取地址列表
- (void) getAddressListWithNetWork
{
    WeakSelf
    
    long long userId = USER_IS_LOGIN;
    
    if (_applyUserId) {
        userId = _applyUserId;
    }
    
    [[logicShareInstance getAddressManager] getAddressListWithUid:userId success:^(id responseObject) {
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
            }else{
//                //如果获取不到用户记录的地址
//                UpdateAddressViewController *updateAddressVC = [[UpdateAddressViewController alloc] init];
//                updateAddressVC.createUserId = _applyUserId;
//                
//                updateAddressVC.orderEntity = self.order;
//                if ([[UIDevice currentDevice].systemVersion doubleValue]<9.0 ) {
//
//                    [self.navigationController pushViewController:updateAddressVC animated:YES];
//                }

            }
                [weakSelf_SC.view endLoading];
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            [weakSelf_SC.view endLoading];
            
        };
    } failure:^(NSString *error) {
        [weakSelf_SC.view endLoading];
        [weakSelf_SC showHudError:error];
    }];
}

- (void)createAddressApplyId:(long long)applyId addCallBackBlock:(void (^)(AddressEntity *))Block
{
    _applyUserId = applyId;
    __Blocks = Block;
}

@end
