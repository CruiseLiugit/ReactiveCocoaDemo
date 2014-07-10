//
//  MyTableViewCell.m
//  ReactiveCocoaDemo
//
//  Created by dajing on 14-6-5.
//  Copyright (c) 2014年 Anjuke. All rights reserved.
//

#import "MyTableViewCell.h"
#import "City.h"
#import "UIImageView+AFNetworking.h"

@interface MyTableViewCell()

@property(nonatomic, strong) UIImageView *imgView;

@end

@implementation MyTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.imgView = [[UIImageView alloc] initWithFrame:CGRectMake(200, 4, 80, 80)];
        [self.contentView addSubview:self.imgView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)configCell {
    self.textLabel.text = self.city.cityName;
    [self.imgView setImageWithURL:[NSURL URLWithString:self.city.cityImage]];
}

// bind image with signal, but the cell will refresh when it will be shown again, need to resolve
//- (void)bindingCellWith:(id)cellData {
////    self.city = (City *)cellData;
////    [RACObserve(self, city) subscribeNext:^(id x) {
//        [[self signalForImage:[NSURL URLWithString:self.city.cityImage]]
//         subscribeNext:^(id x) {
//             self.imgView.image = x;
//         }];
////    }];
//
//    self.textLabel.text = self.city.cityName;
//}

//-(RACSignal *)signalForImage:(NSURL *)imageUrl {
//    RACScheduler *scheduler = [RACScheduler schedulerWithPriority:RACSchedulerPriorityBackground];
//    
//    RACSignal *imageDownloadSignal = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//        NSData *data = [NSData dataWithContentsOfURL:imageUrl];
//        UIImage *image = [UIImage imageWithData:data];
//        [subscriber sendNext:image];
//        [subscriber sendCompleted];
//        return nil;
//    }] subscribeOn:scheduler];
//
//    return [[imageDownloadSignal
//             takeUntil:self.rac_prepareForReuseSignal]
//            deliverOn:[RACScheduler mainThreadScheduler]];
//}

@end
