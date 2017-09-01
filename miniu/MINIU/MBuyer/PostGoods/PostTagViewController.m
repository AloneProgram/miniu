//
//  PostTagViewController.m
//  DLDQ_IOS
//
//  Created by simman on 14-8-24.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#import "PostTagViewController.h"
#import "DWTagList.h"
#import "TagEntity.h"

#define MAXTAGS 5

@interface PostTagViewController () <UITextFieldDelegate, DWTagListDelegate>{
    void(^_tagsBlock)(NSString *);
}

@property (nonatomic, copy) NSString *tagsStr;
@property (nonatomic, strong) DWTagList             *tagList;
@property (nonatomic, strong) DWTagList             *recommendTagList;
@property (nonatomic, strong) NSMutableArray *tagsArray;
@property (nonatomic, strong) NSMutableArray *recommentArray;
@property (weak, nonatomic) IBOutlet UITextField *tagTextField;
- (IBAction)addTagAction:(id)sender;
@property (weak, nonatomic) IBOutlet FUIButton *addTagButton;

@property (weak, nonatomic) IBOutlet UILabel *topLineLable;

@property (weak, nonatomic) IBOutlet UILabel *bottomLineLable;

@end

@implementation PostTagViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setNavTitle:@"标签"];
        _recommentArray = [NSMutableArray arrayWithCapacity:1];
        _tagsArray = [NSMutableArray arrayWithCapacity:1];
    }
    return self;
}

- (id)initWithTags:(NSString *)tags
{
    self = [self initWithNibName:@"PostTagViewController" bundle:nil];
    if ( self && ![tags isEqualToString:@"选择标签"]) {
        self.tagsStr = tags;
    }
    return self;
}

- (void)initControllerData{};

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tagTextField.delegate = self;
    
    WeakSelf
    //点击左边按钮可以取消当前的网络请求
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] bk_initWithBarButtonSystemItem:UIBarButtonSystemItemCancel handler:^(id sender) {
        [weakSelf_SC dismissViewControllerAnimated:YES completion:^{
            [weakSelf_SC cancelCurrentNetWorkRequest];
            _tagsBlock(@"");
        }];
    }];
    //右边的按钮
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] bk_initWithTitle:@"完成" style:UIBarButtonItemStyleDone handler:^(id sender) {
        [weakSelf_SC dismissViewControllerAnimated:YES completion:^{
            [weakSelf_SC cancelCurrentNetWorkRequest];
            NSString *tags = [weakSelf_SC.tagsArray componentsJoinedByString:@","];
            _tagsBlock(tags);
        }];
    }];
    
    
    // view 设置基本样式
    [self.topLineLable setHeight:0.5f];
    [self.topLineLable setWidth:kScreen_Width - 10];
    [self.bottomLineLable setHeight:0.5f];
    [self.bottomLineLable setWidth:kScreen_Width - 10];
    
    [self.tagTextField setWidth:kScreen_Width - 100];
    [self.addTagButton setX:(CGRectGetMaxX(self.tagTextField.frame) + 5)];
    
    
    [self setTagsListView];
    
    if ( [self.tagsStr length] > 0) {
        NSArray *tagsArray = [self.tagsStr componentsSeparatedByString:@","];
        [self.tagsArray addObjectsFromArray:tagsArray];
        [_tagList setTags:tagsArray];
    }
    
    //点击隐藏键盘
    [self Hidden_Keyboard_With_GestureAction:^{
        [self.tagTextField resignFirstResponder];
    }];
    
    
    
    [self getTagsListWithNetWork];
}

/**
 *  标签区 第三方
 */
