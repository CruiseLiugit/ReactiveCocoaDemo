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

// 能否查询的开关信号
@property (nonatomic, strong) RACSignal *searchEnableSignal;

// 查询信号
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
        // 第一种方式
        // use AFNetworking+Extensions
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer new];
        NSDictionary *params = @{@"user_id": self.uid};
         _searchSignal = [manager rac_GET:kSubscribeURL parameters:params];
        return _searchSignal;
        
        // 第二种方式,采用replay subject会只请求一次，以后的subscribe会直接取第一次的结果
        // create a signal with standard AFNetworking framework
//        RACReplaySubject *subject = [RACReplaySubject subject];
//
//        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//        [manager GET:kSubscribeURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//            // send next signal once request is complete
//            [subject sendNext:responseObject];
//            // we should sendCompleted to release this searchSingal when signal is complete
//            [subject sendCompleted];
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            // sendError
//            [subject sendError:nil];
//        }];
//        
//        return subject;

        // 这种方式signal的side effect会在每次subscribe时被调用，
//        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//            [manager GET:kSubscribeURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                // send next signal once request is complete
//                [subscriber sendNext:responseObject];
//                // we should sendCompleted to release this searchSingal when signal is complete
//                [subscriber sendCompleted];
//            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                // sendError
//                [subscriber sendError:nil];
//            }];
//
//            // no resoure to release, so return nil here
//            return nil;
//        }];
        
        // 第三种方式，用multiconnection来share signal的side effects
//         RACSignal *searchSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//            [manager GET:kSubscribeURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                // send next signal once request is complete
//                [subscriber sendNext:responseObject];
//                // we should sendCompleted to release this searchSingal when signal is complete
//                [subscriber sendCompleted];
//            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                // sendError
//                [subscriber sendError:nil];
//            }];
//            
//            return nil;
//        }];
//        return [[searchSignal publish] autoconnect];
        
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
               City *city = [MTLJSONAdapter modelOfClass:City.class fromJSONDictionary:dic error:nil];
               return city;
           }]; // end nested map
        } // end if
        
        return [result.array mutableCopy];
    }]; // end map
    
    // set error signal
    // u can use this error signal directly in viewcontroller and remove statusMessage property
    RACSignal *failedMessageSource = [[self.searchCommand.errors subscribeOn:[RACScheduler mainThreadScheduler]] map:^id(NSError *error) {
        return NSLocalizedString(@"Error", nil);
    }];
    
    // 绑定状态消息
    RAC(self, statusMessage) = failedMessageSource;
}

@end
