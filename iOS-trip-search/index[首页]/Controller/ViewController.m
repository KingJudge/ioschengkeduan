//
//  ViewController.m
//  iOS-trip-search
//
//  Created by Aydin on 2017/5/24.
//  Copyright © 2017年 Amap. All rights reserved.
//

#import "ViewController.h"

#import "MyCityManager.h"
#import "MyRecordManager.h"
#import "MyLocation.h"

#import "MyCityListView.h"
#import "MySearchResultView.h"
#import "MySearchBarView.h"
#import "MyLocationView.h"

#import "AddressSettingViewController.h"
#import "ZJSwitch.h"

#import "waitDriverViewController.h"
#import "perCenterViewController.h"
#import "SFViewController.h"

#define kTableViewMargin    8
#define kNaviBarHeight      60
#define kLocationButtonHeight      48
#define Start_X          10.0f      // 第一个按钮的X坐标
#define Start_Y          10.0f     // 第一个按钮的Y坐标
#define Width_Space      5.0f      // 2个按钮之间的横间距
#define Height_Space     5.0f     // 竖间距
#define Button_Height   120.0f    // 高
#define Button_Width    120.0f    // 宽
typedef NS_ENUM(NSInteger, CurrentGetLocationType)
{
    CurrentGetLocationTypeStart = 0,
    CurrentGetLocationTypeEnd = 1,
};

typedef NS_ENUM(NSInteger, CurrentAddressSettingType)
{
    CurrentAddressSettingTypeNone = 0,
    CurrentAddressSettingTypeHome = 1,
    CurrentAddressSettingTypeCompany = 2,
};

@interface ViewController ()<MAMapViewDelegate, AMapSearchDelegate, MyCityListViewDelegate, MySearchBarViewDelegate, MySearchResultViewDelegate, AddressSettingViewControllerDelegate,UIScrollViewDelegate,SGPageTitleViewDelegate>

@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) AMapSearchAPI *search;

@property (nonatomic, strong) UIButton *titleButton;
@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, strong) UIButton *mainLeftButton;
@property (nonatomic, strong) UIButton *confirmButton;
@property (nonatomic, strong) UIView *choseCarView;
@property (nonatomic, strong) UIButton *buttonSetting;
@property (nonatomic, strong) UIButton *buttonLocation;
@property (nonatomic, strong) UIScrollView *chooseScrollView;
@property (nonatomic, strong) NSArray *titleArr;
@property (nonatomic, strong) SGPageTitleView *pageTitleView;
@property (nonatomic, strong) ZJSwitch *switch2;
@property (nonatomic ,strong) NSString *carType;

@property (nonatomic, strong) UIView *listContainerView;

@property (nonatomic, strong) MyCityListView *cityListView;
@property (nonatomic, strong) MySearchResultView *searchResultView;

@property (nonatomic, strong) MySearchBarView *searchBar;
@property (nonatomic, strong) MyLocationView *locationView;

@property (nonatomic, assign) CurrentGetLocationType currentLocationType;
@property (nonatomic, assign) CurrentAddressSettingType currentAddressSettingType;

@property (nonatomic, strong) AMapInputTipsSearchRequest *currentTipRequest;
@property (nonatomic, strong) AMapReGeocodeSearchRequest *currentRegeoRequest;

@property (nonatomic, assign) BOOL locationRegeoRequested; //初次定位逆地理是否请求过
@property (nonatomic, assign) BOOL regeoSearchNeeded; //地图每次移动后是否需要进行逆地理请求

@property (nonatomic, strong) MAPointAnnotation *startAnnotation;
@property (nonatomic, strong) MAPointAnnotation *endAnnotation;

@property (nonatomic, strong) AMapLocalWeatherLive *weatherLiveView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationController.navigationBar.translucent = NO;
    self.extendedLayoutIncludesOpaqueBars = YES;
    
    [self initMapView];
    [self setupPage];
    [self initTitleButton];
    [self initSearchBarView];
    
    [self initLocationView];
    [self initListContainerView];
    
    [self initControlButtons];
    
    self.regeoSearchNeeded = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - initialization

