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

#warning 在前端没有退出的情况下 没网络获取不到相应的消息

#import "ChatViewController.h"

#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import "SRRefreshView.h"
#import "DXChatBarMoreView.h"
#import "DXRecordView.h"
#import "DXFaceView.h"
#import "EMChatViewCell.h"
#import "EMChatTimeCell.h"
#import "ChatSendHelper.h"
#import "MessageReadManager.h"
#import "MessageModelManager.h"
#import "LocationViewController.h"
#import "UIViewController+HUD.h"
#import "WCAlertView.h"
#import "NSDate+Category.h"
#import "DXMessageToolBar.h"
#import "DXChatBarMoreView.h"
#import "CallViewController.h"
#import "UserEntity.h"
#import "GoodsEntity.h"
#import "PhotoZooo.h"
#import "GoodsEntity.h"
#import "OrderEntity.h"

#import "ChatOrderCell.h"

#import "ApplyOrderViewController.h"
#import "LogisticsViewController.h"

#import "ChatToolBar.h"

#import "IQKeyboardManager.h"

#define KPageCount 20

@interface ChatViewController ()<UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, SRRefreshDelegate, IChatManagerDelegate, DXChatBarMoreViewDelegate, DXMessageToolBarDelegate, LocationViewDelegate, IDeviceManagerDelegate>
{
    UIMenuController *_menuController;
    UIMenuItem *_copyMenuItem;
    UIMenuItem *_deleteMenuItem;
    NSIndexPath *_longPressIndexPath;
    
    NSInteger _recordingCount;
    
    dispatch_queue_t _messageQueue;
    
    BOOL _isScrollToBottom;
}

@property (nonatomic) BOOL isChatGroup;
@property (strong, nonatomic) EMGroup *chatGroup;
@property (strong, nonatomic) NSString *chatter;

@property (strong, nonatomic) NSMutableArray *dataSource;//tableView数据源
@property (strong, nonatomic) SRRefreshView *slimeView;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) DXMessageToolBar *chatToolBar;

@property (strong, nonatomic) UIImagePickerController *imagePicker;

@property (strong, nonatomic) MessageReadManager *messageReadManager;//message阅读的管理者
@property (strong, nonatomic) NSDate *chatTagDate;

@property (nonatomic) BOOL isScrollToBottom;
@property (nonatomic) BOOL isPlayingAudio;

@property (nonatomic, strong) UserEntity *chatterEntity;    // 对方的实体
@property (nonatomic, strong) UserEntity *myEntity;         // 我自己的
@property (nonatomic, strong) NSString *chatterName;

@property (nonatomic, strong) NSMutableDictionary *userEntityDics;      // 所有的对方实体

// ---->>>>>> 2014.10.25 add
@property (nonatomic, strong) UserEntity *sender;
// --- >>> end

@property (nonatomic, weak) AppDelegate*ad;
@end

@implementation ChatViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isPlayingAudio = NO;
        _isCurrentWindow = NO;
        _isChatGroup = NO;
        _userEntityDics = [NSMutableDictionary new];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(switchMessageManager:) name:@"updateServiceHxUid" object:nil];
        _messageQueue = dispatch_queue_create("easemob.com", NULL);
        
        _ad = [UIApplication sharedApplication].delegate;
        
        //根据接收者的username获取当前会话的管理者
        [self setOrSwitchMessageChatManager];
    }
    
    return self;
}


+ (instancetype)shareInstance
{
//    static id instance;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        instance = [[self alloc] initWithNibName:nil bundle:nil];
//    });
//    return instance;
    return [[self alloc] initWithNibName:nil bundle:nil];
}

#pragma mark -- 李伟 。。。。。。。
- (void) setChatterEntity:(UserEntity *)chatterEntity
{
    _chatterEntity = chatterEntity;
    
    [_userEntityDics setObject:chatterEntity forKey:[NSString stringWithFormat:@"%@", chatterEntity.hxUId]];
    
    // 主线程更新UI
    [self asyncMainQueue:^{
        self.title = self.chatterEntity.nickName;
        if ([self.dataSource count]) {
            [self.tableView reloadData];
        }
    }];
}

- (void) setMyEntity:(UserEntity *)myEntity
{
    _myEntity = myEntity;
    
    [self asyncMainQueue:^{
        if ([self.dataSource count]) {
            [self.tableView reloadData];
        }
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor lightGrayColor];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.edgesForExtendedLayout =  UIRectEdgeNone;
    }
    
    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
    temporaryBarButtonItem.title = @"消息";
    self.navigationItem.backBarButtonItem = temporaryBarButtonItem;

    [[[EaseMob sharedInstance] deviceManager] addDelegate:self onQueue:nil];
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
    //注册为SDK的ChatManager的delegate
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeAllMessages:) name:@"RemoveAllMessages" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(exitGroup) name:@"ExitGroup" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:@"applicationDidEnterBackground" object:nil];
    
    _isScrollToBottom = YES;
    
    [self setupBarButtonItem];
    [self.view addSubview:self.tableView];
    [self.tableView addSubview:self.slimeView];
    [self.view addSubview:self.chatToolBar];
    
    //将self注册为chatToolBar的moreView的代理
    if ([self.chatToolBar.moreView isKindOfClass:[DXChatBarMoreView class]]) {
        [(DXChatBarMoreView *)self.chatToolBar.moreView setDelegate:self];
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyBoardHidden)];
    [self.view addGestureRecognizer:tap];
    
    //通过会话管理者获取已收发消息
    [self loadMoreMessages];
    
    [[EaseMob sharedInstance].chatManager loadAllConversationsFromDatabaseWithAppend2Chat:YES]; //no -> yes
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(back) name:@"ChatViewContrllerDismiss" object:nil];;
    
//    WeakSelf
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] bk_initWithImage:[UIImage imageNamed:@"backBtn_Nav"] style:UIBarButtonItemStyleDone handler:^(id sender) {
//        [[weakSelf_SC mainDelegate] changeRootViewController];
//    }];
}

- (void) switchMessageManager:(NSNotification *)notification
{
    [self setOrSwitchMessageChatManager];
    
#warning 这句话会导致定位到不合适的位置
//    //通过会话管理者获取已收发消息
//    [self loadMoreMessages];
}

#pragma mark - 设置或者更新回话管理者
- (void) setOrSwitchMessageChatManager
{
    
    //根据接收者的username获取当前会话的管理者
    _conversation = [[logicShareInstance getEasemobManage] conversation];
    
    //获取当前用户的环信uid
    _chatter = [CURRENT_USER_INSTANCE getCurrentUserServiceHxUId];

    UserEntity *user = [[UserEntity alloc] init];
    _chatterEntity = user;
    _myEntity = user;
    
    // 获取双方的用户实体 (2014.12.25 更改获取用户实体)
    [[logicShareInstance getUserManager] getUserEntityWithHXID:_chatter result:^(UserEntity *userEntity) {
        self.chatterEntity = userEntity;
    }];
    
    [[logicShareInstance getUserManager] getUserEntityWithHXID:[CURRENT_USER_INSTANCE getCurrentUserHXID] result:^(UserEntity *userEntity) {
        self.myEntity = userEntity;
    }];
    
    self.chatterName = _chatter;
}


