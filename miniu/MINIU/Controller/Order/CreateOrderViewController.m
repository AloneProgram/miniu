//
//  CreateOrderViewController.m
//  miniu
//
//  Created by SimMan on 15/6/2.
//  Copyright (c) 2015年 SimMan. All rights reserved.
//

#import "CreateOrderViewController.h"
#import "PutGoodTableViewController.h"
#import "GoodsEntity.h"
#import "PutGoodTableViewCell.h"
#import "UploadManager.h"
#import "JKImagePickerController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "JKPhotoBrowser.h"

#import "PostTagViewController.h"
#import "CreateOrderEnetity.h"

#define MAX_PHOTO_NUM 9

@interface CreateOrderViewController () <PutGoodTableViewCellDelegate,JKImagePickerControllerDelegate,JKPhotoBrowserDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate, UIActionSheetDelegate,UITextViewDelegate>

@property (nonatomic, strong) CreateOrderEnetity *createOrder;

@property (nonatomic, strong) NSMutableArray *assetsArray;      // jkasset 数组

@property (nonatomic, strong) NSMutableArray *alassetArray;     // alasset数组

@property (nonatomic, copy) void (^_Blocks)(OrderEntity *);

@property (nonatomic, assign) float keyBoardHight; //弹出键盘高度
//@property (nonatomic, strong) NSString *description;
//@property (nonatomic, strong) NSString *remarkContent;


@end