- (void)initMapView
{
    
    [AMapServices sharedServices].apiKey = @"7ad7dfc26d1a279cc174225e2ed8c933";
    
    self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.delegate = self;
    self.mapView.showsScale = NO;
    self.mapView.showsCompass = NO;
    self.mapView.rotateEnabled = NO;
    self.mapView.rotateCameraEnabled = NO;
    
    self.mapView.runLoopMode = NSDefaultRunLoopMode;
    [self.mapView setShowsUserLocation:YES];
    
    [self.view addSubview:self.mapView];
    
    
    //search
    self.search = [[AMapSearchAPI alloc] init];
    self.search.delegate = self;
    
    

}
- (void)onWeatherSearchDone:(AMapWeatherSearchRequest *)request response:(AMapWeatherSearchResponse *)response
{
    //解析response获取天气信息，具体解析见 Demo
    
    _weatherLiveView = [response.lives firstObject];
    NSLog(@"%@,%@,%@",_weatherLiveView.weather,_weatherLiveView.temperature,_weatherLiveView.windDirection);
    
}
- (void)initTitleButton
{
    UIButton *titleButton = [[UIButton alloc] init];
    
    [titleButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    
    UIImage *image = [UIImage imageNamed:@"down_arrow"];
    [titleButton setImage:image forState:UIControlStateNormal];
    [titleButton sizeToFit];
    
    [titleButton addTarget:self action:@selector(titleButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    self.titleButton = titleButton;
    self.navigationItem.titleView = titleButton;
    
    [self updateTitleWithString:@"定位中..."];
    
    self.leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.leftButton setImage:[UIImage imageNamed:@"perCenter"] forState:UIControlStateNormal];
    [self.leftButton sizeToFit];
    self.leftButton.tag = 1;
    [self.leftButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithCustomView:self.leftButton];
    self.navigationItem.leftBarButtonItem = item1;

}

-(void)setupPage{
    _titleArr = @[@"出租车",@"专车",@"快车",@"顺风车"];
    SGPageTitleViewConfigure *configure = [SGPageTitleViewConfigure pageTitleViewConfigure];
    configure.indicatorScrollStyle = SGIndicatorScrollStyleHalf;
    configure.titleFont = [UIFont systemFontOfSize:15];
    configure.titleSelectedColor = [UIColor orangeColor];
    configure.indicatorColor = [UIColor orangeColor];
    
    self.pageTitleView = [SGPageTitleView pageTitleViewWithFrame:CGRectMake(0, 60, self.view.frame.size.width, 44) delegate:self titleNames:_titleArr configure:configure];
    _pageTitleView.selectedIndex = 1;
    [self.view addSubview:self.pageTitleView];
}
//pageTitleDelegate

-(void)pageTitleView:(SGPageTitleView *)pageTitleView selectedIndex:(NSInteger)selectedIndex{
    NSLog(@"选择了===%@",self.titleArr[selectedIndex]);
    _carType = [NSString stringWithFormat:@"%@",self.titleArr[selectedIndex]];
    SFViewController *sfCar = [[SFViewController alloc]init];
    switch (selectedIndex) {
            case 3:
            NSLog(@"顺风车");
            [self.navigationController pushViewController:sfCar animated:YES];
            break;
            
        default:
            break;
    }
}

- (void)pageContentScrollView:(SGPageContentScrollView *)pageContentScrollView progress:(CGFloat)progress originalIndex:(NSInteger)originalIndex targetIndex:(NSInteger)targetIndex {
    [self.pageTitleView setPageTitleViewWithProgress:progress originalIndex:originalIndex targetIndex:targetIndex];
}

- (void)initSearchBarView
{
    self.searchBar = [[MySearchBarView alloc] initWithFrame:CGRectMake(0, -kNaviBarHeight, self.view.bounds.size.width, kNaviBarHeight)];
    self.searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.searchBar.delegate = self;
    
    [self.view addSubview:self.searchBar];
}

- (void)initLocationView
{
    self.locationView = [[NSBundle mainBundle] loadNibNamed:@"MyLocationView" owner:nil options:nil].lastObject;
    self.locationView.frame = CGRectMake(0, 0, self.view.bounds.size.width - kTableViewMargin * 2, kLocationButtonHeight * 2);
    self.locationView.center = CGPointMake(self.view.center.x, CGRectGetHeight(self.view.bounds) - kLocationButtonHeight - kTableViewMargin);
    self.locationView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.locationView];
    //
    [self.locationView.startButton addTarget:self action:@selector(startLocationTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.locationView.endButton addTarget:self action:@selector(endLocationTapped:) forControlEvents:UIControlEventTouchUpInside];

    //
    self.confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.confirmButton setBackgroundColor:[UIColor colorWithRed:0.29 green:0.30 blue:0.35 alpha:1.00]];
    [self.confirmButton setTitle:@"确认呼叫" forState:UIControlStateNormal];
    [self.confirmButton setFrame:CGRectMake(0, 0, self.view.bounds.size.width - kTableViewMargin * 2, kLocationButtonHeight)];
    self.confirmButton.center = CGPointMake(self.view.center.x, CGRectGetHeight(self.view.bounds) - kLocationButtonHeight / 2.0 - kTableViewMargin);
    [self.confirmButton addTarget:self action:@selector(confirmAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.confirmButton];
    self.confirmButton.hidden = YES;
    
    self.choseCarView = [[UIView alloc]init];
    self.choseCarView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.choseCarView];
    
    [self.choseCarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.confirmButton.mas_top).offset(-5);
        make.width.equalTo(self.confirmButton);
        make.left.equalTo(self.confirmButton);
        make.height.equalTo(@180);
    }];
    
    self.chooseScrollView = [[UIScrollView alloc]init];
    self.chooseScrollView.backgroundColor = [UIColor brownColor];
    [self.choseCarView addSubview:self.chooseScrollView];
    [self.chooseScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.choseCarView.mas_top);
        make.left.equalTo(self.choseCarView.mas_left);
        make.width.equalTo(self.choseCarView.mas_width);
        make.height.equalTo(@140);
    }];
    for (int i = 0 ; i < 4; i++) {
        NSInteger index = i % 4;
        NSInteger page = i / 4;

        // 圆角按钮
        UIButton *mapBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        mapBtn.tag = i;//这句话不写等于废了
        mapBtn.frame = CGRectMake(index * (Button_Width + Width_Space) + Start_X, page  * (Button_Height + Height_Space)+Start_Y, Button_Width, Button_Height);
        [mapBtn setBackgroundColor:[UIColor yellowColor]];
        [self.chooseScrollView addSubview:mapBtn];
        //按钮点击方法
        [mapBtn addTarget:self action:@selector(mapBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    self.choseCarView.hidden = YES;

    //按钮滚动
}

- (void)initListContainerView
{
    self.listContainerView = [[UIView alloc] initWithFrame:CGRectMake(kTableViewMargin, CGRectGetMaxY(self.view.bounds), self.view.bounds.size.width - kTableViewMargin * 2, self.view.bounds.size.height - kTableViewMargin - kNaviBarHeight)];
    self.listContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.listContainerView.layer.shadowOpacity = 0.3;
    self.listContainerView.layer.shadowOffset = CGSizeMake(0, 0.5);
    [self.view addSubview:self.listContainerView];
    
    
    //
    _cityListView = [[MyCityListView alloc] initWithFrame:self.listContainerView.bounds];
    _cityListView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _cityListView.delegate = self;
    
    [self.listContainerView addSubview:_cityListView];
    
    _searchResultView = [[MySearchResultView alloc] initWithFrame:self.listContainerView.bounds];
    _searchResultView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _searchResultView.delegate = self;
    
    [_searchResultView updateAddressSetting];
    
    [self.listContainerView addSubview:_searchResultView];

}

- (void)initControlButtons
{
    _switch2 = [[ZJSwitch alloc]initWithFrame:CGRectMake(0, 0, 60, 20)];
    _switch2.center = CGPointMake(10 + _switch2.bounds.size.width / 2.0, CGRectGetHeight(self.view.bounds) - 120 - _switch2.bounds.size.height / 2.0);
    _switch2.textColor = [UIColor blackColor];
    _switch2.tintColor = [UIColor colorWithRed:245.f/255.f green:245.f/255.f blue:245.f/255.f alpha:1.0];
    _switch2.onTintColor = [UIColor orangeColor];
    _switch2.backgroundColor = [UIColor clearColor];
    _switch2.onText = @"立即";
    _switch2.offText = @"预约";
    _switch2.on = YES;
    [self.mapView addSubview:_switch2];
    [_switch2 addTarget:self action:@selector(handleSwitchEvent:) forControlEvents:UIControlEventValueChanged];
    
    //location
    _buttonLocation = [[UIButton alloc] init];
    [_buttonLocation setImage:[UIImage imageNamed:@"icon_location"] forState:UIControlStateNormal];
    [_buttonLocation sizeToFit];
    _buttonLocation.center = CGPointMake(10 + _buttonLocation.bounds.size.width / 2.0, CGRectGetMinY(_switch2.frame) - 10 - _buttonLocation.bounds.size.height / 2.0);
    [self.mapView addSubview:_buttonLocation];
    self.buttonLocation.hidden = NO;
    [_buttonLocation addTarget:self action:@selector(onLocationAction:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (MAPointAnnotation *)startAnnotation
{
    if (_startAnnotation == nil) {
        _startAnnotation = [[MAPointAnnotation alloc] init];
        _startAnnotation.title = @"start";
    }
    
    return _startAnnotation;
}

- (MAPointAnnotation *)endAnnotation
{
    if (_endAnnotation == nil) {
        _endAnnotation = [[MAPointAnnotation alloc] init];
        _endAnnotation.title = @"end";
    }
    
    return _endAnnotation;
}

#pragma mark - handler

- (void)prepareForCall
{
    NSLog(@"prepareForCall");
    
    self.startAnnotation.lockedToScreen = NO;
    self.regeoSearchNeeded = NO;
    
    [self.leftButton setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
    self.leftButton.tag = 2;
    
    self.navigationItem.titleView = nil;
    self.title = @"确认呼叫";
    self.confirmButton.hidden = NO;
    self.choseCarView.hidden = NO;
    
    self.locationView.hidden = YES;
    self.buttonSetting.hidden = YES;
    self.buttonLocation.hidden = YES;
}

- (void)resetForLocationChoose
{
    NSLog(@"resetForLocationChoose");
    //从确定呼叫返回
    
    //12313
    self.regeoSearchNeeded = YES;
    self.locationView.endLocation = nil;
    [self addPositionAnnotation:self.endAnnotation forLocation:nil];
    
    [self.leftButton setImage:[UIImage imageNamed:@"perCenter"] forState:UIControlStateNormal];
    self.leftButton.tag = 1;
    
    self.navigationItem.titleView = self.titleButton;
    self.confirmButton.hidden = YES;
    self.choseCarView.hidden = YES;
    self.locationView.hidden = NO;
    self.buttonLocation.hidden = NO;
}

- (void)updateCurrentCity:(MyCity *)currentCity
{
    [MyCityManager sharedInstance].currentCity = currentCity;
    self.searchBar.seachCity = currentCity;
    
    [self updateTitleWithString:currentCity.name];
}

- (void)locatingCurrentCity
{
    if ([MyCityManager sharedInstance].locationCity) {
        return;
    }
    
    if (self.locationRegeoRequested) {
        return;
    }
    
    self.locationRegeoRequested = YES;
    
    [self searchReGeocodeWithLocation:[AMapGeoPoint locationWithLatitude:self.mapView.userLocation.location.coordinate.latitude longitude:self.mapView.userLocation.location.coordinate.longitude]];
}

- (void)updateTitleWithString:(NSString *)title
{
    [self.titleButton setTitle:title forState:UIControlStateNormal];
    [self.titleButton sizeToFit];
    
    [self.titleButton setImageEdgeInsets:UIEdgeInsetsMake(0, self.titleButton.frame.size.width - self.titleButton.currentImage.size.width, 0, 0)];
    [self.titleButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -self.titleButton.currentImage.size.width, 0, self.titleButton.currentImage.size.width)];
    
    NSLog(@"title: %@", title);
    AMapWeatherSearchRequest *request = [[AMapWeatherSearchRequest alloc]init];
    request.city = title;
    request.type = AMapWeatherTypeLive;
    [self.search AMapWeatherSearch:request];
}

// 显示搜索&城市列表
- (void)showCityListViewOnlyCity:(BOOL)onlyCity
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.cityListView reset];
    self.searchResultView.poiArray = nil;
    
    self.searchBar.doubleSearchModeEnable = !onlyCity;
    self.searchBar.seachCity = [MyCityManager sharedInstance].currentCity;
    
    self.searchResultView.hidden = onlyCity;
    if (!onlyCity) {
        [self updateSearchResultForCurrentCity];
    }
    
    [self.searchBar reset];
    [self.searchBar becomeFirstResponder];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.listContainerView.frame = CGRectMake(kTableViewMargin, kTableViewMargin + kNaviBarHeight, self.listContainerView.frame.size.width, self.listContainerView.frame.size.height);
        
        self.searchBar.frame = CGRectMake(0, 0, self.view.bounds.size.width, kNaviBarHeight);
    }];
}

// 隐藏搜索&城市列表
- (void)hideCityListView
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.searchBar resignFirstResponder];
    self.searchBar.currentSearchKeywords = nil;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.listContainerView.frame = CGRectMake(kTableViewMargin, CGRectGetMaxY(self.view.bounds), self.listContainerView.frame.size.width, self.listContainerView.frame.size.height);
        
        self.searchBar.frame = CGRectMake(0, -kNaviBarHeight, self.view.bounds.size.width, kNaviBarHeight);
    }];
}

