//
//  UploadManager.h
//  miniu
//
//  Created by SimMan on 4/25/15.
//  Copyright (c) 2015 SimMan. All rights reserved.
//

#import "ManagerBase.h"
#import "BaseModel.h"

typedef NS_ENUM(NSInteger, UploadType) {
    UploadTypeOfGoods,
    UploadTypeOfAvatar,
    UploadTypeOfLife,
    UploadTypeOfMessage,
    UploadTypeOfUserFile
};

@interface UploadManager : ManagerBase <LogicBaseModel>

/**
 *  @brief  单例
 *
 *  @return 
 */
+ (instancetype)shareInstance;



/**
 *  上传图片
 *
 *  @param imageArr 图片数组
 *  @param tp       图片类型
 *  @param success  成功回调
 *  @param failure  失败回调
 *  @param progress 返回进度
 */
- (void)UpLoadImageWithUIImage:(NSArray *)imageArr type:(UploadType)tp
                       success:(void (^)(NSArray *QNImageEntityArray))success
                       failure:(void (^)(NSString *error))failure
                      progress:(void (^)(CGFloat pro))progress;

@end


@interface QNImageEntity : BaseModel

@property (nonatomic, strong) NSString *imageURL;

@end