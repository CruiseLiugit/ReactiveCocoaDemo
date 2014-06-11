//
//  PropertyManagermentViewController.h
//  ReactiveCocoaDemo
//
//  Created by dajing on 14-6-5.
//  Copyright (c) 2014年 Anjuke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GeoCityViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *entrustedTbl;
@property (nonatomic, strong) NSString *uid;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnAdd;

@end
