//
//  UICityPicker.m
//  DDMates
//
//  Created by ShawnMa on 12/16/11.
//  Copyright (c) 2011 TelenavSoftware, Inc. All rights reserved.
//

#import "TSLocateView.h"

#define kDuration 0.3

@interface TSLocateView()
@property (nonatomic, strong) UIView *mainView;
@property (weak, nonatomic) IBOutlet UIImageView *titleView;
@property (weak, nonatomic) IBOutlet UIButton *LocateButton;

@end
@implementation TSLocateView

@synthesize titleLabel;
@synthesize locatePicker;
@synthesize locate;

- (id)initWithTitle:(NSString *)title delegate:(id /*<UIActionSheetDelegate>*/)delegate
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"TSLocateView" owner:self options:nil] objectAtIndex:0];
    if (self) {
        self.delegate = delegate;
        self.titleLabel.text = title;
        self.locatePicker.dataSource = self;
        self.locatePicker.delegate = self;
        
        //加载数据
        provinces = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ProvincesAndCities.plist" ofType:nil]];
        cities = [[provinces objectAtIndex:0] objectForKey:@"Cities"];
        
        self.backgroundColor = [UIColor colorWithRed:0.243 green:0.192 blue:0.376 alpha:1];
        
        //初始化默认数据
        self.locate = [[TSLocation alloc] init];
        self.locate.state = [[provinces objectAtIndex:0] objectForKey:@"State"];
        self.locate.city = [[cities objectAtIndex:0] objectForKey:@"city"];
//        self.locate.latitude = [[[cities objectAtIndex:0] objectForKey:@"lat"] doubleValue];
//        self.locate.longitude = [[[cities objectAtIndex:0] objectForKey:@"lon"] doubleValue];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    
    [self.titleLabel setWidth:kScreen_Width];
    [self.locatePicker setWidth:kScreen_Width];
    [self.titleView setWidth:kScreen_Width];
    [self.LocateButton setX:kScreen_Width - 50];
    [self.mainView setWidth:kScreen_Width];
    [self setWidth:kScreen_Width];
    
}

- (void)showInView:(UIView *) view
{
    CATransition *animation = [CATransition  animation];
    animation.delegate = self;
    animation.duration = kDuration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromTop;
    [self setAlpha:1.0f];
    [self.layer addAnimation:animation forKey:@"DDLocateView"];
    
    self.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - self.frame.size.height, self.frame.size.width, self.frame.size.height);
    view.alpha = 0.5;
    self.mainView = view;
//    [view addSubview:self];
    view.userInteractionEnabled = NO;
    
    [[[[UIApplication sharedApplication] delegate] window] addSubview:self];
}

#pragma mark - PickerView lifecycle

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            return [provinces count];
            break;
        case 1:
            return [cities count];
            break;
        default:
            return 0;
            break;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            return [[provinces objectAtIndex:row] objectForKey:@"State"];
            break;
        case 1:
            return [[cities objectAtIndex:row] objectForKey:@"city"];
            break;
        default:
            return nil;
            break;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    switch (component) {
        case 0:
            cities = [[provinces objectAtIndex:row] objectForKey:@"Cities"];
            [self.locatePicker selectRow:0 inComponent:1 animated:NO];
            [self.locatePicker reloadComponent:1];
            
            self.locate.state = [[provinces objectAtIndex:row] objectForKey:@"State"];
            self.locate.city = [[cities objectAtIndex:0] objectForKey:@"city"];
//            self.locate.latitude = [[[cities objectAtIndex:0] objectForKey:@"lat"] doubleValue];
//            self.locate.longitude = [[[cities objectAtIndex:0] objectForKey:@"lon"] doubleValue];
            break;
        case 1:
            self.locate.city = [[cities objectAtIndex:row] objectForKey:@"city"];
//            self.locate.latitude = [[[cities objectAtIndex:row] objectForKey:@"lat"] doubleValue];
//            self.locate.longitude = [[[cities objectAtIndex:row] objectForKey:@"lon"] doubleValue];
            break;
        default:
            break;
    }
}

- (void)hiddenView
{
    [self cancel:nil];
}

#pragma mark - Button lifecycle

- (IBAction)cancel:(id)sender
{
    CATransition *animation = [CATransition  animation];
    animation.delegate = self;
    animation.duration = kDuration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromBottom;
    [self setAlpha:0.0f];
    [self.layer addAnimation:animation forKey:@"TSLocateView"];
    
    self.mainView.userInteractionEnabled = YES;
    self.mainView.alpha = 1;
    
    [self performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:kDuration];
    if(self.delegate) {
        [self.delegate actionSheet:self clickedButtonAtIndex:0];
    }
}

- (IBAction)locate:(id)sender {
    CATransition *animation = [CATransition  animation];
    animation.delegate = self;
    animation.duration = kDuration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromBottom;
    [self setAlpha:0.0f];
    [self.layer addAnimation:animation forKey:@"TSLocateView"];
    
    self.mainView.userInteractionEnabled = YES;
    self.mainView.alpha = 1;
    
    [self performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:kDuration];
    if(self.delegate) {
        [self.delegate actionSheet:self clickedButtonAtIndex:1];
    }
    
}

@end
