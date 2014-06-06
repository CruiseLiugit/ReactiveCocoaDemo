//
//  PropertyManagermentViewController.m
//  ReactiveCocoaDemo
//
//  Created by dajing on 14-6-5.
//  Copyright (c) 2014年 Anjuke. All rights reserved.
//

#import "PropertyManagermentViewController.h"
#import "PropertyManagementViewModel.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "CETableViewBindingHelper.h"
#import "MyTableViewCell.h"

@interface PropertyManagermentViewController ()

@property (nonatomic, strong) PropertyManagementViewModel *viewModel;
//@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, assign) BOOL isIng;

@end

@implementation PropertyManagermentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.viewModel = [PropertyManagementViewModel new];
    [self bindViewModel];
    
    self.uid = @"124242";
    [self.viewModel.searchCommand execute:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)bindViewModel {
//    RAC(self, items) = RACObserve(self.viewModel, entrustedProperties);
    RAC(self.viewModel, uid) = RACObserve(self, uid);
    
    MyTableViewCell *myCell = [[MyTableViewCell alloc] init];
    [CETableViewBindingHelper bindingHelperForTableView:self.entrustedTbl
                                           sourceSignal:RACObserve(self.viewModel, entrustedProperties)
                                       selectionCommand:self.viewModel.searchCommand
                                           templateCellClass:myCell];
    
    RAC(self, isIng) = self.viewModel.searchCommand.executing;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
