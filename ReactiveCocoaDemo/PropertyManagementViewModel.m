//
//  PropertyManagementViewModel.m
//  ReactiveCocoaDemo
//
//  Created by dajing on 14-6-5.
//  Copyright (c) 2014年 Anjuke. All rights reserved.
//

#import "PropertyManagementViewModel.h"
#import "AFHTTPRequestOperationManager+RACSupport.h"

static NSString *const kSubscribeURL = @"http://api.anjuke.com/anjuke/4.0/community/info?is_nocheck=1&amp;commid=1&amp;rsl=32";

@interface PropertyManagementViewModel()

@property (nonatomic, strong) RACSignal *searchEnableSignal;
@property (nonatomic, strong) RACSignal *searchSignal;

@end

@implementation PropertyManagementViewModel

-(id)init {
    self = [super init];
    if(!self) return nil;
        
    self.searchCommand = [[RACCommand alloc] initWithEnabled:self.searchEnableSignal signalBlock:^RACSignal *(id input) {
        return self.searchSignal;
    }];

    [self mapSubscribeCommandStateToStatusMessage];
    
    return self;
}

-(RACSignal *)searchSignal {
    if (_searchSignal == nil) {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer new];
        NSDictionary *params = @{@"user_id": self.uid};
         _searchSignal =[[[manager rac_GET:kSubscribeURL parameters:params] logError] replayLazily];
        return _searchSignal;
    }
    return _searchSignal;
}

-(RACSignal *)searchEnableSignal {
    if (_searchEnableSignal == nil) {
        _searchEnableSignal = [RACObserve(self,uid) map:^id(NSString *uid) {
            return @(![uid isEqualToString:@""]);
        }];
    }
    return _searchEnableSignal;
}

- (void)mapSubscribeCommandStateToStatusMessage {
    RACSignal *completedMessageSource = [self.searchCommand.executionSignals flattenMap:^RACStream *(RACSignal *subscribeSignal) {
        return [[[subscribeSignal materialize] filter:^BOOL(RACEvent *event) {
            return event.eventType == RACEventTypeCompleted;
        }] map:^id(id value) {
            self.entrustedProperties = [@[@"1",@"2"] mutableCopy];
            return NSLocalizedString(@"Thanks", nil);
        }];
    }];
    
    RACSignal *failedMessageSource = [[self.searchCommand.errors subscribeOn:[RACScheduler mainThreadScheduler]] map:^id(NSError *error) {
        return NSLocalizedString(@"Error :(", nil);
    }];
    
    RAC(self, statusMessage) = [RACSignal merge:@[completedMessageSource, failedMessageSource]];
}

@end
