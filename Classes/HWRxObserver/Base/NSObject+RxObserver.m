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

#define RxLockSet if (!objc_getAssociatedObject(self, @selector(rx_lock))) {[self setRx_lock:[NSRecursiveLock new]];}

@implementation NSObject (RxObserver_Base)

- (void)addRxObserver:(HWRxObserver *)observer {
    [observer registeredToObserve:self];
    [RxLock lock];
    [self.rx_observers addObject:observer];
    [RxLock unlock];
}

- (void)removeRxObserver:(HWRxObserver *)observer {
    [RxLock lock];
    if ([self.rx_observers containsObject:observer]) {
        if (class_getProperty([self class], [observer.keyPath cStringUsingEncoding:NSASCIIStringEncoding])) {
            [self removeObserver:observer forKeyPath:observer.keyPath];
        }
        [self.rx_observers removeObject:observer];
    }
    [RxLock unlock];
}

- (void)removeAllRxObserver {
    [RxLock lock];
    self.rx_observers.map(^(HWRxObserver *observer) {
        return observer;
    }).forEach(^(HWRxObserver *observer) {
        [self removeRxObserver:observer];
    });
    [RxLock unlock];
}

- (void)executeDisposalBy:(NSObject *)disposer {
    [RxLock lock];
    if (self.rx_observers.count == 0) {
        return;
    }
    self.rx_observers.filter(^(HWRxObserver *observer) {
        return @([observer.disposer isEqualToString:[NSString stringWithFormat:@"%p", disposer]]);
    }).forEach(^(HWRxObserver *observer) {
        [self removeRxObserver:observer];
    });
    [RxLock unlock];
}

#pragma mark - Lock
- (void)setRx_lock:(NSRecursiveLock *)lock {
    objc_setAssociatedObject(self, @selector(rx_lock), lock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSRecursiveLock *)rx_lock { RxLockSet
    return objc_getAssociatedObject(self, @selector(rx_lock));
}

#pragma mark - Observers
- (void)setRx_observers:(NSMutableArray<HWRxObserver *> *)observers {
    objc_setAssociatedObject(self, @selector(rx_observers), observers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray<HWRxObserver *> *)rx_observers {
    return objc_getAssociatedObject(self, @selector(rx_observers));
}

- (void)setRx_delegateTo_disposers:(NSMutableArray<NSObject *> *)rx_disposers {
    objc_setAssociatedObject(self, @selector(rx_delegateTo_disposers), rx_disposers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray<NSObject *> *)rx_delegateTo_disposers {
    return objc_getAssociatedObject(self, @selector(rx_delegateTo_disposers));
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

- (HWRxObserver * _Nonnull (^)(NSString * _Nonnull))RxOnce {
    return ^(NSString *keyPath) {
        if (!self.rx_observers || self.rx_observers.count == 0) {
            return self.Rx(keyPath);
        }
        HWRxObserver *existObserver = self.rx_observers
        .find(HW_BLOCK(HWRxObserver *) {
            return [$0.keyPath isEqualToString:keyPath];
        });
        if (!existObserver) {
            existObserver = self.Rx(keyPath);
        }
        return existObserver;
    };
}

- (void (^)(NSString *))rx_repost {
    return ^(NSString *keyPath) {
        [self willChangeValueForKey:keyPath];
        [self didChangeValueForKey:keyPath];
    };
}

- (HWRxObserver *)rx_dealloc {
    return self.Rx(@"RxObserver_dealloc");
}

@end

@implementation NSObject (RxObserver_dealloc)

+ (void)load {
    
    SEL originalSelector = NSSelectorFromString(@"dealloc");
    SEL swizzledSelector = @selector(RxObserver_dealloc);
    
    Method originalMethod = class_getInstanceMethod([self class], originalSelector);
    Method swizzledMethod = class_getInstanceMethod([self class], swizzledSelector);
    
    BOOL didAddMethod =
    class_addMethod([self class],
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod([self class],
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }

}

- (void)RxObserver_dealloc {
    
    if (self.rx_observers.count != 0) {
        self.rx_observers.forEach(^(HWRxObserver *observer) {
            if ([observer.keyPath isEqualToString:@"RxObserver_dealloc"]) {
                [observer setValue:@"RxObserver_dealloc" forKey:@"rxObj"];
            }
        });
        [self removeAllRxObserver];
    }
    
    if (self.rx_delegateTo_disposers.count != 0) {
        self.rx_delegateTo_disposers.forEach(HW_BLOCK(NSObject *) {
            [$0 executeDisposalBy:self];
        });
        [self.rx_delegateTo_disposers removeAllObjects];
    }
    
    [self RxObserver_dealloc];
}

@end

