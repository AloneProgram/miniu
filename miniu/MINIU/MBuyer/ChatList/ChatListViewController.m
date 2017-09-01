/************************************************************
 *  * EaseMob CONFIDENTIAL
 * __________________
 * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of EaseMob Technologies.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from EaseMob Technologies.
 */

#import "ChatListViewController.h"
#import "SRRefreshView.h"
#import "ChatListCell.h"
#import "EMSearchBar.h"
#import "NSDate+Category.h"
#import "RealtimeSearchUtil.h"
#import "ChatController.h"
#import "EMSearchDisplayController.h"
#import "ConvertToCommonEmoticonsHelper.h"
#import "UserEntity.h"
#import "ContactViewController.h"
#import "BaseNavigationController.h"
#import "NotificationIndexViewController.h"

#import "MBProgressHUD.h"
#import "MBProgressHUD+Add.h"

@interface ChatListViewController ()<UITableViewDelegate,UITableViewDataSource, UISearchDisplayDelegate,SRRefreshDelegate, UISearchBarDelegate, IChatManagerDelegate> {
    dispatch_queue_t _messageQueue;
}

@property (strong, nonatomic) NSMutableArray        *dataSource;
@property (nonatomic, strong) NSMutableDictionary   *msgUserData;     // 存放用户对象的字典
@property (strong, nonatomic) UITableView           *tableView;
@property (nonatomic, strong) EMSearchBar           *searchBar;
@property (nonatomic, strong) SRRefreshView         *slimeView;
@property (nonatomic, strong) UIView                *networkStateView;

@property (strong, nonatomic) EMSearchDisplayController *searchController;

@property (assign ,atomic) BOOL hasNotClickCell; //会出现狂跳转
@end

@implementation ChatListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _dataSource = [NSMutableArray array];
        _msgUserData = [NSMutableDictionary dictionary];
        _messageQueue = dispatch_queue_create("get_hx_user_entity", NULL);
        
#if TARGET_IS_MINIU_BUYER
        //接受通知在这里push相关页面
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushViewcontroller:) name:@"MENU_PUSH_VIEW_CONTROLLER" object:nil];
#endif
    }
    return self;
}

- (void)viewDidLoad
{
    _hasNotClickCell = YES;
    
    [super viewDidLoad];
    [self removeEmptyConversationsFromDB];
    
    [self.view addSubview:self.searchBar];
    [self.view addSubview:self.tableView];
    [self.tableView addSubview:self.slimeView];
    [self networkStateView];
    
    [self searchController];
    
#if TARGET_IS_MINIU_BUYER
    WeakSelf
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] bk_initWithImage:[UIImage imageNamed:@"我"] style:UIBarButtonItemStylePlain handler:^(id sender) {
        [[weakSelf_SC mainDelegate].frostedViewController presentMenuViewController];
    }];
    //把通讯录 改为通知
    /*
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] bk_initWithImage:[UIImage imageNamed:@"iconfont-Contact"] style:UIBarButtonItemStylePlain handler:^(id sender) {
        if (IS_IOS8) {
            ContactViewController *contactvc = [[ContactViewController alloc] init];
            BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:contactvc];
            [self presentViewController:nav animated:YES completion:nil];
        } else {
            [weakSelf_SC showHudError:@"此功能需IOS8及以上版本!"];
        }
    }];
     */
    
#warning 暂时去掉通知消息 等到有需要 系统通知的消息的时候在再开启
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] bk_initWithImage:[UIImage imageNamed:@"notify_focus"] style:UIBarButtonItemStylePlain handler:^(id sender) {
//        if (IS_IOS7) {
//            NotificationIndexViewController *vc = [[NotificationIndexViewController alloc] init];
//            //BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:vc];
//            [self.navigationController pushViewController:vc animated:YES ];
//        } else {
//            [weakSelf_SC showHudError:@"此功能需IOS7及以上版本!"];
//        }
//    }];
#endif
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self refreshDataSource];
    [self registerNotifications];
//    [self testRunTime];
    //NSAssert([[UIApplication sharedApplication] currentUserNotificationSettings].types !=0, @"nononononononoonono");
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self unregisterNotifications];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:NO animated:YES];
}

/**
 *  清除空的数据对话
 */
