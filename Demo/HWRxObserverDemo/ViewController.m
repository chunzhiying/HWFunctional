//
//  ViewController.m
//  HWRxObserverDemo
//
//  Created by 陈智颖 on 2016/11/16.
//  Copyright © 2016年 YY. All rights reserved.
//

#import "ViewController.h"
#import "HWPromise.h"
#import "NSArray+FunctionalType.h"
#import "HWAnimation+Combination.h"
#import "UIView+RxObserver.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *testBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor yellowColor];
    
    @[@1, @2, @3].filter(HW_BLOCK(NSNumber *) {
        return @($0.intValue / 2 == 1);
    }).forEach(HW_BLOCK(NSNumber *) {
        NSLog(@"filter %@", $0);
    });
    
    _testBtn.rx_tap.response(^{
        HWAnimInstance.scale(0.1, 2, 1, 1, 0.1).addTo(_testBtn.layer).run();
    });
    
//        @[[self after:1 result:YES flag:@"一"],
//          [self after:3 result:YES flag:@"二"],
//          [self after:1 result:YES flag:@"三"],
//          [self after:2 result:YES flag:@"四"],
//          [self after:1 result:NO flag:@"五"],
//          [self after:9 result:YES flag:@"六"],
//          [self after:1 result:YES flag:@"七"],
//          [self after:1 result:NO flag:@"八"],
//          [self after:1 result:YES flag:@"九"]].promise.complete(^(NSArray *results) {
//              NSLog(@"全部完成:%@", results);
//          });
    
        [self after:1 result:YES flag:@"一"]
        .next(^(id obj) {
           return [self after:1 result:YES flag:@"二"];
        })
        .next(^(id obj) {
            return [self after:1 result:NO flag:@"三"];
        })
        .next(^(id obj) {
            return [self after:1 result:YES flag:@"四"];
        })
        .next(^(id obj) {
            return [self after:1 result:YES flag:@"五"];
        })
        .next(^(id obj) {
           return  [self after:1 result:YES flag:@"六"];
        })
        .next(^(id obj) {
           return  [self after:1 result:YES flag:@"七"];
        })
        .always(^(HWPromiseResult *obj) {
            NSLog(@"all finised %@", obj.object);
        });
    
    
}


- (HWPromise *)after:(NSUInteger)time result:(BOOL)result flag:(NSString *)flag {
    HWPromise *promise = [HWPromise new];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"%lu, %@, %@", (unsigned long)time, @(result), flag);
        if (result) {
            promise.successObj = [NSString stringWithFormat:@"成功,%@" ,flag];
        } else {
            promise.failObj = [NSString stringWithFormat:@"失败,%@",flag];
        }
    });
    
    return promise;
}

@end