@implementation CreateOrderViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _assetsArray = [NSMutableArray array];
        _alassetArray = [NSMutableArray array];
        _createOrder = [[CreateOrderEnetity alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    [self registerKeyboardObserver];//用了iqkeyboard
    
    self.tableView.backgroundColor = [UIColor colorWithRed:0.922 green:0.922 blue:0.922 alpha:1];
    
    self.title = @"创建订单";
    
    WeakSelf
    //设置返回按钮及其响应方法
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] bk_initWithImage:[UIImage imageNamed:@"backBtn_Nav"] style:UIBarButtonItemStyleDone handler:^(id sender) {
        [weakSelf_SC setNavLeftBarButtonAction:sender];
    }];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    //设置footer view
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 100)];
    footerView.backgroundColor = [UIColor colorWithRed:0.922 green:0.922 blue:0.922 alpha:1];
    
    FUIButton *submitButton = [[FUIButton alloc] initWithFrame:CGRectMake(0, 30, kScreen_Width - 40, 40)];
    [submitButton setTitle:@"发 送" forState:UIControlStateNormal];
    [submitButton setButtonColor:[UIColor colorWithRed:0.325 green:0.843 blue:0.412 alpha:1]];
    submitButton.titleLabel.font = [UIFont boldFlatFontOfSize:15];
    [submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    submitButton.cornerRadius = 3;
    [submitButton bk_addEventHandler:^(id sender) {
        [self postOrderAction];
    } forControlEvents:UIControlEventTouchUpInside];
    
    FUIButton *saveButton = [[FUIButton alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(submitButton.frame) + 20, kScreen_Width - 40, 40)];
    [saveButton setTitle:@"保存为草稿" forState:UIControlStateNormal];
    [saveButton setButtonColor:[UIColor whiteColor]];
    saveButton.titleLabel.font = [UIFont boldFlatFontOfSize:15];
    [saveButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    saveButton.cornerRadius = 3;
    [saveButton bk_addEventHandler:^(id sender) {
        
        [self showHudError:@"此功能暂未实现!%>_<%"];
        
    } forControlEvents:UIControlEventTouchUpInside];
    
    [footerView addSubview:submitButton];
    //[footerView addSubview:saveButton];
    
    self.tableView.tableFooterView = submitButton;
    [footerView setHeight:footerView.frame.size.height-60];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //隐藏tabbar
    [self.rdv_tabBarController setTabBarHidden:YES animated:NO];
}

- (void) setNavLeftBarButtonAction:(id)sender
{
    [SMActionSheet showSheetWithTitle:@"退出将清空此次修改记录!" buttonTitles:@[@"确定"] redButtonIndex:0 completionBlock:^(NSUInteger buttonIndex, SMActionSheet *actionSheet) {
        if (buttonIndex == 0) {
            [self clearTmpData];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
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
    }else if (indexPath.section == 1 &&indexPath.row ==3)
    {
        return 60;
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
    return 4;//增加一个备注
//    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PutGoodTableViewCell *cell;
    
    static NSString *CellIdentifier = @"PutGoodCell";
//    cell = (PutGoodTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            CellIdentifier = @"PutGoodCell6";
        } else if (indexPath.row == 1) {
            CellIdentifier = @"PutGoodCell1";
        }
        
    } else if(indexPath.section == 1) {
        if (indexPath.row == 0) {
            CellIdentifier = @"PutGoodCell102";
        } else if (indexPath.row == 1) {
            CellIdentifier = @"PutGoodCell103";
        } else if (indexPath.row == 2) {
            CellIdentifier = @"PutGoodCell101";
        } else if(indexPath.row == 3) {
            CellIdentifier = @"PutGoodCell1010";
        }
    }
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                cell = [PutGoodTableViewCell shareXibDescription];
//                cell.GoodsDescriptionTextView.delegate = self;
            } else if (indexPath.row == 1) {
                cell = [PutGoodTableViewCell shareXibImageView];
            }
        } else if(indexPath.section == 1) {
            if (indexPath.row == 0) {
                cell = [PutGoodTableViewCell totalAmountXib];
                
            } else if (indexPath.row == 1) {
                cell = [PutGoodTableViewCell totalBailAmountXib];
            } else if (indexPath.row == 2) {
                NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"PutGoodTableViewCell" owner:nil options:nil];
                cell = (PutGoodTableViewCell*)(array[10]);
//                cell = [PutGoodTableViewCell showOfflinePayXib];
            }else if (indexPath.row == 3) {
                cell = [PutGoodTableViewCell remarkXib];
//                cell.remarkTextView.delegate = self;
            }
        }
        cell.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.GoodsDescriptionTextView.text = _createOrder.depictRemark;
        } else if (indexPath.row == 1) {
            [cell setAssetWith:_alassetArray];
        }
    } else if(indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell.totalAmount.text = _createOrder.totalAmount > 0 ? [NSString stringWithFormat:@"%0.2f", _createOrder.totalAmount] : @"" ;
        } else if (indexPath.row == 1) {
            cell.totalBailAmount.text = _createOrder.totalBailAmount > 0 ? [NSString stringWithFormat:@"%0.2f", _createOrder.totalBailAmount] : @"" ;
        } else if (indexPath.row == 2) {
            
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

- (void) goodsPriceTextField:(UITextField *)textField
{
    if (![textField.text length]) {
        return;
    }
    if (textField.tag == 100011) {
        _createOrder.totalAmount = [textField.text doubleValue];
    } else if (textField.tag == 100012) {
        _createOrder.totalBailAmount = [textField.text doubleValue];
    }
}

- (void) goodsDescriptionContent:(NSString *)content
{
    if (![content length]) {
        return;
    }
    _createOrder.depictRemark = content;
}

- (void)clickIsShowOfflinePay:(UISwitch *)switchSender
{
    self.createOrder.isLineTrade = switchSender.isOn;
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
- (void) postOrderAction
{
    [NSNotificationDefaultCenter postNotificationName:@"hiddenKeyBoard" object:nil];
    
    if (_createOrder) {
        
        if (_createOrder.totalAmount >= 10000000) {
            [self showHudError:@"您输入的金额过大!"];
            return;
        }
        
        if (_createOrder.totalBailAmount > _createOrder.totalAmount) {
            [self showHudError:@"定金不能大于总价!"];
            return;
        }
        
        if (![_assetsArray count]) {
            [self showHudError:@"至少选择一张图片!"];
            return;
        }
        
        [self netWorkRequestForPostGoods];
    } else {
        [self showHudError:@"数据错误!"];
    }
}

-(void)netWorkRequestForPostGoods
{
    if (![_alassetArray count]) {
        [self postGoosForNetWork];
        return;
    }
    
    [self showHudLoad:@"开始上传图片..."];
    @try {
        WeakSelf
        [[logicShareInstance getUploadManager] UpLoadImageWithUIImage:_alassetArray type:UploadTypeOfGoods success:^(NSArray *QNImageEntityArray) {
            NSMutableString *imagePathStr = [NSMutableString stringWithCapacity:1];
            for (QNImageEntity *qnimage in QNImageEntityArray) {
                [imagePathStr appendString:[NSString stringWithFormat:@"%@,", qnimage.imageURL]];
            }
            
            NSRange range = NSMakeRange([imagePathStr length] - 1, 1);
            [imagePathStr replaceCharactersInRange:range withString:@""];   // 替换掉最后一个,
            
            // 设置图片数据
            weakSelf_SC.createOrder.goodsImages = imagePathStr;
            [weakSelf_SC postGoosForNetWork];
        } failure:^(NSString *error) {
            [weakSelf_SC showHudError:@"图片上传，请重试！"];
        } progress:^(CGFloat pro) {
            NSLog(@"创建进度-->>>>>>> %0.2f %%", pro);
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
    [self showHudLoad:@"开始生成订单...."];
    @try {
        WeakSelf
        
        [[logicShareInstance getOrderManager] createOrderWith:self.createOrder success:^(id responseObject) {
            
            OrderEntity *orderEntity = [[OrderEntity alloc] init];
            [orderEntity setValuesForKeysWithDictionary:[responseObject objectForKey:@"data"]];
            
            if (__Blocks) {
                __Blocks(orderEntity);
            }
            
            [weakSelf_SC showHudSuccess:@"订单创建成功!"];
            
            [weakSelf_SC dismissViewControllerAnimated:YES completion:nil];
            
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

- (void) scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    [NSNotificationDefaultCenter postNotificationName:@"hiddenKeyBoard" object:nil];
}

- (void) clearTmpData
{
    [_assetsArray removeAllObjects];
    [_alassetArray removeAllObjects];
    _createOrder = nil;
    
    UIButton *button = (UIButton *)[self.view viewWithTag:6981];
    button.selected = NO;
}

#pragma mark -textView delegate
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@" 备注:(尚不能用)"]) {
        textView.text = @"";
        
    }
    [self.tableView scrollToNearestSelectedRowAtScrollPosition:(UITableViewScrollPositionTop) animated:YES];
    [self.tableView setHeight:self.tableView.frame.size.height-_keyBoardHight-40];
    return YES;
}
-(void)textViewDidEndEditing:(UITextView *)textView
{
    [self.tableView setHeight:self.tableView.frame.size.height+_keyBoardHight+40];
    //[self.tableView setHeight:400];
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"create order view controller send! didReceiveMemoryWarning.....");
    [super didReceiveMemoryWarning];
}

- (void) createOrderWithApplyId:(long long)applyId addCallBackBlock:(void (^)(OrderEntity *))Block
{
    self.createOrder.applyUserId = applyId;
    self._Blocks = Block;
}


/**不用这着控制键盘遮挡
- (void)registerKeyboardObserver
{
    //增加监听，当键盘出现或改变时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    //增加监听，当键退出时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];

}

//当键盘出现或改变时调用

- (void)keyboardWillShow:(NSNotification *)aNotification
{
    //获取键盘的高度
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    _keyBoardHight = keyboardRect.size.height;
}

//当键退出时调用
- (void)keyboardWillHide:(NSNotification *)aNotification
{

}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
 */
@end

