//
//  waitDriverViewController.h
//  iOS-trip-search
//
//  Created by yaoqianghong on 2018/9/18.
//  Copyright © 2018年 Amap. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface waitDriverViewController : UIViewController
@property (nonatomic) CGFloat  starLat;
@property (nonatomic) CGFloat  starLng;
@property (nonatomic ,strong) NSString *endLat;
@property (nonatomic ,strong) NSString *endlng;
@property (nonatomic ,strong) NSString *carType;
@end
