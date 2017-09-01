//
//  AssetManager.m
//  DLDQ_IOS
//
//  Created by simman on 14-9-2.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import "AssetManager.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "SDWebImageDownloader.h"

@interface AssetManager()
@property (nonatomic, strong)   NSMutableArray          *maxGroupPhotos;
@property (nonatomic, assign)   BOOL                    updateAlassetLibrary;
@property (nonatomic, strong)   ALAssetsGroup           *miniuGroup;
@end

@implementation AssetManager

+ (instancetype)shareInstance
{
    static AssetManager * instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAlassetLibrary) name:ALAssetsLibraryChangedNotification object:nil];
        _bReverse = YES;
        _updateAlassetLibrary = NO;
    }
    return self;
}

- (ALAssetsLibrary *)assetsLibrary
{
    if (!_assetsLibrary) {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    return _assetsLibrary;
}

//- (void) updateAlassetLibrary
//{
//    _updateAlassetLibrary = YES;
//}

/**
 *  @brief  获取相册列表
 *
 *  @param result
 */
- (void)getGroupList:(void (^)(NSArray *))result
{
    _assetGroups = [[NSMutableArray alloc] init];
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        
        if (group == nil)
        {
            if (_bReverse)
                _assetGroups = [[NSMutableArray alloc] initWithArray:[[_assetGroups reverseObjectEnumerator] allObjects]];
            // end of enumeration
            if (result) {
                result(_assetGroups);
            }
            return;
        }
        NSLog(@"%@", group);
        
        NSString* groupname = [group valueForProperty:ALAssetsGroupPropertyName];
        if ([groupname isEqualToString:@"米妞"]) {
            self.miniuGroup = group;
        }
        
        [_assetGroups addObject:group];
        
    } failureBlock:^(NSError *error) {
        NSLog(@"Error : %@", [error description]);
    }];
    
}

/**
 *  @brief  根据 相册 获取图片列表
 *
 *  @param alGroup 相册
 *  @param result
 */
- (void)getPhotoListOfGroup:(ALAssetsGroup *)alGroup result:(void (^)(NSArray *))result
{
    _assetPhotos = [[NSMutableArray alloc] init];
    [alGroup setAssetsFilter:[ALAssetsFilter allPhotos]];
    [alGroup enumerateAssetsUsingBlock:^(ALAsset *alPhoto, NSUInteger index, BOOL *stop) {
        
        if(alPhoto == nil)
        {
            if (_bReverse)
                _assetPhotos = [[NSMutableArray alloc] initWithArray:[[_assetPhotos reverseObjectEnumerator] allObjects]];
            
            if (result) {
                result(_assetPhotos);
            }
            return;
        }
        
        [_assetPhotos addObject:alPhoto];
    }];
}

- (void) getMiniuLastPhoto
{
    [self getPhotoListOfGroup:self.miniuGroup result:^(NSArray *array) {
        
    }];
}


/**
 *  @brief  根据 相册 索引获取图片列表
 *
 *  @param nGroupIndex 相册索引
 *  @param result      图片列表
 */
- (void)getPhotoListOfGroupByIndex:(NSInteger)nGroupIndex result:(void (^)(NSArray *))result
{
    [self getPhotoListOfGroup:_assetGroups[nGroupIndex] result:^(NSArray *aResult) {
        if (result) {
            result(_assetPhotos);
        }
    }];
}

/**
 *  @brief  获取 保存的相册图片列表
 *
 *  @param result
 *  @param error
 */
