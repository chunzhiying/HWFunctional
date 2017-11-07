//
//  HWPromise+RxObserver.m
//  HWRxObserverDemo
//
//  Created by 陈智颖 on 2017/10/31.
//  Copyright © 2017年 YY. All rights reserved.
//

#import "HWPromise+RxObserver.h"
#import "NSObject+RxObserver.h"
#import "HWRxObserver.h"

@implementation HWPromise (RxObserver)

+ (HWPromise * _Nonnull (^)(HWRxObserver * _Nonnull))observe {
    return ^(HWRxObserver *observer) {
        HWPromise *promise = [HWPromise new];
        observer.subscribe(^(id obj) {
            promise.successObj = obj;
        });
        return promise;
    };
}

+ (HWPromise * _Nonnull (^)(HWRxObserver * _Nonnull, FilterBlock _Nonnull))observeOnce {
    return ^(HWRxObserver *observer, FilterBlock block) {
        HWPromise *promise = [HWPromise new];
        Weakify(observer)
        observer.subscribe(^(id obj) { Strongify(observer)
            if (!(block && block(obj))) {
                return;
            }
            promise.successObj = obj;
            if ([observer.target respondsToSelector:@selector(removeRxObserver:)]) {
                [observer.target removeRxObserver:observer];
            }
        });
        return promise;
    };
}

@end
