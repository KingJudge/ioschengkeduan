//
//  AddressSettingViewController.h
//  iOS-trip-search
//
//  Created by Aydin on 2017/5/27.
//  Copyright © 2017年 Amap. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AddressSettingViewController;
@class MyLocation;
@class MyCity;

@protocol AddressSettingViewControllerDelegate <NSObject>
@optional

- (void)addressSettingViewController:(AddressSettingViewController *)viewController didPOISelected:(MyLocation *)poi;
- (void)didCancelButtonTappedForAddressSettingViewController:(AddressSettingViewController *)viewController;

@end

@interface AddressSettingViewController : UIViewController

@property (nonatomic, weak) id<AddressSettingViewControllerDelegate> delegate;
@property (nonatomic, strong) MyCity *currentCity; // 当前城市
@property (nonatomic, copy) NSString *searchTextPlaceholder;

@end
