//
//  SFcityViewController.m
//  iOS-trip-search
//
//  Created by Aydin on 2018/9/19.
//  Copyright © 2018年 Amap. All rights reserved.
//

#import "SFcityViewController.h"
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
@interface SFcityViewController ()<AMapSearchDelegate, MyCityListViewDelegate, MySearchBarViewDelegate, MySearchResultViewDelegate>
@property (nonatomic, strong) AMapSearchAPI *search;
@property (nonatomic, strong) MyCityListView *cityListView;
@property (nonatomic, strong) MySearchResultView *searchResultView;
@property (nonatomic, strong) UIView *listContainerView;
@property (nonatomic, strong) MyLocationView *locationView;
@property (nonatomic, strong) MySearchBarView *searchBar;
@property (nonatomic, assign) CurrentGetLocationType currentLocationType;
@property (nonatomic, assign) CurrentAddressSettingType currentAddressSettingType;

@end

@implementation SFcityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _search = [[AMapSearchAPI alloc]init];
    _search.delegate = self;
    [self initLocationView];
    [self initSearchBarView];
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
    
//    if (self.mapView.userLocation.location) {
//        request.location = [NSString stringWithFormat:@"%f,%f", self.mapView.userLocation.location.coordinate.longitude, self.mapView.userLocation.location.coordinate.latitude];
//    }
//    
//    [self.search AMapInputTipsSearch:request];
//    
//    self.currentTipRequest = request;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end
