//
//  PutGoodTableViewController.m
//  DLDQ_IOS
//
//  Created by simman on 15/1/13.
//  Copyright (c) 2015年 Liwei. All rights reserved.
//

#import "PutGoodTableViewController.h"
#import "GoodsEntity.h"
#import "PutGoodTableViewCell.h"
#import "UploadManager.h"

#import "TSLocateView.h"

#import "JKImagePickerController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "JKPhotoBrowser.h"

#import "PostTagViewController.h"

#define MAX_PHOTO_NUM 9

@interface PutGoodTableViewController () <PutGoodTableViewCellDelegate,JKImagePickerControllerDelegate,JKPhotoBrowserDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) GoodsEntity *postGoodsEntity;
@property (nonatomic, assign) BOOL isPostWeChat;
@property (nonatomic, strong) GoodsEntity *finishGoodsEntity;   // 发布成功的ID
@property (nonatomic, strong) NSMutableArray *assetsArray;      // jkasset 数组

@property (nonatomic, strong) NSMutableArray *alassetArray;     // alasset数组

@property (nonatomic, strong) TSLocateView *locateView;

@end

@implementation PutGoodTableViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _assetsArray = [NSMutableArray array];
        _alassetArray = [NSMutableArray array];
        _postGoodsEntity = [[GoodsEntity alloc] init];
        _finishGoodsEntity = [[GoodsEntity alloc] init];
        _isPostWeChat = NO;
        _locateView = [[TSLocateView alloc] initWithTitle:@"选择区域" delegate:self];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"发布";
    
    WeakSelf
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] bk_initWithImage:[UIImage imageNamed:@"backBtn_Nav"] style:UIBarButtonItemStyleDone handler:^(id sender) {
        [weakSelf_SC setNavLeftBarButtonAction:sender];
    }];
    
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发布" style:UIBarButtonItemStyleDone target:self action:@selector(navigationRightBarPostAction:)];
    [rightBarButtonItem configureFlatButtonWithColor:FlatButtonColor highlightedColor:FlatButtonColor cornerRadius:2.0f];
    rightBarButtonItem.tintColor = [UIColor sunflowerColor];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 60)];
    footerView.backgroundColor = self.tableView.backgroundColor;
    UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(15, 20, 80, 30)];
    lable.text = @"同步分享到";
    lable.font = [UIFont systemFontOfSize:14];
    [footerView addSubview:lable];
    
    UIButton *wechatButton = [[UIButton alloc] initWithFrame:CGRectMake(100, 20, 30, 30)];
    wechatButton.tag = 6981;
    [wechatButton setBackgroundImage:[UIImage imageNamed:@"icon64_appwx_logo.png"] forState:UIControlStateNormal];
    [wechatButton setBackgroundImage:[UIImage imageNamed:@"icon64_appwx_logo1"] forState:UIControlStateSelected];
    [wechatButton addTarget:self action:@selector(postWechatAction:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:wechatButton];
    self.tableView.tableFooterView = footerView;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    

}

#pragma mark 是否分享到微信
- (void) postWechatAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    button.selected = !button.selected;
    _isPostWeChat = !_isPostWeChat;
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:YES animated:NO];
}