- (void)removeEmptyConversationsFromDB
{
    NSArray *conversations = [[EaseMob sharedInstance].chatManager conversations];
    NSMutableArray *needRemoveConversations;
    for (EMConversation *conversation in conversations) {
        if (!conversation.latestMessage) {
            if (!needRemoveConversations) {
                needRemoveConversations = [[NSMutableArray alloc] initWithCapacity:0];
            }
            
            [needRemoveConversations addObject:conversation.chatter];
        }
    }
    
    if (needRemoveConversations && needRemoveConversations.count > 0) {
        [[EaseMob sharedInstance].chatManager removeConversationsByChatters:needRemoveConversations
                                                             deleteMessages:YES
                                                                append2Chat:NO];
    }
}

#pragma mark - getter

- (SRRefreshView *)slimeView
{
    if (!_slimeView) {
        
        //滑动的背景图
        _slimeView = [[SRRefreshView alloc] init];
        _slimeView.delegate = self;
        _slimeView.upInset = 0;
        _slimeView.slimeMissWhenGoingBack = YES;
        _slimeView.slime.bodyColor = [UIColor grayColor];
        _slimeView.slime.skinColor = [UIColor grayColor];
        _slimeView.slime.lineWith = 1;
        _slimeView.slime.shadowBlur = 4;
        _slimeView.slime.shadowColor = [UIColor grayColor];
        _slimeView.backgroundColor = [UIColor whiteColor];
    }
    
    return _slimeView;
}

- (UISearchBar *)searchBar
{
    if (!_searchBar) {
        _searchBar = [[EMSearchBar alloc] initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, 44)];
        _searchBar.delegate = self;
        _searchBar.placeholder = NSLocalizedString(@"search", @"Search");
        _searchBar.backgroundColor = [UIColor colorWithRed:0.747 green:0.756 blue:0.751 alpha:1.000];
    }
    
    return _searchBar;
}

- (UITableView *)tableView
{
    if (_tableView == nil) {
        //设置在search bar 下面
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.searchBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.searchBar.frame.size.height) style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[ChatListCell class] forCellReuseIdentifier:@"chatListCell"];
    }
    
    return _tableView;
}

