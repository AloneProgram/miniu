//
//  ProfileUpdateViewController.m
//  miniu
//
//  Created by SimMan on 4/25/15.
//  Copyright (c) 2015 SimMan. All rights reserved.
//

#import "ProfileUpdateViewController.h"
#import "ProfileUpdateCell.H"
#import "UserEntity.h"

#import "TSLocateView.h"
#import "RMDateSelectionViewController.h"
#import "VPImageCropperViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "UserReNameViewController.h"
#import "UpdateDesViewController.h"
#import "UserAddressViewController.h"
#import "BindMobileViewController.h"
#import "UploadManager.h"

#define ORIGINAL_MAX_WIDTH 640.0f

typedef enum {
    EditPhoto = 1000,
    EditGenter,
    EditArea
}UIActionSheetType;

@interface ProfileUpdateViewController () <UINavigationControllerDelegate,UIImagePickerControllerDelegate, VPImageCropperDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) UserEntity *selfUser;

@end

@implementation ProfileUpdateViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _selfUser = [CURRENT_USER_INSTANCE getCurrentUser];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.backBarButtonItem = [UIBarButtonItem blankBarButton];
    
    self.title = @"个人信息";
    
    [self reloadUserInfo];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (![[CURRENT_USER_INSTANCE getCurrentUser].phone isEqualToString:_selfUser.phone]) {
        _selfUser = [CURRENT_USER_INSTANCE getCurrentUser];
        
        NSIndexPath *indexPaht = [NSIndexPath indexPathForRow:0 inSection:3];
        
        [self.tableView reloadRowsAtIndexPaths:@[indexPaht] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void) reloadUserInfo
{
    _selfUser = [CURRENT_USER_INSTANCE getCurrentUser];
    
    if (!_selfUser) {
        return;
    }
    
    [self.dataArray removeAllObjects];
    [self.dataArray addObjectsFromArray:@[
                                          @[
                                              @{@"name": @"修改头像", @"value": [NSString stringWithFormat:@"%@", _selfUser.avatar]},
                                              @{@"name": @"昵称", @"value": [NSString stringWithFormat:@"%@", _selfUser.nickName]},
                                              @{@"name": @"微信号", @"value": [NSString stringWithFormat:@"%@", _selfUser.weixinAccount]},
                                              @{@"name": @"绑定手机", @"value": [NSString stringWithFormat:@"%@", _selfUser.phone]}
                                              ],
                                          @[
                                              @{@"name": @"真实姓名", @"value": [NSString stringWithFormat:@"%@", _selfUser.realName]},
                                              @{@"name": @"出生年月", @"value": [NSString stringWithFormat:@"%@", [[NSDate dateWithTimeIntervalInMilliSecondSince1970:_selfUser.borndate] formattedDateForYMD]]},
                                              @{@"name": @"性别", @"value": [NSString stringWithFormat:@"%@", _selfUser.sex]},
                                              @{@"name": @"地区", @"value": [NSString stringWithFormat:@"%@", _selfUser.area]},
                                              @{@"name": @"收货地址", @"value": @""},
                                              @{@"name": @"个人签名", @"value": [NSString stringWithFormat:@"%@", _selfUser.signature]}
                                              ]
                                          ]];
    
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
    self.tableView.rowHeight = 50.0f;
    [self.view addSubview:self.tableView];
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0.001f;
    }
    
    return 20.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.dataArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataArray[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ProfileUpdateCell";
    ProfileUpdateCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ProfileUpdateCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSDictionary *dic = self.dataArray[indexPath.section][indexPath.row];
    
    [cell.leftLable setText:dic[@"name"]];
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        [cell.rightLable setText:@""];
        [cell.avatarImageView setImageWithUrl:dic[@"value"] withSize:ImageSizeOfAuto];
    } else {
        if (dic[@"value"] ==nil) {
            [cell.rightLable setText:@""];
        }else{
            [cell.rightLable setText:dic[@"value"]];
        }
    }
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WeakSelf
    if (indexPath.section == 0) {
        
        switch (indexPath.row) {
            case 0: {   // 修改头像
                [self editPortrait];
            }
                break;
            case 1: {   // 修改昵称
                UserReNameViewController *userReNameVC = [[UserReNameViewController alloc] initWithNibName:@"UserReNameViewController" bundle:nil];
                [userReNameVC setDataWithPlaceholder:@"请输入新的昵称" defaultValue:_selfUser.nickName maxLenght:20 minLenght:2 tipString:nil NavTitle:@"修改昵称" keyBoardType:UIKeyboardTypeDefault saveAction:^(NSString *string) {
                    if ( ![string isEqualToString:_selfUser.nickName] ) {
                        _selfUser.nickName = string;
                        [weakSelf_SC netWorkRequestEditUserProfileWithDic:@{@"nickName": _selfUser.nickName}];
                    }
                }];
                [self.navigationController pushViewController:userReNameVC animated:YES];
            }
                break;
            case 2: {   // 微信号
                UserReNameViewController *userReNameVC = [[UserReNameViewController alloc] initWithNibName:@"UserReNameViewController" bundle:nil];
                [userReNameVC setDataWithPlaceholder:@"请填写微信号" defaultValue:_selfUser.weixinAccount maxLenght:20 minLenght:1 tipString:nil NavTitle:@"修改微信号" keyBoardType:UIKeyboardTypeDefault saveAction:^(NSString *string) {
                    if ( ![string isEqualToString:_selfUser.weixinAccount] ) {
                        _selfUser.weixinAccount = string;
                        [weakSelf_SC netWorkRequestEditUserProfileWithDic:@{@"weixinAccount": _selfUser.weixinAccount}];
                    }
                }];
                [self.navigationController pushViewController:userReNameVC animated:YES];
            }
                break;
            case 3: {   // 绑定手机号
                BindMobileViewController *bindMobileVC = [[BindMobileViewController alloc] initWithNibName:@"BindMobileViewController" bundle:nil];
                [self.navigationController pushViewController:bindMobileVC animated:YES];
            }
                break;
            default:
                break;
        }
    } else if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0: {   // 真实姓名
                UserReNameViewController *userReNameVC = [[UserReNameViewController alloc] initWithNibName:@"UserReNameViewController" bundle:nil];
                [userReNameVC setDataWithPlaceholder:@"请输入真实姓名" defaultValue:_selfUser.realName maxLenght:20 minLenght:1 tipString:nil NavTitle:@"修改真实姓名" keyBoardType:UIKeyboardTypeDefault saveAction:^(NSString *string) {
                    if ( ![string isEqualToString:_selfUser.realName] ) {
                        _selfUser.realName = string;
                        [weakSelf_SC netWorkRequestEditUserProfileWithDic:@{@"realName": _selfUser.realName}];
                    }
                }];
                [self.navigationController pushViewController:userReNameVC animated:YES];
            }
                break;
            case 1: {   // 出生年月
                RMDateSelectionViewController *dateSelectionVC = [RMDateSelectionViewController dateSelectionController];
                
                //You can enable or disable bouncing and motion effects
                dateSelectionVC.hideNowButton = YES;
                //You can access the actual UIDatePicker via the datePicker property
                dateSelectionVC.datePicker.datePickerMode = UIDatePickerModeDate;
                dateSelectionVC.datePicker.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
                dateSelectionVC.datePicker.minuteInterval = 5;
                dateSelectionVC.datePicker.minimumDate = [NSDate dateWithTimeIntervalSince1970:-1767250739];
                dateSelectionVC.datePicker.maximumDate = [NSDate date];
                dateSelectionVC.datePicker.date = [NSDate dateWithTimeIntervalInMilliSecondSince1970:_selfUser.borndate];
                
                [self asyncMainQueue:^{
                    [dateSelectionVC showWithSelectionHandler:^(RMDateSelectionViewController *vc, NSDate *aDate) {
                        _selfUser.borndate = [aDate timeIntervalSince1970InMilliSecond];
                        [weakSelf_SC netWorkRequestEditUserProfileWithDic:@{@"borndate": [NSNumber numberWithLongLong:_selfUser.borndate]}];
                        
                    } andCancelHandler:^(RMDateSelectionViewController *vc) {}];
                }];
            }
                break;
            case 2: {   // 性别
                
                [SMActionSheet showSheetWithTitle:@"修改性别" buttonTitles:@[@"男", @"女"] redButtonIndex:-1 completionBlock:^(NSUInteger buttonIndex, SMActionSheet *actionSheet) {
                    NSString *gender = buttonIndex ? @"女" : @"男";
                    if (![_selfUser.sex isEqualToString:gender] && buttonIndex != 2) {
                        _selfUser.sex = gender;
                        [self netWorkRequestEditUserProfileWithDic:@{@"sex": _selfUser.sex}];
                    }
                }];
                
//                UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"修改性别" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"男",@"女", nil];
//                actionSheet.tag = EditGenter;
//                [actionSheet showInView:self.view];
            }
                break;
            case 3: {   // 地区
                TSLocateView *locateView = [[TSLocateView alloc] initWithTitle:@"选择区域" delegate:self];
                [locateView showInView:self.view];
            }
                break;
            case 4: {   // 通讯地址
                UserAddressViewController *addressListVC = [[UserAddressViewController alloc] init];
                [self.navigationController pushViewController:addressListVC animated:YES];
            }
                break;
            case 5: {   // 个人签名
                UpdateDesViewController *updateDes = [[UpdateDesViewController alloc] init];
                updateDes.userDescription = _selfUser.signature;
                [updateDes saveAction:^(NSString *string) {
                    if ( ![string isEqualToString:_selfUser.signature] ) {
                        _selfUser.signature = string;
                        [weakSelf_SC netWorkRequestEditUserProfileWithDic:@{@"signature": _selfUser.signature}];
                    }
                }];
                
                [self.navigationController pushViewController:updateDes animated:YES];
            }
                break;
            default:
                break;
        }
    }
}


- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == EditGenter) {
//        NSString *gender = [actionSheet buttonTitleAtIndex:buttonIndex];
//        if (![_selfUser.sex isEqualToString:gender] && buttonIndex != 2) {
//            _selfUser.sex = gender;
//            [self netWorkRequestEditUserProfileWithDic:@{@"sex": _selfUser.sex}];
//        }
    } else if (actionSheet.tag == EditPhoto) {
//        if (buttonIndex == 0) {
//            // 拍照
//            if ([self isCameraAvailable] && [self doesCameraSupportTakingPhotos]) {
//                UIImagePickerController *controller = [[UIImagePickerController alloc] init];
//                controller.sourceType = UIImagePickerControllerSourceTypeCamera;
//                if ([self isFrontCameraAvailable]) {
//                    controller.cameraDevice = UIImagePickerControllerCameraDeviceFront;
//                }
//                NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
//                [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
//                controller.mediaTypes = mediaTypes;
//                controller.delegate = self;
//                [self presentViewController:controller
//                                   animated:YES
//                                 completion:^(void){
//                                     NSLog(@"Picker View Controller is presented");
//                                 }];
//            }
//            
//        } else if (buttonIndex == 1) {
//            // 从相册中选取
//            if ([self isPhotoLibraryAvailable]) {
//                UIImagePickerController *controller = [[UIImagePickerController alloc] init];
//                controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//                NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
//                [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
//                controller.mediaTypes = mediaTypes;
//                controller.delegate = self;
//                [self presentViewController:controller
//                                   animated:YES
//                                 completion:^(void){
//                                     NSLog(@"Picker View Controller is presented");
//                                 }];
//            }
//        }
    } else {
        TSLocateView *locateView = (TSLocateView *)actionSheet;
        TSLocation *location = locateView.locate;
        
        if(buttonIndex == 0) {
            NSLog(@"Cancel");
        }else {
            if (![_selfUser.countryName isEqualToString:location.state] || ![_selfUser.cityName isEqualToString:location.city]) {
                _selfUser.countryName = location.state;
                _selfUser.cityName = location.city;
                _selfUser.area = [NSString stringWithFormat:@"%@%@", location.state, location.city];
                [self netWorkRequestEditUserProfileWithDic:@{@"countryName": _selfUser.countryName, @"cityName": _selfUser.cityName}];
            }
        }
    }
}

