//
//  NSObject+RxObserver.h
//  yyfe
//
//  Created by 陈智颖 on 2016/10/21.
//  Copyright © 2016年 yy.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HWRxObserver.h"

@interface NSObject (RxObserver_Base)

@property (nonatomic, strong) NSMutableArray<HWRxObserver *> *rx_observers;

- (void)addRxObserver:(HWRxObserver *)observer;
- (void)removeRxObserver:(HWRxObserver *)observer;
- (void)removeAllRxObserver;
- (void)executeDisposalBy:(NSObject *)disposer;

@end

@interface NSObject (RxObserver)

@property (nonatomic, readonly) HWRxObserver *(^Rx)(NSString *keyPath);
@property (nonatomic, readonly) void(^rx_repost)(NSString *keyPath); //repost with lastest data, prepare for property without KVC

@end
