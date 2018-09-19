//
//  comPleteInfoViewController.m
//  iOS-trip-search
//
//  Created by yaoqianghong on 2018/9/19.
//  Copyright © 2018年 Amap. All rights reserved.
//

#import "comPleteInfoViewController.h"
#import "comPleteHeaderView.h"
@interface comPleteInfoViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic ,strong) UITableView *myTableView;
@property (nonatomic ,strong) comPleteHeaderView *comPleteHeaderView;
@property (nonatomic ,strong) NSArray *titleArray;
@property (nonatomic ,strong) NSArray *imageArray;
@property (nonatomic ,strong) NSArray *detailArray;
@property (nonatomic ,strong) UIButton *rightBtn;
@end

@implementation comPleteInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"完善信息";
    self.view.backgroundColor = [UIColor whiteColor];
    
    _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_rightBtn setTitle:@"编辑资料" forState:UIControlStateNormal];
    [_rightBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [_rightBtn addTarget:self action:@selector(changeInfo) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:self.rightBtn];
    self.navigationItem.rightBarButtonItem = item;
    
    _titleArray = @[@"VIP",@"实名认证",@"车主认证"];
    _imageArray = @[@"vip",@"renzheng",@"chezhu"];
    _detailArray = @[@"钻石会员",@"已实名",@"已实名"];
    
    [self.view addSubview:self.myTableView];
    self.myTableView.tableHeaderView = self.comPleteHeaderView;
}



#pragma 初始化懒加载

-(NSArray *)titleArray{
    if (!_titleArray) {
        _titleArray = [[NSArray alloc]init];
    }
    return _titleArray;
}

-(NSArray *)imageArray{
    if(!_imageArray){
        _imageArray = [[NSArray alloc]init];
    }
    return _imageArray;
}

-(NSArray *)detailArray{
    if(!_detailArray){
        _detailArray = [[NSArray alloc]init];
    }
    return _detailArray;
    
}

-(comPleteHeaderView *)comPleteHeaderView{
    if(!_comPleteHeaderView){
        _comPleteHeaderView = [[comPleteHeaderView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 200)];
        _comPleteHeaderView.backgroundColor = [UIColor whiteColor];
    }
    return _comPleteHeaderView;
}

-(UITableView *)myTableView{
    if(!_myTableView){
        _myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStylePlain];
        _myTableView.backgroundColor = [UIColor whiteColor];
        _myTableView.delegate = self;
        _myTableView.dataSource = self;
        self.myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _myTableView;
}

#pragma tableViewDelegate&DataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.titleArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *TableSampleIdentifier = @"TableSampleIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TableSampleIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:TableSampleIdentifier];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = [_titleArray objectAtIndex:indexPath.row];
    cell.imageView.image = [UIImage imageNamed:_imageArray[indexPath.row]];
    cell.detailTextLabel.text =[_detailArray objectAtIndex:indexPath.row];
    return cell;
}

-(void)changeInfo{
    NSLog(@"haha");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
