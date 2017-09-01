//
//  AssetManager.m
//  DLDQ_IOS
//
//  Created by simman on 14-9-2.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

#define ASSET_PHOTO_THUMBNAIL           0
#define ASSET_PHOTO_ASPECT_THUMBNAIL    1
#define ASSET_PHOTO_SCREEN_SIZE         2
#define ASSET_PHOTO_FULL_RESOLUTION     3

@interface AssetManager : ManagerBase <LogicBaseModel>

@property (nonatomic, strong)   ALAssetsLibrary			*assetsLibrary;
@property (nonatomic, strong)   NSMutableArray          *assetPhotos;
@property (nonatomic, strong)   NSMutableArray          *assetGroups;

@property (readwrite)           BOOL                    bReverse;

+ (instancetype)shareInstance;

// get album list from asset
- (void)getGroupList:(void (^)(NSArray *array))result;
// get maxnum group of photo
- (void)getMaxNumGroupPhotos:(void (^)(NSArray *array))result;
// get photos from specific album with ALAssetsGroup object
- (void)getPhotoListOfGroup:(ALAssetsGroup *)alGroup result:(void (^)(NSArray *array))result;
// get photos from specific album with index of album array
- (void)getPhotoListOfGroupByIndex:(NSInteger)nGroupIndex result:(void (^)(NSArray *array))result;
// get photos from camera roll
- (void)getSavedPhotoList:(void (^)(NSArray *))result error:(void (^)(NSError *error))error;

- (NSInteger)getGroupCount;
- (NSInteger)getPhotoCountOfCurrentGroup;
- (NSDictionary *)getGroupInfo:(NSInteger)nIndex;

- (void)clearData;

// utils
- (UIImage *)getCroppedImage:(NSURL *)urlImage;
- (UIImage *)getImageFromAsset:(ALAsset *)asset type:(NSInteger)nType;
- (UIImage *)getImageAtIndex:(NSInteger)nIndex type:(NSInteger)nType;
- (ALAsset *)getAssetAtIndex:(NSInteger)nIndex;
- (ALAssetsGroup *)getGroupAtIndex:(NSInteger)nIndex;


/**
 *  @brief  保存图片到本地相册
 *
 *  @param image   图片
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void) saveImage:(UIImage *)image
           success:(void (^)(NSString *success))success
           failure:(void (^)(NSString *error))failure;


/**
 *  批量下图
 *
 *  @param imageUrls 
 */
- (void) saveImagesWithImageUrls:(NSArray *)imageUrls
                          isMark:(BOOL)mark
                         success:(void (^)(NSString *success))successBlock
                         failure:(void (^)(NSString *error))failureBlock;
@end

