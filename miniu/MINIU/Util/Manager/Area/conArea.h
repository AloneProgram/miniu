//
//  conArea.h
//  DLDQ_IOS
//
//  Created by simman on 14-5-19.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseModel.h"
@interface conArea : BaseModel

@property (nonatomic, retain) NSString *area_name;
@property (nonatomic, retain) NSString *area_en_name;
@property (nonatomic, retain) NSString *area_index;
@property (nonatomic, retain) NSString *area_num;

- (instancetype)initWitharea_en_name:(NSString *)area_en_name Area_name:(NSString *)area_name Area_index:(NSString *)area_index Area_num:(NSString *)area_num;

@end