- (void)setupBarButtonItem
{
//    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
//    [backButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
//    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
//    [self.navigationItem setLeftBarButtonItem:backItem];
//    

    self.navigationItem.leftBarButtonItem.title = @"2";
    self.navigationItem.leftBarButtonItem.action = @selector(back);
    
//    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:@selector(back)];
//    
//    self.navigationItem.leftBarButtonItem = leftBarButton;
    
    
    if (_isChatGroup) {
        UIButton *detailButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
        [detailButton setImage:[UIImage imageNamed:@"group_detail"] forState:UIControlStateNormal];
        [detailButton addTarget:self action:@selector(showRoomContact:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:detailButton];
    }
    else{
        
        UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(removeAllMessages:)];
        self.navigationItem.rightBarButtonItem = rightBarButton;
//        
//        UIButton *clearButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
//        [clearButton setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
//        [clearButton addTarget:self action:@selector(removeAllMessages:) forControlEvents:UIControlEventTouchUpInside];
//        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:clearButton];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
//    [[logicShareInstance getJpushManage]setBadge:0];
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    //设置买家版全部已读
    //[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    //重新加载内容

//    [[EaseMob sharedInstance].chatManager loadAllConversationsFromDatabaseWithAppend2Chat:YES];
//    [self.tableView reloadData];
    
    _ad.isTalking = YES;
    [super viewWillAppear:animated];
    
//    [_conversation loadAllMessages];
    [[ChatToolBar shareInstance]setHidden:YES];
    //强制刷新数据
  //  [self.tableView reloadData];
    
    //滚动到最下方
    if (_isScrollToBottom) {
        [self scrollViewToBottom:YES];
    }
    else{
        _isScrollToBottom = YES;
    }
    
    _isCurrentWindow = YES;
    
    [[logicShareInstance getEasemobManage] autoLogin];
    
    // 如果有图片,那么则发送
    if (self.willSendImage) {
        [self sendImageMessage:self.willSendImage];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;

    [super viewWillDisappear:animated];
    
    NSArray *convers = [[EaseMob sharedInstance].chatManager loadAllConversationsFromDatabaseWithAppend2Chat:YES];
    if(convers.count >=2)
    {
        NSLog(@"c ->%@",convers);
        //当该用户被总客服米妞转移过客服的话 需要处理下总客服登录提醒的消息设为已读
        for (int i = 0; i<convers.count; i++) {
            EMConversation *con = convers[i];
            if ([con.chatter isEqualToString:@"mnhxuser1"]) {
                [con markAllMessagesAsRead:YES];
                break;
            }
        }
    }

    _isCurrentWindow = NO;
    _ad.isTalking = NO;
    
//    [self back];
    [[ChatToolBar shareInstance]setHidden:NO];

    // 设置当前conversation的所有message为已读
//    [[ChatViewController shareInstance].conversation unreadMessagesCount];
    [[[logicShareInstance getEasemobManage] conversation] markAllMessagesAsRead:YES];
//    NSInteger iii = _conversation. unreadMessagesCount;
//    设置图标角标为0 因为只有一个客服会话 若日后开启其他推送角标 则要在此处理+其他未读推送角标
//    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];

}

-(void)viewDidDisappear:(BOOL)animated
{
//    // 设置当前conversation的所有message为已读
//    if([_conversation markAllMessagesAsRead:YES]){
//       NSLog(@"-----%d", [_conversation unreadMessagesCount]);
//        
//        [[ChatToolBar shareInstance]updateBadge];
////        [[JpushManage shareInstance]reloadBadge];
//    }
//    if([_conversation markAllMessagesAsRead:YES]){
//        NSLog(@"*******%d", [_conversation unreadMessagesCount]);
//        
//        [[ChatToolBar shareInstance]updateBadge];
//        //        [[JpushManage shareInstance]reloadBadge];
//    }
    NSLog(@"_conversation pointer - > %p",_conversation);
    [[ChatToolBar shareInstance]updateBadge];
    
    [super viewDidDisappear:YES];
}

- (void)dealloc
{
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
    _tableView = nil;
    
    _slimeView.delegate = nil;
    _slimeView = nil;
    
    _chatToolBar.delegate = nil;
    _chatToolBar = nil;
    
    [[EaseMob sharedInstance].chatManager stopPlayingAudio];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [[EaseMob sharedInstance].chatManager removeDelegate:self];
    [[[EaseMob sharedInstance] deviceManager] removeDelegate:self];
}

- (void)back
{
    //判断当前会话是否为空，若符合则删除该会话
//    EMMessage *message = [_conversation latestMessage];
//    if (message == nil) {
//        [[EaseMob sharedInstance].chatManager removeConversationByChatter:_conversation.chatter deleteMessages:YES append2Chat:YES];
//    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
//    [self dismissViewControllerAnimated:YES completion:nil];

}

#pragma mark - helper
- (NSURL *)convert2Mp4:(NSURL *)movUrl {
    NSURL *mp4Url = nil;
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:movUrl options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality]) {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset
                                                                              presetName:AVAssetExportPresetHighestQuality];
        mp4Url = [movUrl copy];
        mp4Url = [mp4Url URLByDeletingPathExtension];
        mp4Url = [mp4Url URLByAppendingPathExtension:@"mp4"];
        exportSession.outputURL = mp4Url;
        exportSession.shouldOptimizeForNetworkUse = YES;
        exportSession.outputFileType = AVFileTypeMPEG4;
        dispatch_semaphore_t wait = dispatch_semaphore_create(0l);
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusFailed: {
                    NSLog(@"failed, error:%@.", exportSession.error);
                } break;
                case AVAssetExportSessionStatusCancelled: {
                    NSLog(@"cancelled.");
                } break;
                case AVAssetExportSessionStatusCompleted: {
                    NSLog(@"completed.");
                } break;
                default: {
                    NSLog(@"others.");
                } break;
            }
            dispatch_semaphore_signal(wait);
        }];
        long timeout = dispatch_semaphore_wait(wait, DISPATCH_TIME_FOREVER);
        if (timeout) {
            NSLog(@"timeout.");
        }
        if (wait) {
            //dispatch_release(wait);
            wait = nil;
        }
    }
    
    return mp4Url;
}

#pragma mark - getter

- (NSMutableArray *)dataSource
{
    if (_dataSource == nil) {
        _dataSource = [NSMutableArray array];
    }
    
    return _dataSource;
}

- (SRRefreshView *)slimeView
{
    if (_slimeView == nil) {
        _slimeView = [[SRRefreshView alloc] init];
        _slimeView.delegate = self;
        _slimeView.upInset = 0;
        _slimeView.slimeMissWhenGoingBack = YES;
        _slimeView.slime.bodyColor = [UIColor grayColor];
        _slimeView.slime.skinColor = [UIColor grayColor];
        _slimeView.slime.lineWith = 1;
        _slimeView.slime.shadowBlur = 4;
        _slimeView.slime.shadowColor = [UIColor grayColor];
    }
    
    return _slimeView;
}

- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - self.chatToolBar.frame.size.height) style:UITableViewStylePlain];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor colorWithRed:0.906 green:0.902 blue:0.906 alpha:1];
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        lpgr.minimumPressDuration = .5;
        [_tableView addGestureRecognizer:lpgr];
    }
    
    return _tableView;
}

- (DXMessageToolBar *)chatToolBar
{
    if (_chatToolBar == nil) {
        _chatToolBar = [[DXMessageToolBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - [DXMessageToolBar defaultHeight], self.view.frame.size.width, [DXMessageToolBar defaultHeight])];
        _chatToolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
        _chatToolBar.delegate = self;
        
        ChatMoreType type = _isChatGroup == YES ? ChatMoreTypeGroupChat : ChatMoreTypeChat;
        _chatToolBar.moreView = [[DXChatBarMoreView alloc] initWithFrame:CGRectMake(0, (kVerticalPadding * 2 + kInputTextViewMinHeight), _chatToolBar.frame.size.width, 80) typw:type];
        _chatToolBar.moreView.backgroundColor = [UIColor colorWithRed:0.906 green:0.902 blue:0.906 alpha:1];
        _chatToolBar.moreView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    }
    
    return _chatToolBar;
}

- (UIImagePickerController *)imagePicker
{
    if (_imagePicker == nil) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.delegate = self;
    }
    
    return _imagePicker;
}

- (MessageReadManager *)messageReadManager
{
    if (_messageReadManager == nil) {
        _messageReadManager = [MessageReadManager defaultManager];
    }
    
    return _messageReadManager;
}

