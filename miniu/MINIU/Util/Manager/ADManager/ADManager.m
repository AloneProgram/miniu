//
//  ADManager.m
//  DLDQ_IOS
//
//  Created by simman on 15/1/19.
//  Copyright (c) 2015年 Liwei. All rights reserved.
//

#import "ADManager.h"

#define API_LOAD_ADS    @{@"method": @"activity.model.one"}

@interface ADManager()

@property (nonatomic, copy) void (^block)(NSArray* ads);

@end

@implementation ADManager

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

+ (instancetype)shareInstance
{
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (void) refreshAdsWithTag:(NSString *)tagName block:(void (^)(NSArray *))block
{
    _block = block;
    
    NSDictionary *dic = @{@"tagName": [NSString stringWithFormat:@"%@", tagName], @"method": @"activity.model.one"};
    
    @try {
        [NET_WORK_HANDLE HttpRequestWithRequestType:POST parameters:dic success:^(NSURLSessionDataTask *task, id responseObject) {
            
            @try {
                
                NSMutableArray *dataArray = [NSMutableArray new];
                
                for (NSDictionary *dic in responseObject[@"data"]) {
                    
                    if (![dic isKindOfClass:[NSDictionary class]]) {
                        continue;
                    }
                    
                    ADentity *adentiy = [[ADentity alloc] init];
                    [adentiy setValuesForKeysWithDictionary:dic];
                    [dataArray addObject:adentiy];
                }
                
                if (_block) {
                    _block(dataArray);
                }
            }
            @catch (NSException *exception) {
                
            }
            @finally {
                
            }
            
        } failure:^(NSURLSessionDataTask *task, NSString *error) {}];
    }
    @catch (NSException *exception) {}
    @finally {}
}

- (void) doLoginSuccessfulLogic{}
- (void) load{}

@end


// --------------

@implementation ADentity

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.imageUrl = @"";
        self.linkedUrl = @"";
        self.depictRemark = @"";
        self.title = @"";
    }
    return self;
}

@end