//
//  driverInfo.m
//  iOS-trip-search
//
//  Created by Aydin on 2018/9/18.
//  Copyright © 2018年 Amap. All rights reserved.
//

#import "driverInfo.h"

@interface driverInfo()
@property (nonatomic ,strong) UIImageView * driverImage;
@property (nonatomic ,strong) UILabel *driverNameLabel;

@end

@implementation driverInfo

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        _driverImage = [[UIImageView alloc]init];
        _driverImage.backgroundColor = [UIColor brownColor];
        _driverImage.layer.cornerRadius = 25;
        [self addSubview:_driverImage];
        [_driverImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_top).offset(5);
            make.left.equalTo(self.mas_left).offset(5);
            make.width.equalTo(@50);
            make.height.equalTo(@50);
        }];
        
        _driverNameLabel = [[UILabel alloc]init];
        _driverNameLabel.text = @"ceshi";
        _driverNameLabel.font = [UIFont systemFontOfSize:18];
        _driverNameLabel.textColor =[UIColor blackColor];
        _driverNameLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_driverNameLabel];
        [_driverNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_driverImage.mas_top);
            make.left.equalTo(_driverImage.mas_right).offset(10);
            make.height.equalTo(@20);
        }];
    }
    return self;
}

@end
