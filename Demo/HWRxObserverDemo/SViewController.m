//
//  SViewController.m
//  HWRxObserverDemo
//
//  Created by 陈智颖 on 2016/11/16.
//  Copyright © 2016年 YY. All rights reserved.
//

#import "SViewController.h"
#import "NSNotificationCenter+RxObserver.h"
#import "UIView+RxObserver.h"
#import "HWRxObserver.h"
#import "UITableView+RxDataSource.h"
#import "UICollectionView+RxDataSource.h"
#import "TestTableViewCell.h"
#import "STestTableViewCell.h"
#import "TestCollectionViewCell.h"
#import "STestCollectionViewCell.h"
#import "HWPromise+RxObserver.h"
#import "NSNotificationCenter+RxObserver.h"
#import <objc/runtime.h>


@interface SViewController () <UITableViewDelegate>

@property (nonatomic) dispatch_queue_t queue;

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) HWRxObserver *customObser;

@property (nonatomic, strong) HWRxObserver *schedule;

@property (nonatomic, strong) HWRxVariable *variable1;
@property (nonatomic, strong) HWRxVariable *variable2;

@end

@implementation SViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:[UILabel new].then(HW_BLOCK(UILabel *) {
        $0.frame = CGRectMake(350, 100, 300, 50);
        $0.text = @"aaa.text";
        $0.textColor = [UIColor blackColor];
        _label = $0;
    })];
    
    _queue = dispatch_queue_create("testQueue", DISPATCH_QUEUE_SERIAL);
    _label.rx_dealloc.subscribe(HW_BLOCK(UILabel *) {
        $0.text = @"dealloc";
    });
    
//    [self test_base];
//    [self test_weakDisposer];
//    [self test_promise];
//    [self test_debounce];
//    [self test_throttle];
//    [self test_takeUtil];
//    [self test_of];
//    [self test_dealloc];
//    [self test_behavior];
//    [self test_Notification];
//    [self test_switchLatest];
    [self test_TableView_CollectionView];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)dealloc {
    NSLog(@"sviewcontroller dealloc");
}

#pragma mark - base
- (void)test_base {
    HWRx(_label, text)
    .map(HW_BLOCK(NSString *) {
        return [NSString stringWithFormat:@"%@，猜你个头", $0];
    })
    .subscribe(HW_BLOCK(NSString *) {
        NSLog(@"%@", $0);
    });

    _label.text = @"你猜";
}

#pragma mark - weak disposer
- (void)test_weakDisposer {
    UITextField *a = [UITextField new];
    a.rx_text.disposeBy(self).response(^{
        
    });
}

#pragma mark - promise & observer
- (void)test_promise {
    
    HWRxInstance.schedule(1, YES).disposeBy(self).response(^{
        [HWRxNoCenter postNotificationName:@"abc" object:nil userInfo:@{@"d":@"d"}];
    });
    
    [self notification:2 userInfo:@{@"1":@"1"}]
    .next(HW_BLOCK(NSDictionary *) {
        return [self notification:2 userInfo:@{@"2":@"2"}];
    })
    .next(HW_BLOCK(NSDictionary *) {
        return [self notification:2 userInfo:@{@"3":@"3"}];
    })
    .next(HW_BLOCK(NSDictionary *) {
        return [self notification:2 userInfo:@{@"4":@"4"}];
    });
}

- (HWPromise *)notification:(NSUInteger)delayTime userInfo:(NSDictionary *)userInfo {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [HWRxNoCenter postNotificationName:@"abc" object:nil userInfo:userInfo];
    });
    
    return HWPromise.observeOnce(HWRxNoCenter.Rx(@"abc").disposeBy(self), HW_BLOCK(NSDictionary *) {
                                     return (BOOL)![$0.allKeys.firstObject isEqualToString:@"d"];
                                 });
}

#pragma mark - rx_tap & debounce
- (void)test_debounce {
    static int a = 0;
    _label.rx_dynamicTap.debounce(0.3).subscribe(HW_BLOCK(UILabel *) {
        a++;
        $0.text = [NSString stringWithFormat:@"%@", @(a)];
        NSLog(@"aaa text: %@", @(a));
    });
}

#pragma mark - rx_tap & throttle
- (void)test_throttle {
    _label.Rx(@"text").throttle(1).map(HW_BLOCK(NSString *) {
        return [NSString stringWithFormat:@"throttle: %@", $0];
    }).subscribe(HW_BLOCK(NSString *){
        NSLog(@"%@", $0);
    });
}

#pragma mark - schedule & takeUtil
- (void)test_takeUtil {
    HWRxObserver *observer = HWRxInstance;
    observer.schedule(1, YES).disposeBy(self)
    .subscribe(HW_BLOCK(HWIntegerNumber *) {
        NSLog(@"%@", [NSString stringWithFormat:@"takeUtil %@", @($0.integerValue)]);
    }).takeUntil(_label.RxOnce(@"text"));
}

#pragma mark - switchLatest
- (void)test_switchLatest {
    _customObser = HWRxInstance.create(@"switchLatest custom");
    HWRxObserver *observer1 = HWRxInstance.create(@"switchLatest test1").disposeBy(self);
    HWRxObserver *observer2 = HWRxInstance.create(@"switchLatest test2").disposeBy(self);
    HWRxObserver *observer3 = HWRxInstance.create(@"switchLatest test3").disposeBy(self);
    
    HWRxObserver *switchObserver = _customObser.switchLatest();
    switchObserver
    .subscribe(HW_BLOCK(id) {
        NSLog(@"switchLatest %@", $0);
    });
    
    _customObser.next(observer1);
    observer1.next(@(11));
    observer1.next(@(12));
    
    _customObser.next(observer2);
    observer1.next(@(13));
    observer2.next(@(21));
    observer2.next(@(22));
    
    _customObser.next(observer3);
    observer1.next(@(14));
    observer2.next(@(23));
    observer3.next(@(31));
    
    NSLog(@"switchObserver retainCount: %@", @(CFGetRetainCount((__bridge CFTypeRef)switchObserver)));
}


