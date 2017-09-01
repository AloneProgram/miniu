//
//  PutGoodTableViewController.m
//  DLDQ_IOS
//
//  Created by simman on 15/1/13.
//  Copyright (c) 2015年 Liwei. All rights reserved.
//

#import "PutGoodTableViewController.h"
#import "UzysAssetsPickerController.h"
#import "GoodsEntity.h"
#import "PutGoodTableViewCell.h"
#import "PostTagViewController.h"
#import "PhotoWindowsViewController.h"

#define MAX_PHOTO_NUM 9

@interface PutGoodTableViewController () <UzysAssetsPickerControllerDelegate, PutGoodTableViewCellDelegate>
@property (nonatomic, assign) NSInteger current_selected_photo_num; // 当前选中的图片数量
@property (nonatomic, strong) NSMutableArray *select_image_array;   // 已经选择的图片数组
@property (nonatomic, strong) NSMutableArray *select_image_asset;   // 已经选择的图片资源
@property (nonatomic, strong) GoodsEntity *postGoodsEntity;
@property (nonatomic, assign) BOOL isShowAgencyButton;                     // 是否显示代购按钮
@property (nonatomic, assign) BOOL isPostWeChat;
@property (nonatomic, strong) GoodsEntity *finishGoodsEntity;   // 发布成功的ID

@end

@implementation PutGoodTableViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _current_selected_photo_num = 0;
        _select_image_array = [NSMutableArray arrayWithCapacity:1];
        _select_image_asset = [NSMutableArray arrayWithCapacity:1];
        _postGoodsEntity = [[GoodsEntity alloc] init];
        _finishGoodsEntity = [[GoodsEntity alloc] init];
        _isShowAgencyButton = YES;
        _isPostWeChat = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(setNavLeftBarButtonAction:)];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发布" style:UIBarButtonItemStyleDone target:self action:@selector(navigationRightBarPostAction:)];
    [rightBarButtonItem configureFlatButtonWithColor:FlatButtonColor highlightedColor:FlatButtonColor cornerRadius:2.0f];
    rightBarButtonItem.tintColor = [UIColor sunflowerColor];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
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
}

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
    if ([_select_image_array count] || [_postGoodsEntity.goodsDescription length]) {
        [WCAlertView showAlertWithTitle:@"提示" message:@"您的商品还未发布,是否存为草稿？" customizationBlock:^(WCAlertView *alertView) {
            
        } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
            if (buttonIndex == 0) {
                [self clearTmpData];
                [self.rdv_tabBarController setSelectedIndex:0];
            } else {
               [self.rdv_tabBarController setSelectedIndex:0];
            }
        } cancelButtonTitle:@"退出" otherButtonTitles:@"存储", nil];
    } else {
        [self clearTmpData];
        [self.rdv_tabBarController setSelectedIndex:0];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
            return 88.0f;
        } else if (indexPath.row == 1) {
            
            if (_current_selected_photo_num >=0 && _current_selected_photo_num <= 3) {
                return 81.0f;
            } else if (_current_selected_photo_num >= 4 && _current_selected_photo_num < 8) {
                return (81 + 65 + 8);
            } else if (_current_selected_photo_num >= 8 && _current_selected_photo_num <= 9) {
                return (81 + 65 + 8 + 65 + 8);
            }
        }
    }
    return 44.0f;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    if (![CURRENT_USER_INSTANCE getCurrentUserIsBuyer]) {
        return 2;
    }
    return 3;
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
    if ([CURRENT_USER_INSTANCE getCurrentUserIsBuyer]) {
        if (section == 1) {
            if (_isShowAgencyButton) {
                return 2;
            } else {
                return 1;
            }
        }
    }
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    PutGoodTableViewCell *cell;
    if ([CURRENT_USER_INSTANCE getCurrentUserIsBuyer]) {
        static NSString *CellIdentifier = @"PutGoodCell";
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                CellIdentifier = @"PutGoodCell6";
            } else if (indexPath.row == 1) {
                CellIdentifier = @"PutGoodCell1";
            }
            
        } else if(indexPath.section == 1) {
            if (indexPath.row == 0) {
                CellIdentifier = @"PutGoodCell2";
            } else if (indexPath.row == 1) {
                CellIdentifier = @"PutGoodCell3";
            }
        } else if (indexPath.section == 2) {
            if (indexPath.row == 0) {
                CellIdentifier = @"PutGoodCell4";
            } else if(indexPath.row == 1) {
                CellIdentifier = @"PutGoodCell5";
            } else if(indexPath.row == 2) {
                CellIdentifier = @"PutGoodCell7";
            }
        }
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            if (indexPath.section == 0) {
                if (indexPath.row == 0) {
                    cell = [PutGoodTableViewCell shareXibDescription];
                    cell.GoodsDescriptionTextView.text = _postGoodsEntity.goodsDescription;
                } else if (indexPath.row == 1) {
                    cell = [PutGoodTableViewCell shareXibImageView];
                }
            } else if(indexPath.section == 1) {
                if (indexPath.row == 0) {
                    cell = [PutGoodTableViewCell shareXibPriceButtonView];
                } else if (indexPath.row == 1) {
                    cell.GoodsPriceTextField.text = [_postGoodsEntity.price floatValue] > 0 ? [NSString stringWithFormat:@"%0.2f", [_postGoodsEntity.price floatValue]] : @"" ;
                    cell = [PutGoodTableViewCell shareXibPriceView];
                }
            } else if (indexPath.section == 2) {
                if (indexPath.row == 0) {
                    cell = [PutGoodTableViewCell shareXibLocationView];
                } else if (indexPath.row == 1) {
                    cell = [PutGoodTableViewCell shareXibTagView];
                } else if (indexPath.row == 2) {
                    cell = [PutGoodTableViewCell shareXibShowMark];
                }
            }
            cell.delegate = self;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