- (void)updateSearchResultForCurrentCity
{
    self.searchResultView.historyArray = [[MyRecordManager sharedInstance] historyArrayFilteredByCityName:self.searchBar.seachCity.name];
    self.searchResultView.poiArray = nil;
    [self searchTipsByKeyword:self.searchBar.currentSearchKeywords city:self.searchBar.seachCity];
}

- (void)addPositionAnnotation:(MAPointAnnotation *)annotation forLocation:(MyLocation *)location
{
    NSLog(@"add location :%@", location.name);
    
    if (location == nil) {
        [self.mapView removeAnnotation:annotation];
    }
    else {
        annotation.coordinate = location.coordinate;
        
        [self.mapView addAnnotation:annotation];
    }
    
    if (self.locationView.startLocation && self.locationView.endLocation) {
        [self.mapView showAnnotations:@[self.startAnnotation, self.endAnnotation] edgePadding:UIEdgeInsetsMake(120, 80, 140, 80) animated:YES];
        
        //已经有了起点和终点
        [self prepareForCall];
    }
    else if (self.locationView.startLocation){ // startAnnotation 应该保证一直存在
        [self.mapView showAnnotations:@[self.startAnnotation] animated:NO];
        [self.mapView setZoomLevel:17.5 animated:YES];
        
        self.startAnnotation.lockedScreenPoint = CGPointMake(CGRectGetMidX(self.mapView.bounds), CGRectGetMidY(self.mapView.bounds));
        self.startAnnotation.lockedToScreen = YES;
    }
}