- (EMSearchDisplayController *)searchController
{
    if (_searchController == nil) {
        _searchController = [[EMSearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
        _searchController.delegate = self;
        _searchController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        __weak ChatListViewController *weakSelf = self;
        [_searchController setCellForRowAtIndexPathCompletion:^UITableViewCell *(UITableView *tableView, NSIndexPath *indexPath) {
            static NSString *CellIdentifier = @"ChatListCell";
            ChatListCell *cell = (ChatListCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            // Configure the cell...
            if (cell == nil) {
                cell = [[ChatListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            
            EMConversation *conversation = [weakSelf.searchController.resultsSource objectAtIndex:indexPath.row];
            
            //设置名字
            [[logicShareInstance getUserManager] getUserEntityWithHXID:conversation.chatter result:^(UserEntity *userEntity) {
                cell.name = userEntity.nickName;
                cell.imageURL = userEntity.avatar;
            }];
            
            if (!conversation.isGroup) {
                cell.placeholderImage = [UIImage imageNamed:@"chatListCellHead.png"];
            }
            else{
                //NSString *imageName = @"groupPublicHeader";
                NSArray *groupArray = [[EaseMob sharedInstance].chatManager groupList];
                for (EMGroup *group in groupArray) {
                    if ([group.groupId isEqualToString:conversation.chatter]) {
                        cell.name = group.groupSubject;
                        //imageName = group.isPublic ? @"groupPublicHeader" : @"groupPrivateHeader";
                        break;
                    }
                }
                //cell.placeholderImage = [UIImage imageNamed:imageName];
            }
            cell.detailMsg = [weakSelf subTitleMessageByConversation:conversation];
            cell.time = [weakSelf lastMessageTimeByConversation:conversation];
            cell.unreadCount = [weakSelf unreadMessageCountByConversation:conversation];
            if (indexPath.row % 2 == 1) {
                cell.contentView.backgroundColor = RGBACOLOR(246, 246, 246, 1);
            }else{
                cell.contentView.backgroundColor = [UIColor whiteColor];
            }
            return cell;
        }];
        
        [_searchController setHeightForRowAtIndexPathCompletion:^CGFloat(UITableView *tableView, NSIndexPath *indexPath) {
            return [ChatListCell tableView:tableView heightForRowAtIndexPath:indexPath];
        }];
        
        [_searchController setDidSelectRowAtIndexPathCompletion:^(UITableView *tableView, NSIndexPath *indexPath) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [weakSelf.searchController.searchBar endEditing:YES];
            
            EMConversation *conversation = [weakSelf.searchController.resultsSource objectAtIndex:indexPath.row];
            
#if TARGET_IS_MINIU_BUYER
//            if ([conversation.chatter isEqualToString:[CURRENT_USER_INSTANCE getCurrentUserHXID]]) {
//                [weakSelf showHudError:@"抱歉,你不能和自己聊天!"];
//                return;
//            }
#endif
            
            ChatController *chatVC = [[ChatController alloc] initWithChatter:conversation.chatter];
            chatVC.title = conversation.chatter;
            [weakSelf.navigationController pushViewController:chatVC animated:YES];
        }];
    }
    
    return _searchController;
}

- (UIView *)networkStateView
{
    if (_networkStateView == nil) {
        _networkStateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
        _networkStateView.backgroundColor = [UIColor colorWithRed:255 / 255.0 green:199 / 255.0 blue:199 / 255.0 alpha:0.5];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, (_networkStateView.frame.size.height - 20) / 2, 20, 20)];
        imageView.image = [UIImage imageNamed:@"messageSendFail"];
        [_networkStateView addSubview:imageView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) + 5, 0, _networkStateView.frame.size.width - (CGRectGetMaxX(imageView.frame) + 15), _networkStateView.frame.size.height)];
        label.font = [UIFont systemFontOfSize:15.0];
        label.textColor = [UIColor grayColor];
        label.backgroundColor = [UIColor clearColor];
        label.text = NSLocalizedString(@"network.disconnection", @"Network disconnection");
        [_networkStateView addSubview:label];
    }
    
    return _networkStateView;
}

#pragma mark - private

- (NSMutableArray *)loadDataSource
{
    NSMutableArray *ret = nil;
    //数据加载
    NSArray *conversations = [[EaseMob sharedInstance].chatManager conversations];
    
    NSLog(@"current chatter's conversations -> %@",conversations);
    
    NSArray* sorte = [conversations sortedArrayUsingComparator:
                      ^(EMConversation *obj1, EMConversation* obj2){
                          EMMessage *message1 = [obj1 latestMessage];
                          EMMessage *message2 = [obj2 latestMessage];
                          if(message1.timestamp > message2.timestamp) {
                              return(NSComparisonResult)NSOrderedAscending;
                          }else {
                              return(NSComparisonResult)NSOrderedDescending;
                          }
                      }];
    
    ret = [[NSMutableArray alloc] initWithArray:sorte];
    return ret;
}

// 得到最后消息时间
-(NSString *)lastMessageTimeByConversation:(EMConversation *)conversation
{
    NSString *ret = @"";
    EMMessage *lastMessage = [conversation latestMessage];;
    if (lastMessage) {
        ret = [NSDate formattedTimeFromTimeInterval:lastMessage.timestamp];
    }
    
    return ret;
}

// 得到未读消息条数
- (NSInteger)unreadMessageCountByConversation:(EMConversation *)conversation
{
    NSInteger ret = 0;
    ret = conversation.unreadMessagesCount;
    
    return  ret;
}

// 得到最后消息文字或者类型
-(NSString *)subTitleMessageByConversation:(EMConversation *)conversation
{
    NSString *ret = @"";
    EMMessage *lastMessage = [conversation latestMessage];
    if (lastMessage) {
        id<IEMMessageBody> messageBody = lastMessage.messageBodies.lastObject;
        switch (messageBody.messageBodyType) {
            case eMessageBodyType_Image:{
                ret = NSLocalizedString(@"message.image1", @"[image]");
            } break;
            case eMessageBodyType_Text:{
                // 表情映射。
                NSString *didReceiveText = [ConvertToCommonEmoticonsHelper
                                            convertToSystemEmoticons:((EMTextMessageBody *)messageBody).text];
                ret = didReceiveText;
            } break;
            case eMessageBodyType_Voice:{
                ret = NSLocalizedString(@"message.voice1", @"[voice]");
            } break;
            case eMessageBodyType_Location: {
                ret = NSLocalizedString(@"message.location1", @"[location]");
            } break;
            case eMessageBodyType_Video: {
                ret = NSLocalizedString(@"message.vidio1", @"[vidio]");
            } break;
            default: {
            } break;
        }
    }
    
    return ret;
}

#pragma mark - TableViewDelegate & TableViewDatasource

-(UITableViewCell *)tableView:(UITableView *)tableView
        cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identify = @"chatListCell";
    ChatListCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    
    if (!cell) {
        cell = [[ChatListCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identify];
    }
    //获取对话实体
    EMConversation *conversation = [self.dataSource objectAtIndex:indexPath.row];
    
    UserEntity *user = [[UserEntity alloc] init];
    @try {
        if (self.msgUserData) {
            user = self.msgUserData[conversation.chatter];
        }
    }
    @catch (NSException *exception) {}
    @finally {}
    
    cell.name = user.nickName;
//    cell.name = conversation.chatter;
    
    if (!conversation.isGroup) {
        
        [cell.imageView setImageWithUrl:user.avatar withSize:ImageSizeOf64];
        
//        cell.placeholderImage = [UIImage imageNamed:@"chatListCellHead.png"];
//        cell.imageURL = user.avatar;
    }
    else{
        NSString *imageName = @"groupPublicHeader";
        if (![conversation.ext objectForKey:@"groupSubject"] || ![conversation.ext objectForKey:@"isPublic"])
        {
            NSArray *groupArray = [[EaseMob sharedInstance].chatManager groupList];
            for (EMGroup *group in groupArray) {
                if ([group.groupId isEqualToString:conversation.chatter]) {
                    cell.name = group.groupSubject;
                    imageName = group.isPublic ? @"groupPublicHeader" : @"groupPrivateHeader";
                    
                    NSMutableDictionary *ext = [NSMutableDictionary dictionaryWithDictionary:conversation.ext];
                    [ext setObject:group.groupSubject forKey:@"groupSubject"];
                    [ext setObject:[NSNumber numberWithBool:group.isPublic] forKey:@"isPublic"];
                    conversation.ext = ext;
                    break;
                }
            }
        }
        else
        {
            cell.name = [conversation.ext objectForKey:@"groupSubject"];
            imageName = [[conversation.ext objectForKey:@"isPublic"] boolValue] ? @"groupPublicHeader" : @"groupPrivateHeader";
        }
        cell.placeholderImage = [UIImage imageNamed:imageName];
    }
    cell.detailMsg = [self subTitleMessageByConversation:conversation];
    cell.time = [self lastMessageTimeByConversation:conversation];
    cell.unreadCount = [self unreadMessageCountByConversation:conversation];
    if (indexPath.row % 2 == 1) {
        cell.contentView.backgroundColor = RGBACOLOR(246, 246, 246, 1);
    }else{
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  self.dataSource.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [ChatListCell tableView:tableView heightForRowAtIndexPath:indexPath];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    EMConversation *conversation = [self.dataSource objectAtIndex:indexPath.row];
    
    ChatController *chatController;
    NSString *title = conversation.chatter;
#warning 尚无群聊
    /*
    if (conversation.isGroup) {
        NSArray *groupArray = [[EaseMob sharedInstance].chatManager groupList];
        for (EMGroup *group in groupArray) {
            if ([group.groupId isEqualToString:conversation.chatter]) {
                title = group.groupSubject;
                break;
            }
        }
    }
     */
    NSString *chatter = conversation.chatter;

//#if TARGET_IS_MINIU_BUYER
//    if ([chatter isEqualToString:[CURRENT_USER_INSTANCE getCurrentUserHXID]]) {
//        [self showHudError:@"不好意思,你不能和自己聊天!"];
//        return;
//    }
//#endif
    
//    static int i = 0;
//    [self showStatusBarError:[NSString stringWithFormat: @"clickcell %i",i++]];
    
    //chatController = [[ChatController alloc] initWithChatter:chatter];
    //chatController.title = title;
    
    if (_hasNotClickCell) {
        _hasNotClickCell = false;
        chatController = [[ChatController alloc] initWithChatter:chatter];
        chatController.title = title;
        [self performSelector:@selector(changeFlagForClick) withObject:nil afterDelay:0.5f];
        [self.navigationController pushViewController:chatController animated:YES];
    }
    
}

-(void)changeFlagForClick
{
    _hasNotClickCell = YES;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        WeakSelf
        [WCAlertView showAlertWithTitle:@"提示" message:@"是否删除此条消息？" customizationBlock:^(WCAlertView *alertView) {
            
        } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
            if (buttonIndex == 1) {
                EMConversation *converation = [self.dataSource objectAtIndex:indexPath.row];
                [[EaseMob sharedInstance].chatManager removeConversationByChatter:converation.chatter deleteMessages:YES append2Chat:YES];
                [weakSelf_SC.dataSource removeObjectAtIndex:indexPath.row];
                [weakSelf_SC.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
        } cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    }
}

#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    
    return YES;
}

//多线程查询联系人
#warning 目前只能根据联系人的环信id查询 需要重写
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    static NSMutableArray *resultArray;
    if (!resultArray) {
        resultArray = [[NSMutableArray alloc]init];
    }else{
        [resultArray removeAllObjects];
    }
    

    for (EMConversation *conversation in self.dataSource) {
        
        [[logicShareInstance getUserManager] getUserEntityWithHXID:conversation.chatter result:^(UserEntity *userEntity) {
            NSLog(@"nick name - > %@\nserachtext ->%@",userEntity.nickName,searchText);
            if ([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0) {
                if ([userEntity.nickName containsString:searchText]) {
                    [resultArray addObject:conversation];
                    
                }
            }else{
                [self showHudError:@"只能在iOS8以上才能查询!"];
            }
            
            
        }];
        
    }
    if (resultArray.count == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.searchController.resultsSource removeAllObjects];
            //[self.searchController.resultsSource addObjectsFromArray:resultArray];
            [self.searchController.searchResultsTableView reloadData];
        });
        return;
    }else{
        
        NSLog(@"有%d个结果",resultArray.count);
        //显示查询结果
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.searchController.resultsSource removeAllObjects];
            [self.searchController.resultsSource addObjectsFromArray:resultArray];
            [self.searchController.searchResultsTableView reloadData];
        });
    }
    /*
    [[RealtimeSearchUtil currentUtil] realtimeSearchWithSource:self.dataSource searchText:(NSString *)searchText collationStringSelector:@selector(chatter) resultBlock:^(NSArray *results) {
        if (results) {
            //显示查询结果
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.searchController.resultsSource removeAllObjects];
                [self.searchController.resultsSource addObjectsFromArray:results];
                [self.searchController.searchResultsTableView reloadData];
            });
        }
    }];
     */
}



- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = @"";
    [[RealtimeSearchUtil currentUtil] realtimeSearchStop];
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
}

#pragma mark - scrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_slimeView scrollViewDidScroll];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_slimeView scrollViewDidEndDraging];
}

#pragma mark - slimeRefresh delegate
//刷新消息列表
- (void)slimeRefreshStartRefresh:(SRRefreshView *)refreshView
{
    [self refreshDataSource];
    [_slimeView endRefresh];
}

#pragma mark - IChatMangerDelegate

-(void)didUnreadMessagesCountChanged
{
    [self refreshDataSource];
}

- (void)didUpdateGroupList:(NSArray *)allGroups error:(EMError *)error
{
    [self refreshDataSource];
}

#pragma mark - registerNotifications
-(void)registerNotifications{
    [self unregisterNotifications];
    
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    //[[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:dispatch_get_global_queue(QOS_CLASS_UTILITY, 0)];//改为global线程
}

-(void)unregisterNotifications{
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
}

- (void)dealloc{
    [self unregisterNotifications];
}

#pragma mark - public
/**
 *  刷新数据
 */
-(void)refreshDataSource
{
    //if(!_hasNotClickCell)return;
    
    //获取聊天对话conversations
    self.dataSource = [self loadDataSource];
    //更新对话ui
    [self refreshUserEntityData];
    [_tableView reloadData];
    
    NSInteger unreadCount = 0;
    for (EMConversation *conversation in self.dataSource) {
        unreadCount += conversation.unreadMessagesCount;
    }
    
    WeakSelf
    //设置tabbar的未读数
    [self asyncMainQueue:^{
        [weakSelf_SC.rdv_tabBarItem setBadgePositionAdjustment:UIOffsetMake(-4, 1)];
        if ( unreadCount > 0) {
            [weakSelf_SC.rdv_tabBarItem setBadgeValue:[NSString stringWithFormat:@"%d",(int)unreadCount]];
        } else {
            [weakSelf_SC.rdv_tabBarItem setBadgeValue:@""];
        }
    }];
//    [self hideHud];
}