//                [cell setImagesWith:_select_image_array];
            } else if(indexPath.row == 1) {
                [cell setAssetWith:_select_image_asset];
            }
            
        } else if(indexPath.section == 1) {
            if (indexPath.row == 0) {
                [cell setIsShowPrice:_isShowAgencyButton];
            } else if (indexPath.row == 1) {
                
            }
        } else if (indexPath.section == 2) {
            if (indexPath.row == 0) {
                
            } else if (indexPath.row == 1) {
                
            } else if (indexPath.row == 2) {
                [cell setIsShowMarkS:_postGoodsEntity.isShowMark];
            }
        }
        
    } else {
        static NSString *CellIdentifier = @"PutGoodCell";
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                CellIdentifier = @"PutGoodCell6";
            } else if (indexPath.row == 1) {
                CellIdentifier = @"PutGoodCell1";
            }
            
        } else if (indexPath.section == 1) {
            if (indexPath.row == 0) {
                CellIdentifier = @"PutGoodCell4";
            } else if(indexPath.row == 1) {
                CellIdentifier = @"PutGoodCell5";
            } else if (indexPath.row == 2) {
                CellIdentifier = @"PutGoodCell7";
            }
        }
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            if (indexPath.section == 0) {
                if (indexPath.row == 0) {
                    cell = [PutGoodTableViewCell shareXibDescription];
                    cell.GoodsDescriptionTextView.text = _postGoodsEntity.goodsDescription;
                } else if (indexPath.row == 1) {
                    cell = [PutGoodTableViewCell shareXibImageView];
                }
            } else if (indexPath.section == 1) {
                if (indexPath.row == 0) {
                    cell = [PutGoodTableViewCell shareXibLocationView];
                } else if (indexPath.row == 1) {
                    cell = [PutGoodTableViewCell shareXibTagView];
                } else if (indexPath.row == 2) {
                    cell = [PutGoodTableViewCell shareXibShowMark];
                }
            }
            cell.delegate = self;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {

            } else if(indexPath.row == 1) {
                [cell setAssetWith:_select_image_asset];
            }
            
        } else if (indexPath.section == 1) {
            if (indexPath.row == 0) {
                
            } else if (indexPath.row == 1) {
                
            } else if (indexPath.row == 2) {
                [cell setIsShowMarkS:_postGoodsEntity.isShowMark];
            }
        }
        
    }
    return cell;
}



