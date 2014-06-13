//
//  MyTableViewCell.h
//  ReactiveCocoaDemo
//
//  Created by dajing on 14-6-5.
//  Copyright (c) 2014年 Anjuke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "City.h"

@interface MyTableViewCell : UITableViewCell
//- (void)bindingCellWith:(id)cellData;
- (void)configCell;
@property (nonatomic, strong) City *city;
@end