- (NSDate *)chatTagDate
{
    if (_chatTagDate == nil) {
        _chatTagDate = [NSDate dateWithTimeIntervalInMilliSecondSince1970:0];
    }
    
    return _chatTagDate;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [self.dataSource count]) {
        id obj = [self.dataSource objectAtIndex:indexPath.row];
        
        if ([obj isKindOfClass:[NSString class]]) {
            EMChatTimeCell *timeCell = (EMChatTimeCell *)[tableView dequeueReusableCellWithIdentifier:@"MessageCellTime"];
            if (timeCell == nil) {
                timeCell = [[EMChatTimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MessageCellTime"];
                timeCell.backgroundColor = [UIColor clearColor];
                timeCell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            timeCell.textLabel.text = (NSString *)obj;
            
            return timeCell;
        }
        else{
            MessageModel *model = (MessageModel *)obj;

            // 订单Cell
            if (model.extMessageType == extMessageType_Order || model.extMessageType == extMessageType_Order_Address || model.extMessageType == extMessageType_Order_Logistics || model.extMessageType == extMessageType_Order_Refund) {
                NSString *cellIdentifier = @"orderCell";
                ChatOrderCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                if (cell == nil) {
                    cell = [[ChatOrderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                }
                cell.messageModel = model;
                
                
                if (model.extMessageType == extMessageType_Order_Address) {
                    [cell.userAvatar setImageWithUrl:self.myEntity.avatar withSize:ImageSizeOfAuto];
                } else if (model.extMessageType == extMessageType_Order_Logistics) {
                    [cell.userAvatar setImageWithUrl:self.chatterEntity.avatar withSize:ImageSizeOfAuto];
                } else if (model.extMessageType == extMessageType_Order_Refund) {
                    [cell.userAvatar setImageWithUrl:self.chatterEntity.avatar withSize:ImageSizeOfAuto];
                } else if (model.extMessageType == extMessageType_Order) {
                    [cell.userAvatar setImageWithUrl:self.myEntity.avatar withSize:ImageSizeOfAuto];
                }
                
                [cell addCallBackBlock:^(MessageModel *messageModel) {

                    _isScrollToBottom = NO;
                    
                    // 订单Cell
                    if (messageModel.extMessageType == extMessageType_Order || messageModel.extMessageType == extMessageType_Order_Address || messageModel.extMessageType == extMessageType_Order_Refund) {
                        ApplyOrderViewController *applyOrderVC = [ApplyOrderViewController new];
                        applyOrderVC.order = messageModel.order;
                        [self.navigationController pushViewController:applyOrderVC animated:YES];
                        // 物流
                    } else if (messageModel.extMessageType == extMessageType_Order_Logistics) {
                        LogisticsViewController *logisticsVC = [LogisticsViewController new];
                        logisticsVC.order = messageModel.order;
                        [self.navigationController pushViewController:logisticsVC animated:YES];
                    }
                }];
                
                return cell;
            } else {
                NSString *cellIdentifier = [EMChatViewCell cellIdentifierForMessageModel:model];
                EMChatViewCell *cell = (EMChatViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                if (cell == nil) {
                    cell = [[EMChatViewCell alloc] initWithMessageModel:model reuseIdentifier:cellIdentifier];
                    cell.backgroundColor = [UIColor clearColor];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                cell.messageModel = [self disposeMessageWithMessageModel:model];
                
                [cell.headImageView sd_setImageWithURL:cell.messageModel.headImageURL placeholderImage:[UIImage imageNamed:@"avatar"]];
                
                return cell;
            }
        }
    }
    
    return nil;
}

/**
 *  整合用户信息处理
 *
 *  @param model
 *
 *  @return
 */
- (MessageModel *)disposeMessageWithMessageModel:(MessageModel *)model
{
//    UserEntity *user = [[UserEntity alloc] init];
    UserEntity *user;
    // 自己
    if ([model.username isEqualToString:self.myEntity.hxUId]) {
        user = self.myEntity;
    } else {
        
        user = (UserEntity *)[_userEntityDics objectForKey:[NSString stringWithFormat:@"%@", model.username]];
        
        if (!user) {
            user = self.chatterEntity;
        }
    }
        
    model.nickName = user.nickName;
    model.headImageURL = [NSURL URLWithString:user.avatar];
    model.userId = user.userId;
    
    return model;
}



#pragma mark - Table view delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSObject *obj = [self.dataSource objectAtIndex:indexPath.row];
    if ([obj isKindOfClass:[NSString class]]) {
        return 40;
    }
    else{
        MessageModel *messageModel = (MessageModel *)obj;
        if (messageModel.extMessageType) {
            return [ChatOrderCell cellHeight];
        }
        return [EMChatViewCell tableView:tableView heightForRowAtIndexPath:indexPath withObject:(MessageModel *)obj];
    }
}

#pragma mark - scrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_slimeView) {
        [_slimeView scrollViewDidScroll];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (_slimeView) {
        [_slimeView scrollViewDidEndDraging];
    }
}

#pragma mark - slimeRefresh delegate
//加载更多
- (void)slimeRefreshStartRefresh:(SRRefreshView *)refreshView
{
    [self loadMoreMessages];
    [_slimeView endRefresh];
}

#pragma mark - GestureRecognizer

// 点击背景隐藏
-(void)keyBoardHidden
{
    [self.chatToolBar endEditing:YES];
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer
{
	if (recognizer.state == UIGestureRecognizerStateBegan && [self.dataSource count] > 0) {
        CGPoint location = [recognizer locationInView:self.tableView];
        NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint:location];
        id object = [self.dataSource objectAtIndex:indexPath.row];
        if ([object isKindOfClass:[MessageModel class]]) {
            EMChatViewCell *cell = (EMChatViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            [cell becomeFirstResponder];
            _longPressIndexPath = indexPath;
            
            if (cell.messageModel.extMessageType) {
                [self showMenuViewController:cell.contentView andIndexPath:indexPath messageType:cell.messageModel.type];
            } else {
                [self showMenuViewController:cell.bubbleView andIndexPath:indexPath messageType:cell.messageModel.type];
            }
        }
    }
}

#pragma mark - UIResponder actions

- (void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo
{
    MessageModel *model = [userInfo objectForKey:KMESSAGEKEY];
    if ([eventName isEqualToString:kRouterEventTextURLTapEventName]) {
        [self chatTextCellUrlPressed:[userInfo objectForKey:@"url"]];
    }
    else if ([eventName isEqualToString:kRouterEventAudioBubbleTapEventName]) {
        [self chatAudioCellBubblePressed:model];
    }
    else if ([eventName isEqualToString:kRouterEventImageBubbleTapEventName]){
        [self keyBoardHidden];
        [self chatImageCellBubblePressed:model imageView:[userInfo objectForKey:@"imageView"]];
    }
    else if ([eventName isEqualToString:kRouterEventLocationBubbleTapEventName]){
        [self chatLocationCellBubblePressed:model];
    }
    else if([eventName isEqualToString:kResendButtonTapEventName]){
        EMChatViewCell *resendCell = [userInfo objectForKey:kShouldResendCell];
        MessageModel *messageModel = resendCell.messageModel;
        messageModel.status = eMessageDeliveryState_Delivering;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:resendCell];
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                              withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
        id <IChatManager> chatManager = [[EaseMob sharedInstance] chatManager];
        [chatManager asyncResendMessage:messageModel.message progress:nil];
    }else if([eventName isEqualToString:kRouterEventChatCellVideoTapEventName]){
        [self chatVideoCellPressed:model];
    } else if ([eventName isEqualToString:kRouterEventChatHeadImageTapEventName]) {
//        if (!model.userId) {
//            [self faildMessage:@"用户信息获取失败!"];
//        } else {
//            [self keyBoardHidden];
//            BuyerDetailsViewController *buyerVC = [[BuyerDetailsViewController alloc] init];
//            buyerVC.isMessagePush = YES;
//            UserEntity *user = [[UserEntity alloc] init];
//            user.userId = model.userId;
//            buyerVC.user = user;
//            [self.navigationController pushViewController:buyerVC animated:YES];
//        }
    } else if ([eventName isEqualToString:@"kRouterEventGoodsBubbleTapEventName"]) {
//        NSString *goodsId = model.goodsId;
//        
//        if (![goodsId length]) {
//            [self faildMessage:@"商品信息获取失败,请重试!"];
//            return;
//        }
//        
//        GoodsEntity *goods = [[GoodsEntity alloc] initWithGoodsId:goodsId];
//        
//        GoodsDetailsViewController *goodsVC = [[GoodsDetailsViewController alloc] init];
//        [goodsVC setDataWith:goods];
//        goodsVC.isMessagePush = YES;
//        [self.navigationController pushViewController:goodsVC animated:YES];
    } else if ([eventName isEqualToString:@"kRouterEventOrderBubbleTapEventName"]) {
        
//        NSString *orderId = model.OrderId;
//        if (![orderId length]) {
//            [self faildMessage:@"订单信息获取失败,请重试!"];
//            return;
//        }
//        
//        OrderDetailsViewController *orderDVC = [[OrderDetailsViewController alloc] init];
//        OrderEntity *order = [[OrderEntity alloc] initWithOrderNo:orderId];
//        [orderDVC setDataWithOrderEntity:order orderQueryType:queryTypeOfMyApply callBackBlock:nil];
//        orderDVC.isMessagePush = YES;
//        [self.navigationController pushViewController:orderDVC animated:YES];
    }
}

//链接被点击
- (void)chatTextCellUrlPressed:(NSURL *)url
{
    if (url) {
        [self openUrlOnWebViewWithURL:url type:PUSH];
    }
}

// 语音的bubble被点击
-(void)chatAudioCellBubblePressed:(MessageModel *)model
{
    id <IEMFileMessageBody> body = [model.message.messageBodies firstObject];
    EMAttachmentDownloadStatus downloadStatus = [body attachmentDownloadStatus];
    if (downloadStatus == EMAttachmentDownloading) {
        [self showHint:@"正在下载语音，稍后点击"];
        return;
    }
    else if (downloadStatus == EMAttachmentDownloadFailure)
    {
        [self showHint:@"正在下载语音，稍后点击"];
        [[EaseMob sharedInstance].chatManager asyncFetchMessage:model.message progress:nil];
        
        return;
    }
    
    // 播放音频
    if (model.type == eMessageBodyType_Voice) {
        __weak ChatViewController *weakSelf = self;
        BOOL isPrepare = [self.messageReadManager prepareMessageAudioModel:model updateViewCompletion:^(MessageModel *prevAudioModel, MessageModel *currentAudioModel) {
            if (prevAudioModel || currentAudioModel) {
                [weakSelf.tableView reloadData];
            }
        }];
        
        if (isPrepare) {
            _isPlayingAudio = YES;
            __weak ChatViewController *weakSelf = self;
            [[[EaseMob sharedInstance] deviceManager] enableProximitySensor];
            [[EaseMob sharedInstance].chatManager asyncPlayAudio:model.chatVoice completion:^(EMError *error) {
                [weakSelf.messageReadManager stopMessageAudioModel];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.tableView reloadData];
                    
                    weakSelf.isPlayingAudio = NO;
//                    [[[EaseMob sharedInstance] deviceManager] disableProximitySensor];
                    
                    //---->>>>>>>>>>>>>>>>>>>>>>>
                    
                    [self continuousPlayVoiceWithPreModel:model];
                    
                    //---->>>>>>>>>>>>>>>>>>>>>>>
                });
            } onQueue:nil];
        }
        else{
            _isPlayingAudio = NO;
        }
    }
    
}

/**
 *  连播声音
 *
 *  @param obj 上一个音频
 */
- (void) continuousPlayVoiceWithPreModel:(MessageModel *)premodel
{
    @try {
        // 一共有多少
        NSInteger dataCount = [self.dataSource count];
        
        // 当前这个是第几个
        NSInteger currentModelIndex = [self.dataSource indexOfObject:premodel];
        
        // 检查下一个是否为音频
        if (dataCount > currentModelIndex + 1) {
            id audioObj = [self.dataSource objectAtIndex:currentModelIndex + 1];
            // 如果是时间的话则跳过
            if ([audioObj isKindOfClass:[NSString class]]) return;
            
            MessageModel *newmodel = (MessageModel *)audioObj;
            if (newmodel.type == eMessageBodyType_Voice) {
                [self chatAudioCellBubblePressed:newmodel];
            } else if (dataCount > currentModelIndex + 2) {
                id audioObj = [self.dataSource objectAtIndex:currentModelIndex + 1];
                // 如果是时间的话则跳过
                if ([audioObj isKindOfClass:[NSString class]]) return;
                MessageModel *newmodel = (MessageModel *)audioObj;
                if (newmodel.type == eMessageBodyType_Voice) {
                    [self chatAudioCellBubblePressed:newmodel];
                }
            }
        }
    }
    @catch (NSException *exception) {}
    @finally {}
}


// 位置的bubble被点击
-(void)chatLocationCellBubblePressed:(MessageModel *)model
{
    _isScrollToBottom = NO;
    LocationViewController *locationController = [[LocationViewController alloc] initWithLocation:CLLocationCoordinate2DMake(model.latitude, model.longitude)];
    [self.navigationController pushViewController:locationController animated:YES];
}

- (void)chatVideoCellPressed:(MessageModel *)model{
    __weak ChatViewController *weakSelf = self;
    id <IChatManager> chatManager = [[EaseMob sharedInstance] chatManager];
    [weakSelf showHudInView:weakSelf.view hint:@"正在获取视频..."];
    [chatManager asyncFetchMessage:model.message progress:nil completion:^(EMMessage *aMessage, EMError *error) {
        [weakSelf hideHud];
        if (!error) {
            NSString *localPath = aMessage == nil ? model.localPath : [[aMessage.messageBodies firstObject] localPath];
            if (localPath && localPath.length > 0) {
                [weakSelf playVideoWithVideoPath:localPath];
            }
        }else{
            [weakSelf showHint:@"视频获取失败!"];
        }
    } onQueue:nil];
}

- (void)playVideoWithVideoPath:(NSString *)videoPath
{
    _isScrollToBottom = NO;
    NSURL *videoURL = [NSURL fileURLWithPath:videoPath];
    MPMoviePlayerViewController *moviePlayerController = [[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
    [moviePlayerController.moviePlayer prepareToPlay];
    moviePlayerController.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
    [self presentMoviePlayerViewControllerAnimated:moviePlayerController];
}

// 图片的bubble被点击
-(void)chatImageCellBubblePressed:(MessageModel *)model imageView:(UIImageView *)imageView
{
    __weak ChatViewController *weakSelf = self;
    id <IChatManager> chatManager = [[EaseMob sharedInstance] chatManager];
    if ([model.messageBody messageBodyType] == eMessageBodyType_Image) {
        EMImageMessageBody *imageBody = (EMImageMessageBody *)model.messageBody;
        if (imageBody.thumbnailDownloadStatus == EMAttachmentDownloadSuccessed) {
//            [weakSelf showHudInView:weakSelf.view hint:@"正在获取大图..."];
            [chatManager asyncFetchMessage:model.message progress:nil completion:^(EMMessage *aMessage, EMError *error) {
                [weakSelf hideHud];
                if (!error) {
                    NSString *localPath = aMessage == nil ? model.localPath : [[aMessage.messageBodies firstObject] localPath];
                    if (localPath && localPath.length > 0) {
//                        NSURL *url = [NSURL fileURLWithPath:localPath];
//                        weakSelf.isScrollToBottom = NO;
//                        [weakSelf.messageReadManager showBrowserWithImages:@[url]];
//                        [weakSelf.messageReadManager zoomPhotoWithURL:url AndImageView:imageView];
                        
                        _isScrollToBottom = NO;
                        [PhotoZooo shareInstance].enableSendToFriend = NO;
                        [[PhotoZooo shareInstance] showImageWithArray:@[localPath] setInitialPageIndex:0 withController:self];
                        
//                        PhotoZooo *photoZooo = [[PhotoZooo alloc] init];
//                        [photoZooo showAndArray:@[url.absoluteString] withController:self setInitialPageIndex:0];
                        
                        return ;
                    }
                }
                [weakSelf showHint:@"大图获取失败!"];
            } onQueue:nil];
        }else{
            //获取缩略图
            [chatManager asyncFetchMessageThumbnail:model.message progress:nil completion:^(EMMessage *aMessage, EMError *error) {
                if (!error) {
                    [weakSelf reloadTableViewDataWithMessage:model.message];
                }else{
                    [weakSelf showHint:@"缩略图获取失败!"];
                }
                
            } onQueue:nil];
        }
    }else if ([model.messageBody messageBodyType] == eMessageBodyType_Video) {
        //获取缩略图
        EMVideoMessageBody *videoBody = (EMVideoMessageBody *)model.messageBody;
        if (videoBody.thumbnailDownloadStatus != EMAttachmentDownloadSuccessed) {
            [chatManager asyncFetchMessageThumbnail:model.message progress:nil completion:^(EMMessage *aMessage, EMError *error) {
                if (!error) {
                    [weakSelf reloadTableViewDataWithMessage:model.message];
                }else{
                    [weakSelf showHint:@"缩略图获取失败!"];
                }
            } onQueue:nil];
        }
    }
}

#pragma mark - IChatManagerDelegate

-(void)didSendMessage:(EMMessage *)message error:(EMError *)error;
{
    [self reloadTableViewDataWithMessage:message];
}

- (void)reloadTableViewDataWithMessage:(EMMessage *)message{
    __weak ChatViewController *weakSelf = self;
    dispatch_async(_messageQueue, ^{
        if ([weakSelf.conversation.chatter isEqualToString:message.conversationChatter])
        {
            for (int i = 0; i < weakSelf.dataSource.count; i ++) {
                id object = [weakSelf.dataSource objectAtIndex:i];
                if ([object isKindOfClass:[MessageModel class]]) {
                    EMMessage *currMsg = [weakSelf.dataSource objectAtIndex:i];
                    if ([message.messageId isEqualToString:currMsg.messageId]) {
                        MessageModel *cellModel = [MessageModelManager modelWithMessage:message];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf.tableView beginUpdates];
                            [weakSelf.dataSource replaceObjectAtIndex:i withObject:cellModel];
                            [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                            [weakSelf.tableView endUpdates];
                            
                        });
                        
                        break;
                    }
                }
            }
        }
    });
}

- (void)didMessageAttachmentsStatusChanged:(EMMessage *)message error:(EMError *)error{
    if (!error) {
        id<IEMFileMessageBody>fileBody = (id<IEMFileMessageBody>)[message.messageBodies firstObject];
        if ([fileBody messageBodyType] == eMessageBodyType_Image) {
            EMImageMessageBody *imageBody = (EMImageMessageBody *)fileBody;
            if ([imageBody thumbnailDownloadStatus] == EMAttachmentDownloadSuccessed)
            {
                [self reloadTableViewDataWithMessage:message];
            }
        }else if([fileBody messageBodyType] == eMessageBodyType_Video){
            EMVideoMessageBody *videoBody = (EMVideoMessageBody *)fileBody;
            if ([videoBody thumbnailDownloadStatus] == EMAttachmentDownloadSuccessed)
            {
                [self reloadTableViewDataWithMessage:message];
            }
        }else if([fileBody messageBodyType] == eMessageBodyType_Voice){
            if ([fileBody attachmentDownloadStatus] == EMAttachmentDownloadSuccessed)
            {
                [self reloadTableViewDataWithMessage:message];
            }
        }
        
    }else{
        
    }
}

- (void)didFetchingMessageAttachments:(EMMessage *)message progress:(float)progress{
    NSLog(@"didFetchingMessageAttachment: %f", progress);
}

-(void)didReceiveMessage:(EMMessage *)message
{
    if ([_conversation.chatter isEqualToString:message.conversationChatter]) {
        
        _isScrollToBottom = YES;
        [self addChatDataToMessage:message];
    }
}

- (void)group:(EMGroup *)group didLeave:(EMGroupLeaveReason)reason error:(EMError *)error
{
    if (_isChatGroup && [group.groupId isEqualToString:_chatter]) {
        [self.navigationController popToViewController:self animated:NO];
        [self.navigationController popViewControllerAnimated:NO];
    }
}

- (void)didInterruptionRecordAudio
{
    [_chatToolBar cancelTouchRecord];
    
    // 设置当前conversation的所有message为已读
    [_conversation markAllMessagesAsRead:YES];
    
    [self stopAudioPlaying];
}

#pragma mark - EMChatBarMoreViewDelegate

- (void)moreViewPhotoAction:(DXChatBarMoreView *)moreView
{
    // 隐藏键盘
    [self keyBoardHidden];
    
    // 弹出照片选择
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    [self presentViewController:self.imagePicker animated:YES completion:NULL];
}

- (void)moreViewTakePicAction:(DXChatBarMoreView *)moreView
{
    [self keyBoardHidden];
    
#if TARGET_IPHONE_SIMULATOR
    [self showHint:@"模拟器不支持拍照"];
#elif TARGET_OS_IPHONE
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    [self presentViewController:self.imagePicker animated:YES completion:NULL];
#endif
}

- (void)moreViewLocationAction:(DXChatBarMoreView *)moreView
{
    // 隐藏键盘
    [self keyBoardHidden];
    
    LocationViewController *locationController = [[LocationViewController alloc] initWithNibName:nil bundle:nil];
    locationController.delegate = self;
    [self.navigationController pushViewController:locationController animated:YES];
}

- (void)moreViewVideoAction:(DXChatBarMoreView *)moreView{
    [self keyBoardHidden];
    
#if TARGET_IPHONE_SIMULATOR
    [self showHint:@"模拟器不支持录像"];
#elif TARGET_OS_IPHONE
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.imagePicker.mediaTypes = @[(NSString *)kUTTypeMovie];
    [self presentViewController:self.imagePicker animated:YES completion:NULL];
#endif
}

- (void)moreViewAudioCallAction:(DXChatBarMoreView *)moreView
{
    CallViewController *callController = [CallViewController shareController];
    [callController setupCallOutWithChatter:_chatter];
//    [callController setupCallInWithChatter:_chatter];
    [self presentViewController:callController animated:YES completion:nil];
}

#pragma mark - DXMessageToolBarDelegate
- (void)inputTextViewWillBeginEditing:(XHMessageTextView *)messageInputTextView{
    [_menuController setMenuItems:nil];
}

- (void)didChangeFrameToHeight:(CGFloat)toHeight
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = self.tableView.frame;
        rect.origin.y = 0;
        rect.size.height = self.view.frame.size.height - toHeight;
        self.tableView.frame = rect;
    }];
    [self scrollViewToBottom:YES];
}