#pragma mark POSTVIEWDELEGATE
- (void) clickShowLocation:(UIButton *)locationButton cancelButton:(UIButton *)cancelButton
{
    if (locationButton.selected) {
        cancelButton.hidden = NO;
        [locationButton setTitle:@"正在获取中..." forState:UIControlStateSelected];
        WeakSelf
        [[logicShareInstance getLocationManager] getCurrentLocation:^(CLLocation *location) {
            weakSelf_SC.postGoodsEntity.gpsPosition = [NSString stringWithFormat:@"%f,%f", location.coordinate.latitude, location.coordinate.longitude];
        } Placemark:^(CLPlacemark *placemark) {
            weakSelf_SC.postGoodsEntity.position = [NSString stringWithFormat:@"%@ %@", placemark.country, placemark.locality];
            [locationButton setTitle:[NSString stringWithFormat:@"%@ %@", placemark.country, placemark.locality] forState:UIControlStateSelected];
        } error:^(NSString *error) {
            locationButton.selected = NO;
            [weakSelf_SC faildMessage:error];
        }];
    } else {
        cancelButton.hidden = NO;
        [locationButton setTitle:@"显示位置" forState:UIControlStateNormal];
    }
}

- (void)clickHiddenLocation:(UIButton *)cancelButton locationButton:(UIButton *)locationButton
{
    locationButton.selected = NO;
    cancelButton.hidden = YES;
    self.postGoodsEntity.gpsPosition = @"";
    self.postGoodsEntity.position = @"";
    [locationButton setTitle:@"显示位置" forState:UIControlStateNormal];
}

- (void) clickTag:(UIButton *)tagButton
{
    PostTagViewController *postTagVC = [[PostTagViewController alloc] initWithTags:self.postGoodsEntity.goodsTags];
    WeakSelf
    [postTagVC addCallBackWithTag:^(NSString *tags) {
        weakSelf_SC.postGoodsEntity.goodsTags = tags;
        [weakSelf_SC asyncMainQueue:^{
            if ([tags length] > 0) {
                [tagButton setTitle:@"查看已选标签" forState:UIControlStateSelected];
                tagButton.selected = YES;
            } else {
                [tagButton setTitle:@"选择标签" forState:UIControlStateNormal];
                tagButton.selected = NO;
            }
        }];
    }];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:postTagVC];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)clickIsShowPrice:(UISwitch *)switchSender
{
    _isShowAgencyButton = switchSender.isOn;
    self.postGoodsEntity.isShowBuyBtn = _isShowAgencyButton;
    
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:1];
    [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void) clickIsShowMark:(UISwitch *)switchSender
{
    _postGoodsEntity.isShowMark = switchSender.isOn;
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
    _postGoodsEntity.goodsDescription = content;
}

- (void)setPhotoWindow:(UIImageView *)imageView
{
    PhotoWindowsViewController *photoWindowVC = [[PhotoWindowsViewController alloc] initWithPhotoArray:_select_image_asset CurrentPhotoIndex:(imageView.tag - 900)];
    // 添加回调
    [photoWindowVC callBackActionWithPhotoArr:^(NSMutableArray *photos) {
        
        // 如果没有做操作，则不变化
        NSInteger photoCount = [photos count];
        if (photoCount != [_select_image_asset count]) {
            [_select_image_asset removeAllObjects];
            
            if (photoCount) {
                [_select_image_asset addObjectsFromArray:photos];
                _current_selected_photo_num = [_select_image_asset count];
            } else {
                _current_selected_photo_num = 0;
            }

            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];

            [self loadPostImages];
        }
    }];
    
    [self.navigationController pushViewController:photoWindowVC animated:YES];
}

