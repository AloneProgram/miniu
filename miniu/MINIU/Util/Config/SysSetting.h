//
//  SysSetting.h
//  DLDQ_IOS
//
//  Created by simman on 14-8-19.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#ifndef DLDQ_IOS_SysSetting_h
#define DLDQ_IOS_SysSetting_h

// ----------------------------------- UI界面 -----------------------------

//图片的宏定义
#define QINIU_URL @"http://mnstatic.dldq.org"

#define LoadImage(file,ext) [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:file ofType:ext]]

// 区分Target
#if TARGET_VERSION_LITE == 1

#define TARGET_IS_MINIU 1
#define TARGET_IS_MINIU_BUYER 0

#elif TARGET_VERSION_LITE == 2

#define TARGET_IS_MINIU 0
#define TARGET_IS_MINIU_BUYER 1

#endif


// 推送
#define JPUSH_SENDID @"jpush_send_id"                       // sendId的key


//字体
#define LaMaFont11 [UIFont fontWithName:@"Arial" size:11.0f]
#define LaMaFont12 [UIFont fontWithName:@"Arial" size:12.0f]
#define LaMaFont14 [UIFont fontWithName:@"Arial" size:14.0f]
#define LaMaFont16 [UIFont fontWithName:@"Arial" size:16.0f]
#define LaMaFont18 [UIFont fontWithName:@"Arial" size:18.0f]
#define LaMaFont20 [UIFont fontWithName:@"Arial" size:20.0f]

// 各种尺寸
#define NavHeight  ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] == NSOrderedAscending ? 44.0f : 64.0f)
#define IS_IOS7 ([[[UIDevice currentDevice] systemVersion] floatValue]>=7.0)
#define IS_IOS8 ([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0)
#define IS_IPHONE6PLUS  ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO)
#define IS_IPAD UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad

#define TabBarHeight 25

#define Main_Height ([UIScreen mainScreen].bounds.size.height - 108)
#define ScrollView_Main_height (Main_Height + 49)
#define Main_Width 320

#define CURRENT_WINDOW_SIZE [UIScreen mainScreen].bounds.size

// 颜色
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]  // 从 Rgb 获取颜色

#define FlatButtonColor [UIColor colorWithRed:0.204 green:0.706 blue:0.365 alpha:1]


#import "AppDelegate.h"
#define GETMAINDELEGATE (AppDelegate *)[UIApplication sharedApplication].delegate

// --------------------------------- 客户端 ---------------------------------

// 常用方法
#define MAIN_DELEGATE (AppDelegate *)[UIApplication sharedApplication].delegate     // 全局Delegate
#define NET_WORK_HANDLE [NetWorkHandle sharedClient] // 网络
#define NSUSER_DEFAULT [NSUserDefaults standardUserDefaults]  // NSUserDefault
#define PATH_OF_APP_HOME    NSHomeDirectory()
#define PATH_OF_TEMP        NSTemporaryDirectory()
#define PATH_OF_DOCUMENT    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define PATH_OF_LIBRARY    [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define FILE_MANAGER    [NSFileManager defaultManager]


#define WeakSelf __weak __typeof(&*self)weakSelf_SC = self;


//常用变量
#define DebugLog(s, ...) NSLog(@"%s(%d): %@", __FUNCTION__, __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__])
#define kTipAlert(_S_, ...)     [[[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:(_S_), ##__VA_ARGS__] delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil] show]

#define kKeyWindow [UIApplication sharedApplication].keyWindow

#define kHigher_iOS_6_1 (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
#define kHigher_iOS_6_1_DIS(_X_) ([[NSNumber numberWithBool:kHigher_iOS_6_1] intValue] * _X_)
#define kNotHigher_iOS_6_1_DIS(_X_) (-([[NSNumber numberWithBool:kHigher_iOS_6_1] intValue]-1) * _X_)

#define kDevice_Is_iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define kDevice_Is_iPhone6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : NO)
#define kDevice_Is_iPhone6Plus ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO)

#define kScreen_Bounds [UIScreen mainScreen].bounds
#define kScreen_Height [UIScreen mainScreen].bounds.size.height
#define kScreen_Width [UIScreen mainScreen].bounds.size.width
#define kPaddingLeftWidth 15.0
#define kLoginPaddingLeftWidth 18.0
#define kMySegmentControl_Height 44.0
#define kMySegmentControlIcon_Height 70.0

#define  kBackButtonFontSize 16
#define  kNavTitleFontSize 19
#define  kBadgeTipStr @"badgeTip"

#define kDefaultLastId [NSNumber numberWithInteger:99999999]

#define kColor999 [UIColor colorWithHexString:@"0x999999"]
#define kColorTableBG [UIColor colorWithHexString:@"0xfafafa"]
#define kColorTableSectionBg [UIColor colorWithHexString:@"0xe5e5e5"]

#define kImage999 [UIImage imageWithColor:kColor999]

