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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // set right save button
    self.btnSave = [UIButton buttonWithType:UIButtonTypeContactAdd];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.btnSave];

    // set slider vertical
    CGAffineTransform trans = CGAffineTransformMakeRotation(M_PI * 3 / 2);
    self.sliderPop.transform = trans;

    [self bindViewModel];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)bindViewModel {
    @weakify(self);

    // init viewModel
    self.viewModel = [AddCityViewModel new];
    self.tfCityName.delegate = self;
    // set validation once user input
    [[self.tfCityName.rac_textSignal distinctUntilChanged] subscribeNext:^(NSString *name) {
        @strongify(self);
        
        if([name isEqualToString:@"\n"]) {
            [self.tfCityName resignFirstResponder];
        }

        self.viewModel.cityName = name;
    }];
    
    RAC(self.btnSave, enabled) = self.viewModel.cityNameValidatorSignal;
    
    [[self.btnSave rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        // set validation delay until button click

//        self.viewModel.cityName = self.tfCityName.text;
        [self.tfCityName resignFirstResponder];
    }];

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