#pragma mark 选择图片
- (void) choosePhoto
{
    UzysAssetsPickerController *picker = [[UzysAssetsPickerController alloc] init];
    picker.delegate = self;
    picker.maximumNumberOfSelectionVideo = 0;
    picker.maximumNumberOfSelectionPhoto = (MAX_PHOTO_NUM - _current_selected_photo_num);
    [self presentViewController:picker animated:YES completion:^{
        
    }];
}

#pragma mark - UzysAssetsPickerControllerDelegate methods
- (void)UzysAssetsPickerController:(UzysAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    NSLog(@"delegate-time--recive");
//    NSInteger assetsCount = assets.count;
    [_select_image_asset addObjectsFromArray:assets];
     _current_selected_photo_num = [_select_image_asset count];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self loadPostImages];
}

// 加载发布用的图片
- (void) loadPostImages
{
    if (![_select_image_asset count]) {
        return;
    }
    
    [_select_image_array removeAllObjects];
    if([[_select_image_asset[0] valueForProperty:@"ALAssetPropertyType"] isEqualToString:@"ALAssetTypePhoto"]) //Photo
    {
        
        [self asyncBackgroundQueue:^{
            [_select_image_asset enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                ALAsset *representation = obj;
                
                //[UIImage imageWithCGImage:representation.defaultRepresentation.fullScreenImage
                //        scale:representation.defaultRepresentation.orientation
                //        orientation:(UIImageOrientation)representation.defaultRepresentation.orientation];
                
                UIImage *img = [UIImage imageWithCGImage:representation.defaultRepresentation.fullScreenImage];
                [_select_image_array addObject:img];
                
                if ((idx + 1) == _current_selected_photo_num) {
                    *stop = YES;
                    //                [self.tableView reloadData];
                    //                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:0];
                    //                [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
                }
            }];
        }];
    }
}


- (void)UzysAssetsPickerControllerDidExceedMaximumNumberOfSelection:(UzysAssetsPickerController *)picker
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                    message:[NSString stringWithFormat:@"您最多选择 %d 张图片", (int)(MAX_PHOTO_NUM - _current_selected_photo_num)]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark 发布
- (void) navigationRightBarPostAction:(id)sender
{
   [NSNotificationDefaultCenter postNotificationName:@"hiddenKeyBoard" object:nil];

    if (_postGoodsEntity) {
        
        if ([_postGoodsEntity.price floatValue] >= 10000000) {
            [self faildMessage:@"您输入的金额过大!"];
            return;
        }
        
        if ([_postGoodsEntity.price floatValue] > 0) {

            NSArray * array = [[_postGoodsEntity.price stringValue] componentsSeparatedByString:@"."];
            
            if ([array count] > 1) {
                NSMutableString *s = [NSMutableString stringWithFormat:@"%@", [array objectAtIndex:1]];
                if ([s length] > 2) {
                    [self faildMessage:@"只允许保留小数点后两位!"];
                    return;
                }
            }
        }

        
        if (![_select_image_asset count]) {
            [self faildMessage:@"至少选择一张图片!"];
            return;
        }
        
        if (!_postGoodsEntity.isShowBuyBtn) {
            _postGoodsEntity.price = @0;
        }
        
        if (![CURRENT_USER_INSTANCE getCurrentUserIsBuyer]) {
            _postGoodsEntity.price = @0;
            _postGoodsEntity.isShowBuyBtn = NO;
        }
        
        [self netWorkRequestForPostGoods];
    } else {
        [self faildMessage:@"数据错误!"];
    }
}