/**
 *  获取用户名字典 并更新UI
 */
- (void) refreshUserEntityData
{
    // 如果数量相等,则不进行刷新
    NSInteger dataCount = [self.dataSource count];
    
    //应当根据是否有变化的情况下再刷新数据
    
    //强制刷新 by LZJ  买手版2015.8.19cancel //节省很多时间
#if TARGET_IS_MINIU_BUYER
    if ([[self.msgUserData allKeys] count] == dataCount) {
        return;
    }
#endif
    NSMutableDictionary *tmpUserData = [NSMutableDictionary dictionaryWithCapacity:1];
    
    if (self) {
        
        [self showHudLoad:@"正在获取对话消息"];
    }
    WeakSelf
    dispatch_async(_messageQueue, ^{
        for (EMConversation *coversation in weakSelf_SC.dataSource) {
            
            //正在加载内容 通过查询本地缓存 没有就写入 然后再更新ui 对话多的时候会卡 添加进度限制锁
            [[logicShareInstance getUserManager] getUserEntityWithHXID:coversation.chatter result:^(UserEntity *userEntity) {
                //设置用户名key-value 集合
                [tmpUserData setObject:userEntity forKey:userEntity.hxUId];
                NSLog(@"all the user data :%@",tmpUserData);
                // 如果全部获取完，刷新UI
                if (dataCount == [[tmpUserData allKeys] count]) {
                    NSLog(@"环信用户数据拉取成功...");
                    
//                    [weakSelf_SC.msgUserData removeAllObjects];
//                    [weakSelf_SC.msgUserData setDictionary:tmpUserData];
                    

                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf_SC.msgUserData removeAllObjects];
                        [weakSelf_SC.msgUserData setDictionary:tmpUserData];

                        [self endHudLoad];
                        [weakSelf_SC.tableView reloadData];
                    });
                }
            }];
        }
        [self endHudLoad];

    });
}
//好像没用 deprecated
//- (void)isConnect:(BOOL)isConnect
//{
//    if (!isConnect) {
//        _tableView.tableHeaderView = _networkStateView;
//    }
//    else{
//        _tableView.tableHeaderView = nil;
//    }
//}

