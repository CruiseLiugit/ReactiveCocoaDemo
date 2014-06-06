//
//  ViewController.m
//  ReactiveCocoaDemo
//
//  Created by dajing on 14-6-3.
//  Copyright (c) 2014年 Anjuke. All rights reserved.
//

#import "ViewController.h"
#import <ReactiveCocoa.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [
     [self.tfUserName.rac_textSignal
            filter:^BOOL(id value) {
                    NSString *str = value;
                    return str.length > 3;
    }]
     
     subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
