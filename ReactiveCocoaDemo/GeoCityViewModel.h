//
//  GeoCityViewModel
//  ReactiveCocoaDemo
//
//  Created by dajing on 14-6-5.
//  Copyright (c) 2014年 Anjuke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GeoCityViewModel : NSObject

@property (nonatomic, strong) NSMutableArray *entrustedProperties;

@property (nonatomic, strong) RACCommand *searchCommand;

@property (nonatomic, strong) NSString *uid;

@property (nonatomic, strong) NSString *statusMessage;

@end