#pragma mark 更新信息--网络
#pragma mark 修改用户资料
- (void)netWorkRequestEditUserProfileWithDic:(NSDictionary *)dic
{
    @try {
        WeakSelf
        [self showStatusBarQueryStr:@"更新中..."];
        [self.currentRequest addObject:[[logicShareInstance getUserManager] updateInfoWithPhone:dic success:^(id responseObject) {
            
            // 重新保存用户数据
            [CURRENT_USER_INSTANCE updateCurrentUser:_selfUser];
            
            [weakSelf_SC showStatusBarSuccessStr:@"更新成功!"];
            // 重载数据
            [weakSelf_SC reloadUserInfo];
            
        } failure:^(NSString *error) {
            [weakSelf_SC showStatusBarError:error];
        }]];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    };
}




#pragma mark 修改头像
// =======================================================================================
- (void)editPortrait {
//    UIActionSheet *choiceSheet = [[UIActionSheet alloc] initWithTitle:nil
//                                                             delegate:self
//                                                    cancelButtonTitle:@"取消"
//                                               destructiveButtonTitle:nil
//                                                    otherButtonTitles:@"拍照", @"从相册中选取", nil];
//    choiceSheet.tag = EditPhoto;
//    [choiceSheet showInView:self.view];
//    
    [SMActionSheet showSheetWithTitle:@"请选择" buttonTitles:@[@"拍照", @"从相册中选择"] redButtonIndex:2 completionBlock:^(NSUInteger buttonIndex, SMActionSheet *actionSheet) {
        if (buttonIndex == 0) {
            // 拍照
            if ([self isCameraAvailable] && [self doesCameraSupportTakingPhotos]) {
                UIImagePickerController *controller = [[UIImagePickerController alloc] init];
                controller.sourceType = UIImagePickerControllerSourceTypeCamera;
                if ([self isFrontCameraAvailable]) {
                    controller.cameraDevice = UIImagePickerControllerCameraDeviceFront;
                }
                NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
                [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
                controller.mediaTypes = mediaTypes;
                controller.delegate = self;
                [self presentViewController:controller
                                   animated:YES
                                 completion:^(void){
                                     NSLog(@"Picker View Controller is presented");
                                 }];
            }
            
        } else if (buttonIndex == 1) {
            // 从相册中选取
            if ([self isPhotoLibraryAvailable]) {
                UIImagePickerController *controller = [[UIImagePickerController alloc] init];
                controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
                [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
                controller.mediaTypes = mediaTypes;
                controller.delegate = self;
                [self presentViewController:controller
                                   animated:YES
                                 completion:^(void){
                                     NSLog(@"Picker View Controller is presented");
                                 }];
            }
        }
    }];
}

#pragma mark VPImageCropperDelegate
- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage {
    WeakSelf
    NSMutableArray *imageArr = [NSMutableArray arrayWithCapacity:1];
    [imageArr addObject:editedImage];
    
    [self showStatusBarQueryStr:@"图片上载中..."];
    [[logicShareInstance getUploadManager] UpLoadImageWithUIImage:imageArr type:UploadTypeOfAvatar success:^(NSArray *QNImageEntityArray) {
        
        QNImageEntity *qnImage = [QNImageEntityArray firstObject];
        _selfUser.avatar = qnImage.imageURL;
        [weakSelf_SC netWorkRequestEditUserProfileWithDic:@{@"avatar": qnImage.imageURL}];
    } failure:^(NSString *error) {
        [weakSelf_SC showStatusBarError:@"更改头像失败,请重新上传!"];
    } progress:^(CGFloat pro) {
        [weakSelf_SC showStatusBarProgress:pro];
    }];
    
    [cropperViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController {
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^() {
        UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        portraitImg = [self imageByScalingToMaxSize:portraitImg];
        // present the cropper view controller
        VPImageCropperViewController *imgCropperVC = [[VPImageCropperViewController alloc] initWithImage:portraitImg cropFrame:CGRectMake(0, 100.0f, self.view.frame.size.width, self.view.frame.size.width) limitScaleRatio:3.0];
        imgCropperVC.delegate = self;
        [self presentViewController:imgCropperVC animated:YES completion:^{
            
        }];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^(){
    }];
}

#pragma mark image scale utility
- (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage {
    if (sourceImage.size.width < ORIGINAL_MAX_WIDTH) return sourceImage;
    CGFloat btWidth = 0.0f;
    CGFloat btHeight = 0.0f;
    if (sourceImage.size.width > sourceImage.size.height) {
        btHeight = ORIGINAL_MAX_WIDTH;
        btWidth = sourceImage.size.width * (ORIGINAL_MAX_WIDTH / sourceImage.size.height);
    } else {
        btWidth = ORIGINAL_MAX_WIDTH;
        btHeight = sourceImage.size.height * (ORIGINAL_MAX_WIDTH / sourceImage.size.width);
    }
    CGSize targetSize = CGSizeMake(btWidth, btHeight);
    return [self imageByScalingAndCroppingForSourceImage:sourceImage targetSize:targetSize];
}

- (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize {
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil) NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
}

#pragma mark camera utility
- (BOOL) isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isRearCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

- (BOOL) isFrontCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

- (BOOL) doesCameraSupportTakingPhotos {
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isPhotoLibraryAvailable{
    return [UIImagePickerController isSourceTypeAvailable:
            UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickVideosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeMovie sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickPhotosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (BOOL) cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType{
    __block BOOL result = NO;
    if ([paramMediaType length] == 0) {
        return NO;
    }
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]){
            result = YES;
            *stop= YES;
        }
    }];
    return result;
}

// =======================================================================================

@end
