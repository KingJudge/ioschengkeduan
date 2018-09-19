//
//  perHeaderView.m
//  iOS-trip-search
//
//  Created by Aydin on 2018/9/19.
//  Copyright © 2018年 Amap. All rights reserved.
//

#import "perHeaderView.h"
@interface perHeaderView()
@property (nonatomic ,strong) UIImageView *userImageView;
@property (nonatomic ,strong) UILabel *userNameLabel;
@end
@implementation perHeaderView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _userImageView = [[UIImageView alloc]init];
        [_userImageView setImage:[UIImage imageNamed:@"perCenter"]];
        _userImageView.layer.cornerRadius = 30;
        _userImageView.layer.masksToBounds = YES;
        [self addSubview:_userImageView];
        [_userImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.centerY.equalTo(self);
            make.width.equalTo(@60);
            make.height.equalTo(@60);
        }];
        
        _userNameLabel = [[UILabel alloc]init];
        _userNameLabel.text = @"用户名";
        _userNameLabel.font = [UIFont systemFontOfSize:20];
        _userNameLabel.textColor = [UIColor blackColor];
        [self addSubview:_userNameLabel];
        [_userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_userImageView.mas_bottom).offset(10);
            make.centerX.equalTo(self);
            make.height.equalTo(@30);
        }];
    }
    return self;
}

@end
