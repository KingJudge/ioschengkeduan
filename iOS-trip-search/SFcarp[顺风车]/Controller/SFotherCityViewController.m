//
//  SFotherCityViewController.m
//  iOS-trip-search
//
//  Created by Aydin on 2018/9/19.
//  Copyright © 2018年 Amap. All rights reserved.
//

#import "SFotherCityViewController.h"
#import "AddressSettingViewController.h"

#import "MyCityManager.h"
#import "MyRecordManager.h"
#import "MyLocation.h"

#import "MyCityListView.h"
#import "MySearchResultView.h"
#import "MySearchBarView.h"
#import "MyLocationView.h"
#define kTableViewMargin    8
#define kNaviBarHeight      60
#define kLocationButtonHeight      48
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
@interface SFotherCityViewController ()<AMapSearchDelegate, MyCityListViewDelegate, MySearchBarViewDelegate, MySearchResultViewDelegate,AddressSettingViewControllerDelegate>
@property (nonatomic, strong) AMapSearchAPI *search;
@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) MySearchResultView *searchResultView;
@property (nonatomic, strong) MyCityListView *cityListView;
@property (nonatomic, strong) MySearchBarView *searchBar;
@property (nonatomic, strong) MyLocationView *locationView;
@property (nonatomic, strong) UIView *listContainerView;
@property (nonatomic, assign) CurrentGetLocationType currentLocationType;
@property (nonatomic, assign) CurrentAddressSettingType currentAddressSettingType;
@property (nonatomic, strong) AMapPath *path;
@property (nonatomic, strong) AMapRoute *route;

@property (nonatomic, strong) MAPointAnnotation *startAnnotation;
@property (nonatomic, strong) MAPointAnnotation *endAnnotation;

@property (nonatomic, assign) BOOL locationRegeoRequested; //初次定位逆地理是否请求过
@property (nonatomic, assign) BOOL regeoSearchNeeded; //地图每次移动后是否需要进行逆地理请求

@property (nonatomic, strong) AMapInputTipsSearchRequest *currentTipRequest;
@property (nonatomic, strong) AMapReGeocodeSearchRequest *currentRegeoRequest;
@end

@implementation SFotherCityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _search = [[AMapSearchAPI alloc]init];
    _search.delegate = self;
    [self initLocationView];
    [self initSearchBarView];
    [self initListContainerView];
    self.regeoSearchNeeded = YES;
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
    self.locationView.layer.borderWidth = 1;
    self.locationView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.locationView.layer.cornerRadius = 10;
    self.locationView.layer.shadowOffset = CGSizeMake(4, 4);
    self.locationView.layer.shadowOpacity = 0.3f;
    self.locationView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.locationView.center = CGPointMake(self.view.center.x, 100);
    self.locationView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.locationView];
    
    //
    [self.locationView.startButton addTarget:self action:@selector(startLocationTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.locationView.endButton addTarget:self action:@selector(endLocationTapped:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)initListContainerView
{
    self.listContainerView = [[UIView alloc] initWithFrame:CGRectMake(kTableViewMargin, CGRectGetMaxY(self.view.bounds), self.view.bounds.size.width - kTableViewMargin * 2, self.view.bounds.size.height - kTableViewMargin - kNaviBarHeight)];
    self.listContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.listContainerView];
    
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

//提交订单

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



- (void)updateCurrentCity:(MyCity *)currentCity
{
    [MyCityManager sharedInstance].currentCity = currentCity;
    self.searchBar.seachCity = currentCity;
    
    
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
        self.listContainerView.frame = CGRectMake(kTableViewMargin, CGRectGetMaxY(self.view.bounds)+20, self.listContainerView.frame.size.width, self.listContainerView.frame.size.height);
        
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
        [self searchRoutePlanningDrive];
        //已经有了起点和终点
        
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
        NSLog(@"locationstar===>%@",location.name);
        
    }
    else {
        self.locationView.endLocation = location;
        [self addPositionAnnotation:self.endAnnotation forLocation:location];
        NSLog(@"locationend=====>%@",location.name);
        
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

#pragma mark - do search
-(void)searchRoutePlanningDrive{
    AMapDrivingRouteSearchRequest *navi = [[AMapDrivingRouteSearchRequest alloc]init];
    navi.requireExtension = YES;
    navi.strategy = 0;
    navi.origin = [AMapGeoPoint locationWithLatitude:_startAnnotation.coordinate.latitude longitude:_startAnnotation.coordinate.longitude];
    navi.destination = [AMapGeoPoint locationWithLatitude:_endAnnotation.coordinate.latitude longitude:_endAnnotation.coordinate.longitude];
    
    
    [self.search AMapDrivingRouteSearch:navi];
    
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

- (void)onSettingAction:(UIButton *)sender
{
    NSLog(@"clear the address setting for home & company");
    [MyRecordManager sharedInstance].home = nil;
    [MyRecordManager sharedInstance].company = nil;
    [[MyRecordManager sharedInstance] clearHistory];
    
    [self.searchResultView updateAddressSetting];
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
