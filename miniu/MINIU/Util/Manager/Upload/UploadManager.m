//
//  UploadManager.m
//  miniu
//
//  Created by SimMan on 4/25/15.
//  Copyright (c) 2015 SimMan. All rights reserved.
//

#import "UploadManager.h"
#import "QiniuSDK.h"
#import "NSUserDefaults+Category.h"
#import <AssetsLibrary/AssetsLibrary.h>

#define GET_QINIU_UPLOAD_TOKEN @"qiniu.upload"

#define QINIU_UPLOAD_TOKEN_NAME @"QINIU_UPLOAD_TOKEN_NAME"
#define QINIU_UPLOAD_TOKEN_EXPTIME @"QINIU_UPLOAD_TOKEN_EXPTIME"

@interface UploadManager() <QNRecorderDelegate>

@property (nonatomic, strong) NSTimer *time;
@property (nonatomic, strong) QNUploadManager *uploadManager;

@end

@implementation UploadManager

+ (instancetype)shareInstance
{
    static UploadManager * instance;
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
        
        _uploadManager = [QNUploadManager sharedInstanceWithRecorder:self recorderKeyGenerator:^NSString *(NSString *uploadKey, NSString *filePath) {
            NSLog(@"uploadKey: %@, filePath: %@", uploadKey, filePath);
            return [NSString stringWithFormat:@"%@%@%@", uploadKey, filePath, [NSString timeStamp]];
        }];
    }
    return self;
}

- (void)UpLoadImageWithUIImage:(NSArray *)images type:(UploadType)tp success:(void (^)(NSArray *))success failure:(void (^)(NSString *))failure progress:(void (^)(CGFloat))progress
{
    int i = 0;  // 图片的索引
    __block int j = 0;  // 已完成的图片数量

    WeakSelf
    long imageCount = [images count];

    NSMutableArray *imageUrlData = [NSMutableArray array];
    for (int i = 0; i < imageCount; i ++) {
        [imageUrlData addObject:@""];
    }
    
    for (id imgObj in images) {
        
        UIImage *newImage;
        if ([imgObj isKindOfClass:[UIImage class]]) {
            UIImage *img = (UIImage *)imgObj;
            if (img.size.width > 1400) {
                newImage = [img scaledToSize:CGSizeMake(1334, 750)];
            } else {
                newImage = img;
            }
        } else if ([imgObj isKindOfClass:[ALAsset class]]) {
            CGImageRef imgRef = [[imgObj defaultRepresentation] fullScreenImage];
            newImage = [UIImage imageWithCGImage:imgRef];
        }
        
        // 转换图片为 NSData
        NSData *imageData = UIImageJPEGRepresentation(newImage, 0.8);
        
        // 可选参数集合
        QNUploadOption *option = [[QNUploadOption alloc] initWithMime:nil progressHandler:^(NSString *key, float percent) {
            float per = (j + percent) /imageCount;
            progress(per);
        } params:@{@"x:index":[NSString stringWithFormat:@"%d", i] } checkCrc:NO cancellationSignal:nil];
        
        NSString *fileName = [self getSaveKeyWithType:tp];

        // 检查Token
        if (![self getQiniuUploadToken]) {
            failure(@"获取上传秘钥失败,请重试!");
            return;
        }
        
        
        // 开始上传
        [_uploadManager putData:imageData key:fileName token:[self getQiniuUploadToken] complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
            
            if (!resp) {
                
                failure(@"上传失败,请重试!");
                return;
            }
            
            j ++;
            
            // resp
            /*
             hash = "FsXvGPpeUDx-qlNGLbjhQeskFF3I";
             key = "20123123/asldkjfkalsjf/123123.png";
             "x:index" = 10000001;
             */
            
            // 获取图片的Index,Url
            NSString *imageIndex = [resp objectForKey:@"x:index"];
            NSString *imageUrl = [NSString stringWithFormat:@"%@/%@", QINIU_URL, key];
            
            QNImageEntity *imageEntity = [[QNImageEntity alloc] init];
            imageEntity.imageURL = imageUrl;
            
            // 按顺序替换
            [imageUrlData replaceObjectAtIndex:[imageIndex integerValue] withObject:imageEntity];
            
            if (j == imageCount) {
                success(imageUrlData);
            }
            
        } option:option];
        
        i ++;
    }
}

#pragma mark 根据图片类型获取保存的路径
-(NSString * )getSaveKeyWithType:(UploadType)type {
    
    NSString *typeDir = nil;
    
    switch (type) {
        case UploadTypeOfGoods:
            typeDir = @"Goods";
            break;
        case UploadTypeOfAvatar:
            typeDir = @"Avatar";
            break;
        case UploadTypeOfLife:
            typeDir = @"Life";
            break;
        case UploadTypeOfMessage:
            typeDir = @"Message";
        case UploadTypeOfUserFile:
            typeDir = @"UserFile";
        default:
            break;
    }
    return [NSString stringWithFormat:@"%@/%@%@", typeDir, [NSDate getDateDirName], [NSString timeStamp]];
}


- (NSString *) getQiniuUploadToken
{
    // 首先拿出Token
    NSString *expTime = [NSUSER_DEFAULT objForKey:QINIU_UPLOAD_TOKEN_EXPTIME];
    NSString *uploadToken = [NSUSER_DEFAULT objForKey:QINIU_UPLOAD_TOKEN_NAME];
    
    if (!expTime || [expTime longLongValue] + 80000 < [[NSString timeStamp] longLongValue]) {
        WeakSelf
        // 网络请求,得到 token
        
        [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:@{@"method": GET_QINIU_UPLOAD_TOKEN} success:^(NSURLSessionDataTask *task, id responseObject) {
            
            NSString *gToken = [NSString stringWithFormat:@"%@", responseObject[@"data"]];
            
            [NSUSER_DEFAULT setObj:[NSString timeStamp] forKey:QINIU_UPLOAD_TOKEN_EXPTIME];
            [NSUSER_DEFAULT setObj:gToken forKey:QINIU_UPLOAD_TOKEN_NAME];
            
        } failure:^(NSURLSessionDataTask *task, NSString *error) {
            NSLog(@"获取Token错误!");
        }];
    }
    
    if ([uploadToken isEqualToString:@""]) {
        return nil;
    }
    
    return uploadToken;
}

#pragma mark
#pragma mark logic层统一管理协议方法
- (void)load
{
    // 默认先执行一遍
    
    WeakSelf
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [weakSelf_SC getQiniuUploadToken];
    });
    
    // 这里初始化定时器,进行拉取 QiniuToken 数据
    [NSTimer bk_scheduledTimerWithTimeInterval:43200 block:^(NSTimer *timer) {
        [weakSelf_SC getQiniuUploadToken];
    } repeats:YES];
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

@implementation QNImageEntity

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.imageURL = @"";
    }
    return self;
}

@end