- (void)getSavedPhotoList:(void (^)(NSArray *))result error:(void (^)(NSError *))error
{
    dispatch_async(dispatch_get_main_queue(), ^{

        void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop)
        {
            if ([[group valueForProperty:@"ALAssetsGroupPropertyType"] intValue] == ALAssetsGroupSavedPhotos)
            {
                [group setAssetsFilter:[ALAssetsFilter allPhotos]];

                [group enumerateAssetsUsingBlock:^(ALAsset *alPhoto, NSUInteger index, BOOL *stop) {
                    
                    if(alPhoto == nil)
                    {
                        if (_bReverse)
                            _assetPhotos = [[NSMutableArray alloc] initWithArray:[[_assetPhotos reverseObjectEnumerator] allObjects]];
                        
                        result(_assetPhotos);
                        return;
                    }
                    
                    [_assetPhotos addObject:alPhoto];
                }];
            }
        };
        
        void (^assetGroupEnumberatorFailure)(NSError *) = ^(NSError *err)
        {
            NSLog(@"Error : %@", [err description]);
            error(err);
        };
        
        _assetPhotos = [[NSMutableArray alloc] init];
        [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                                      usingBlock:assetGroupEnumerator
                                    failureBlock:assetGroupEnumberatorFailure];
    });
}

/**
 *  @brief  获取相册数量
 *
 *  @return
 */
- (NSInteger)getGroupCount
{
    return _assetGroups.count;
}

/**
 *  @brief  获取所有的图片数量
 *
 *  @return
 */
- (NSInteger)getPhotoCountOfCurrentGroup
{
    return _assetPhotos.count;
}

/**
 *  @brief  根据 相册 索引获取相册信息
 *
 *  @param nIndex 相册索引
 *
 *  @return name、count
 */
- (NSDictionary *)getGroupInfo:(NSInteger)nIndex
{
    return @{@"name" : [_assetGroups[nIndex] valueForProperty:ALAssetsGroupPropertyName],
             @"count" : @([_assetGroups[nIndex] numberOfAssets])};
}

/**
 *  @brief  清空数据
 */
- (void)clearData
{
	_assetGroups = nil;
	_assetPhotos = nil;
}

#pragma mark - utils
- (UIImage *)getCroppedImage:(NSURL *)urlImage
{
    __block UIImage *iImage = nil;
    __block BOOL bBusy = YES;
    
    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
    {
        ALAssetRepresentation *rep = [myasset defaultRepresentation];
        NSString *strXMP = rep.metadata[@"AdjustmentXMP"];
        if (strXMP == nil || [strXMP isKindOfClass:[NSNull class]])
        {
            CGImageRef iref = [rep fullResolutionImage];
            if (iref)
                iImage = [UIImage imageWithCGImage:iref scale:1.0 orientation:(UIImageOrientation)rep.orientation];
            else
                iImage = nil;
        }
        else
        {
            // to get edited photo by photo app
            NSData *dXMP = [strXMP dataUsingEncoding:NSUTF8StringEncoding];
            
            CIImage *image = [CIImage imageWithCGImage:rep.fullResolutionImage];
            
            NSError *error = nil;
            NSArray *filterArray = [CIFilter filterArrayFromSerializedXMP:dXMP
                                                         inputImageExtent:image.extent
                                                                    error:&error];
            if (error) {
                NSLog(@"Error during CIFilter creation: %@", [error localizedDescription]);
            }
            
            for (CIFilter *filter in filterArray) {
                [filter setValue:image forKey:kCIInputImageKey];
                image = [filter outputImage];
            }
            
            iImage = [UIImage imageWithCIImage:image scale:1.0 orientation:(UIImageOrientation)rep.orientation];
        }
        
		bBusy = NO;
    };
    
    ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror)
    {
        NSLog(@"booya, cant get image - %@",[myerror localizedDescription]);
    };
    
    [self.assetsLibrary assetForURL:urlImage
                    resultBlock:resultblock
                   failureBlock:failureblock];
    
	while (bBusy)
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    
    return iImage;
}

/**
 *  @brief  在图片资源中获取图片（各种类型）
 *
 *  @param asset 图片资源
 *  @param nType 封面、照片全屏图 、照片全尺寸图
 *
 *  @return
 */
