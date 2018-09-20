//
//  OrderListViewController.m
//  iOS-trip-search
//
//  Created by yaoqianghong on 2018/9/20.
//  Copyright © 2018年 Amap. All rights reserved.
//

#import "OrderListViewController.h"

@interface OrderListViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic ,strong) UITableView *orderListTableview;
@property (nonatomic ,strong) NSMutableArray *orderMuArray;
@end

@implementation OrderListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"订单列表";
    [self.view addSubview:self.orderListTableview];
}

#pragma 初始化懒加载

-(NSMutableArray *)orderMuArray{
    if (!_orderMuArray) {
        _orderMuArray = [[NSMutableArray alloc]init];
    }
    return _orderMuArray;
}

-(UITableView *)orderListTableview{
    if (!_orderListTableview) {
        _orderListTableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStylePlain];
        _orderListTableview.backgroundColor = [UIColor colorWithRed:245.f/255.f green:245.f/255.f blue:245.f/255.f alpha:1.0];
        _orderListTableview.delegate = self;
        _orderListTableview.dataSource = self;
        _orderListTableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _orderListTableview;
}

#pragma tableViewDelegate&DaraSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

//-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    加载cell
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