- (void)didSendText:(NSString *)text
{
    if (text && text.length > 0) {
        [self sendTextMessage:text];
    }
}

/**
 *  按下录音按钮开始录音
 */
- (void)didStartRecordingVoiceAction:(UIView *)recordView
{
//    if (_isRecording) {
//        ++_recordingCount;
//        if (_recordingCount > 10)
//        {
//            _recordingCount = 0;
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"亲，已经戳漏了，随时崩溃给你看" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//            [alertView show];
//        }
//        else if (_recordingCount > 5) {
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"亲，手别抖了，快被戳漏了" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//            [alertView show];
//        }
//        return;
//    }
//    _isRecording = YES;
    
    DXRecordView *tmpView = (DXRecordView *)recordView;
    tmpView.center = self.view.center;
    [self.view addSubview:tmpView];
    [self.view bringSubviewToFront:recordView];
    
    NSError *error = nil;
    [[EaseMob sharedInstance].chatManager startRecordingAudioWithError:&error];
    if (error) {
        NSLog(@"开始录音失败");
    }
}

/**
 *  手指向上滑动取消录音
 */
- (void)didCancelRecordingVoiceAction:(UIView *)recordView
{
    [[EaseMob sharedInstance].chatManager asyncCancelRecordingAudioWithCompletion:nil onQueue:nil];
}

