//
//  ApplyOrderViewController.m
//  miniu
//
//  Created by SimMan on 4/27/15.
//  Copyright (c) 2015 SimMan. All rights reserved.
//

#import "ApplyOrderViewController.h"
#import "ApplyOrderView.h"
#import "PayOrderView.h"
#import "GoodsEntity.h"
#import "PaySuccessOrderView.h"
#import "PayBalanceOrderView.h"

#import "UserAddressViewController.h"

#import "LogisticsViewController.h"
#import "ChatController.h"
#import "ChatViewController.h"

#import "NetWorkHandle.h"

#import "ChatToolBar.h"

#import "GoodsDetailsViewController.h"

@interface ApplyOrderViewController () <UIScrollViewDelegate, PayOrderViewDelegate, PaySuccessOrderViewDelegate, PayBalanceOrderViewDelegate,UIAlertViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) ApplyOrderView *applyOrderView;
@property (nonatomic, strong) PayOrderView *payOrderView;
@property (nonatomic, strong) PaySuccessOrderView *paySuccessView;
@property (nonatomic, strong) PayBalanceOrderView *payBalanceView;
@end

@implementation ApplyOrderViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}
#pragma mark - 右上角功能键
- (void)setupBarButtonItem
{
    self.navigationItem.leftBarButtonItem.title = @"";

    //买家版的已付款订单不显示更多按钮
    if(self.order.orderStatus == orderStatusOfisPaymentFull && TARGET_IS_MINIU){
        return;
    }
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] bk_initWithImage:[UIImage imageNamed:@"moreBtn_Nav"] style:UIBarButtonItemStyleDone handler:^(id sender) {
        [self selectAction];
    }];
    
    
}

/**
 *  点击右上角响应事件
 */
