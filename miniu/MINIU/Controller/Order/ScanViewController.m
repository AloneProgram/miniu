//
//  ScanViewController.m
//  miniu
//
//  Created by SimMan on 15/6/10.
//  Copyright (c) 2015年 SimMan. All rights reserved.
//

#import "ScanViewController.h"
#import "AVCaptureSession+ZZYQRCodeAndBarCodeExtension.h"

@interface ScanViewController () <AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) CADisplayLink *link;
@property (nonatomic, strong) AVCaptureSession *session;

@property (nonatomic, copy) void (^_Blocks)(NSString *);

@end

@implementation ScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"单号扫描（测试版）";
    
    WeakSelf
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] bk_initWithTitle:@"取消" style:UIBarButtonItemStyleDone handler:^(id sender) {
        [weakSelf_SC dismissViewControllerAnimated:YES completion:nil];
    }];

    // 添加跟屏幕刷新频率一样的定时器
    CADisplayLink *link = [CADisplayLink displayLinkWithTarget:self selector:@selector(scan)];
    self.link = link;

    // 获取读取条形码的会话
    self.session = [AVCaptureSession readBarCodeWithMetadataObjectsDelegate:self];
    
    // 创建预览图层
    AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    previewLayer.frame = self.view.bounds;
    // 插入到最底层
    [self.view.layer insertSublayer:previewLayer atIndex:0];
}

// 在页面将要显示的时候添加定时器
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.session startRunning];
    [self.link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

// 在页面将要消失的时候移除定时器
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.link removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

// 扫描效果
- (void)scan
{
    
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (metadataObjects.count > 0) {
        // 停止扫描
        [self.session stopRunning];
        // 获取信息
        AVMetadataMachineReadableCodeObject *object = metadataObjects.lastObject;
        
        // 弹窗提示
        [WCAlertView showAlertWithTitle:@"提示" message:[NSString stringWithFormat:@"订单号：%@",object.stringValue] customizationBlock:^(WCAlertView *alertView) {
            
        } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
            
            if (buttonIndex && __Blocks) {
                __Blocks(object.stringValue);
                [self dismissViewControllerAnimated:YES completion:nil];
            } else {
                [self.session startRunning];
            }
        } cancelButtonTitle:@"重新扫描" otherButtonTitles:@"确定", nil];
    }
}

- (void)addCallBackBlock:(void (^)(NSString *))Block
{
    __Blocks = Block;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
