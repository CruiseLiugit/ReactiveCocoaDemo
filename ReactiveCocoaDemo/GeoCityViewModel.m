//
//  GeoCityViewModel
//  ReactiveCocoaDemo
//
//  Created by dajing on 14-6-5.
//  Copyright (c) 2014年 Anjuke. All rights reserved.
//

#import "GeoCityViewModel.h"
#import "AFHTTPRequestOperationManager+RACSupport.h"
#import "City.h"

// mock up data request URL
static NSString *const kSubscribeURL = @"http://api.geonames.org/citiesJSON?north=44.1&south=-9.9&east=-22.4&west=55.2&lang=de&username=anjuke";

@interface GeoCityViewModel()

@property (nonatomic, strong) RACSignal *searchEnableSignal;
@property (nonatomic, strong) RACSignal *searchSignal;

@end

@implementation GeoCityViewModel

-(id)init {
    self = [super init];
    if(!self) return nil;
    // init search command
    self.searchCommand = [[RACCommand alloc] initWithEnabled:self.searchEnableSignal signalBlock:^RACSignal *(id input) {
        return self.searchSignal;
    }];

    // setup search command call back
    [self registerCommandState];
    
    return self;
}

-(RACSignal *)searchSignal {
    if (_searchSignal == nil) {
        // first way
        // use AFNetworking+Extensions
//        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//        manager.requestSerializer = [AFJSONRequestSerializer new];
//        NSDictionary *params = @{@"user_id": self.uid};
//         _searchSignal = [manager rac_GET:kSubscribeURL parameters:params];
//        return _searchSignal;
        
        // second way
        // create a signal with standard AFNetworking framework
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            [manager GET:kSubscribeURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                // send next signal once request is complete
                [subscriber sendNext:responseObject];
                // we should sendCompleted to release this searchSingal when signal is complete
                [subscriber sendCompleted];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                // sendError
                [subscriber sendError:nil];
            }];

            // no resoure to release, so return nil here
            return nil;
        }];
        
    } // end if
    
    return _searchSignal;
}

// search signal controlled by user id
-(RACSignal *)searchEnableSignal {
    if (_searchEnableSignal == nil) {
        _searchEnableSignal = [RACObserve(self,uid) map:^id(NSString *uid) {
            return @(![uid isEqualToString:@""]);
        }];
    }
    return _searchEnableSignal;
}

// setup search command call back
- (void)registerCommandState {
    // search success complete call back
    RACSignal *searchResultsSignal = [[self.searchCommand.executionSignals
//       flattenMap:^RACStream *(id value) {
//           return value;
//       }]
                                       switchToLatest]
         map:^id(NSDictionary *jsonSearchResult) {
             /* return signal which contains array that can be binded to self.entrustedProperties
                or u can just set 'self.entrustedProperties = jsonSearchResult[@"geonames"]' which
                will notify the subscriber in viewcontroller to refresh the tableview */
             NSArray *rawArray = jsonSearchResult[@"geonames"];
             return rawArray;
         }
     ];
    
    // set additional image url to each data
    // if u chose set self.entrustedProperties = array, remove the line below
    RAC(self, cities) = [searchResultsSignal map:^id(NSArray *rawArray) {
        RACSequence *result;
        if (rawArray) {
           result = [rawArray.rac_sequence map:^id(NSDictionary *rawDic) {
               NSMutableDictionary *dic = [(NSDictionary *)rawDic mutableCopy];
               City *city = [[City alloc] init];
               
               NSString *cityName = dic[@"toponymName"];
               
               city.cityName = cityName;
               
               if ([cityName isEqualToString:@"Beijing"])
                   [dic setObject:@"http://upload.wikimedia.org/wikipedia/commons/thumb/9/95/BeijingWatchTower.jpg/220px-BeijingWatchTower.jpg" forKey:@"imgUrl"];
               else if([cityName isEqualToString:@"Seoul"])
                   [dic setObject:@"http://upload.wikimedia.org/wikipedia/commons/thumb/6/69/Gyeongbok-gung_palace-05_%28xndr%29.jpg/220px-Gyeongbok-gung_palace-05_%28xndr%29.jpg" forKey:@"imgUrl"];
               else if([cityName isEqualToString:@"Tokyo"])
                   [dic setObject:@"http://upload.wikimedia.org/wikipedia/commons/thumb/1/12/TokyoMetropolitanGovernmentOffice.jpg/220px-TokyoMetropolitanGovernmentOffice.jpg" forKey:@"imgUrl"];
               else if([cityName isEqualToString:@"Mexico City"])
                   [dic setObject:@"http://upload.wikimedia.org/wikipedia/commons/thumb/8/88/Old_architecture_Mexico_City.jpg/220px-Old_architecture_Mexico_City.jpg" forKey:@"imgUrl"];
               else if([cityName isEqualToString:@"Manila"])
                   [dic setObject:@"http://upload.wikimedia.org/wikipedia/en/thumb/7/72/Intramuros_002.JPG/220px-Intramuros_002.JPG" forKey:@"imgUrl"];
               else if([cityName isEqualToString:@"Dhaka"])
                   [dic setObject:@"http://upload.wikimedia.org/wikipedia/commons/thumb/1/1e/Dhaka_Lalbagh_Fort_5.JPG/220px-Dhaka_Lalbagh_Fort_5.JPG" forKey:@"imgUrl"];
               else if([cityName isEqualToString:@"Jakarta"])
                   [dic setObject:@"http://upload.wikimedia.org/wikipedia/commons/thumb/e/ef/Andries_Beeckman_-_The_Castle_of_Batavia.jpg/220px-Andries_Beeckman_-_The_Castle_of_Batavia.jpg" forKey:@"imgUrl"];
               else if([cityName isEqualToString:@"Taipei"])
                   [dic setObject:@"http://upload.wikimedia.org/wikipedia/commons/thumb/d/d2/Chiang_Kai-shek_memorial_amk.jpg/220px-Chiang_Kai-shek_memorial_amk.jpg" forKey:@"imgUrl"];
               else if([cityName isEqualToString:@"Hong Kong"])
                   [dic setObject:@"http://upload.wikimedia.org/wikipedia/commons/thumb/6/6c/HK_Central_Statue_Square_Legislative_Council_Building_n_Neoclassicism_n_Lippo_Centre.JPG/220px-HK_Central_Statue_Square_Legislative_Council_Building_n_Neoclassicism_n_Lippo_Centre.JPG" forKey:@"imgUrl"];
               else
                    [dic setObject:@"http://upload.wikimedia.org/wikipedia/commons/thumb/c/c6/Old_timer_structural_worker2.jpg/220px-Old_timer_structural_worker2.jpg" forKey:@"imgUrl"];

               city.cityImage = dic[@"imgUrl"];
               return city;
//               return dic;
           }]; // end nested map
        } // end if
        
        return [result.array mutableCopy];
    }]; // end map
    
    // set error signal
    // u can use this error signal directly in viewcontroller and remove statusMessage property
    RACSignal *failedMessageSource = [[self.searchCommand.errors subscribeOn:[RACScheduler mainThreadScheduler]] map:^id(NSError *error) {
        return NSLocalizedString(@"Error", nil);
    }];
    
    RAC(self, statusMessage) = failedMessageSource;
}

@end
