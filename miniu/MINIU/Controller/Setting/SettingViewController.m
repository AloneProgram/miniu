//
//  SettingViewController.m
//  miniu
//
//  Created by SimMan on 4/22/15.
//  Copyright (c) 2015 SimMan. All rights reserved.
//

#import "SettingViewController.h"
//#import "iVersion.h"
#import "AboutUSViewController.h"

@interface SettingViewController () 

@property (nonatomic, retain) FUIButton *logoutBtn;
@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, assign) float cacheSize;
@property (nonatomic, assign) NSUInteger cacheCount;

@end

@implementation SettingViewController

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        [self setNavTitle:@"设置"];
        
        _cacheSize = 0;
        
        [self asyncBackgroundQueue:^{
            [self setCacheCount:[[SDImageCache sharedImageCache] getDiskCount]];
            [self setCacheSize: ([[SDImageCache sharedImageCache] getSize]) / 1024.0 / 1024.0];
        }];
    }
    return self;
}

- (void) setCacheSize:(float)cacheSize
{
    _cacheSize = cacheSize;
    WeakSelf
    [self asyncMainQueue:^{
        [weakSelf_SC.tableView reloadData];
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 15)];
    
    _logoutBtn = [[FUIButton alloc] initWithFrame:CGRectMake(20, 0, kScreen_Width - 40, 40)];
    [_logoutBtn setTitle:@"退出登录" forState:UIControlStateNormal];
    [_logoutBtn setButtonColor:[UIColor redColor]];
    _logoutBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    _logoutBtn.cornerRadius = 5;
    
    [_logoutBtn addTarget:self action:@selector(userLogoutAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 80)];
    [view addSubview:_logoutBtn];
    
    
    self.tableView.tableFooterView = view;
    
    
    //    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor colorWithRed:0.902 green:0.902 blue:0.894 alpha:1];
    self.tableView.rowHeight = 50.0f;
    
    self.titleArray = @[
                        @[@"清除缓存",],
                        @[@"用户协议", @"关于米妞"]
                        ];
    
    [self.tableView reloadData];
}

- (void)customTable
{
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth
    |UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.tableView];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.titleArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.titleArray[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifiter = @"SettingCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifiter];
    
    if (cell == nil) {
        //        cell = [SettingCell shareInstanceCell];
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifiter];
    }
    //    [cell setCellLableName:self.titleArray[indexPath.section][indexPath.row]];
    //    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [cell.textLabel setText:self.titleArray[indexPath.section][indexPath.row]];
    [cell.textLabel setFont:[UIFont systemFontOfSize:14]];
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        [cell.detailTextLabel setText:[NSString stringWithFormat:@"%0.2fM", _cacheSize]];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        [self clearImageCache];
    } else if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0: {
                [self openUrlOnWebViewWithURL:[NSURL URLWithString:API_Agreement] type:PUSH];
            }
                break;
            case 1: {
                AboutUSViewController *aboutVC = [[AboutUSViewController alloc] init];
                [self.navigationController pushViewController:aboutVC animated:YES];
            }
                break;
            case 2: {
//                [[iVersion sharedInstance] openAppPageInAppStore];
            }
                break;
            default:
                break;
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark 清除缓存
- (void)clearImageCache
{
    NSString *message = [NSString stringWithFormat:@"缓存大小: %0.2fM,文件个数: %d", _cacheSize, (int)_cacheCount];
    
    WeakSelf
    [WCAlertView showAlertWithTitle:@"清除缓存" message:message customizationBlock:^(WCAlertView *alertView) {
        
    } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
        
        if (buttonIndex == 0) {
            [[SDImageCache sharedImageCache] clearDiskOnCompletion:^{
                
                [weakSelf_SC setCacheCount:[[SDImageCache sharedImageCache] getDiskCount]];
                [weakSelf_SC setCacheSize: ([[SDImageCache sharedImageCache] getSize]) / 1024.0 / 1024.0];
                
                [weakSelf_SC showStatusBarSuccessStr:@"成功清除缓存文件!"];
                [weakSelf_SC.tableView reloadData];
            }];
        }
    } cancelButtonTitle:@"清除" otherButtonTitles:@"取消", nil];
}

#pragma mark 用户退出
- (void)userLogoutAction
{
    WeakSelf
    @try {

        [logicShareInstance doLogoutLogic];
        [[weakSelf_SC mainDelegate] changeRootViewController];
        [weakSelf_SC.navigationController popToRootViewControllerAnimated:YES];
    }
    @catch (NSException *exception) {}
    @finally {};
}
@end