/**
 *  松开手指完成录音
 */
- (void)didFinishRecoingVoiceAction:(UIView *)recordView
{
    [[EaseMob sharedInstance].chatManager
     asyncStopRecordingAudioWithCompletion:^(EMChatVoice *aChatVoice, NSError *error){
         if (!error) {
             [self sendAudioMessage:aChatVoice];
         }else{
             if (error.code == EMErrorAudioRecordNotStarted) {
                 [self showHint:error.domain yOffset:-40];
             } else {
                 [self showHint:error.domain];
             }
         }
         
     } onQueue:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    [WCAlertView showAlertWithTitle:@"提示" message:@"确认发送?" customizationBlock:^(WCAlertView *alertView) {
        
    } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
        
        if (buttonIndex == 1) {
            NSString *mediaType = info[UIImagePickerControllerMediaType];
            if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
                NSURL *videoURL = info[UIImagePickerControllerMediaURL];
                [picker dismissViewControllerAnimated:YES completion:nil];
                // video url:
                // file:///private/var/mobile/Applications/B3CDD0B2-2F19-432B-9CFA-158700F4DE8F/tmp/capture-T0x16e39100.tmp.9R8weF/capturedvideo.mp4
                // we will convert it to mp4 format
                NSURL *mp4 = [self convert2Mp4:videoURL];
                NSFileManager *fileman = [NSFileManager defaultManager];
                if ([fileman fileExistsAtPath:videoURL.path]) {
                    NSError *error = nil;
                    [fileman removeItemAtURL:videoURL error:&error];
                    if (error) {
                        NSLog(@"failed to remove file, error:%@.", error);
                    }
                }
                EMChatVideo *chatVideo = [[EMChatVideo alloc] initWithFile:[mp4 relativePath] displayName:@"video.mp4"];
                [self sendVideoMessage:chatVideo];
                
            }else{
                UIImage *orgImage = info[UIImagePickerControllerOriginalImage];
                [picker dismissViewControllerAnimated:YES completion:nil];
                [self sendImageMessage:orgImage];
            }
        }
    } cancelButtonTitle:@"取消" otherButtonTitles:@"发送", nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - MenuItem actions

- (void)copyMenuAction:(id)sender
{
    // todo by du. 复制
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    if (_longPressIndexPath.row > 0) {
        MessageModel *model = [self.dataSource objectAtIndex:_longPressIndexPath.row];
        pasteboard.string = model.content;
    }
    
    _longPressIndexPath = nil;
}

- (void)deleteMenuAction:(id)sender
{
    if (_longPressIndexPath && _longPressIndexPath.row > 0) {
        MessageModel *model = [self.dataSource objectAtIndex:_longPressIndexPath.row];
        NSMutableArray *messages = [NSMutableArray arrayWithObjects:model, nil];
        [_conversation removeMessage:model.message];
        
        [[logicShareInstance getMessageManager] deleteExtMessageWithMIds:@[model.message.messageId] receiveUid:nil];
        
        NSMutableArray *indexPaths = [NSMutableArray arrayWithObjects:_longPressIndexPath, nil];;
        if (_longPressIndexPath.row - 1 >= 0) {
            id nextMessage = nil;
            id prevMessage = [self.dataSource objectAtIndex:(_longPressIndexPath.row - 1)];
            if (_longPressIndexPath.row + 1 < [self.dataSource count]) {
                nextMessage = [self.dataSource objectAtIndex:(_longPressIndexPath.row + 1)];
            }
            if ((!nextMessage || [nextMessage isKindOfClass:[NSString class]]) && [prevMessage isKindOfClass:[NSString class]]) {
                [messages addObject:prevMessage];
                [indexPaths addObject:[NSIndexPath indexPathForRow:(_longPressIndexPath.row - 1) inSection:0]];
            }
        }
        [self.dataSource removeObjectsInArray:messages];
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    }
    
    _longPressIndexPath = nil;
}

#pragma mark - private

- (BOOL)canRecord
{
    __block BOOL bCanRecord = YES;
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending)
    {
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
            [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
                if (granted) {
                    bCanRecord = YES;
                } else {
                    bCanRecord = NO;
                }
            }];
        }
        
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }
    
    return bCanRecord;
}