- (void) setTagsListView
{
    _tagList = [[DWTagList alloc] initWithFrame:CGRectMake(20.0f, 70.0f, kScreen_Width - 40.0f, 50.0f)];
    [_tagList setAutomaticResize:YES];
    [_tagList setTagDelegate:self];
    
    // Customisation
    [_tagList setCornerRadius:4.0f];
    [_tagList setTagBackgroundColor:[UIColor colorWithRed:0.988 green:0.678 blue:0.200 alpha:1]];

    [_tagList setTextColor:[UIColor whiteColor]];
    [_tagList setFont:[UIFont systemFontOfSize:16]];
    [_tagList setBorderColor:[UIColor clearColor].CGColor];
    [_tagList setBorderWidth:0];
    [self.view addSubview:_tagList];
    
    //----------------------------
    
    _recommendTagList = [[DWTagList alloc] initWithFrame:CGRectMake(20.0f, _tagList.frame.origin.y + 200, kScreen_Width - 40.0f, 250.0f)];
    [_recommendTagList setAutomaticResize:YES];
    [_recommendTagList clickTagBlock:^(NSString *tagName, NSInteger tagIndex) {
        [self addTagToTagList:tagName AndTextField:nil];
    }];
    
    // Customisation
    [_recommendTagList setCornerRadius:4.0f];
    [_recommendTagList setTagBackgroundColor:[UIColor colorWithRed:1.000 green:0.263 blue:0.318 alpha:1]];
    [_recommendTagList setTextColor:[UIColor whiteColor]];
    [_recommendTagList setFont:[UIFont systemFontOfSize:16]];
    [_recommendTagList setBorderWidth:0];
    [_recommendTagList setBorderColor:[UIColor clearColor].CGColor];
    
    [self.view addSubview:_recommendTagList];
}


- (void) addTagToTagList:(NSString *)tag AndTextField:(UITextField *)textField
{
    if ( [_tagsArray count] >= MAXTAGS ) {
        [self showHudError:[NSString stringWithFormat:@"最多选择%d个标签", MAXTAGS]];
    } else {
        
        if ([tag length]) {
            
            if ([tag length] > 10) {
                [self showHudError:@"标签最长为10个字符"];
            } else if ([_tagsArray containsObject:tag]) {
                [self showHudError:@"不能使用相同的标签"];
            } else {
                [textField setText:@""];
                [_tagsArray addObject:tag];
                [_tagList setTags:_tagsArray];
            }
        } else {
            [self showHudError:@"不能输入空标签!"];
        }
    }
}

- (void)tagListTagsChanged:(DWTagList *)tagList
{
    [_tagsArray removeAllObjects];
    [_tagsArray addObjectsFromArray:tagList.textArray];
}

- (void) addCallBackWithTag:(void (^)(NSString *))tags
{
    _tagsBlock = tags;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - text field should return
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self addTagToTagList:_tagTextField.text AndTextField:_tagTextField];
    return YES;
}

- (IBAction)addTagAction:(id)sender {
    [self addTagToTagList:_tagTextField.text AndTextField:_tagTextField];
}

- (void) getTagsListWithNetWork
{
    [self showHudLoad:@"正在获取标签..."];
    long long userId = [CURRENT_USER_INSTANCE getCurrentUserID];
    
    [self.currentRequest addObject:[[logicShareInstance getTagManager] getGoodsTagsWithUserId:userId goodsId:0 currentPage:0 pageSize:0 success:^(id responseObject) {
        
        //            for (NSDictionary *dic in responseObject[@"data"][@"tagsMatchList"]) {
        
        //                TagEntity *tagEntity = [[TagEntity alloc] init];
        //                [tagEntity setValuesForKeysWithDictionary:dic];
        //                [self.recommentArray addObject:tagEntity.value];
        for (NSDictionary *dic in responseObject[@"data"]) {
            [self.recommentArray addObject:dic[@"tagName"]];
            if (self.recommentArray.count>= 10) {
                break;
            }
            
        }
        [_recommendTagList setTags:_recommentArray];
        
        [self endHudLoad];
        
    } failure:^(NSString *error) {
        [self showHudError:error];
    }]];
}


@end