#define kPlaceholderMonkeyRoundWidth(_width_) [UIImage imageNamed:[NSString stringWithFormat:@"placeholder_monkey_round_%.0f", _width_]]
#define kPlaceholderMonkeyRoundView(_view_) [UIImage imageNamed:[NSString stringWithFormat:@"placeholder_monkey_round_%.0f", CGRectGetWidth(_view_.frame)]]

#define kPlaceholderCodingSquareWidth(_width_) [UIImage imageNamed:[NSString stringWithFormat:@"placeholder_coding_square_%.0f", _width_]]
#define kPlaceholderCodingSquareView(_view_) [UIImage imageNamed:[NSString stringWithFormat:@"placeholder_coding_square_%.0f", CGRectGetWidth(_view_.frame)]]

#define kScaleFrom_iPhone5_Desgin(_X_) (_X_ * (kScreen_Width/320))

#define kUnReadKey_messages @"messages"
#define kUnReadKey_notifications @"notifications"
#define kUnReadKey_project_update_count @"project_update_count"
#define kUnReadKey_notification_AT @"notification_at"
#define kUnReadKey_notification_Comment @"notification_comment"
#define kUnReadKey_notification_System @"notification_system"

//链接颜色
#define kLinkAttributes     @{(__bridge NSString *)kCTUnderlineStyleAttributeName : [NSNumber numberWithBool:NO],(NSString *)kCTForegroundColorAttributeName : (__bridge id)[UIColor colorWithHexString:@"0x3bbd79"].CGColor}
#define kLinkAttributesActive       @{(NSString *)kCTUnderlineStyleAttributeName : [NSNumber numberWithBool:NO],(NSString *)kCTForegroundColorAttributeName : (__bridge id)[[UIColor colorWithHexString:@"0x1b9d59"] CGColor]}


#define kTaskPrioritiesDisplay @[@"有空再看", @"正常处理", @"优先处理", @"十万火急"]


///=============================================
/// @name Weak Object
///=============================================
#pragma mark - Weak Object

/**
 * @code
 * ESWeak(imageView, weakImageView);
 * [self testBlock:^(UIImage *image) {
 *         ESStrong(weakImageView, strongImageView);
 *         strongImageView.image = image;
 * }];
 *
 * // `ESWeak_(imageView)` will create a var named `weak_imageView`
 * ESWeak_(imageView);
 * [self testBlock:^(UIImage *image) {
 *         ESStrong_(imageView);
 * 	_imageView.image = image;
 * }];
 *
 * // weak `self` and strong `self`
 * ESWeakSelf;
 * [self testBlock:^(UIImage *image) {
 *         ESStrongSelf;
 *         _self.image = image;
 * }];
 * @endcode
 */

#define ESWeak(var, weakVar) __weak __typeof(&*var) weakVar = var
#define ESStrong_DoNotCheckNil(weakVar, _var) __typeof(&*weakVar) _var = weakVar
#define ESStrong(weakVar, _var) ESStrong_DoNotCheckNil(weakVar, _var); if (!_var) return;

#define ESWeak_(var) ESWeak(var, weak_##var);
#define ESStrong_(var) ESStrong(weak_##var, _##var);

/** defines a weak `self` named `__weakSelf` */
#define ESWeakSelf      ESWeak(self, __weakSelf);
/** defines a strong `self` named `_self` from `__weakSelf` */
#define ESStrongSelf    ESStrong(__weakSelf, _self);



// ----------------------  环信相关

#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define KNOTIFICATION_LOGINCHANGE @"loginStateChange"
#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]
#define KNOTIFICATION_LOGINCHANGE @"loginStateChange"
#define CHATVIEWBACKGROUNDCOLOR [UIColor colorWithRed:0.936 green:0.932 blue:0.907 alpha:1]

#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

typedef enum _BasicViewControllerInfo {
    eBasicControllerInfo_Title,
    eBasicControllerInfo_ImageName,
    eBasicControllerInfo_BadgeString
}BasicViewControllerInfo;



#pragma mark - runtime macros
// check if runs on iPad
#define IS_IPAD_RUNTIME (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

// version check
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:       NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:       NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:       NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:       NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:       NSNumericSearch] != NSOrderedDescending)

#define NTF_WILLSENDMESSAGETOJID                @"NTF_WILLSENDMESSAGETOJID"
#define WILLSENDMESSAGETOJID                    @"WILLSENDMESSAGETOJID"
#define WILLSENDMESSAGETOJID_CHATROOMMESSAGE    @"WILLSENDMESSAGETOJID_CHATROOMMESSAGE"
#define WILLSENDMESSAGETOJID_CHATDATA           @"WILLSENDMESSAGETOJID_CHATDATA"

#define NTF_FINISHED_LOAD_DATA_FROM_DB  @"NTF_FINISHED_LOAD_DATA_FROM_DB"

// used in settings.
typedef enum _playSoundMode {
    ePlaySoundMode_AutoDetect,
    ePlaySoundMode_Speaker,
    ePlaySoundMode_Handset
}PlaySoundMode;

#endif
