//
//  MyTableViewCell.h
//  ReactiveCocoaDemo
//
//  Created by dajing on 14-6-5.
//  Copyright (c) 2014年 Anjuke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CEReactiveView.h"

@interface MyTableViewCell : UITableViewCell <CEReactiveView>

- (void)bindViewModel:(id)viewModel;

@end
