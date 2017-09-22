//
//  HWRxObserver.h
//  HWKitDemo
//
//  Created by 陈智颖 on 2016/10/20.
//  Copyright © 2016年 YY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HWFunctionalType.h"

#define HWRxInstance [HWRxObserver new]

NS_ASSUME_NONNULL_BEGIN

@class HWRxObserver;

typedef void(^nextBlankType)();
typedef void(^nextType)(id obj);

@interface HWRxObserver : NSObject <HWFunctionalType>

@property (nonatomic, weak) NSObject *target;
@property (nonatomic, copy) NSString *disposer;
@property (nonatomic, copy) NSString *keyPath;
@property (nonatomic) SEL tapAction;

- (void)registeredToObserve:(NSObject *)object;

@end


@interface HWRxObserver (Create_Extension)

@property (nonatomic, readonly) HWRxObserver *(^create)(NSString *desc); // show in keyPath for description
@property (nonatomic, readonly) HWRxObserver *(^next)(id);
@property (nonatomic, readonly) HWRxObserver *(^of)(NSArray *);

@end


@interface HWRxObserver (Base_Extension)

@property (nonatomic, readonly) HWRxObserver *(^then)(thenType);
@property (nonatomic, readonly) HWRxObserver *(^observeOn)(dispatch_queue_t);
@property (nonatomic, readonly) HWRxObserver *(^subscribe)(nextType);
@property (nonatomic, readonly) HWRxObserver *(^response)(nextBlankType); //not response to startWith

@property (nonatomic, readonly) HWRxObserver *(^bindTo)(id object, NSString *keyPath);
@property (nonatomic, readonly) HWRxObserver *(^disposeBy)(NSObject *);

@property (nonatomic, readonly) HWRxObserver *(^debounce)(CGFloat value); // received, then wait value seconds.
@property (nonatomic, readonly) HWRxObserver *(^throttle)(CGFloat value); // after value seconds, then received.
@property (nonatomic, readonly) HWRxObserver *(^startWith)(NSArray *);

@property (nonatomic, readonly) HWRxObserver *(^behavior)(); // receive data until connect()
@property (nonatomic, readonly) HWRxObserver *(^connect)();
@property (nonatomic, readonly) HWRxObserver *(^disconnect)();

@property (nonatomic, readonly) HWRxObserver *(^takeUntil)(HWRxObserver *);
@property (nonatomic, readonly) HWRxObserver *(^switchLatest)(); // next: HWRxObserver, always subscribe the new one

@end


@interface HWRxObserver (Functional_Extension) //return NEW observer

@property (nonatomic, readonly) HWRxObserver *(^map)(mapType);
@property (nonatomic, readonly) HWRxObserver *(^filter)(filterType);
@property (nonatomic, readonly) HWRxObserver *(^reduce)(id, reduceType);
@property (nonatomic, readonly) HWRxObserver *(^distinctUntilChanged)();

@end


@interface HWRxObserver (Schedule_Extension)

@property (nonatomic, readonly) HWRxObserver *(^schedule)(NSUInteger interval, BOOL repeat);
@property (nonatomic, readonly) HWRxObserver *(^stop)();

@end


@interface NSArray (RxObserver_Extension) //return NEW observer

@property (nonatomic, readonly) HWRxObserver *merge;
@property (nonatomic, readonly) HWRxObserver *combineLatest;

@end


NS_ASSUME_NONNULL_END
