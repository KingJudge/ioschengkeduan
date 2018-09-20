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
@property (nonatomic ,strong) UIButton * callPlicemen;
@property (nonatomic ,strong) UIButton * callDriver;

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
        
        _callPlicemen = [UIButton buttonWithType:UIButtonTypeCustom];
        [_callPlicemen setTitle:@"报警" forState:UIControlStateNormal];
        _callPlicemen.frame = CGRectMake(10, self.bounds.size.height-35, self.bounds.size.width/4, 30);
        _callPlicemen.tag = 1;
        [_callPlicemen setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_callPlicemen addTarget:self action:@selector(callPD:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_callPlicemen];
//        [_callPlicemen mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.bottom.equalTo(self.mas_bottom).offset(-5);
//            make.left.equalTo(self.mas_left).offset(10);
//            make.height.equalTo(@30);
//            make.width.equalTo(@100);
//        }];
        
        _callDriver = [[UIButton alloc]init];
        [_callDriver setTitle:@"联系司机" forState:UIControlStateNormal];
        _callDriver.tag = 2;
        [_callDriver setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_callDriver addTarget:self action:@selector(callDriver:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_callDriver];
        [_callDriver mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_callPlicemen.mas_top);
            make.left.equalTo(_callPlicemen.mas_right);
            make.width.equalTo(_callPlicemen);
            make.height.equalTo(_callPlicemen);
        }];
        
        
    }
    return self;
}

-(void)callPD:(UIButton *)sender{
    if ([_delegate respondsToSelector:@selector(baojing:)]) {
//        sender.tag = self.tag;
        [_delegate baojing:sender];
    }
}

-(void)callDriver:(UIButton *)sender{
    if ([_delegate respondsToSelector:@selector(callDriv:)]) {
//        sender.tag = self.tag;
        [_delegate callDriv:sender];
    }
}

@end