- (UIImage *)getImageFromAsset:(ALAsset *)asset type:(NSInteger)nType
{
    CGImageRef iRef = nil;
    
    if (nType == ASSET_PHOTO_THUMBNAIL)
        iRef = [asset thumbnail];
    else if (nType == ASSET_PHOTO_ASPECT_THUMBNAIL)
        iRef = [asset aspectRatioThumbnail];
    else if (nType == ASSET_PHOTO_SCREEN_SIZE)
        iRef = [asset.defaultRepresentation fullScreenImage];
    else if (nType == ASSET_PHOTO_FULL_RESOLUTION)
    {
        NSString *strXMP = asset.defaultRepresentation.metadata[@"AdjustmentXMP"];
        if (strXMP == nil || [strXMP isKindOfClass:[NSNull class]])
        {
            iRef = [asset.defaultRepresentation fullResolutionImage];
            return [UIImage imageWithCGImage:iRef scale:1.0 orientation:(UIImageOrientation)asset.defaultRepresentation.orientation];
        }
        else
        {
            NSData *dXMP = [strXMP dataUsingEncoding:NSUTF8StringEncoding];
            
            CIImage *image = [CIImage imageWithCGImage:asset.defaultRepresentation.fullResolutionImage];
            
            NSError *error = nil;
            NSArray *filterArray = [CIFilter filterArrayFromSerializedXMP:dXMP
                                                         inputImageExtent:image.extent
                                                                    error:&error];
            if (error) {
                NSLog(@"Error during CIFilter creation: %@", [error localizedDescription]);
            }
            
            for (CIFilter *filter in filterArray) {
                [filter setValue:image forKey:kCIInputImageKey];
                image = [filter outputImage];
            }
            
            UIImage *iImage = [UIImage imageWithCIImage:image scale:1.0 orientation:(UIImageOrientation)asset.defaultRepresentation.orientation];
            return iImage;
        }
    }
    
    return [UIImage imageWithCGImage:iRef];
}

- (void)getMaxNumGroupPhotos:(void (^)(NSArray *))result
{
    WeakSelf
    NSLog(@"获取最多的图片...");
    if ([_maxGroupPhotos count]) {
        
        NSLog(@"已经生成了,直接返回....");
        if (result) {
            result(_maxGroupPhotos);
        }
    } else {
        // 默认当前已经有相册数组了.
        NSLog(@"从相册里加载....");
        if ([self getGroupCount]) {
            [self getPhotoListOfGroupByIndex:0 result:^(NSArray *array) {
                if (result) {
                    result(array);
                }
            }];
        } else {
            [[logicShareInstance getAssetManager] getGroupList:^(NSArray *array) {
                // 加载完相册,在加载所有的图片
                NSLog(@"开始加载图片最多相册的图片列表...");
                [weakSelf_SC getPhotoListOfGroupByIndex:0 result:^(NSArray *array) {
                    weakSelf_SC.maxGroupPhotos = [NSMutableArray arrayWithArray:array];
                    if (result) {
                        result(array);
                    }
                }];
            }];
        }
    }
}

- (UIImage *)getImageAtIndex:(NSInteger)nIndex type:(NSInteger)nType
{
    return [self getImageFromAsset:(ALAsset *)_assetPhotos[nIndex] type:nType];
}

- (ALAsset *)getAssetAtIndex:(NSInteger)nIndex
{
    return _assetPhotos[nIndex];
}

- (ALAssetsGroup *)getGroupAtIndex:(NSInteger)nIndex
{
    return _assetGroups[nIndex];
}


- (void) saveImage:(UIImage *)image
           success:(void (^)(NSString *))success
           failure:(void (^)(NSString *))failure
{

    if (!image && failure) {
        failure(@"图片不能为空!");
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //        UIImageWriteToSavedPhotosAlbum(self.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        
        [self.assetsLibrary saveImage:image toAlbum:@"米妞" withCompletionBlock:^(NSError *error) {
            if (error) {
                if (failure) {
                    failure(@"创建相册失败,请前往手机设置里授权'米妞'!");
                }
            } else {
                if (success) {
                    success(@"成功保存到相册!");
                }
            }
        }];
        
    });
}