- (void) setNavLeftBarButtonAction:(id)sender
{
    [self clearTmpData];
    [self dismissViewControllerAnimated:YES completion:nil];
//    [self.navigationController popViewControllerAnimated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return 88.0f;
        } else if (indexPath.row == 1) {
            NSInteger lNums = kScreen_Width / 73;
            return ([_assetsArray count] / lNums) * (65 + 8) + 81.0f;
        }
    }
    return 44.0f;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0.00000000000001;
    }
    return 25;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    }
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    PutGoodTableViewCell *cell;

    static NSString *CellIdentifier = @"PutGoodCell";
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            CellIdentifier = @"PutGoodCell6";
        } else if (indexPath.row == 1) {
            CellIdentifier = @"PutGoodCell1";
        }
        
    } else if(indexPath.section == 1) {
        if (indexPath.row == 0) {
            CellIdentifier = @"PutGoodCell3";
        } else if (indexPath.row == 1) {
            CellIdentifier = @"PutGoodCell4";
        } else if (indexPath.row == 2) {
            CellIdentifier = @"PutGoodCell5";
        }
    }
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                cell = [PutGoodTableViewCell shareXibDescription];
            } else if (indexPath.row == 1) {
                cell = [PutGoodTableViewCell shareXibImageView];
            }
        } else if(indexPath.section == 1) {
            if (indexPath.row == 0) {
                cell = [PutGoodTableViewCell shareXibPriceView];
            } else if (indexPath.row == 1) {
                cell = [PutGoodTableViewCell shareXibLocationView];
            } else if (indexPath.row == 2) {
                cell = [PutGoodTableViewCell shareXibTagView];
            }
        }
        cell.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.GoodsDescriptionTextView.text = _postGoodsEntity.depictRemark;
        } else if (indexPath.row == 1) {
            [cell setAssetWith:_alassetArray];
        }
    } else if(indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell.GoodsPriceTextField.text = [_postGoodsEntity.price floatValue] > 0 ? [NSString stringWithFormat:@"%0.2f", [_postGoodsEntity.price floatValue]] : @"" ;
        } else if (indexPath.row == 1) {
            if ([self.postGoodsEntity.position length]) {
                [cell.LocationButton setTitle:self.postGoodsEntity.position forState:UIControlStateNormal];
                [cell.canCelLocationButton setHidden:NO];
            } else {
                [cell.canCelLocationButton setHidden:YES];
            }
        } else if (indexPath.row == 2) {
            if ([self.postGoodsEntity.goodsTags length]) {
                [cell.TagButton setTitle:@"查看已选标签" forState:UIControlStateSelected];
                cell.TagButton.selected = YES;
            } else {
                [cell.TagButton setTitle:@"选择标签" forState:UIControlStateNormal];
                cell.TagButton.selected = NO;
            }
        }
    }
    
    return cell;
}

- (void)clickImageWithImageView:(UIImageView *)imageView
{
    if (imageView.tag == 8888) {
        [self choosePhoto];
    } else {
        [self setPhotoWindow:imageView];
    }
}

- (void)goodsPriceContent:(NSString *)content
{
    if (![content length]) {
        return;
    }
    _postGoodsEntity.price = [NSNumber numberWithDouble:[content doubleValue]];
}

- (void) goodsDescriptionContent:(NSString *)content
{
    if (![content length]) {
        return;
    }
    _postGoodsEntity.depictRemark = content;
}

- (void) clickShowLocation:(UIButton *)locationButton cancelButton:(UIButton *)cancelButton
{
    [_locateView showInView:self.view];
}

- (void) clickHiddenLocation:(UIButton *)cancelButton locationButton:(UIButton *)locationButton
{
    cancelButton.hidden = YES;
    self.postGoodsEntity.position = @"";
    [locationButton setTitle:@"显示位置" forState:UIControlStateNormal];
}

/**
 *  设置位置
 *
 *  @param actionSheet 弹出框
 *  @param buttonIndex 返回 or 确定 按钮
 */
- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    TSLocateView *locateView = (TSLocateView *)actionSheet;
    TSLocation *location = locateView.locate;
    
    if(buttonIndex == 0) {
        NSLog(@"Cancel");
    }else {
        //储存地址
        self.postGoodsEntity.position = [NSString stringWithFormat:@"%@ %@", location.state, location.city];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:1];
        //更新界面
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void) clickTag:(UIButton *)tagButton
{
    PostTagViewController *postTagVC = [[PostTagViewController alloc] initWithTags:self.postGoodsEntity.goodsTags];
    WeakSelf
    [postTagVC addCallBackWithTag:^(NSString *tags) {
        weakSelf_SC.postGoodsEntity.goodsTags = tags;
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([tags length] > 0) {
                [tagButton setTitle:@"查看已选标签" forState:UIControlStateSelected];
                tagButton.selected = YES;
            } else {
                [tagButton setTitle:@"选择标签" forState:UIControlStateNormal];
                tagButton.selected = NO;
            }
        });
    }];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:postTagVC];
    [self presentViewController:nav animated:YES completion:nil];
}