- (void)setLocation:(MyLocation *)location forType:(CurrentGetLocationType)type
{
    if (type == CurrentGetLocationTypeStart) {
        self.locationView.startLocation = location;
        [self addPositionAnnotation:self.startAnnotation forLocation:location];
    }
    else {
        self.locationView.endLocation = location;
        [self addPositionAnnotation:self.endAnnotation forLocation:location];
    }
}

- (void)calculateStartLocationWithRegeocode:(AMapReGeocode *)regeocode
{
    
    NSArray<AMapPOI *> *sortedPOI = regeocode.pois;
    NSArray<AMapRoadInter *> *sortedInter = [regeocode.roadinters sortedArrayUsingComparator:^NSComparisonResult(AMapRoadInter * _Nonnull obj1, AMapRoadInter * _Nonnull obj2) {
        return obj1.distance > obj2.distance;
    }];

#define kPickupSpotDistanceThreshold    15

    MyLocation *location = [[MyLocation alloc] init];
    
    AMapPOI *firstPOI = sortedPOI.firstObject;
    
    if (firstPOI) {
        location.name = [NSString stringWithFormat:@"%@附近", firstPOI.name];
        location.coordinate = CLLocationCoordinate2DMake(self.currentRegeoRequest.location.latitude, self.currentRegeoRequest.location.longitude);
        
        if (firstPOI.distance < kPickupSpotDistanceThreshold) {
            location.name = firstPOI.name;
            location.coordinate = CLLocationCoordinate2DMake(firstPOI.location.latitude, firstPOI.location.longitude);
        }
    }
    
    //如果满足条件，则使用交叉路口
    AMapRoadInter *firstInter = sortedInter.firstObject;
    if (firstInter) {
        if (firstInter.distance < kPickupSpotDistanceThreshold && firstInter.distance < firstPOI.distance) {
            location.name = [NSString stringWithFormat:@"%@和%@交叉路口", firstInter.firstName, firstInter.secondName];
            location.coordinate = CLLocationCoordinate2DMake(firstInter.location.latitude, firstInter.location.longitude);
        }
    }
    
    
    // just regeo for poi
    self.locationView.startLocation = location;
    
    [self addPositionAnnotation:self.startAnnotation forLocation:self.locationView.startLocation];
}

