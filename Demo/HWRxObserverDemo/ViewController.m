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
#import "HWRxVariable.h"
#import <objc/runtime.h>

@protocol bbp <NSObject>
- (void)show;
@end

@interface Cbbp : NSObject <bbp>
@end

@implementation Cbbp
@end

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *testBtn;
@property (weak, nonatomic) IBOutlet UILabel *testLabel;
@property (weak, nonatomic) IBOutlet UIImageView *testImg;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    self.view.backgroundColor = [UIColor yellowColor];
//
//    NSMutableArray *b = [NSMutableArray arrayWithArray:@[@1, @2, @3]];
//    HWIntNumber *bResult = b.pop(HW_BLOCK(HWIntNumber *) {
//        return (BOOL)($0.intValue == 2);
//    });
    
    NotNilArray(@[@1,@2,@3]).map(HW_BLOCK(HWIntNumber *) {
        return @($0.intValue + 1);
    }).filter(HW_BLOCK(NSNumber *) {
        return (BOOL)($0.intValue / 2 == 1);
    }).forEach(HW_BLOCK(NSNumber *) {
        NSLog(@"filter %@", $0);
    });
    
    Cbbp *bb = [Cbbp new];
    [self addMehod:bb];
    if ([bb respondsToSelector:@selector(show)]) {
        [bb show];
    }

    
//
//    _testBtn.rx_tap.subscribe(^(UIButton *button) {
//        HWAnimInstance.scale(0.1, 2, 1, 1, 0.1).addTo(_testBtn.layer).run();
//    });
//
//    _testLabel.rx_dynamicTap.debounce(1).subscribe(HW_BLOCK(UILabel *) {
//        NSLog(@"label tap");
//        $0.text = @"aa";
//    });
//
//    _testImg.rx_dynamicTapToAlpha(0.2).response(^{
//        NSLog(@"img AnimTap");
//    });
    
    
    
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
    
//        [self after:1 result:YES flag:@"一"]
//        .next(^(id obj) {
//           return [self after:1 result:YES flag:@"二"];
//        })
//        .next(^(id obj) {
//            return [self after:1 result:NO flag:@"三"];
//        })
//        .next(^(id obj) {
//            return [self after:1 result:YES flag:@"四"];
//        })
//        .next(^(id obj) {
//            return [self after:1 result:YES flag:@"五"];
//        })
//        .next(^(id obj) {
//           return  [self after:1 result:YES flag:@"六"];
//        })
//        .next(^(id obj) {
//           return  [self after:1 result:YES flag:@"七"];
//        })
//        .always(^(HWPromiseResult *obj) {
//            NSLog(@"all finised %@", obj.object);
//        });
    
    
}

- (void)addMehod:(NSObject *)b {
    Method method = class_getInstanceMethod([self class], @selector(show));
    BOOL success = class_addMethod([b class],
                                   @selector(show),
                                   method_getImplementation(method),
                                   method_getTypeEncoding(method));
    if (!success) {
        NSLog(@"add method not success");
    } else {
        NSLog(@"add method success");
    }
}

- (void)show {
    NSLog(@"add method call");
}


- (HWPromise *)after:(NSUInteger)time result:(BOOL)result flag:(NSString *)flag {
    HWPromise *promise = [HWPromise new];
    
//    if ([flag isEqualToString:@"二"]) {
//        NSLog(@"%lu, %@, %@", (unsigned long)time, @(result), flag);
//         promise.successObj = [NSString stringWithFormat:@"成功,%@" ,flag];
//        return promise;
//    }
   
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
