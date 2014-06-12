//
//  MyTableViewCell.m
//  ReactiveCocoaDemo
//
//  Created by dajing on 14-6-5.
//  Copyright (c) 2014年 Anjuke. All rights reserved.
//

#import "MyTableViewCell.h"
#import "City.h"

@interface MyTableViewCell()

@property (nonatomic, strong) City *city;

@property(nonatomic, strong) UIImageView *imgView;

- (void)bindingCell;

@end

@implementation MyTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellData:(id)cellData
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.city = (City *)cellData;
        self.imgView = [[UIImageView alloc] initWithFrame:CGRectMake(200, 4, 80, 80)];
        [self.contentView addSubview:self.imgView];
        [self bindingCell];
    }
    return self;
}

- (void)bindingCell {
    self.imgView.image = nil;
    [[[self signalForImage:[NSURL URLWithString:self.city.cityImage]] deliverOn:[RACScheduler mainThreadScheduler]]
     subscribeNext:^(id x) {
        self.imgView.image = x;
     }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)configCell {
    self.textLabel.text = self.city.cityName;
}

-(RACSignal *)signalForImage:(NSURL *)imageUrl {
    RACScheduler *scheduler = [RACScheduler schedulerWithPriority:RACSchedulerPriorityBackground];
    
    RACSignal *imageDownloadSignal = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSData *data = [NSData dataWithContentsOfURL:imageUrl];
        UIImage *image = [UIImage imageWithData:data];
        [subscriber sendNext:image];
        [subscriber sendCompleted];
        return nil;
    }] subscribeOn:scheduler];

    return [[imageDownloadSignal
             takeUntil:self.rac_prepareForReuseSignal]
            deliverOn:[RACScheduler mainThreadScheduler]];
}

@end