#pragma mark - Search

- (void)searchTipsByKeyword:(NSString *)keyword city:(MyCity *)city
{
    if (keyword.length == 0) {
        return;
    }
    
    AMapInputTipsSearchRequest *request = [[AMapInputTipsSearchRequest alloc] init];
    request.city = city.name;
    request.cityLimit = YES;
    request.keywords = keyword;
    
    if (self.mapView.userLocation.location) {
        request.location = [NSString stringWithFormat:@"%f,%f", self.mapView.userLocation.location.coordinate.longitude, self.mapView.userLocation.location.coordinate.latitude];
    }
    
    [self.search AMapInputTipsSearch:request];
    
    self.currentTipRequest = request;
}

//- (void)searchPoiByKeyword:(NSString *)keyword city:(MyCity *)city
//{
//    AMapPOIKeywordsSearchRequest *request = [MyRecordManager POISearchRequestWithKeyword:keyword inCity:city];
//    
//    [self.search AMapPOIKeywordsSearch:request];
//    
//    self.currentRequest = request;
//}

- (void)searchReGeocodeWithLocation:(AMapGeoPoint *)location
{
    AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];
    
    regeo.location = location;
    regeo.requireExtension = YES;
    [self.search AMapReGoecodeSearch:regeo];
    
    self.currentRegeoRequest = regeo;
}

