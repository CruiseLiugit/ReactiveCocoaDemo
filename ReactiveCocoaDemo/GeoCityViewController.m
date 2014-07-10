//
//  GeoCityViewController
//  ReactiveCocoaDemo
//
//  Created by dajing on 14-6-5.
//  Copyright (c) 2014年 Anjuke. All rights reserved.
//

#import "GeoCityViewController.h"
#import "AddCityViewController.h"

#import "GeoCityViewModel.h"

#import "MyTableViewCell.h"

#import "City.h"

#import "RACDelegateProxy.h"

@interface GeoCityViewController ()<UITableViewDataSource>

@property (nonatomic, strong) GeoCityViewModel *viewModel;

@end

@implementation GeoCityViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // setup lots of bindings
    [self bindViewModel];
    
    // set uid to enable searchCommand
    self.uid = @"124242";
    
    // execute searchCommand
    [self.viewModel.searchCommand execute:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewDidAppear:(BOOL)animated {
    @weakify(self);

    // add bind here due to the signal will release when push to new controller
    [RACObserve(self.viewModel, cities) subscribeNext:^(id x) {
        @strongify(self);
        [self.entrustedTbl reloadData];
    }];
}

-(void)bindViewModel {
    @weakify(self);

    // init viewModel
    self.viewModel = [GeoCityViewModel new];
    
    // bind self.uid to viewModel.uid
    RAC(self.viewModel, uid) = RACObserve(self, uid);

//    // suscribe viewModel.entrustedProperties to refresh tableview
//    [RACObserve(self.viewModel, cities) subscribeNext:^(id x) {
//        @strongify(self);
//        [self.entrustedTbl reloadData];
//    }];
    
    // bind viewModel.searchCommand.executing to the invisible of loading indicator
    /* using   RAC([UIApplication sharedApplication], networkActivityIndicatorVisible) = self.viewModel.searchCommand.executing;
        will crash when u request data second time, dont know why, expect reason...
     */
    [[RACObserve(self.viewModel.searchCommand, executing) flattenMap:^RACStream *(id value) {
        return value;
    }] subscribeNext:^(id x) {
        @strongify(self);

        BOOL isLoading = [x boolValue];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = isLoading;
        self.btnAdd.enabled = !isLoading;
    }];
    
    // subscribe statusMessage to show the alert
    [[RACObserve(self.viewModel, statusMessage) filter:^BOOL(id value) {
        return value != nil;
    }]
     subscribeNext:^(NSString *msg) {
        UIAlertView *msgAlert = [[UIAlertView alloc] initWithTitle:msg message:msg delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        [msgAlert show];
    }];
    
    // set tableview datasource to self, the cell render logic will be placed in this viewcontroller
    self.entrustedTbl.dataSource = self;
}

#pragma mark - UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.cities.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"identifierCell";

    MyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[MyTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    cell.city = self.viewModel.cities[indexPath.row];

    [cell configCell];
    
    return  cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // 设置接受SaveDataCallBack回调的对象为self.viewDelegate
    self.viewDelegate = [[RACDelegateProxy alloc]
                                                initWithProtocol:@protocol(SaveDataCallBack)];
    
    // 回调的处理
    [[self.viewDelegate rac_signalForSelector:@selector(didSaveDataCallback:) fromProtocol:@protocol(SaveDataCallBack)] subscribeNext:^(RACTuple *tuple) {
        City *newCity = tuple.first;
        [self.viewModel.cities insertObject:newCity atIndex:0];
    }];
    
    // 再传递viewDelegate给新页面
    AddCityViewController *addController = (AddCityViewController *)[segue destinationViewController];
    addController.delegate = (id<SaveDataCallBack>)self.viewDelegate;
}

@end
