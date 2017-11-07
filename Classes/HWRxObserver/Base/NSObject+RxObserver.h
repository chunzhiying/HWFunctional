//
//  NSObject+RxObserver.h
//  yyfe
//
//  Created by 陈智颖 on 2016/10/21.
//  Copyright © 2016年 yy.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HWRxObserver.h"

#define RxLock [self rx_lock]

NS_ASSUME_NONNULL_BEGIN

typedef id _Nullable (^WeakReference)(void);

@interface NSObject (RxObserver_Base)

@property (nonatomic, strong, readonly) NSRecursiveLock *rx_lock;
@property (nonatomic, strong) NSMutableArray<HWRxObserver *> *rx_observers;
@property (nonatomic, strong) NSMutableArray<WeakReference> *rx_delegateTo_disposers; //when self dealloc, [obj executeDisposalBy:self]

- (void)addRxObserver:(HWRxObserver *)observer;
- (void)removeRxObserver:(HWRxObserver *)observer;
- (void)removeAllRxObserver;
- (void)executeDisposalBy:(NSObject *)disposer;

@end

@interface NSObject (RxObserver)

@property (nonatomic, readonly) HWRxObserver *(^Rx)(NSString *keyPath);
@property (nonatomic, readonly) HWRxObserver *(^RxOnce)(NSString *keyPath);

@property (nonatomic, readonly) HWRxObserver *rx_dealloc;
@property (nonatomic, readonly) void(^rx_repost)(NSString *keyPath); //repost with lastest data

@end

NS_ASSUME_NONNULL_END