- (void)searchGeocodeWithName:(NSString *)cityName
{
    AMapGeocodeSearchRequest *geo = [[AMapGeocodeSearchRequest alloc] init];
    geo.address = cityName;
    geo.city = cityName;
    [self.search AMapGeocodeSearch:geo];
}

#pragma mark - actions

- (void)confirmAction:(UIButton *)sender
{
    NSLog(@"confirm!!!!!");
    waitDriverViewController *waitDriver = [[waitDriverViewController alloc]init];
    waitDriver.starLat = self.startAnnotation.coordinate.latitude;
    waitDriver.starLng = self.startAnnotation.coordinate.longitude;
    waitDriver.carType = self.carType;
    NSLog(@"lat====%f",self.startAnnotation.coordinate.latitude);
    NSLog(@"lng====%f",self.startAnnotation.coordinate.longitude);
    NSLog(@"Elat====%f",self.endAnnotation.coordinate.latitude);
    NSLog(@"Elng====%f",self.endAnnotation.coordinate.longitude);
    [self.navigationController pushViewController:waitDriver animated:YES];
}

- (void)backAction:(UIButton *)sender
{
    if(sender.tag == 2){
    [self resetForLocationChoose];
    }else{
        perCenterViewController *per = [[perCenterViewController alloc]init];
        [self.navigationController pushViewController:per animated:YES];
    }
}

- (void)handleSwitchEvent:(id)sender
{
    NSLog(@"wocao%s", __FUNCTION__);
    NSLog(@"zt%d",_switch2.isOn);
}

- (void)onLocationAction:(UIButton *)sender
{
    self.mapView.userTrackingMode = MAUserTrackingModeFollow;
    
    if (self.regeoSearchNeeded) {
        [self searchReGeocodeWithLocation:[AMapGeoPoint locationWithLatitude:self.mapView.userLocation.location.coordinate.latitude longitude:self.mapView.userLocation.location.coordinate.longitude]];
    }
}

-(void)mapBtnClick:(UIButton *)sender{
    NSLog(@"haha");
}

- (void)startLocationTapped:(UIButton *)sender
{
    self.currentLocationType = CurrentGetLocationTypeStart;
    self.searchBar.searchTextPlaceholder = @"您现在在哪儿";
    
    [self showCityListViewOnlyCity:NO];
}

- (void)endLocationTapped:(UIButton *)sender
{
    self.currentLocationType = CurrentGetLocationTypeEnd;
    self.searchBar.searchTextPlaceholder = @"您要去哪儿";
    
    [self showCityListViewOnlyCity:NO];
}

- (void)titleButtonTapped:(UIButton *)sender
{
    self.searchBar.searchTextPlaceholder = @"请输入出发城市";
    [self showCityListViewOnlyCity:YES];
}