- (void)selectAction
{
#warning mark - 这个地方可能需要重写 逻辑不好
    if (!self.order) {
        [self showHudError:@"无法获取订单号,请退出重试!"];
        return;
    }
    
    //根据当前的order statues 来做数组
    NSArray* arrList;
    if(self.order.orderStatus == orderStatusOfWaitPayment){
        arrList = @[@"关闭订单"];
    }else if (self.order.orderStatus == orderStatusOfisPaymentFull){
        if(TARGET_IS_MINIU){
//            arrList = @[@"1",@"22",@"33"];
        }else{
            arrList = @[@"申请退款"];
        }
        
    }
    
    [SMActionSheet showSheetWithTitle:@"请选择" buttonTitles:arrList redButtonIndex:-1 completionBlock:^(NSUInteger buttonIndex, SMActionSheet *actionSheet) {
        if (buttonIndex == 0) {
            NSLog(@"点击了第一个按钮");
            //判断是否点击了取消
            if(arrList.count == 0)
            {
                //默认没有内容
                return ;
            }
            if(self.order.orderStatus == orderStatusOfWaitPayment){
 
                [[logicShareInstance getOrderManager]closeOrderWithWithOrderNo:self.order.orderNo success:^(id responseObject) {
                    [self showHudSuccess:@"关闭订单成功!"];
                    
                    dispatch_time_t timeDelay = dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC);
                    
                    dispatch_after(timeDelay, dispatch_get_main_queue(), ^{
                        //                       [[ChatToolBar shareInstance]updateBadge];
                        [self performSelectorOnMainThread:@selector(getOrderInfoWithNetwork) withObject:nil waitUntilDone:YES];
                    });
                    
                    //[self getOrderInfoWith
                    //[self.navigationController popViewControllerAnimated:YES];
                } failure:^(NSString *error) {
                    [self showHudError:error];
                }];
                
                
                //提交关闭订单
            }else if (self.order.orderStatus == orderStatusOfisPaymentFull){
                //make sure miniu can not do this
                if(TARGET_IS_MINIU){
                    return;
                }
                static UIView *viewa;
                if (viewa) {
                    return ;
                }
                viewa= [[UIView alloc]initWithFrame:CGRectMake(0, 0, 300, 400)];
                viewa.center = self.view.center;
                [viewa setY:-50];
                [self .view addSubview:viewa];
                
                [UIView animateWithDuration:1 animations:^{
                    [viewa setY:50];
                    viewa.backgroundColor =[UIColor colorWithRed:0.820 green:0.808 blue:0.867 alpha:1.0];
                } completion:nil];
                
                UILabel *l1 = [[UILabel alloc]initWithFrame:CGRectMake(20, 20, 80, 20)];
                l1.text = @"退款原因:";
                l1.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
                [viewa addSubview:l1];
                
                UITextView *refundReason = [[UITextView alloc]initWithFrame:CGRectMake(20, 50, 260, 100)];
                refundReason.backgroundColor =[UIColor colorWithRed:0.920 green:0.908 blue:0.967 alpha:1.0];
                [viewa addSubview:refundReason];
                
                UILabel *l2 = [[UILabel alloc]initWithFrame:CGRectMake(20, 160, 80, 20)];
                l2.text = @"退款描述:";
                l2.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
                [viewa addSubview:l2];
                
                UITextView *refundDes = [[UITextView alloc]initWithFrame:CGRectMake(20, 190, 260, 100)];
                refundDes.backgroundColor = [UIColor colorWithRed:0.920 green:0.908 blue:0.967 alpha:1.0];
                [viewa addSubview:refundDes];
                
                UIButton *btnCencel = [UIButton buttonWithType:UIButtonTypeSystem];
                btnCencel.frame = CGRectMake(20, 320, 120, 60);
                btnCencel.tintColor = [UIColor pomegranateColor];
                //                btnCencel.titleLabel.font =[UIFont systemFontOfSize:[UIFont systemFontSize]];
                //                btnCencel.titleLabel.text = @"取消";
                [btnCencel setTitle:@"取消" forState:(UIControlStateNormal)];
                btnCencel.layer.borderWidth = 1;
                btnCencel.layer.borderColor = [UIColor grayColor].CGColor;
                [btnCencel bk_addEventHandler:^(id sender) {
                    [viewa removeFromSuperview];
                    viewa = nil;
                } forControlEvents:(UIControlEventTouchUpInside)];
                [viewa addSubview:btnCencel];
                
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
                btn.frame = CGRectMake(160, 320, 120, 60);
                btn.tintColor = [UIColor nephritisColor];
                btn.layer.borderWidth = 1;
                btn.layer.borderColor = [UIColor grayColor].CGColor;
                [btn setTitle:@"OK" forState:(UIControlStateNormal)];
                [viewa addSubview:btn];
                [btn bk_addEventHandler:^(id sender) {
                    NSLog(@"点击了确定退款按钮");
                    
                    //提交退款申请
                    //需要配置一下申请理由 和 退款描述 when ui deliver a pic
                    [[logicShareInstance getOrderManager]refundWithOrderNo:self.order.orderNo reason:refundReason.text remark:refundDes.text success:^(id responseObject) {
                        [viewa removeFromSuperview];
                        viewa = nil;
                        [self showHudSuccess:@"申请成功!"];
                        //[self.navigationController popViewControllerAnimated:YES];
                        [self performSelectorOnMainThread:@selector(getOrderInfoWithNetwork) withObject:nil waitUntilDone:YES];
                    } failure:^(NSString *error) {
                        [self showHudError:error];
                    }];
                    
                } forControlEvents:(UIControlEventTouchUpInside)];
                
                
//                //提交退款申请
//                //需要配置一下申请理由 和 退款描述 when ui deliver a pic
//                [[logicShareInstance getOrderManager]refundWithOrderNo:self.order.orderNo reason:refundReason.text remark:refundDes.text success:^(id responseObject) {
//                    [self showHudSuccess:@"申请成功!"];
//                    //[self.navigationController popViewControllerAnimated:YES];
//                    [self performSelectorOnMainThread:@selector(getOrderInfoWithNetwork) withObject:nil waitUntilDone:YES];
//                } failure:^(NSString *error) {
//                    [self showHudError:error];
//                }];
            }
        }else if (buttonIndex == 1){
            NSLog(@"11111");
        }
       
    }];

}

- (void)sendHttpRequestWithOrderNO:(NSString*)orderNO orderStates:(orderStatusType)statues
{
    NSDictionary*dic;
    if (statues == orderStatusOfWaitPayment) {
        
    }else if (statues == orderStatusOfisPaymentFull){
        
    }
    
    [[NetWorkHandle sharedClient]HttpRequestWithRequestType:POST parameters:dic success:^(NSURLSessionDataTask *task, id responseObject) {
    } failure:^(NSURLSessionDataTask *task, NSString *error) {
        [self showStatusBarError:error];
    }];
}

