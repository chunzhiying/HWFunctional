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

+ (HWPromise * _Nonnull (^)(HWRxObserver * _Nonnull))observe {
    return ^(HWRxObserver *observer) {
        HWPromise *promise = [HWPromise new];
        observer.subscribe(^(id obj) {
            if (!obj || [obj isKindOfClass:[NSNull class]]) {
                promise.failObj = @(NO);
            } else {
                promise.successObj = obj;
            }
        });
        return promise;
    };
}

@end
