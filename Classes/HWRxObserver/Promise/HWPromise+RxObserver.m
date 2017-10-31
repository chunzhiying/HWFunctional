//
//  HWPromise+RxObserver.m
//  HWRxObserverDemo
//
//  Created by 陈智颖 on 2017/10/31.
//  Copyright © 2017年 YY. All rights reserved.
//

#import "HWPromise+RxObserver.h"
#import "HWRxObserver.h"

@implementation HWPromise (RxObserver)

- (HWPromise * _Nonnull (^)(HWRxObserver * _Nonnull))observe {
    return ^(HWRxObserver *observer) {
        observer.subscribe(^(id obj) {
            if (!obj || [obj isKindOfClass:[NSNull class]]) {
                self.failObj = @(NO);
            } else {
                self.successObj = obj;
            }
        });
        return self;
    };
}

@end
