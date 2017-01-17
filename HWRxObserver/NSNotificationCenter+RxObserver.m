//
//  NSNotificationCenter+RxObserver.m
//  HWKitDemo
//
//  Created by 陈智颖 on 2016/11/14.
//  Copyright © 2016年 YY. All rights reserved.
//

#import "NSNotificationCenter+RxObserver.h"
#import "NSArray+FunctionalType.h"

@implementation NSNotificationCenter (RxObserver)

- (void (^)(NSString *))rx_repost {
    return ^(NSString *notifyName) {
        self.rx_observers.forEach(^(HWRxObserver *observer){
            if ([observer.keyPath isEqualToString:notifyName]) {
                [self postNotificationName:notifyName object:nil userInfo:[observer valueForKey:@"_latestData"]];
                return;
            }
        });
    };
}

- (void)removeRxObserver:(HWRxObserver *)observer {
    [self removeObserver:observer];
    [self.rx_observers removeObject:observer];
}

@end
