//
//  AddCityViewController.m
//  ReactiveCocoaDemo
//
//  Created by dajing on 14-6-10.
//  Copyright (c) 2014年 Anjuke. All rights reserved.
//

#import "AddCityViewController.h"
#import "AddCityViewModel.h"
#import "UIControl+RACSignalSupport.h"
#import "UISlider+RACSignalSupport.h"

@interface AddCityViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *tfCityName;
@property (weak, nonatomic) IBOutlet UILabel *lblCityName;
@property (nonatomic, strong) AddCityViewModel *viewModel;
@property (weak, nonatomic) IBOutlet UISlider *sliderPop;
@property (nonatomic, strong) UIButton *btnSave;
@property (weak, nonatomic) IBOutlet UIView *barPopu;
@end

@implementation AddCityViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)initUI {
    self.btnSave = [UIButton buttonWithType:UIButtonTypeContactAdd];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.btnSave];
    
    self.tfCityName.delegate = self;
    
    // set slider vertical
    CGAffineTransform trans = CGAffineTransformMakeRotation(M_PI * 3 / 2);
    self.sliderPop.transform = trans;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    
    [self bindViewModel];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

-(void)bindViewModel {
    @weakify(self);

    // init viewModel
    self.viewModel = [AddCityViewModel new];
    
    // set validation once user input
    [[self.tfCityName.rac_textSignal distinctUntilChanged] subscribeNext:^(NSString *name) {
        @strongify(self);
        self.viewModel.cityName = name;
    }];
    
    RAC(self.btnSave, enabled) = self.viewModel.cityNameValidatorSignal;
    
    // set validation delay until button click
//    [[self.btnSave rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
//        self.viewModel.cityName = self.tfCityName.text;
//    }];

    // bind label textColor property to viewModel's cityNameValidatorSignal
    RAC(self.lblCityName, textColor) = [self.viewModel.cityNameValidatorSignal map:^id(NSNumber *valid) {
        BOOL isValid = [valid boolValue];
        return isValid?[UIColor blackColor]:[UIColor redColor];
    }];
    
    [[self.sliderPop rac_newValueChannelWithNilValue:[NSNumber numberWithFloat:0.]] subscribeNext:^(NSNumber *popu) {
        self.viewModel.population = [popu floatValue];
    }];
;
    
    RAC(self.barPopu, backgroundColor) = RACObserve(self.viewModel, popColor);
}

@end
