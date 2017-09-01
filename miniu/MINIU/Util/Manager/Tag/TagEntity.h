//
//  TagEntity.h
//  DLDQ_IOS
//
//  Created by simman on 14-9-2.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import "BaseModel.h"

@interface TagEntity : BaseModel

@property (nonatomic, strong) NSString *value;      // 标签名
@property (nonatomic, strong) NSNumber *status;     // 是否选中

@end
