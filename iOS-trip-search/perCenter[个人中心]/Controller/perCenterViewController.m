//
//  perCenterViewController.m
//  iOS-trip-search
//
//  Created by Aydin on 2018/9/19.
//  Copyright © 2018年 Amap. All rights reserved.
//

#import "perCenterViewController.h"
#import "perHeaderView.h"
#import "comPleteInfoViewController.h"
@interface perCenterViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic ,strong) perHeaderView *perHeader;
@property (nonatomic ,strong) UITableView *perTableview;
@property (nonatomic ,strong) NSArray *TitleArray;
@property (nonatomic ,strong) NSArray *ImageArray;
@property (nonatomic ,strong) UIButton *rightBtn;
@property (nonatomic ,strong) UIButton *leftBtn;
@end

@implementation perCenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"个人中心";
    self.view.backgroundColor = [UIColor whiteColor];
    
    _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_rightBtn setTitle:@"修改信息" forState:UIControlStateNormal];
    [_rightBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [_rightBtn addTarget:self action:@selector(completeInfo) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:self.rightBtn];
    self.navigationItem.rightBarButtonItem = item;
    
    self.leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.leftBtn setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
    [self.leftBtn sizeToFit];
    self.leftBtn.tag = 1;
    [self.leftBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithCustomView:self.leftBtn];
    self.navigationItem.leftBarButtonItem = item1;
    
    _TitleArray = @[@"订单",@"安全",@"钱包",@"客服",@"设置",@"推荐有奖",@"车主招募"];
    _ImageArray = @[@"dingdan",@"anquan",@"qianbao",@"kefu",@"shezhi",@"tuijian",@"zhaomu"];
    
    [self.view addSubview:self.perTableview];
    self.perTableview.tableHeaderView = self.perHeader;
    
    
}



#pragma 初始化懒加载
-(perHeaderView *)perHeader{
    if (!_perHeader) {
        _perHeader = [[perHeaderView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height/4)];
        _perHeader.backgroundColor = [UIColor whiteColor];
    }
    return _perHeader;
}

-(UITableView *)perTableview{
    if (!_perTableview) {
        _perTableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStylePlain];
        _perTableview.backgroundColor = [UIColor whiteColor];
        _perTableview.separatorStyle = NO;
        _perTableview.delegate = self;
        _perTableview.dataSource = self;
    }
    return _perTableview;
}

-(NSArray *)TitleArray{
    if (!_TitleArray) {
        _TitleArray = [[NSArray alloc]init];
    }
    return _TitleArray;
}

-(NSArray *)ImageArray{
    if (!_ImageArray) {
        _ImageArray = [[NSArray alloc]init];
    }
    return _ImageArray;
}

#pragma-tableViewDelegate&dataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _TitleArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *TableSampleIdentifier = @"TableSampleIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TableSampleIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:TableSampleIdentifier];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = [_TitleArray objectAtIndex:indexPath.row];
    cell.imageView.image = [UIImage imageNamed:_ImageArray[indexPath.row]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"点击了==%@",_TitleArray[indexPath.row]);
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

-(void)backAction:(UIButton *)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)completeInfo{
    NSLog(@"完善信息");
    comPleteInfoViewController *completeInfo = [[comPleteInfoViewController alloc]init];
    [self.navigationController pushViewController:completeInfo animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