#pragma mark view did load
- (void)viewDidLoad {
    [super viewDidLoad];
       //如果是从聊天框进来的话
//    if([self.navigationController.viewControllers[self.navigationController.viewControllers.count-2] isKindOfClass:[ChatController class]]||[self.navigationController.viewControllers[self.navigationController.viewControllers.count-2] isKindOfClass:[ChatViewController class]]){
//        
//        //处理
//        self.navigationItem.backBarButtonItem = [UIBarButtonItem blankBarButton];
//        //设置右边的更多按钮
//        [self setupBarButtonItem];
//        
//        // 添加ScrollView
//        [self.view addSubview:self.scrollView];
//        
//        // 添加头部
//        [self.scrollView addSubview:self.applyOrderView];
//        
//        return;
//        
//        
//    }
//    //每次进入都要更新一下order
//    [[[LogicManager shareInstance] getOrderManager]getOrderDetailsWithOrderNo:self.order.orderNo success:^(id responseObject) {
//        NSLog(@"responseObject = %@",responseObject);
//    } failure:^(NSString *error) {
//        [self showHudError:error];
//    }];
    self.title = @"支付订单";
    
    self.navigationItem.backBarButtonItem = [UIBarButtonItem blankBarButton];
    //设置右边的更多按钮
    [self setupBarButtonItem];
    
    // 添加ScrollView
    [self.view addSubview:self.scrollView];
    
    // 添加头部
    [self.scrollView addSubview:self.applyOrderView];
    
    //有订单号且订单状态不等于等待付款
    if (_order && _order.orderStatus != orderStatusOfWaitPayment) {
        
        // 判断订单状态
        
        // 如果是已付定金
        if (_order.orderStatus == orderStatusOfisPaymentWaitBalance) {
            
            [self.scrollView addSubview:self.payBalanceView];
            //[self getOrderInfoWithNetwork];
            
            // 如果是已付全款，那么则显示成功页面。 可以申请退款
        } else if (_order.orderStatus == orderStatusOfisPaymentFull) {
            self.title = @"订单详情";
            [self.scrollView addSubview:self.paySuccessView];
            
            //            NSLog(@"%@",NSStringFromCGRect(self.paySuccessView.frame));
//            if (TARGET_IS_MINIU_BUYER){
//                //添加退款功能
//                UIButton *btnRefund = [UIButton buttonWithType:(UIButtonTypeSystem)];
//                [btnRefund setTitle:@"申请退款" forState:(UIControlStateNormal)];
//                [btnRefund setTintColor:[UIColor redColor]];
//                
//                btnRefund.frame = CGRectMake(kScreen_Width/2-70, self.paySuccessView.logisticsInfoLable.selfMaxY+230, 140, 20);
//                [self.scrollView addSubview:btnRefund];
//                
//                [btnRefund bk_addEventHandler:^(id sender) {
//                    UIAlertView *alt = [[UIAlertView alloc]initWithTitle:@"申请退款" message:@"是否申请退款?" delegate:self cancelButtonTitle:@"不" otherButtonTitles:@"是", nil];
//                    alt.tag = 1001;
//                    [alt show];
//                    
//                    //[self showHudSuccess:@"申请退款成功"];
//                } forControlEvents:(UIControlEventTouchUpInside)];
//                    NSLog(@"%@",NSStringFromCGRect(btnRefund.frame));
//                
//            }
            //[self getOrderInfoWithNetwork];
        }else if (_order.orderStatus == orderStatusOfisDeliver)
        {
            [self.scrollView addSubview:self.paySuccessView];
            self.title = @"已发货";
            //[self getOrderInfoWithNetwork];
#warning 这里也需要处理发货和退款中的两种状态的显示
        }else if(_order.orderStatus == orderStatusOfRefunding || _order.orderStatus == orderStatusOfRefundComfirm ||_order.orderStatus == 9){
            NSLog(@"正在退款的需要处理!!");
            self.title = @"正在退款中";
            //[self getOrderInfoWithNetwork];
        //尚未付款的可以关闭订单
        }else if(_order.orderStatus == orderStatusOfRefund){
            self.title = @"退款成功";
        }else if (_order.orderStatus == orderStatusOfClose){
            self.title = @"订单已关闭";
        }
        // 如果是新订单或者是未付款状态的订单
    } else {
        
        if (_goodsId && !_order) {
            // 生成订单
            [self applyOrderWithNetwork];
        } else {
            // 查询订单详情
            //[self getOrderInfoWithNetwork];
        }
        
        // 添加尾部
        [self.scrollView addSubview:self.payOrderView];
    }
    
    [self.view beginLoading];
}

