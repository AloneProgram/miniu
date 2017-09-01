/************************************************************
  *  * EaseMob CONFIDENTIAL 
  * __________________ 
  * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved. 
  *  
  * NOTICE: All information contained herein is, and remains 
  * the property of EaseMob Technologies.
  * Dissemination of this information or reproduction of this material 
  * is strictly forbidden unless prior written permission is obtained
  * from EaseMob Technologies.
  */

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "LocationViewController.h"

#import "UIViewController+HUD.h"

static LocationViewController *defaultLocation = nil;

@interface LocationViewController () <MKMapViewDelegate>
{
    MKPointAnnotation *_annotation;
    
    CLLocationCoordinate2D _currentLocationCoordinate;
    BOOL _isSendLocation;
}

@property (nonatomic, strong) MKMapView *mapView;
@property (strong, nonatomic) NSString *addressString;

@end

@implementation LocationViewController

@synthesize addressString = _addressString;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isSendLocation = YES;
    }
    
    return self;
}

- (instancetype)initWithLocation:(CLLocationCoordinate2D)locationCoordinate
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _isSendLocation = NO;
        _currentLocationCoordinate = locationCoordinate;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"位置信息";
    
    WeakSelf
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] bk_initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStyleDone handler:^(id sender) {
        [weakSelf_SC.navigationController popViewControllerAnimated:YES];
    }];
    
    
    _mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    _mapView.delegate = self;
    _mapView.mapType = MKMapTypeStandard;
    _mapView.zoomEnabled = YES;
    [self.view addSubview:_mapView];
    
    
    if (_isSendLocation) {
        
        // 检测是否有权限
        [[logicShareInstance getLocationManager] getCurrentLocation:^(CLLocation *location) {
            
            weakSelf_SC.mapView.showsUserLocation = YES;//显示当前位置
            
            UIButton *sendButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
            [sendButton setTitle:@"发送" forState:UIControlStateNormal];
            [sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
            [sendButton addTarget:weakSelf_SC action:@selector(sendLocation) forControlEvents:UIControlEventTouchUpInside];
            [weakSelf_SC.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:sendButton]];
            weakSelf_SC.navigationItem.rightBarButtonItem.enabled = NO;
            
            [weakSelf_SC startLocation];
            
        } Placemark:^(CLPlacemark *placemark) {
            
        } error:^(NSString *error) {
            
        }];
    }
    else{
        [self removeToLocation:_currentLocationCoordinate];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

#pragma mark - class methods

+ (instancetype)defaultLocation
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultLocation = [[LocationViewController alloc] initWithNibName:nil bundle:nil];
    });
    
    return defaultLocation;
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    __weak typeof(self) weakSelf = self;
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:userLocation.location completionHandler:^(NSArray *array, NSError *error) {
        if (!error && array.count > 0) {
            CLPlacemark *placemark = [array objectAtIndex:0];
            weakSelf.addressString = placemark.name;
            
//            [weakSelf removeToLocation:userLocation.coordinate];
        }
    }];
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    [self showHudError:@"定位失败!"];
}

#pragma mark - public

- (void)startLocation
{
    if (_isSendLocation) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    
    [self showHudLoad:@"正在定位..."];
}

-(void)createAnnotationWithCoords:(CLLocationCoordinate2D)coords
{
    if (_annotation == nil) {
        _annotation = [[MKPointAnnotation alloc] init];
    }
    else{
        [_mapView removeAnnotation:_annotation];
    }
    _annotation.coordinate = coords;
    [_mapView addAnnotation:_annotation];
}

- (void)removeToLocation:(CLLocationCoordinate2D)locationCoordinate
{
    [self endHudLoad];
    
    _currentLocationCoordinate = locationCoordinate;
    float zoomLevel = 0.01;
    MKCoordinateRegion region = MKCoordinateRegionMake(_currentLocationCoordinate, MKCoordinateSpanMake(zoomLevel, zoomLevel));
    [_mapView setRegion:[_mapView regionThatFits:region] animated:YES];
    
    if (_isSendLocation) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    
    [self createAnnotationWithCoords:_currentLocationCoordinate];
}

- (void)sendLocation
{
    if (_delegate && [_delegate respondsToSelector:@selector(sendLocationLatitude:longitude:andAddress:)]) {
        [_delegate sendLocationLatitude:_currentLocationCoordinate.latitude longitude:_currentLocationCoordinate.longitude andAddress:_addressString];
    }

    _mapView.showsUserLocation = NO;
    _mapView.delegate = nil;
    _mapView = nil;
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc
{
    
}

@end