- (void) saveImagesWithImageUrls:(NSArray *)imageUrls
                          isMark:(BOOL)mark
                         success:(void (^)(NSString *))successBlock
                         failure:(void (^)(NSString *))failureBlock
{
    NSInteger imageCount = [imageUrls count];
    
    if (!imageCount) {
        failureBlock(@"没有图片！");
        return;
    }
    
    [self showStatusBarQueryStr:@"正在下载图片..."];
    __block NSInteger i = 0;
    WeakSelf
    for (NSString *imageUrlStr in imageUrls) {
        NSURL *imageURL = [NSURL URLWithString:imageUrlStr];
        
        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:imageURL options:SDWebImageDownloaderContinueInBackground progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
            i ++;
            [self saveImage:image success:nil failure:nil];
            if (imageCount == i) {
                if (successBlock) {
                    [weakSelf_SC showStatusBarSuccessStr:@"下载完成!"];
                    successBlock(@"");
                }
            }
        }];
    }
}


+ (BOOL)checkPhotoLibraryAuthorizationStatus:(BOOL)tips
{
#if !TARGET_IPHONE_SIMULATOR
//    if ([ALAssetsLibrary respondsToSelector:@selector(authorizationStatus)]) {
        ALAuthorizationStatus authStatus = [ALAssetsLibrary authorizationStatus];
        if (ALAuthorizationStatusDenied == authStatus ||
            ALAuthorizationStatusRestricted == authStatus) {
            if (tips) {
                [self showSettingAlertStr:@"请在iPhone的“设置->隐私->照片”中打开本应用的访问权限"];
            }
            return NO;
        }
//    }
#endif
    return YES;
}

+ (BOOL)checkCameraAuthorizationStatus
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        kTipAlert(@"该设备不支持拍照");
        return NO;
    }
    
    if ([AVCaptureDevice respondsToSelector:@selector(authorizationStatusForMediaType:)]) {
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (AVAuthorizationStatusDenied == authStatus ||
            AVAuthorizationStatusRestricted == authStatus) {
            [self showSettingAlertStr:@"请在iPhone的“设置->隐私->相机”中打开本应用的访问权限"];
            return NO;
        }
    }
    
    return YES;
}

+ (void)showSettingAlertStr:(NSString *)tipStr{
    //iOS8+系统下可跳转到‘设置’页面，否则只弹出提示窗即可
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1) {
        UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:@"提示" message:tipStr];
        [alertView bk_setCancelButtonWithTitle:@"取消" handler:nil];
        [alertView bk_addButtonWithTitle:@"设置" handler:nil];
        [alertView bk_setDidDismissBlock:^(UIAlertView *alert, NSInteger index) {
            if (index == 1) {
                UIApplication *app = [UIApplication sharedApplication];
                NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if ([app canOpenURL:settingsURL]) {
                    [app openURL:settingsURL];
                }
            }
        }];
        [alertView show];
    }else{
        kTipAlert(@"%@", tipStr);
    }
}

#pragma mark
#pragma mark logic层统一管理协议方法
- (void)load
{
    // 检查是否有权限访问相册,如果有,那么就加载所有的资源
    if ([[self class] checkPhotoLibraryAuthorizationStatus:NO]) {
        // 加载所有的相册
        WeakSelf
        [[logicShareInstance getAssetManager] getGroupList:^(NSArray *array) {
            // 加载完相册,在加载所有的图片
            [weakSelf_SC getPhotoListOfGroupByIndex:0 result:^(NSArray *array) {
                weakSelf_SC.maxGroupPhotos = [NSMutableArray arrayWithArray:array];
            }];
        }];
    }
}
- (void)loadUserData{}
- (void)save{}
- (void)reset{}
- (void)enterBackgroundMode{}
- (void)enterForeground{}
- (void)doLoginSuccessfulLogic{}
- (void)doLogoutLogic{}
- (void)disconnectNet{}

@end