-(void)viewWillAppear:(BOOL)animated
{
    //如果是重chat view controller 进来的话 则不显示toolbar
    id subController = (self.navigationController.childViewControllers)[self.navigationController.childViewControllers.count-2];
    if (subController) {
        if ([subController isKindOfClass:[ChatViewController class]]) {//subController == [ChatViewController shareInstance]
            [[ChatToolBar shareInstance]setHidden:YES];
            
        }
    }
    
    if (_goodsId && !_order) {
        // 生成订单
        //[self applyOrderWithNetwork];
    }else{
        [self getOrderInfoWithNetwork];
    }
}


#pragma mark 生成订单
/**
 *  用户点击一键下单后进入 新建订单请求
 */
- (void) applyOrderWithNetwork
{
    WeakSelf
    [self.currentRequest addObject:[[logicShareInstance getOrderManager] applyOrderWithGoodsId:self.goodsId success:^(id responseObject) {
        
        OrderEntity *order = [[OrderEntity alloc] init];
        [order setValuesForKeysWithDictionary:[responseObject objectForKey:@"data"]];
        
        weakSelf_SC.order = order;
        [weakSelf_SC.applyOrderView setOrderEntity:order];
        [weakSelf_SC.payOrderView setOrder:order];
        [weakSelf_SC.view endLoading];
        
    } failure:^(NSString *error) {
        
        [weakSelf_SC showHudError:error];
        
        [weakSelf_SC bk_performBlock:^(id obj) {
            [weakSelf_SC.navigationController popViewControllerAnimated:YES];
            [weakSelf_SC.view endLoading];
        } afterDelay:1.5];
    }]];
}

#pragma mark 获取订单详情
- (void) getOrderInfoWithNetwork
{
    WeakSelf
    [[logicShareInstance getOrderManager] getOrderDetailsWithOrderNo:self.order.orderNo success:^(id responseObject) {
        
        OrderEntity *order = [[OrderEntity alloc] init];
        [order setValuesForKeysWithDictionary:[responseObject objectForKey:@"data"]];
        
        weakSelf_SC.order = order;
        
        if (order.orderStatus == orderStatusOfisPaymentWaitBalance) {
            
            [weakSelf_SC.payOrderView removeFromSuperview];
            [weakSelf_SC.paySuccessView removeFromSuperview];
            [weakSelf_SC.payBalanceView removeFromSuperview];
            
            [weakSelf_SC.scrollView addSubview:weakSelf_SC.payBalanceView];
            
            [weakSelf_SC.payBalanceView setOrder:order];
        } else if (order.orderStatus == orderStatusOfWaitPayment) {
            
            [weakSelf_SC.payOrderView removeFromSuperview];
            [weakSelf_SC.paySuccessView removeFromSuperview];
            [weakSelf_SC.payBalanceView removeFromSuperview];
            
            [weakSelf_SC.scrollView addSubview:weakSelf_SC.payOrderView];
          //  NSLog(@"可以关闭订单");
            //添加关闭订单功能 改为右上角的了
//            UIButton *btnRefund = [UIButton buttonWithType:(UIButtonTypeSystem)];
//            [btnRefund setTitle:@"关闭订单" forState:(UIControlStateNormal)];
//            [btnRefund setTintColor:[UIColor redColor]];
//            
//            btnRefund.frame = CGRectMake(kScreen_Width/2-70, self.paySuccessView.logisticsInfoLable.selfMaxY+280, 140, 20);
//            [self.scrollView addSubview:btnRefund];
//            
//            [btnRefund bk_addEventHandler:^(id sender) {
////                [self showHudSuccess:@"关闭订单成功!"];
//                UIAlertView *alt = [[UIAlertView alloc]initWithTitle:@"取消订单 " message:@"是否关闭订单?" delegate:self cancelButtonTitle:@"不" otherButtonTitles:@"是", nil];
//                alt.tag = 1002;
//                [alt show];
//            } forControlEvents:(UIControlEventTouchUpInside)];
            
            [weakSelf_SC.payOrderView setOrder:order];
        } else if (order.orderStatus == orderStatusOfisPaymentFull) {
            [weakSelf_SC.payOrderView removeFromSuperview];
            [weakSelf_SC.paySuccessView removeFromSuperview];
            [weakSelf_SC.payBalanceView removeFromSuperview];
            
            [weakSelf_SC.scrollView addSubview:weakSelf_SC.paySuccessView];
            
            [weakSelf_SC.paySuccessView setOrder:order];
        } else if (order.orderStatus == orderStatusOfClose) {
            [weakSelf_SC.payOrderView removeFromSuperview];
            [weakSelf_SC.paySuccessView removeFromSuperview];
            [weakSelf_SC.payBalanceView removeFromSuperview];
            
            UIImageView *imgv = [[UIImageView alloc]initWithFrame:weakSelf_SC.payOrderView.frame ];
            //可以放个图片
            imgv.backgroundColor = [UIColor clearColor];
            weakSelf_SC.title =@"订单已关闭";
            [weakSelf_SC.scrollView addSubview:imgv];
            
            [weakSelf_SC.paySuccessView setOrder:order];
        }else if (order.orderStatus == orderStatusOfRefunding ||order.orderStatus == orderStatusOfRefundComfirm) {
            [weakSelf_SC.payOrderView removeFromSuperview];
            [weakSelf_SC.paySuccessView removeFromSuperview];
            [weakSelf_SC.payBalanceView removeFromSuperview];
            
            UIImageView *imgv = [[UIImageView alloc]initWithFrame:weakSelf_SC.payOrderView.frame ];
            //可以放个图片
            imgv.backgroundColor = [UIColor clearColor];
            weakSelf_SC.title =@"正在退款中";
            [weakSelf_SC.scrollView addSubview:imgv];
            
            [weakSelf_SC.paySuccessView setOrder:order];
        }
#warning 这里可能还需要补充其他状态... 2015.8.
        [weakSelf_SC.applyOrderView setOrderEntity:order];
        
        
        [weakSelf_SC endHudLoad];
        [weakSelf_SC.view endLoading];
        
    } failure:^(NSString *error) {
        [weakSelf_SC showHudError:error];
        
        [weakSelf_SC bk_performBlock:^(id obj) {
            [weakSelf_SC.navigationController popViewControllerAnimated:YES];
            [weakSelf_SC.view endLoading];
        } afterDelay:1.5];
    }];
}