#pragma mark - MySearchBarViewDelegate

- (void)searchBarView:(MySearchBarView *)searchBarView didSearchTextChanged:(NSString *)text
{
    if (!self.searchBar.doubleSearchModeEnable) {
        self.cityListView.filterKeywords = text;
    }
    else {
        
        [self searchTipsByKeyword:text city:[MyCityManager sharedInstance].currentCity];
        //搜索的时候不显示历史记录
        self.searchResultView.historyArray = nil;
        self.searchResultView.poiArray = nil;
    }
}

- (void)searchBarView:(MySearchBarView *)searchBarView didCityTextChanged:(NSString *)text
{
    if (self.searchBar.doubleSearchModeEnable) {
        self.cityListView.filterKeywords = text;
    }
}

- (void)didCancelButtonTapped:(MySearchBarView *)searchBarView
{
    [self hideCityListView];
}

- (void)searchBarView:(MySearchBarView *)searchBarView didCityTextShown:(BOOL)shown
{
    self.searchResultView.hidden = shown;
}

#pragma mark - MyCityListViewDelegate

- (void)cityListView:(MyCityListView *)listView didCitySelected:(MyCity *)city
{
    MyCity *oldCity = [MyCityManager sharedInstance].currentCity;
    
    //单独改变当前城市
    if (!self.searchBar.doubleSearchModeEnable) {
        
        //单独改变城市时修改当前城市
        [self updateCurrentCity:city];
        
        [self hideCityListView];
        
        // 城市改变后清空
        if (![oldCity.name isEqualToString:city.name]) {
            self.locationView.startLocation = nil;
            self.locationView.endLocation = nil;
            // remove
            [self.mapView removeAnnotation:self.startAnnotation];
            [self.mapView removeAnnotation:self.endAnnotation];
            
        }
        
        //如果当前城市是定位城市直接进行当前定位的逆地理，否则进行地理编码获取城市位置。
        if ([city.name isEqualToString:[MyCityManager sharedInstance].locationCity.name]) {
            
            [self.mapView setCenterCoordinate:self.mapView.userLocation.location.coordinate animated:YES];
            
            [self searchReGeocodeWithLocation:[AMapGeoPoint locationWithLatitude:self.mapView.userLocation.location.coordinate.latitude longitude:self.mapView.userLocation.location.coordinate.longitude]];
        }
        else {
            [self searchGeocodeWithName:city.name];
        }
    }
    else {
        
        if (![oldCity.name isEqualToString:city.name]) {
            self.searchBar.seachCity = city; // 只修改搜索city
            [self updateSearchResultForCurrentCity];
        }
    }
}

- (void)didCityListViewwScroll:(MyCityListView *)listView
{
    [self.searchBar resignFirstResponder];
}


#pragma mark - MySearchResultViewDelegate

- (void)resultListView:(MySearchResultView *)listView didPOISelected:(MyLocation *)poi
{
    [self setLocation:poi forType:self.currentLocationType];
    [[MyRecordManager sharedInstance] addHistoryRecord:poi];
    
    [self hideCityListView];
}

