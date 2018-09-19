//
//  comPleteHeaderView.m
//  iOS-trip-search
//
//  Created by yaoqianghong on 2018/9/19.
//  Copyright © 2018年 Amap. All rights reserved.
//

#import "comPleteHeaderView.h"

@interface comPleteHeaderView()
@property (nonatomic ,strong) UIImageView *userImageView;
@property (nonatomic ,strong) UILabel *userPhoneLabel;
@property (nonatomic ,strong) UILabel *userWorkLabel;
@property (nonatomic ,strong) UILabel *userAutographLabel;
@end

@implementation comPleteHeaderView

-(instancetype)initWithFrame:(CGRect)frame{
    self= [super initWithFrame:frame];
    if(self){
        _userImageView = [[UIImageView alloc]init];
        _userImageView.backgroundColor = [UIColor brownColor];
        _userImageView.layer.cornerRadius = 30;
        _userImageView.layer.masksToBounds = YES;
        [self addSubview:_userImageView];
        [_userImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(30);
            make.centerX.equalTo(self);
            make.width.equalTo(@60);
            make.height.equalTo(@60);
        }];
        
        _userPhoneLabel = [[UILabel alloc]init];
        _userPhoneLabel.text = @"15666666666";
        _userPhoneLabel.font = [UIFont systemFontOfSize:18];
        _userPhoneLabel.textColor = [UIColor lightGrayColor];
        [self addSubview:_userPhoneLabel];
        [_userPhoneLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_userImageView.mas_bottom).offset(5);
            make.centerX.equalTo(self);
            make.height.equalTo(@20);
        }];
        
        _userWorkLabel = [[UILabel alloc]init];
        _userWorkLabel.text = @"行业·公司·职业";
        _userWorkLabel.textColor = [UIColor lightGrayColor];
        _userWorkLabel.font = [UIFont systemFontOfSize:15];
        [self addSubview:_userWorkLabel];
        [_userWorkLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_userPhoneLabel.mas_bottom).offset(10);
            make.centerX.equalTo(self);
            make.height.equalTo(@20);
        }];
        
        _userAutographLabel = [[UILabel alloc]init];
        _userAutographLabel.text = @"个性签名";
        _userAutographLabel.textColor = [UIColor lightGrayColor];
        _userAutographLabel.font = [UIFont systemFontOfSize:15];
        [self addSubview:_userAutographLabel];
        [_userAutographLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_userWorkLabel.mas_bottom).offset(10);
            make.centerX.equalTo(self);
            make.height.equalTo(@20);
        }];
    }
    return self;
}

@end
