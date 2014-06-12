//
//  AddCityViewModel.m
//  ReactiveCocoaDemo
//
//  Created by dajing on 14-6-10.
//  Copyright (c) 2014年 Anjuke. All rights reserved.
//

#import "AddCityViewModel.h"

@implementation AddCityViewModel

-(id)init {
    self = [super init];
    if(!self) return nil;
    
    self.cityName = @"";
    
    [self bindPopulationColor];
    
    return self;
}

-(void)bindPopulationColor {
    RAC(self, popColor) = [RACObserve(self, population) map:^id(NSNumber *popu) {
        return [UIColor colorWithRed:[popu floatValue] / 255. green:59 /255. blue:93/255. alpha:1.];
    }];
}

-(RACSignal *)cityNameValidatorSignal {
    return [RACObserve(self,cityName) map:^id(NSString *newName) {
        BOOL isValid = true;
        
        if ([newName isEqualToString:@""]) {
            isValid = false;
        }
        
        return [NSNumber numberWithBool:isValid];
    }];
}

@end
