//
//  AddCityViewModel.m
//  ReactiveCocoaDemo
//
//  Created by dajing on 14-6-10.
//  Copyright (c) 2014年 Anjuke. All rights reserved.
//

#import "AddCityViewModel.h"
#import "City.h"

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
    if (_cityNameValidatorSignal == nil ) {
        _cityNameValidatorSignal = [RACObserve(self,cityName) map:^id(NSString *newName) {
            BOOL isValid = true;
            
            if ([newName isEqualToString:@""]) {
                isValid = false;
            }
            
            return [NSNumber numberWithBool:isValid];
        }];
    }
    return _cityNameValidatorSignal;
}

-(RACCommand *)saveCommand {
    if (_saveCommand == nil) {
        _saveCommand = [[RACCommand alloc] initWithEnabled:self.cityNameValidatorSignal signalBlock:
            ^RACSignal *(id input) {
                return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                    City *newCity = [[City alloc] init];
                    newCity.cityName = self.cityName;
                    newCity.cityImage = @"";
                    
                    [subscriber sendNext:newCity];
                    [subscriber sendCompleted];
                    return nil;
                }];
            }];

    }
    return _saveCommand;
}

@end
