//
//  ChooseCompanyViewController.m
//  miniu
//
//  Created by SimMan on 15/6/10.
//  Copyright (c) 2015年 SimMan. All rights reserved.
//

#import "ChooseCompanyViewController.h"

#import "JSONKit.h"

@interface ChooseCompanyViewController ()

@property (nonatomic, strong) NSMutableArray *titleArray;
@property (nonatomic, copy) void (^_Blocks)(NSString *, NSString *);

@end

@implementation ChooseCompanyViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.dataArray = [NSMutableArray arrayWithArray:[[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"companys.plist" ofType:nil]]];
    
        self.titleArray = [NSMutableArray new];
        for (NSDictionary *dic in self.dataArray) {
            [_titleArray addObject:[dic objectForKey:@"index"]];
        }
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    WeakSelf
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] bk_initWithTitle:@"取消" style:UIBarButtonItemStyleDone handler:^(id sender) {
        [weakSelf_SC dismissViewControllerAnimated:YES completion:nil];
    }];
    
    self.title = @"选择物流公司";
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.rowHeight = 55.0f;
}

- (void)customTable
{
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth
    |UIViewAutoresizingFlexibleHeight;
    
    [self.view addSubview:self.tableView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.dataArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[self.dataArray objectAtIndex:section] objectForKey:@"list"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ChooseCompanyCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
        [cell.imageView setFrame:CGRectMake(25, 5, 45, 45)];
        cell.imageView.layer.masksToBounds = YES;
        cell.imageView.layer.cornerRadius = 45 / 2;
    }
    
    NSDictionary *dic = [[[self.dataArray objectAtIndex:indexPath.section] objectForKey:@"list"] objectAtIndex:indexPath.row];
    
    [cell.imageView setImage:[UIImage imageNamed:dic[@"logoMd5"]]];
    [cell.textLabel setText:dic[@"name"]];
    [cell.detailTextLabel setText:dic[@"contact"]];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = [NSString stringWithFormat:@"%@", self.titleArray[section]];
    return title;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return _titleArray;
}
#pragma mark -
#pragma mark Table View Delegate Methods
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath;
}
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title
               atIndex:(NSInteger)index
{
    return index;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dic = [[[self.dataArray objectAtIndex:indexPath.section] objectForKey:@"list"] objectAtIndex:indexPath.row];

    if (__Blocks) {
        __Blocks(dic[@"number"], dic[@"name"]);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addCallBackBlock:(void (^)(NSString *, NSString *))Block
{
    __Blocks = Block;
}

@end
