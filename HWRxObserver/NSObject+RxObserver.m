//
//  NSObject+RxObserver.m
//  yyfe
//
//  Created by 陈智颖 on 2016/10/21.
//  Copyright © 2016年 yy.com. All rights reserved.
//

#import "NSObject+RxObserver.h"
#import "NSArray+FunctionalType.h"
#import <objc/runtime.h>

@implementation NSObject (RxObserver_Base)

- (void)addRxObserver:(HWRxObserver *)observer {
    [observer registeredToObserve:self];
    [self.rx_observers addObject:observer];
}

- (void)removeRxObserver:(HWRxObserver *)observer {
    if (class_getProperty([self class], [observer.keyPath cStringUsingEncoding:NSASCIIStringEncoding])) {
        [self removeObserver:observer forKeyPath:observer.keyPath];
    }
    [self.rx_observers removeObject:observer];
}

- (void)removeAllRxObserver {
    self.rx_observers.map(^(HWRxObserver *observer) {
        return observer;
    }).forEach(^(HWRxObserver *observer) {
        [self removeRxObserver:observer];
    });
}

- (void)executeDisposalBy:(NSObject *)disposer {
    self.rx_observers.filter(^(HWRxObserver *observer) {
        return @([observer.disposer isEqualToString:[NSString stringWithFormat:@"%p", disposer]]);
    }).forEach(^(HWRxObserver *observer) {
        [self removeRxObserver:observer];
    });
}

#pragma mark - Observers
- (void)setRx_observers:(NSMutableArray<HWRxObserver *> *)observers {
    objc_setAssociatedObject(self, @selector(rx_observers), observers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray<HWRxObserver *> *)rx_observers {
    return objc_getAssociatedObject(self, @selector(rx_observers));
}

@end

@implementation NSObject (RxObserver)

- (HWRxObserver *(^)(NSString *))Rx {
    return ^(NSString *keyPath) {
        if (!self.rx_observers) {
            self.rx_observers = [NSMutableArray new];
        }
        return [HWRxObserver new].then(^(HWRxObserver *observer) {
            observer.target = self;
            observer.keyPath = keyPath;
            [self addRxObserver:observer];
        });
    };
}

- (void (^)(NSString *))rx_repost {
    return ^(NSString *keyPath) {
        [self willChangeValueForKey:keyPath];
        [self didChangeValueForKey:keyPath];
    };
}

@end
