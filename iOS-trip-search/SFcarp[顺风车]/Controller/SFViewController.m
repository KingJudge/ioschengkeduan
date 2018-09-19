//
//  SFViewController.m
//  iOS-trip-search
//
//  Created by 袁文轶 on 2017/11/8.
//  Copyright © 2017年 Amap. All rights reserved.
//

#import "SFViewController.h"

#import "SFcityViewController.h"
#import "SFotherCityViewController.h"
#import "SFinviteDriverViewController.h"

@interface SFViewController ()

@property (nonatomic, strong) UIScrollView *mainScrollView;

@end

@implementation SFViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    self.contentViewFrame = CGRectMake(0, 64, screenSize.width, screenSize.height - 64);
    self.tabBar.frame = CGRectMake(0, 20, screenSize.width, 44);
    
    self.tabBar.itemTitleColor = [UIColor lightGrayColor];
    self.tabBar.itemTitleSelectedColor = [UIColor orangeColor];
    self.tabBar.itemTitleFont = [UIFont systemFontOfSize:17];
    self.tabBar.itemTitleSelectedFont = [UIFont systemFontOfSize:22];
    self.tabBar.leftAndRightSpacing = 100;
    
    [self setContentScrollEnabledAndTapSwitchAnimated:NO];
    [self.tabBar setScrollEnabledAndItemFitTextWidthWithSpacing:40];
    self.tabBar.itemFontChangeFollowContentScroll = YES;
    
    self.tabBar.itemSelectedBgScrollFollowContent = YES;
    self.tabBar.itemSelectedBgColor = [UIColor orangeColor];
    [self.tabBar setItemSelectedBgInsets:UIEdgeInsetsMake(40, 15, 0, 15) tapSwitchAnimated:NO];
    [self initViewControllers];
    self.navigationItem.titleView = self.tabBar;
}

- (void)initViewControllers {
    SFcityViewController *controller1 = [[SFcityViewController alloc] init];
    controller1.yp_tabItemTitle = @"市内";
    
    SFotherCityViewController *controller2 = [[SFotherCityViewController alloc] init];
    controller2.yp_tabItemTitle = @"跨市";
    
    SFinviteDriverViewController *controller3 = [[SFinviteDriverViewController alloc] init];
    controller3.yp_tabItemTitle = @"司机";
    
    
    
    self.viewControllers = [NSMutableArray arrayWithObjects:controller1, controller2, controller3, nil];
    
}

@end
