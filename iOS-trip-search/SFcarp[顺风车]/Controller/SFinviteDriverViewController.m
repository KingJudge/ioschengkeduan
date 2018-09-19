//
//  SFinviteDriverViewController.m
//  iOS-trip-search
//
//  Created by yaoqianghong on 2018/9/19.
//  Copyright © 2018年 Amap. All rights reserved.
//

#import "SFinviteDriverViewController.h"

@interface SFinviteDriverViewController ()
@property (nonatomic ,strong) UIImageView *backGroundImageView;
@property (nonatomic ,strong) UIButton *imageButton;
@end

@implementation SFinviteDriverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor yellowColor];
    
    _backGroundImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ico_cross_bg"]];
    _backGroundImageView.frame = CGRectMake(0, -64, self.view.bounds.size.width, self.view.bounds.size.height);
    _backGroundImageView.userInteractionEnabled = YES;
    [self.view addSubview:_backGroundImageView];
    
    _imageButton = [[UIButton alloc]init];
    [_imageButton setTitle:@"成为顺风车主" forState:UIControlStateNormal];
    [_imageButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_imageButton setBackgroundColor:[UIColor orangeColor]];
    [_imageButton addTarget:self action:@selector(BecomeDriver:) forControlEvents:UIControlEventTouchUpInside];
    _imageButton.layer.cornerRadius = 25;
    [self.backGroundImageView addSubview:_imageButton];
    [_imageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.backGroundImageView.mas_bottom).offset(-40);
        make.centerX.equalTo(self.view);
        make.width.equalTo(@300);
        make.height.equalTo(@50);
    }];
}

-(void)BecomeDriver:(UIButton *)sender{
    NSLog(@"haha");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