#pragma mark - of & observeOn
- (void)test_of {
    HWRxObserver *ofObser =
    HWRxInstance.of(@[@(1),@(2)]).observeOn(_queue);
    
    ofObser.subscribe(HW_BLOCK(id) {
        NSLog(@"of: %@", $0);
    });
    
    // not response to of
    ofObser.response(^ {
        NSLog(@"of");
    });
}


#pragma mark - behavior + connect
- (void)test_behavior {
    HWRxObserver *observer = HWRxInstance.create(@"behavior");
    
    observer.next(@"aa");
    
    observer
    .behavior()
    .map(HW_BLOCK(NSString *) {
        return [NSString stringWithFormat:@"behavior: %@", $0];
    })
    .subscribe(HW_BLOCK(NSObject *) {
        NSLog(@"%@", $0);
    });
    
    observer.connect();
    observer.next(@"bb");
}

#pragma mark - rx_dealloc
- (void)test_dealloc {
    _label.rx_dealloc.response(^{
        NSLog(@"_aaa dealloc");
    });
}

#pragma mark - Notification
- (void)test_Notification { Weakify(self)
    HWRxNoCenter.Rx(@"bbaNotification").disposeBy(self)
    .subscribe(^(NSDictionary *userInfo) { Strongify(self)
        self.view.backgroundColor = [UIColor yellowColor];
    });
}

#pragma mark - TableView & CollectionView
- (void)test_TableView_CollectionView {
    _variable1 = [HWRxVariable variable:@[
//                                          @"1",
//                                          @"2",
//                                          @"3",
//                                          @"4",
//                                          @"5",
//                                          @"6",
                                          ]];

    _variable2 = [HWRxVariable variable:@[@"11",
                                          @"12",
                                          @"13",
                                          @"14",
                                          @"15",
                                          @"16",]];

    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 100, 320, 250) style:UITableViewStyleGrouped];
    _tableView.backgroundColor = [UIColor grayColor];

    [self test_TableView_RxDataSource];
    [self.view addSubview:_tableView];

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(60, 60);

    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 380, 320, 250) collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor brownColor];

    [self test_CollectionView_RxDataSource];
    [self.view addSubview:_collectionView];


    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), _queue, ^{
        
        [_variable1 addObject:@"333"];
//        [_variable1 removeObjectAtIndex:3];
//        [_variable2 reloadObject:@[@"1", @"2", @"3"]];
//        [_variable1 replaceByObject:@"11111" select:HW_BLOCK(NSString *, NSInteger) {
//            return (BOOL)($1 == 3);
//        }];
        [HWRxNoCenter postNotificationName:@"bbaNotification" object:nil userInfo:@{@"aa":@"aa"}];
    });

}

#pragma mark - TableView RxDataSource RxDelegate
- (void)test_TableView_RxDataSource { Weakify(self)
    
    _tableView.RxDataSource()
    .registerNibDefault(@[@"TestTableViewCell", @"STestTableViewCell"])
    .insertAnimation(UITableViewRowAnimationRight)
    .deleteAnimation(UITableViewRowAnimationLeft)
    .reloadAnimation(UITableViewRowAnimationBottom)
    .cellForItem(HW_BLOCK(UITableViewCell *, NSString *, NSIndexPath *) {
        if ($2.section == 0) {
            TestTableViewCell *cell = (TestTableViewCell *)$0;
            cell.label.textColor = [UIColor redColor];
            cell.label.text = $1;
        } else {
            STestTableViewCell *cell = (STestTableViewCell *)$0;
            cell.label.textColor = [UIColor yellowColor];
            cell.label.text = $1;
        }
        $0.selectionStyle = UITableViewCellSelectionStyleNone;
    })
    .bindTo(@[_variable1, _variable2]);
    
    
    _tableView.RxDelegate()
    .heightForRow(^(id a, NSIndexPath *b) {
        return 30.f;
    })
    .cellSelected(HW_BLOCK(NSString *, NSIndexPath *) { Strongify(self)
        NSLog(@"%@", $0);
        if ($1.section == 0) {
            [self.variable1 removeObjectAtIndex:$1.row];
        } else {
            [self.variable2 removeObjectAtIndex:$1.row];
        }
    });
    
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [UIView new].then(HW_BLOCK(UIView *) {
        $0.backgroundColor = [UIColor yellowColor];
    });
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50.f;
}

#pragma mark - CollectionView RxDataSource
- (void)test_CollectionView_RxDataSource {
    _collectionView.RxDataSource()
    .registerNibDefault(@[@"TestCollectionViewCell", @"STestCollectionViewCell"])
    .cellForItem(HW_BLOCK(UICollectionViewCell *, NSString *, NSIndexPath *) {
        if ($2.section == 0) {
            TestCollectionViewCell *cell = (TestCollectionViewCell *)$0;
            cell.label.textColor = [UIColor redColor];
            cell.label.text = $1;
        } else {
            STestCollectionViewCell *cell = (STestCollectionViewCell *)$0;
            cell.label.textColor = [UIColor yellowColor];
            cell.label.text = $1;
        }
    }).bindTo(@[_variable1, _variable2]);
}

@end