- (void)resultListView:(MySearchResultView *)listView didHomeSelected:(MyLocation *)home
{
    if (home) {
        
        [self setLocation:home forType:self.currentLocationType];
        [self hideCityListView];
    }
    else {
        // set home
        self.currentAddressSettingType = CurrentAddressSettingTypeHome;
        AddressSettingViewController *vc = [[AddressSettingViewController alloc] init];
        vc.delegate = self;
        vc.currentCity = [MyCityManager sharedInstance].locationCity;
        vc.searchTextPlaceholder = @"输入家的地址";
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)resultListView:(MySearchResultView *)listView didCompanySelected:(MyLocation *)company
{
    if (company) {
        [self setLocation:company forType:self.currentLocationType];
        [self hideCityListView];
    }
    else {
        // set company
        self.currentAddressSettingType = CurrentAddressSettingTypeCompany;
        AddressSettingViewController *vc = [[AddressSettingViewController alloc] init];
        vc.delegate = self;
        vc.currentCity = [MyCityManager sharedInstance].locationCity;
        vc.searchTextPlaceholder = @"输入公司地址";
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)didResultListViewScroll:(MySearchResultView *)listView
{
    [self.searchBar resignFirstResponder];
}

#pragma mark - MAMapViewDelegate

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    if (!updatingLocation) {
        return;
    }
    
    [self locatingCurrentCity];
}

- (void)mapView:(MAMapView *)mapView mapWillMoveByUser:(BOOL)wasUserAction
{
    if (!wasUserAction) {
        return;
    }
    if (self.regeoSearchNeeded) {
        self.locationView.startLocation = nil;
    }
}

- (void)mapView:(MAMapView *)mapView mapDidMoveByUser:(BOOL)wasUserAction
{
    if (!wasUserAction) {
        return;
    }
    //移动结束后更新上车点
    if (self.regeoSearchNeeded) {
        [self searchReGeocodeWithLocation:[AMapGeoPoint locationWithLatitude:self.mapView.centerCoordinate.latitude longitude:self.mapView.centerCoordinate.longitude]];
    }
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAUserLocation class]]) {
        return nil;
    }
    
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *pointReuseIndetifier = @"pointReuseIndetifier";
        MAAnnotationView *annotationView = (MAAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndetifier];
            
            annotationView.canShowCallout = NO;
        }
        
        annotationView.image = (annotation == self.startAnnotation) ? [UIImage imageNamed:@"default_navi_route_startpoint"] : [UIImage imageNamed:@"default_navi_route_endpoint"];
        annotationView.centerOffset = CGPointMake(0, -10);
        
        return annotationView;
    }
    
    return nil;

}

#pragma mark - AddressSettingViewControllerDelegate

- (void)addressSettingViewController:(AddressSettingViewController *)viewController didPOISelected:(MyLocation *)poi
{
    if (self.currentAddressSettingType == CurrentAddressSettingTypeHome) {
        
        [MyRecordManager sharedInstance].home = poi;
    }
    else if (self.currentAddressSettingType == CurrentAddressSettingTypeCompany) {
        [MyRecordManager sharedInstance].company = poi;
    }
    
    [self.searchResultView updateAddressSetting];
    [self.navigationController popViewControllerAnimated:YES];
    self.currentAddressSettingType = CurrentAddressSettingTypeNone;
}

- (void)didCancelButtonTappedForAddressSettingViewController:(AddressSettingViewController *)viewController
{
    [self.navigationController popViewControllerAnimated:YES];
    self.currentAddressSettingType = CurrentAddressSettingTypeNone;
}


#pragma mark - AMapSearchDelegate

- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
    NSLog(@"search error :%@", error);
}

- (void)onInputTipsSearchDone:(AMapInputTipsSearchRequest *)request response:(AMapInputTipsSearchResponse *)response
{
    if (self.currentTipRequest == request) {
        NSMutableArray *locations = [NSMutableArray array];
        for (AMapTip *tip in response.tips) {
            MyLocation *loc = [MyLocation locationWithTip:tip city:request.city];
            if (loc) {
                [locations addObject:loc];
            }
        }
        
        self.searchResultView.poiArray = locations;
    }
}

- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    if (response.regeocode == nil || request != self.currentRegeoRequest) {
        return;
    }
    
    if ([MyCityManager sharedInstance].locationCity == nil) {
        [MyCityManager sharedInstance].locationCity = [[MyCity alloc] init];
        
        
        NSString *city = response.regeocode.addressComponent.city;
        
        //为了和本地数据源保持一直，去掉“市”。
        if ([city hasSuffix:@"市"]) {
            city = [city substringToIndex:city.length - 1];
        }
        [MyCityManager sharedInstance].locationCity.name = city;
        
        self.cityListView.locationCity = [MyCityManager sharedInstance].locationCity;
        
        if ([MyCityManager sharedInstance].currentCity == nil) {
            [self updateCurrentCity:[MyCityManager sharedInstance].locationCity];
        }

    }
    
    [self calculateStartLocationWithRegeocode:response.regeocode];
}

- (void)onGeocodeSearchDone:(AMapGeocodeSearchRequest *)request response:(AMapGeocodeSearchResponse *)response
{
    if (response.geocodes.count == 0)
    {
        return;
    }
    AMapGeocode *geocode = response.geocodes.firstObject;
    [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(geocode.location.latitude, geocode.location.longitude) animated:YES];
    
    [self searchReGeocodeWithLocation:geocode.location];
}

@end
