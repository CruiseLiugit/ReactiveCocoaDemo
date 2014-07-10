//
//  GeoCityViewController
//  ReactiveCocoaDemo
//
//  Created by dajing on 14-6-5.
//  Copyright (c) 2014年 Anjuke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GeoCityViewController : UIViewController

/**
 *  城市列表
 */
@property (weak, nonatomic) IBOutlet UITableView *entrustedTbl;

/**
 *  用户ID
 */
@property (nonatomic, strong) NSString *uid;

/**
 *  右上角的添加Button
 */
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnAdd;

/**
 *  RACDelegateProxy用于设置接收回调的对象
 */
@property(nonatomic,strong) id viewDelegate;

@end
