//
//  BaiduTj.h
//  DLDQ_IOS
//
//  Created by simman on 14-7-6.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaiduMobStat.h"
@interface BaiduTj : NSObject


/**
 *  百度统计管理的实例
 *
 *  @return
 */
+ (instancetype)shareInstance;

/**
 *  百度统计设置
 *
 *  @param launchOptions
 */
- (void)baiduTjSettingLaunching;


//-(void) viewDidAppear:(BOOL)animated
//{
//    
//    NSString* cName = [NSString stringWithFormat:@"%@",  self.tabBarItem.title, nil];
//    [[BaiduMobStat defaultStat] pageviewStartWithName:cName];
//    
//}
//
//-(void) viewDidDisappear:(BOOL)animated
//{
//    NSString* cName = [NSString stringWithFormat:@"%@", self.tabBarItem.title, nil];
//    [[BaiduMobStat defaultStat] pageviewEndWithName:cName];
//}

/**
 BaiduMobStat* statTracker = [BaiduMobStat defaultStat];
 [statTracker logEvent:@"TabClick3" eventLabel:[NSString stringWithFormat: @"Tab%d", index]];
 **/

@end