#pragma mark 支付按钮被点击了的代理
- (void)payButtonDidClick:(payButtonTag)payButtonTag
{
    [self showHudLoad:@"正在请求数据..."];
    
    WeakSelf
    payMentPattern paymentPattern;
    // 微信支付
    if (payButtonTag == payButtonTagWithWechatPay) {
        paymentPattern = payMentPatternOfWeCaht;
        // 支付宝支付
    } else if (payButtonTag == payButtonTagWithAlipay) {
        paymentPattern = payMentPatternOfAlipay;
        // 银行卡支付
    } else if (payButtonTag == payButtonTagWithBank) {
        paymentPattern = payMentPatternOfBank;
    } else {
        [self showHudError:@"请选择支付渠道!"];
        return;
    }
    
    [[logicShareInstance getOrderManager] pingPlusCreateOrderWith:self.order.orderNo payChannel:paymentPattern success:^(id responseObject) {
        
        NSDictionary *dic = responseObject[@"data"];
        NSString *charge = [dic JSONString];
        
        [weakSelf_SC endHudLoad];
        [[logicShareInstance getPingPlusManager] createPayment:charge viewController:weakSelf_SC success:^(NSString *resultDic) {
            
            [weakSelf_SC showHudSuccess:@"支付成功!"];
            
            [weakSelf_SC.view beginLoading];
            [weakSelf_SC getOrderInfoWithNetwork];
            
        } failure:^(NSString *error) {
            [weakSelf_SC showHudError:error];
        }];
    } failure:^(NSString *error) {
        [weakSelf_SC showHudError:error];
    }];
}

#pragma mark 物流按钮被点击了
/**
 *  订单页面
 *
 *  @param action 点击 查看物流详情 or 添加收获地址
 */