- (void)stopAudioPlaying
{
    //停止音频播放及播放动画
    [[EaseMob sharedInstance].chatManager stopPlayingAudio];
    MessageModel *playingModel = [self.messageReadManager stopMessageAudioModel];
    
    NSIndexPath *indexPath = nil;
    if (playingModel) {
        indexPath = [NSIndexPath indexPathForRow:[self.dataSource indexOfObject:playingModel] inSection:0];
    }
    
    if (indexPath) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView endUpdates];
        });
    }
}

- (void)loadMoreMessages
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(_messageQueue, ^{
        NSInteger currentCount = [weakSelf.dataSource count];
        EMMessage *latestMessage = [weakSelf.conversation latestMessage];
        NSTimeInterval beforeTime = 0;
        if (latestMessage) {
            beforeTime = latestMessage.timestamp + 1;
        }else{
            beforeTime = [[NSDate date] timeIntervalSince1970] * 1000 + 1;
        }
        
        NSArray *chats = [weakSelf.conversation loadNumbersOfMessages:(currentCount + KPageCount) before:beforeTime];
        
        // ----->>>
//        for (MessageModel *messageModel in chats) {
//            if (messageModel.message.from != [CURRENT_USER_INSTANCE getCurrentUserHXID]) {
//                NSDictionary *extDic = messageModel.message.ext;
//                if ([extDic count] > 0 && [[extDic allKeys] containsObject:@"UserInfo"]) {
//                    
//                }
//            }
//        }
//        
//        
//        [[logicShareInstance getUserManager] getUserEntityWithHXID:chatter result:^(UserEntity *userEntity) {
//            self.chatterEntity = userEntity;
//        }];
//        
        // ----->>>
        
        if ([chats count] > currentCount) {
            weakSelf.dataSource.array = [weakSelf sortChatSource:chats];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.tableView reloadData];
                if([weakSelf.tableView numberOfRowsInSection:0]==0)
                {
                    return ;
                }
                
                [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[weakSelf.dataSource count] - currentCount - 1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            });
        }
    });
}

- (NSArray *)sortChatSource:(NSArray *)array
{
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    if (array && [array count] > 0) {
        
        for (EMMessage *message in array) {
            NSDate *createDate = [NSDate dateWithTimeIntervalInMilliSecondSince1970:(NSTimeInterval)message.timestamp];
            NSTimeInterval tempDate = [createDate timeIntervalSinceDate:self.chatTagDate];
            if (tempDate > 60 || tempDate < -60 || (self.chatTagDate == nil)) {
                [resultArray addObject:[createDate formattedTime]];
                self.chatTagDate = createDate;
            }
            
            MessageModel *model = [MessageModelManager modelWithMessage:message];
            if (model) {
                [resultArray addObject:model];
            }
        }
    }
    
    return resultArray;
}

-(NSMutableArray *)addChatToMessage:(EMMessage *)message
{
    NSMutableArray *ret = [[NSMutableArray alloc] init];
    NSDate *createDate = [NSDate dateWithTimeIntervalInMilliSecondSince1970:(NSTimeInterval)message.timestamp];
    NSTimeInterval tempDate = [createDate timeIntervalSinceDate:self.chatTagDate];
    if (tempDate > 60 || tempDate < -60 || (self.chatTagDate == nil)) {
        [ret addObject:[createDate formattedTime]];
        self.chatTagDate = createDate;
    }
    
    MessageModel *model = [MessageModelManager modelWithMessage:message];
    if (model) {
        [ret addObject:model];
    }
    
    return ret;
}

-(void)addChatDataToMessage:(EMMessage *)message
{
    __weak ChatViewController *weakSelf = self;
    dispatch_async(_messageQueue, ^{
        NSArray *messages = [weakSelf addChatToMessage:message];
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < messages.count; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:weakSelf.dataSource.count+i inSection:0];
//            [indexPaths insertObject:indexPath atIndex:0];
            [indexPaths addObject:indexPath];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.tableView beginUpdates];
            [weakSelf.dataSource addObjectsFromArray:messages];
            [weakSelf.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
            [weakSelf.tableView endUpdates];
            
            //强制刷新一下 可能会影响性能
            //[weakSelf.tableView reloadData];
            
            [weakSelf.tableView scrollToRowAtIndexPath:[indexPaths lastObject] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        });
    });
}

- (void)scrollViewToBottom:(BOOL)animated
{
    //如果当前内容高度大于表格框的时候才执行
    if (self.tableView.contentSize.height > self.tableView.frame.size.height)
    {
        CGPoint offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height);
        
        NSLog(@"........当前指向位置 %@",NSStringFromCGPoint(offset));
        [self.tableView setContentOffset:offset animated:YES];
    }
}

- (void)showRoomContact:(id)sender
{
    [self.view endEditing:YES];
    if (_isChatGroup) {
//        ChatGroupDetailViewController *detailController = [[ChatGroupDetailViewController alloc] initWithGroupId:_chatter];
//        [self.navigationController pushViewController:detailController animated:YES];
    }
}

