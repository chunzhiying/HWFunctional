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

@interface SViewController ()

@property (nonatomic, strong) UILabel *aaa;
@property (nonatomic, strong) HWRxObserver *customObser;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) HWRxVariable *variable1;
@property (nonatomic, strong) HWRxVariable *variable2;

@end

@implementation SViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:[UILabel new].then(HW_BLOCK(UILabel *) {
        $0.frame = CGRectMake(20, 100, 300, 50);
        $0.text = @"aaa.text";
        $0.textColor = [UIColor blackColor];
        _aaa = $0;
    })];
    
    
    Weakify(self)
    _aaa.Rx(@"text").response(^{ Strongify(self)
        self.view.backgroundColor = [UIColor redColor];
    });
    
    
    _customObser = HWRxInstance.create(@"custom");
    
    _customObser.next(^{
        return @"aa";
    });
    
    _customObser
    .behavior()
    .subscribe(HW_BLOCK(NSObject *) {
        NSLog(@"customObser: %@", $0);
    }).connect();
    
    
    
    _customObser.next(^{
        return @"bb";
    });
    
    _aaa.rx_dealloc.response(^{
        NSLog(@"_aaa dealloc");
    });
    
    
    //////////////////////////////
    _variable1 = [HWRxVariable variable:@[@"1",
                                          @"2",
                                          @"3",
                                          @"4",
                                          @"5",
                                          @"6",
                                          ]];
    
    _variable2 = [HWRxVariable variable:@[@"11",
                                          @"12",
                                          @"13",
                                          @"14",
                                          @"15",
                                          @"16",]];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_variable1 removeObjectAtIndex:3];
        [_variable2 removeObjectAtIndex:0];
    });
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 100, 320, 250) style:UITableViewStyleGrouped];
    _tableView.backgroundColor = [UIColor grayColor];
    
    
    _tableView.RxDataSource()
    .registerNibDefault(@[@"TestTableViewCell", @"STestTableViewCell"])
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
    })
    .bindTo(@[_variable1, _variable2]);
    
    
    _tableView.RxDelegate()
    .heightForRow(HW_BLOCK(id, NSIndexPath *) {
        return 80.f;
    })
    .viewForHeader(HW_BLOCK(NSUInteger) {
        UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 60)];
        header.backgroundColor = [UIColor purpleColor];
        return header;
    })
    .viewForFooter(HW_BLOCK(NSUInteger) {
        UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 30)];
        footer.backgroundColor = [UIColor greenColor];
        return footer;
    })
    .cellSelected(HW_BLOCK(NSString *, NSIndexPath *) { Strongify(self)
        NSLog(@"%@", $0);
        if ($1.section == 0) {
            [self.variable1 removeObjectAtIndex:$1.row];
        } else {
            [self.variable2 removeObjectAtIndex:$1.row];
        }
    });
    
    [self.view addSubview:_tableView];
    
    ////////////////////////////////////////
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(60, 60);
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 380, 320, 250) collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor brownColor];
    
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
    
     [self.view addSubview:_collectionView];
    
    
    ////////////////////////////////////////
    HWRxObserver *observer = _aaa.rx_tap.debounce(0.5).behavior().response(^{ Strongify(self)
        self.aaa.text = [NSString stringWithFormat:@"%@,click", self.aaa.text];
    });
    
    HWRxNoCenter.Rx(@"bbaNotification").disposeBy(self).subscribe(^(NSDictionary *userInfo) { Strongify(self)
        self.view.backgroundColor = [UIColor yellowColor];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [HWRxNoCenter postNotificationName:@"bbaNotification" object:nil userInfo:@{@"aa":@"aa"}];
        observer.connect();
    });
    
}


- (void)dealloc {
    NSLog(@"sviewcontroller dealloc");
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
