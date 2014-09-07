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

static NSString *identifier = @"identifierCell";

@interface GeoCityViewController ()<UITableViewDataSource>

@property (nonatomic, strong) GeoCityViewModel *viewModel;

@property (nonatomic, assign) BOOL isLoading;

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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)bindViewModel {
    @weakify(self);

    [self.geoTbl registerClass:[MyTableViewCell class] forCellReuseIdentifier:identifier];
    self.geoTbl.dataSource = self;

    // init viewModel
    self.viewModel = [GeoCityViewModel new];
    self.isLoading = YES;
    self.uid = @"124242";

    RAC(self.viewModel, uid) = RACObserve(self, uid);
    
    // network loading flag subscription
    [RACObserve(self, isLoading) subscribeNext:^(id x) {
        UIApplication.sharedApplication.networkActivityIndicatorVisible = [x boolValue];
        self.btnAdd.enabled = ! [x boolValue];
    }];
    
    // network success binding
    [[[RACObserve(self.viewModel, cities) ignore:nil] doNext:^(id x) {
        self.isLoading = YES;
    }] subscribeNext:^(id x) {
        @strongify(self);
        [self.geoTbl reloadData];
        self.isLoading = NO;
    }];
    
    // network fail binding
    [[RACObserve(self.viewModel, statusMessage) filter:^BOOL(id value) {
        return value != nil;
    }]
     subscribeNext:^(NSString *msg) {
         UIAlertView *msgAlert = [[UIAlertView alloc] initWithTitle:msg message:msg delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
         [msgAlert show];
     }];
}

#pragma mark - UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.cities.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    cell.city = self.viewModel.cities[indexPath.row];
    
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
        [self.geoTbl reloadData];
    }];
    
    // 再传递viewDelegate给新页面
    AddCityViewController *addController = (AddCityViewController *)[segue destinationViewController];
    addController.delegate = (id<SaveDataCallBack>)self.viewDelegate;
}

@end
