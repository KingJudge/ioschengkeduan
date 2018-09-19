//
//  waitDriverViewController.m
//  iOS-trip-search
//
//  Created by yaoqianghong on 2018/9/18.
//  Copyright © 2018年 Amap. All rights reserved.
//

#import "waitDriverViewController.h"
#import "driverInfo.h"
@interface waitDriverViewController ()<MAMapViewDelegate>

@property (nonatomic, strong) MAPointAnnotation *startAnnotation;
@property (nonatomic, strong) MAPointAnnotation *endAnnotation;
@property (nonatomic, strong) MAPointAnnotation *driverAnnotation;
@property (assign, nonatomic) CLLocationCoordinate2D startCoordinate;
@property (assign, nonatomic) CLLocationCoordinate2D driverCoordinate;
@property (assign, nonatomic) CLLocationCoordinate2D endCoordinate;

@property (nonatomic ,strong) MAMapView *mapView;
@property (nonatomic ,strong) driverInfo *DriverInfo;
@end

@implementation waitDriverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"lat====%f",self.starLat);
    NSLog(@"lng====%f",self.starLng);
    self.navigationItem.title = @"等待司机接单";
    
    [self initMap];
    [self.view addSubview:self.DriverInfo];

}

-(void)initMap{
    [AMapServices sharedServices].enableHTTPS = YES;
    _mapView = [[MAMapView alloc]initWithFrame: self.view.bounds];
    _mapView.delegate = self;
    _mapView.allowsAnnotationViewSorting = NO;
    [self.view addSubview:_mapView];
    
    _mapView.showsUserLocation = YES;
    _mapView.userTrackingMode = MAUserTrackingModeFollow;
}

-(driverInfo *)DriverInfo{
    if (!_DriverInfo) {
        _DriverInfo = [[driverInfo alloc]initWithFrame:CGRectMake(0, self.view.bounds.size.height-210, self.view.bounds.size.width, 200)];
        _DriverInfo.backgroundColor = [UIColor whiteColor];
    }
    return _DriverInfo;
}

-(void)setupData{
    
    _startCoordinate.latitude = _starLat;
    _startCoordinate.longitude = _starLng;
    
    [self initAnnotation];
}

-(void)initAnnotation{
    
    
    MAPointAnnotation *startAnnotation = [[MAPointAnnotation alloc]init];
    startAnnotation.coordinate = _startCoordinate;
    startAnnotation.title = @"起点";
    self.startAnnotation = startAnnotation;
    
//    MAPointAnnotation *driverAnnotation = [[MAPointAnnotation alloc]init];
//    driverAnnotation.coordinate = _driverCoordinate;
//    driverAnnotation.title = @"司机";
//    self.driverAnnotation = driverAnnotation;
    
    [self.mapView addAnnotation:self.startAnnotation];
//    [self.mapView addAnnotation:self.driverAnnotation];
    [self.mapView showAnnotations:@[self.startAnnotation] edgePadding:UIEdgeInsetsMake(120, 80, 140, 80) animated:YES];
    // [self searchRoutePlanningDrive];
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *customReuseIdentifier = @"customReuseIdentifier";
        
        growAnnotationView *annotationView = (growAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:customReuseIdentifier];
        
        if (annotationView == nil)
        {
            annotationView = [[growAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"growView"];
            
            annotationView.image = [UIImage imageNamed:@"default_navi_route_startpoint"];
            annotationView.centerOffset = CGPointMake(0, -(annotationView.image.size.height / 2.0));
            
        }
        
        return annotationView;
    }
    
    return nil;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end
