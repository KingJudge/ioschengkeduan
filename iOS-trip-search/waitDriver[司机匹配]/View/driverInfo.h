//
//  driverInfo.h
//  iOS-trip-search
//
//  Created by Aydin on 2018/9/18.
//  Copyright © 2018年 Amap. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol driverInfoDelegate <NSObject>
-(void)baojing:(UIButton *)button;
-(void)callDriv:(UIButton *)button;
@end

@interface driverInfo : UIView
@property (assign, nonatomic) id<driverInfoDelegate> delegate;
@end