- (void)removeAllMessages:(id)sender
{
    if (_dataSource.count == 0) {
        [self showHint:@"消息已经清空"];
        return;
    }
    
    if ([sender isKindOfClass:[NSNotification class]]) {
        NSString *groupId = (NSString *)[(NSNotification *)sender object];
        if (_isChatGroup && [groupId isEqualToString:_conversation.chatter]) {
            [_conversation removeAllMessages];
            [_dataSource removeAllObjects];
            [_tableView reloadData];
            [self showHint:@"消息已经清空"];
        }
    }
    else{
        __weak typeof(self) weakSelf = self;
        [WCAlertView showAlertWithTitle:@"提示"
                                message:@"确定清空与该用户的所有聊天记录吗?"
                     customizationBlock:^(WCAlertView *alertView) {
                         
                     } completionBlock:
         ^(NSUInteger buttonIndex, WCAlertView *alertView) {
             if (buttonIndex == 1) {
                 [weakSelf.conversation removeAllMessages];
                 
                 [[logicShareInstance getMessageManager] deleteExtMessageWithReceiveUid:weakSelf.conversation.chatter];
                 
                 [weakSelf.dataSource removeAllObjects];
                 [weakSelf.tableView reloadData];
             }
         } cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    }
}

- (void)showMenuViewController:(UIView *)showInView andIndexPath:(NSIndexPath *)indexPath messageType:(MessageBodyType)messageType
{
    if (_menuController == nil) {
        _menuController = [UIMenuController sharedMenuController];
    }
    if (_copyMenuItem == nil) {
        _copyMenuItem = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copyMenuAction:)];
    }
    if (_deleteMenuItem == nil) {
        _deleteMenuItem = [[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(deleteMenuAction:)];
    }
    
    if (messageType == eMessageBodyType_Text) {
        [_menuController setMenuItems:@[_copyMenuItem, _deleteMenuItem]];
    }
    else{
        [_menuController setMenuItems:@[_deleteMenuItem]];
    }
    
    [_menuController setTargetRect:showInView.frame inView:showInView.superview];
    [_menuController setMenuVisible:YES animated:YES];
}

- (void)exitGroup
{
    [self.navigationController popToViewController:self animated:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)applicationDidEnterBackground
{
    [_chatToolBar cancelTouchRecord];
    
    // 设置当前conversation的所有message为已读
    [_conversation markAllMessagesAsRead:YES];
}

#pragma mark - send message

- (void)sendGoodsMessage:(GoodsEntity *)goodsEntity
{
    if (![[logicShareInstance getMessageManager] isEnableSendGoodsWithMessage]) {
        return;
    }
    
    // 查询是否已经发送了
    BOOL isSend = [[logicShareInstance getMessageManager] isSendedExtMessageWithItemId:[NSString stringWithFormat:@"%lld", goodsEntity.goodsId] replayTime:0 messageType:extMessageType_Goods receiveUid:[NSString stringWithFormat:@"%lld", goodsEntity.createUserId]];

    if (!isSend) {
        [[logicShareInstance getMessageManager] insertExtMessageWithItemId:[NSString stringWithFormat:@"%lld", goodsEntity.goodsId] messageType:extMessageType_Goods receiveUid:[NSString stringWithFormat:@"%lld", goodsEntity.createUserId]];
        
        WeakSelf
        [self bk_performBlock:^(id obj) {
            [weakSelf_SC sendGoodsDetailsWithGoodsEntity:goodsEntity];
        } afterDelay:1];
    }
}

- (void) sendOrderMessage:(OrderEntity *)orderEntity
{
    if (![[logicShareInstance getMessageManager] isEnableSendGoodsWithMessage]) {
        return;
    }
    // 查询是否已经发送了
    BOOL isSend = [[logicShareInstance getMessageManager] isSendedExtMessageWithItemId:[NSString stringWithFormat:@"%@", orderEntity.orderNo] replayTime:0 messageType:extMessageType_Order receiveUid:[NSString stringWithFormat:@"%ld", (long)orderEntity.buyerUserId]];
    
    if (!isSend) {
        [[logicShareInstance getMessageManager] insertExtMessageWithItemId:[NSString stringWithFormat:@"%@", orderEntity.orderNo] messageType:extMessageType_Order receiveUid:[NSString stringWithFormat:@"%ld", (long)orderEntity.buyerUserId]];
        WeakSelf
        [self bk_performBlock:^(id obj) {
            // extOrderId
            EMMessage *tempMessage = [ChatSendHelper sendMessageWithOrder:orderEntity toUsername:_conversation.chatter];
            [weakSelf_SC addChatDataToMessage:tempMessage];
        } afterDelay:1];
    }
}

#pragma mark 发送商品内容
- (void) sendGoodsDetailsWithGoodsEntity:(GoodsEntity *)goods
{
    EMMessage *tempMessage = [ChatSendHelper sendMessageWithGoods:goods toUsername:_conversation.chatter];
    [self addChatDataToMessage:tempMessage];
}

-(void)sendTextMessage:(NSString *)textMessage
{
//    for (int i = 0; i < 100; i++) {
//        NSString *str = [NSString stringWithFormat:@"%@--%i", _conversation.chatter, i];
//        EMMessage *tempMessage = [ChatSendHelper sendTextMessageWithString:str toUsername:_conversation.chatter isChatGroup:_isChatGroup requireEncryption:NO];
//        [self addChatDataToMessage:tempMessage];
//    }
    EMMessage *tempMessage = [ChatSendHelper sendTextMessageWithString:textMessage toUsername:_conversation.chatter isChatGroup:_isChatGroup requireEncryption:NO];
    [self addChatDataToMessage:tempMessage];
}

-(void)sendImageMessage:(UIImage *)imageMessage
{
    EMMessage *tempMessage = [ChatSendHelper sendImageMessageWithImage:imageMessage toUsername:_conversation.chatter isChatGroup:_isChatGroup requireEncryption:NO];
    [self addChatDataToMessage:tempMessage];
    if (self.willSendImage) {
        self.willSendImage = nil;
    }
}

-(void)sendAudioMessage:(EMChatVoice *)voice
{
    EMMessage *tempMessage = [ChatSendHelper sendVoice:voice toUsername:_conversation.chatter isChatGroup:_isChatGroup requireEncryption:NO];
    [self addChatDataToMessage:tempMessage];
}

-(void)sendVideoMessage:(EMChatVideo *)video
{
    EMMessage *tempMessage = [ChatSendHelper sendVideo:video toUsername:_conversation.chatter isChatGroup:_isChatGroup requireEncryption:NO];
    [self addChatDataToMessage:tempMessage];
}

#pragma mark - LocationViewDelegate

-(void)sendLocationLatitude:(double)latitude longitude:(double)longitude andAddress:(NSString *)address
{
    EMMessage *locationMessage = [ChatSendHelper sendLocationLatitude:latitude longitude:longitude address:address toUsername:_conversation.chatter isChatGroup:_isChatGroup requireEncryption:NO];
    [self addChatDataToMessage:locationMessage];
}

#pragma mark - EMDeviceManagerProximitySensorDelegate

- (void)proximitySensorChanged:(BOOL)isCloseToUser{
    //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗（省电啊）
    if (isCloseToUser)//黑屏
    {
        // 使用耳机播放
        [[EaseMob sharedInstance].deviceManager switchAudioOutputDevice:eAudioOutputDevice_earphone];
    } else {
        // 使用扬声器播放
        [[EaseMob sharedInstance].deviceManager switchAudioOutputDevice:eAudioOutputDevice_speaker];
        if (!_isPlayingAudio) {
            [[[EaseMob sharedInstance] deviceManager] disableProximitySensor];
        }
    }
}




@end