- (void)logisticsAction:(logisticsAction)action
{
    //订单详情
    if (action == logisticsActionWithInfo) {
        LogisticsViewController *logisticsVC = [LogisticsViewController new];
        logisticsVC.order = self.order;
        [self.navigationController pushViewController:logisticsVC animated:YES];
        
        //添加收获地址
    } else if (action == logisticsActionWithAddAddress) {
        
        UserAddressViewController *userAddressVC = [[UserAddressViewController alloc] init];
        userAddressVC.order = self.order;
        long long applyUserId;
        
#if TARGET_IS_MINIU
        
        // 如果是买家，并且已经有地址了则弹出提示
        if ([self.order.consignee length]) {
            [WCAlertView showAlertWithTitle:@"提示" message:@"您已经添加过地址,如需修改请联系\"米妞\"!" customizationBlock:^(WCAlertView *alertView) {
                
            } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
                
            } cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            
            return;
        }
        
        //没有地址的话 直接进入添加地址界面
        applyUserId = USER_IS_LOGIN;
#elif TARGET_IS_MINIU_BUYER
        applyUserId = self.order.applyUserId;
#endif
        
        WeakSelf
        [userAddressVC createAddressApplyId:applyUserId addCallBackBlock:^(AddressEntity *address) {
            [weakSelf_SC showHudLoad:@"正在更新..."];
            [[logicShareInstance getOrderManager] addAddressWithOrderNo:self.order.orderNo address:address success:^(id responseObject) {
                
                OrderEntity *order = [[OrderEntity alloc] init];
                [order setValuesForKeysWithDictionary:[responseObject objectForKey:@"data"]];
                
                weakSelf_SC.order = order;
                
                if (order.orderStatus == orderStatusOfisPaymentWaitBalance) {
                    [weakSelf_SC.payBalanceView setOrder:order];
                } else if (order.orderStatus == orderStatusOfWaitPayment) {
                    [weakSelf_SC.applyOrderView setOrderEntity:order];
                }
                
                [weakSelf_SC.payOrderView setOrder:order];
                [weakSelf_SC.paySuccessView setOrder:order];
                [weakSelf_SC endHudLoad];
                
            } failure:^(NSString *error) {
                [weakSelf_SC showHudError:error];
            }];
        }];
        
        [self.navigationController pushViewController:userAddressVC animated:YES];
    }
}

#pragma mark 选择支付方式按钮
- (void) choosePayMentButton
{
    [SMActionSheet showSheetWithTitle:@"请选择支付方式" buttonTitles:@[@"微信支付", @"支付宝", @"网银支付"] redButtonIndex:-1 completionBlock:^(NSUInteger buttonIndex, SMActionSheet *actionSheet) {
        if (buttonIndex == 0) {
            [self payButtonDidClick:payButtonTagWithWechatPay];
        } else if (buttonIndex == 1) {
            [self payButtonDidClick:payButtonTagWithAlipay];
        } else if (buttonIndex == 2) {
            [self payButtonDidClick:payButtonTagWithBank];
        }
    }];
}

#pragma mark - getter
- (ApplyOrderView *)applyOrderView
{
    if (!_applyOrderView) {
        _applyOrderView = [ApplyOrderView new];
        //添加点击跳转订单详情页 2015.09.24
        _applyOrderView.userInteractionEnabled = YES;
        [_applyOrderView bk_whenTapped:^{
            NSLog(@"it need to go to the detail page");
            GoodsDetailsViewController * gdvc = [[GoodsDetailsViewController alloc]initWithOrder:_order];
            [self.navigationController pushViewController:gdvc animated:YES];
            
        }];
        
    }
    return _applyOrderView;
}

- (PayBalanceOrderView *)payBalanceView
{
    if (!_payBalanceView) {
        _payBalanceView = [PayBalanceOrderView new];
        _payBalanceView.delegate  = self;
    }
    return _payBalanceView;
}

- (PaySuccessOrderView *)paySuccessView
{
    if (!_paySuccessView) {
        _paySuccessView = [PaySuccessOrderView new];
        _paySuccessView.delegate = self;
    }
    return _paySuccessView;
}

- (PayOrderView *)payOrderView
{
    if (!_payOrderView) {
        _payOrderView = [PayOrderView new];
        _payOrderView.delegate = self;
    }
    return _payOrderView;
}

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        [_scrollView setContentSize:CGSizeMake(kScreen_Width, 650)];
        _scrollView.alwaysBounceVertical = YES;
        _scrollView.delegate = self;
    }
    return _scrollView;
}

#pragma mark alter view delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1001) {
        if(buttonIndex == 1){
           //send request to refund
        }
    }else if (alertView.tag == 1002)
    {
        if(buttonIndex == 1){
            //send request to close the order
        }
    }
}
@end
