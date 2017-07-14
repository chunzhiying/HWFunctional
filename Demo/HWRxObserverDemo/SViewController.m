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

@interface SViewController ()

@property (nonatomic, strong) UILabel *aaa;
@property (nonatomic, strong) HWRxObserver *customObser;

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
    
    
//    Weakify(self)
//    _aaa.Rx(@"text").response(^{ Strongify(self)
//        self.view.backgroundColor = [UIColor redColor];
//    });
//    
    
    _customObser = HWRxInstance.asObservable();
    
    _customObser.next(^{
        return @"aa";
    });
    
    _customObser.behavior().subscribe(HW_BLOCK(NSObject *) {
         NSLog(@"customObser: %@", $0);
    }).connect();
    
    
    
    _customObser.next(^{
        return @"bb";
    });
    
    _aaa.rx_dealloc.response(^{
        NSLog(@"_aaa dealloc");
    });
    
//    HWRxObserver *observer = _aaa.rx_tap.debounce(0.5).behavior().response(^{ Strongify(self)
//        self.aaa.text = [NSString stringWithFormat:@"%@,click", self.aaa.text];
//    });
//    
//    HWRxNoCenter.Rx(@"bbaNotification").disposeBy(self).subscribe(^(NSDictionary *userInfo) { Strongify(self)
//        self.view.backgroundColor = [UIColor yellowColor];
//    });
//    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [HWRxNoCenter postNotificationName:@"bbaNotification" object:nil userInfo:@{@"aa":@"aa"}];
//        observer.connect();
//    });

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