-(void)netWorkRequestForPostGoods
{
    [self beginLoadWithText:@"发布中..."];
    @try {
        WeakSelf
        [NET_WORK_HANDLE UpLoadPhotoWithUIImage:_select_image_array type:UploadTypeOfGoods success:^(id data) {
            
            NSMutableString *imagePathStr = [NSMutableString stringWithCapacity:1];
            for (NSDictionary *dic in data) {
                NSLog(@">>>>>>>> %@", [dic objectForKey:@"url"]);
                [imagePathStr appendString:[NSString stringWithFormat:@"%@%@,", UPYUN_URL,[dic objectForKey:@"url"]]];
            }
            
            NSRange range = NSMakeRange([imagePathStr length] - 1, 1);
            [imagePathStr replaceCharactersInRange:range withString:@""];   // 替换掉最后一个,
            
            // 设置图片数据
            weakSelf_SC.postGoodsEntity.goodsImages = imagePathStr;
            [weakSelf_SC postGoosForNetWork];
            
        } failure:^(NSError *error) {
            NSLog(@"%@", error);
            
            [weakSelf_SC faildMessage:@"发布失败，请重试！"];
        } progress:^(CGFloat pro) {
            
            NSLog(@"-->>>>>>> %d", (int)pro);
            
        }];
    }
    @catch (NSException *exception) {
        [self endLoad];
    }
    @finally {
    };
    
    
}

- (void)postGoosForNetWork
{
    [self beginLoadWithText:@"发布中...."];
    @try {
        WeakSelf
        [[logicShareInstance getGoodsManager] postGoods:self.postGoodsEntity success:^(id responseObject) {
            
            @try {
                [weakSelf_SC.finishGoodsEntity setValuesForKeysWithDictionary:[responseObject objectForKey:@"data"]];
            }
            @catch (NSException *exception) {}
            @finally {}
            
            [[NSNotificationCenter defaultCenter] postNotificationName:UpdateGoodsList object:nil]; // 通知首页刷新
            [weakSelf_SC successMessage:@"发布成功！"];
            [weakSelf_SC bk_performBlock:^(id obj) {
                [weakSelf_SC otherOptionAction];
            } afterDelay:1];
        } failure:^(NSString *error) {
            [weakSelf_SC faildMessage:error];
        }];
    }
    @catch (NSException *exception) {
        [self endLoad];
    }
    @finally {
        
    };
}

- (void) otherOptionAction
{
    WeakSelf
    //    [self dismissViewControllerAnimated:YES completion:^{
    if ([_select_image_array count] > 0) {
        weakSelf_SC.postGoodsEntity.shareImage = [_select_image_array firstObject];
    }
    
    if (_isPostWeChat) {
        
        NSString *url = [NSString stringWithFormat:@"%@/share/goods?appKey=ios&userId=%lld&goodsId=%lld", [[URLManager shareInstance] getBaseURL],USER_IS_LOGIN, weakSelf_SC.finishGoodsEntity.goodsId];
        
        [[logicShareInstance getWeChatManage] weChatShareForFriendsWithImage:weakSelf_SC.postGoodsEntity.shareImage title:weakSelf_SC.postGoodsEntity.goodsDescription description:weakSelf_SC.postGoodsEntity.goodsDescription openURL:url WithSuccessBlock:^{
            
            [weakSelf_SC bk_performBlock:^(id obj) {
                [weakSelf_SC successMessage:@"成功分享到朋友圈"];
            } afterDelay:0.5];
        } errorBlock:^(NSString *error) {
            [weakSelf_SC bk_performBlock:^(id obj) {
                [weakSelf_SC faildMessage:error];
            } afterDelay:0.5];
        }];
    }
    
    NSLog(@"");
    
    [self clearTmpData];
    [self.rdv_tabBarController setSelectedIndex:0];
}

- (void) scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    [NSNotificationDefaultCenter postNotificationName:@"hiddenKeyBoard" object:nil];
}

- (void) clearTmpData
{
    _current_selected_photo_num = 0;
    [_select_image_array removeAllObjects];
    [_select_image_asset removeAllObjects];
    _postGoodsEntity = [[GoodsEntity alloc] init];
    _finishGoodsEntity = [[GoodsEntity alloc] init];
    _isShowAgencyButton = YES;
    _isPostWeChat = NO;
    
    UIButton *button = (UIButton *)[self.view viewWithTag:6981];
    button.selected = NO;
    
    [NSNotificationDefaultCenter postNotificationName:@"clearPutGoodCellViewData" object:nil];
    
//    self.tableView = nil;
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"didReceiveMemoryWarning.....");
    [super didReceiveMemoryWarning];
}

@end