#pragma mark 点击图片显示浏览器
- (void)setPhotoWindow:(UIImageView *)imageView
{
    
    JKPhotoBrowser  *photoBorwser = [[JKPhotoBrowser alloc] initWithFrame:[UIScreen mainScreen].bounds];
    photoBorwser.delegate = self;
    photoBorwser.isJkAsset = YES;
    photoBorwser.currentPage = (imageView.tag - 900);
    photoBorwser.assetsArray = [NSMutableArray arrayWithArray:_assetsArray];
    [photoBorwser show:YES];
}

#pragma mark 删除图片的回调
- (void) photoBrowser:(JKPhotoBrowser *)photoBrowser deleteCalback:(NSArray *)assetsArray
{
    NSInteger assetsCount = [assetsArray count];
    if (assetsCount != [_assetsArray count]) {
        
        [_assetsArray removeAllObjects];
        [_assetsArray addObjectsFromArray:assetsArray];
        
        [_alassetArray removeAllObjects];
        for (JKAssets *jkasset in assetsArray) {
            [_alassetArray addObject:jkasset.alasset];
        }
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark 选择图片
- (void) choosePhoto
{
    JKImagePickerController *imagePickerController = [[JKImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.showsCancelButton = YES;
    imagePickerController.allowsMultipleSelection = YES;
    imagePickerController.minimumNumberOfSelection = 1;
    imagePickerController.maximumNumberOfSelection = 9;
    imagePickerController.selectedAssetArray = self.assetsArray;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:imagePickerController];
    [self presentViewController:navigationController animated:YES completion:NULL];
}
#pragma mark - JKImagePickerControllerDelegate
- (void)imagePickerController:(JKImagePickerController *)imagePicker didSelectAsset:(JKAssets *)asset isSource:(BOOL)source
{
    [imagePicker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)imagePickerController:(JKImagePickerController *)imagePicker didSelectAssets:(NSArray *)assets isSource:(BOOL)source
{
    self.assetsArray = [NSMutableArray arrayWithArray:assets];
    [_alassetArray removeAllObjects];
    for (JKAssets *jkasset in assets) {
        [_alassetArray addObject:jkasset.alasset];
    }
    
    [imagePicker dismissViewControllerAnimated:YES completion:^{
        [self.tableView reloadData];
    }];
}

- (void)imagePickerControllerDidCancel:(JKImagePickerController *)imagePicker
{
    [imagePicker dismissViewControllerAnimated:YES completion:^{
        
    }];
}


#pragma mark 发布
- (void) navigationRightBarPostAction:(id)sender
{
   [NSNotificationDefaultCenter postNotificationName:@"hiddenKeyBoard" object:nil];

    if (_postGoodsEntity) {
        
        if ([_postGoodsEntity.price floatValue] >= 10000000) {
            [self showHudError:@"您输入的金额过大!"];
            return;
        }
        
        if ([_postGoodsEntity.price floatValue] > 0) {

            NSArray * array = [[_postGoodsEntity.price stringValue] componentsSeparatedByString:@"."];
            
            if ([array count] > 1) {
                NSMutableString *s = [NSMutableString stringWithFormat:@"%@", [array objectAtIndex:1]];
                if ([s length] > 2) {
                    [self showHudError:@"只允许保留小数点后两位!"];
                    return;
                }
            }
        }
        
        if (![_assetsArray count]) {
            [self showHudError:@"至少选择一张图片!"];
            return;
        }
        
        if (![_postGoodsEntity.goodsTags length]) {
            [self showHudError:@"请填写标签!"];
            return;
        }
        
        [self netWorkRequestForPostGoods];
    } else {
        [self showHudError:@"数据错误!"];
    }
}

-(void)netWorkRequestForPostGoods
{
    [self showHudLoad:@"发布中..."];
    @try {
        WeakSelf
        [[logicShareInstance getUploadManager] UpLoadImageWithUIImage:_alassetArray type:UploadTypeOfGoods success:^(NSArray *QNImageEntityArray) {
            NSMutableString *imagePathStr = [NSMutableString stringWithCapacity:1];
            for (QNImageEntity *qnimage in QNImageEntityArray) {
                [imagePathStr appendString:[NSString stringWithFormat:@"%@,", qnimage.imageURL]];
            }
            
            NSRange range = NSMakeRange([imagePathStr length] - 1, 1);
            [imagePathStr replaceCharactersInRange:range withString:@""];   // 替换掉最后一个,
            
            // 设置图片数据 todotodo 5156
            weakSelf_SC.postGoodsEntity.goodsImages = imagePathStr;
            [weakSelf_SC postGoosForNetWork];
        } failure:^(NSString *error) {
            [weakSelf_SC showHudError:@"发布失败，请重试！"];
        } progress:^(CGFloat pro) {
            NSLog(@"创建订单进度百分比-->>>>>>> %0.2f", pro);
        }];
    }
    @catch (NSException *exception) {
        [self endHudLoad];
    }
    @finally {
    };
}

- (void)postGoosForNetWork
{
    [self showHudLoad:@"发布中...."];
    @try {
        WeakSelf
        [[logicShareInstance getGoodsManager] postGoods:self.postGoodsEntity success:^(id responseObject) {
            
            @try {
                [weakSelf_SC.finishGoodsEntity setValuesForKeysWithDictionary:[responseObject objectForKey:@"data"]];
            }
            @catch (NSException *exception) {}
            @finally {}
            
            [[NSNotificationCenter defaultCenter] postNotificationName:DID_FINISH_PUSH_GOODS object:nil]; // 通知首页刷新
            [weakSelf_SC showHudSuccess:@"发布成功！"];
            [weakSelf_SC bk_performBlock:^(id obj) {
                [weakSelf_SC otherOptionAction];
            } afterDelay:1];
        } failure:^(NSString *error) {
            [weakSelf_SC showHudError:error];
        }];
    }
    @catch (NSException *exception) {
        [self endHudLoad];
    }
    @finally {
        
    };
}

- (void) otherOptionAction
{
    WeakSelf
    if ([_alassetArray count] > 0) {
        ALAsset *alasset = [_alassetArray firstObject];
        weakSelf_SC.postGoodsEntity.shareImage = [UIImage imageWithCGImage:[[alasset defaultRepresentation] fullScreenImage]];
    }
    
    if (_isPostWeChat) {
        
        NSString *url = [NSString stringWithFormat:@"%@/share/goods?appKey=ios&userId=%lld&goodsId=%lld", [[URLManager shareInstance] getBaseURL],USER_IS_LOGIN, weakSelf_SC.finishGoodsEntity.goodsId];
        
        [[logicShareInstance getWeChatManage] weChatShareForFriendsWithImage:weakSelf_SC.postGoodsEntity.shareImage title:weakSelf_SC.postGoodsEntity.depictRemark description:weakSelf_SC.postGoodsEntity.depictRemark openURL:url WithSuccessBlock:^{
            
            [weakSelf_SC bk_performBlock:^(id obj) {
                [weakSelf_SC showHudSuccess:@"成功分享到朋友圈"];
            } afterDelay:0.5];
        } errorBlock:^(NSString *error) {
            [weakSelf_SC bk_performBlock:^(id obj) {
                [weakSelf_SC showHudError:error];
            } afterDelay:0.5];
        }];
    }
    [self clearTmpData];
    [self dismissViewControllerAnimated:YES completion:nil];
//    [self.navigationController popViewControllerAnimated:YES];
}

- (void) scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    [NSNotificationDefaultCenter postNotificationName:@"hiddenKeyBoard" object:nil];
}

- (void) clearTmpData
{
    [_locateView hiddenView];
    [_assetsArray removeAllObjects];
    [_alassetArray removeAllObjects];
    _postGoodsEntity = [[GoodsEntity alloc] init];
    _finishGoodsEntity = [[GoodsEntity alloc] init];
    _isPostWeChat = NO;
    
    UIButton *button = (UIButton *)[self.view viewWithTag:6981];
    button.selected = NO;
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"put good table view controller send! didReceiveMemoryWarning.....");
    [super didReceiveMemoryWarning];
}

@end