- (void)didConnectionStateChanged:(EMConnectionState)connectionState
{
    [self networkChanged:connectionState];
}

/**
 *  显示当前网络不可用
 *
 *  @param connectionState connectionState description
 */
- (void)networkChanged:(EMConnectionState)connectionState
{
    if (connectionState == eEMConnectionDisconnected) {
        _tableView.tableHeaderView = _networkStateView;
    }
    else{
        _tableView.tableHeaderView = nil;
    }
}

- (void)willReceiveOfflineMessages{
    NSLog(NSLocalizedString(@"message.beginReceiveOffine", @"Begin to receive offline messages"));
}

//- (void)testRunTime
//{
//    unsigned int count = 0;
//    Ivar *ivars = class_copyIvarList([self class], &count);
//    for (int i = 0; i <count; i ++) {
//        Ivar ivar = ivars[i];
//        const char *name = ivar_getName(ivar);
//        NSLog(@"%s",name);
//    }
//    free(ivars);
//    objc_msgSend(self,@selector(testRunTime));
//}

/**
 *  收到离线消息
 *
 *  @param offlineMessages offlineMessages description
 */
- (void)didReceiveOfflineMessages:(NSArray *)offlineMessages
{
    [self refreshDataSource];
}

/**
 *  完成离线消息的接受
 *
 *  @param offlineMessages 不知道为何要refresh 两次
 */
- (void)didFinishedReceiveOfflineMessages:(NSArray *)offlineMessages{
    NSLog(NSLocalizedString(@"message.endReceiveOffine", @"End to receive offline messages"));
    //[self refreshDataSource];
}

/**
 *  push 侧边栏的内容点击事件
 *
 *  @param notification 包含了需要push到哪的内容
 */
- (void) pushViewcontroller:(NSNotification *)notification
{
    if ([notification.object isKindOfClass:[UIViewController class]]) {
        [self.navigationController pushViewController:(UIViewController *)notification.object animated:YES];
    }
}

@end
